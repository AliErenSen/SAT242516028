use [SAT242516028]
go

-----------------------------------------------------------------------------------
-- 1. TABLO: PATIENT (Hasta Bilgileri)
-----------------------------------------------------------------------------------

create table [dbo].[Patient]
(
    [Id]          [int] identity (1,1) not null,
    [TCNo]        [nvarchar](11)       null, -- TC Kimlik No
    [FirstName]   [nvarchar](50)       null, -- Ad
    [LastName]    [nvarchar](50)       null, -- Soyad
    [Phone]       [nvarchar](20)       null, -- Telefon
    [BirthDate]   [date]               null, -- Doğum Tarihi
    [Gender]      [nvarchar](10)       null, -- Cinsiyet
    constraint [PK_Patient] primary key clustered
        (
         [Id] asc
            ) with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on, optimize_for_sequential_key = off) on [PRIMARY]
) on [PRIMARY]
go

-- View Index için SCHEMABINDING kullanımı
create view [dbo].[Vw_Patient]
with schemabinding
as
    select p.Id
         , p.TCNo
         , p.FirstName
         , p.LastName
         , p.Phone
         , p.BirthDate
         , p.Gender
    from dbo.Patient as p
go

-- View üzerinde Clustered Index
create unique clustered index [IX_Vw_Patient_Id] on [dbo].[Vw_Patient]
    (
     [Id] asc
    )
go

-- Arama performansı için NonClustered Index (TC, Ad, Soyad)
create nonclustered index [IX_Patient_Search] on [dbo].[Patient]
    (
     [TCNo] asc,
     [FirstName] asc,
     [LastName] asc,
     [Id] asc
        )
go

create procedure [dbo].[sp_Patient_Add_Update_Remove] @operation varchar(10), @jsonvalues nvarchar(max)
as
begin

    select *
    into #temp
    from openjson(@jsonvalues)
                  with
                      (
                      Id int,
                      TCNo nvarchar(11),
                      FirstName nvarchar(50),
                      LastName nvarchar(50),
                      Phone nvarchar(20),
                      BirthDate date,
                      Gender nvarchar(10)
                      )

    declare @rowcount int = null

    if @operation = 'add'
        begin
            insert Patient (TCNo, FirstName, LastName, Phone, BirthDate, Gender)
            select TCNo, FirstName, LastName, Phone, BirthDate, Gender
            from #temp

            set @rowcount = @@rowcount
        end

    if @operation = 'update'
        begin
            update p
            set p.TCNo = t.TCNo,
                p.FirstName = t.FirstName,
                p.LastName = t.LastName,
                p.Phone = t.Phone,
                p.BirthDate = t.BirthDate,
                p.Gender = t.Gender
            from #temp t join Patient p on t.Id = p.Id

            set @rowcount = @@rowcount
        end

    if @operation = 'remove'
        begin
            delete p
            from #temp t join Patient p on t.Id = p.Id

            set @rowcount = @@rowcount
        end

    select @operation [Key], iif(isnull(@rowcount, 0) > 0, 1, 0) [Value]

end
go

create procedure [dbo].[Sp_Patients] @pagination Type_Dictionary_String_String readonly,
                                     @where Type_Dictionary_String_String readonly
as
begin
    --sıralama
    declare @orderby nvarchar(max) = isnull((
                                                select [Value]
                                                from @pagination
                                                where [Key] = 'OrderBy'
                                            ), 'Id asc')
    --sayfalama
    declare @pagenumber int = isnull((
                                     select [Value]
                                     from @pagination
                                     where [Key] = 'PageNumber'
                                     ), 1)
    declare @pagesize int = isnull((
                                   select [Value]
                                   from @pagination
                                   where [Key] = 'PageSize'
                                   ), 10)

    --- filtreleme
    declare @table_ids table (id int)
    insert @table_ids(id)
    select ss.value
    from @where w
             cross apply string_split(w.[Value], ',') ss
    where w.[Key] = 'Id' and isnull(ss.value, '') <> ''

    -- İsim veya TC ile arama için 'Name' keyini kullanıyoruz (şablona uygunluk için)
    declare @table_names table (value nvarchar(100))
    insert @table_names(value)
    select ss.value
    from @where w
             cross apply string_split(w.[Value], ',') ss
    where w.[Key] = 'Name' and isnull(ss.value, '') <> '' 

    -----------
    ;
    with cte_data as (
                          select *
                          from Vw_Patient
                      )
       , cte_filter as (
                          select s.*
                          from cte_data s
                          where (not exists
                                  (
                                      select 1
                                      from @table_ids
                                  ) or exists
                                  (
                                      select 1
                                      from @table_ids t
                                      where s.Id = t.id
                                  ))
                            and (not exists
                                  (
                                      select 1
                                      from @table_names
                                  ) or exists
                                  (
                                      -- Ad, Soyad veya TC içinde arama yapar
                                      select 1 from @table_names t 
                                      where s.FirstName like concat('%', t.value, '%') 
                                         or s.LastName like concat('%', t.value, '%')
                                         or s.TCNo like concat('%', t.value, '%')
                                  )
                             )
                       )
       , cte_total_count as (
                          select count(*) TotalRecordCount
                               , ceiling(cast(count(*) as float) / @pagesize) TotalPageCount
                          from cte_filter
                       )
       , cte_ordered as (
                          select *
                               , row_number() over
                              (order by
                                  case when @orderby = 'Id asc' then Id end asc,
                                  case when @orderby = 'Id desc' then Id end desc,
                                  -- Şablondaki 'Name' sıralamasını FirstName'e bağladım
                                  case when @orderby = 'Name asc' then FirstName end asc,
                                  case when @orderby = 'Name desc' then FirstName end desc,
                                  Id asc
                              ) RowNumber
                          from cte_filter
                       )

       , cte_pagination as (
                          select TotalRecordCount
                               , TotalPageCount
                               , iif(@pagenumber > TotalPageCount, TotalPageCount, @pagenumber) PageNumber
                          from cte_total_count
                       )
    select *
    from cte_ordered, cte_pagination
    where RowNumber between (@pagesize * (PageNumber - 1)) + 1 and @pagesize * PageNumber
    order by RowNumber


end
go

create trigger [dbo].[Trg_Patient_Insert_Update_Delete]
    on [dbo].[Patient]
    after insert, update, delete
    as
begin

    set nocount on;

    declare @tableName nvarchar(100) = 'Patient'
    declare @rowid int =
        (
            select coalesce(i.Id, d.Id, 0)
            from inserted i
                     full join deleted d on i.Id = d.Id
        )

    declare @actiontype varchar(10) =
        (
            select case
                       when i.Id is not null and d.Id is null then 'insert'
                       when i.Id is not null and d.Id is not null then 'update'
                       when i.Id is null and d.Id is not null then 'delete'
                       end
            from inserted i
                     full join deleted d on i.Id = d.Id
        )

    declare @oldvalues nvarchar(max) = (
                                            select *
                                            from deleted
                                            for json path
                                       )
    declare @newvalues nvarchar(max) = (
                                            select *
                                            from inserted
                                            for json path
                                       )

    insert into Logs_Table (TableName, RowId, ActionType, OldValue, NewValue)
    values (@tableName, @rowid, @actiontype, @oldvalues, @newvalues)
end
go
alter table [dbo].[Patient] enable trigger [Trg_Patient_Insert_Update_Delete]
go