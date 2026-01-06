use [SAT242516028]
go

-----------------------------------------------------------------------------------
-- 2. TABLO: LABTEST (Test Tanımları)
-----------------------------------------------------------------------------------

create table [dbo].[LabTest]
(
    [Id]           [int] identity (1,1) not null,
    [TestCode]     [nvarchar](20)       null, -- Test Kodu (örn: GLU, HEM)
    [TestName]     [nvarchar](100)      null, -- Test Adı (örn: Glikoz, Hemogram)
    [Unit]         [nvarchar](20)       null, -- Birim (örn: mg/dL, %)
    [ReferenceMin] [decimal](10, 2)     null, -- Referans Alt Sınır
    [ReferenceMax] [decimal](10, 2)     null, -- Referans Üst Sınır
    constraint [PK_LabTest] primary key clustered
        (
         [Id] asc
            ) with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on, optimize_for_sequential_key = off) on [PRIMARY]
) on [PRIMARY]
go

-- View Index için SCHEMABINDING kullanımı
create view [dbo].[Vw_LabTest]
with schemabinding
as
    select lt.Id
         , lt.TestCode
         , lt.TestName
         , lt.Unit
         , lt.ReferenceMin
         , lt.ReferenceMax
    from dbo.LabTest as lt
go

-- View üzerinde Clustered Index
create unique clustered index [IX_Vw_LabTest_Id] on [dbo].[Vw_LabTest]
    (
     [Id] asc
    )
go

-- Arama performansı için NonClustered Index
create nonclustered index [IX_LabTest_Search] on [dbo].[LabTest]
    (
     [TestName] asc,
     [TestCode] asc,
     [Id] asc
        )
go

create procedure [dbo].[sp_LabTest_Add_Update_Remove] @operation varchar(10), @jsonvalues nvarchar(max)
as
begin

    select *
    into #temp
    from openjson(@jsonvalues)
                  with
                      (
                      Id int,
                      TestCode nvarchar(20),
                      TestName nvarchar(100),
                      Unit nvarchar(20),
                      ReferenceMin decimal(10, 2),
                      ReferenceMax decimal(10, 2)
                      )

    declare @rowcount int = null

    if @operation = 'add'
        begin
            insert LabTest (TestCode, TestName, Unit, ReferenceMin, ReferenceMax)
            select TestCode, TestName, Unit, ReferenceMin, ReferenceMax
            from #temp

            set @rowcount = @@rowcount
        end

    if @operation = 'update'
        begin
            update lt
            set lt.TestCode = t.TestCode,
                lt.TestName = t.TestName,
                lt.Unit = t.Unit,
                lt.ReferenceMin = t.ReferenceMin,
                lt.ReferenceMax = t.ReferenceMax
            from #temp t join LabTest lt on t.Id = lt.Id

            set @rowcount = @@rowcount
        end

    if @operation = 'remove'
        begin
            delete lt
            from #temp t join LabTest lt on t.Id = lt.Id

            set @rowcount = @@rowcount
        end

    select @operation [Key], iif(isnull(@rowcount, 0) > 0, 1, 0) [Value]

end
go

create procedure [dbo].[Sp_LabTests] @pagination Type_Dictionary_String_String readonly,
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

    -- İsim veya Kod ile arama
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
                          from Vw_LabTest
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
                                      -- Test Adı veya Kodu içinde arama yapar
                                      select 1 from @table_names t 
                                      where s.TestName like concat('%', t.value, '%') 
                                         or s.TestCode like concat('%', t.value, '%')
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
                                  -- Name parametresi ile TestName sıralanır
                                  case when @orderby = 'Name asc' then TestName end asc,
                                  case when @orderby = 'Name desc' then TestName end desc,
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

create trigger [dbo].[Trg_LabTest_Insert_Update_Delete]
    on [dbo].[LabTest]
    after insert, update, delete
    as
begin

    set nocount on;

    declare @tableName nvarchar(100) = 'LabTest'
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
alter table [dbo].[LabTest] enable trigger [Trg_LabTest_Insert_Update_Delete]
go