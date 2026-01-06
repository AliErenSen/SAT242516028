use [SAT242516028]
go

-----------------------------------------------------------------------------------
-- 3. TABLO: LABRESULT (Sonuçlar)
-----------------------------------------------------------------------------------

create table [dbo].[LabResult]
(
    [Id]          [int] identity (1,1) not null,
    [PatientId]   [int]                not null, -- Hangi Hasta?
    [LabTestId]   [int]                not null, -- Hangi Test?
    [ResultValue] [decimal](10, 2)     null,     -- Sonuç Değeri
    [ResultDate]  [datetime]           default getdate(), -- Sonuç Tarihi
    constraint [PK_LabResult] primary key clustered
        (
         [Id] asc
            ) with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on, optimize_for_sequential_key = off) on [PRIMARY],
    -- İlişkiler (Foreign Keys)
    constraint [FK_LabResult_Patient] foreign key ([PatientId]) references [dbo].[Patient] ([Id]),
    constraint [FK_LabResult_LabTest] foreign key ([LabTestId]) references [dbo].[LabTest] ([Id])
) on [PRIMARY]
go

-- View Index için SCHEMABINDING kullanımı
create view [dbo].[Vw_LabResult]
with schemabinding
as
    select r.Id
         , r.PatientId
         , r.LabTestId
         , r.ResultValue
         , r.ResultDate
    from dbo.LabResult as r
go

-- View üzerinde Clustered Index
create unique clustered index [IX_Vw_LabResult_Id] on [dbo].[Vw_LabResult]
    (
     [Id] asc
    )
go

-- Performans için NonClustered Index (Hasta ve Test ID'ye göre sık sorgulanır)
create nonclustered index [IX_LabResult_Search] on [dbo].[LabResult]
    (
     [PatientId] asc,
     [LabTestId] asc,
     [ResultDate] asc,
     [Id] asc
        )
go

create procedure [dbo].[sp_LabResult_Add_Update_Remove] @operation varchar(10), @jsonvalues nvarchar(max)
as
begin

    select *
    into #temp
    from openjson(@jsonvalues)
                  with
                      (
                      Id int,
                      PatientId int,
                      LabTestId int,
                      ResultValue decimal(10, 2),
                      ResultDate datetime
                      )

    declare @rowcount int = null

    if @operation = 'add'
        begin
            insert LabResult (PatientId, LabTestId, ResultValue, ResultDate)
            select PatientId, LabTestId, ResultValue, isnull(ResultDate, getdate())
            from #temp

            set @rowcount = @@rowcount
        end

    if @operation = 'update'
        begin
            update r
            set r.PatientId = t.PatientId,
                r.LabTestId = t.LabTestId,
                r.ResultValue = t.ResultValue,
                r.ResultDate = t.ResultDate
            from #temp t join LabResult r on t.Id = r.Id

            set @rowcount = @@rowcount
        end

    if @operation = 'remove'
        begin
            delete r
            from #temp t join LabResult r on t.Id = r.Id

            set @rowcount = @@rowcount
        end

    select @operation [Key], iif(isnull(@rowcount, 0) > 0, 1, 0) [Value]

end
go

create procedure [dbo].[Sp_LabResults] @pagination Type_Dictionary_String_String readonly,
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

    -- Arama (Name parametresi üzerinden gelen değerle sayısal sonucu string gibi arıyoruz)
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
                          from Vw_LabResult
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
                                      -- Sonuç Değeri içinde arama yapar (Stringe çevirerek)
                                      select 1 from @table_names t 
                                      where cast(s.ResultValue as nvarchar(50)) like concat('%', t.value, '%')
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
                                  case when @orderby = 'Date asc' then ResultDate end asc,
                                  case when @orderby = 'Date desc' then ResultDate end desc,
                                  case when @orderby = 'Value asc' then ResultValue end asc,
                                  case when @orderby = 'Value desc' then ResultValue end desc,
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

create trigger [dbo].[Trg_LabResult_Insert_Update_Delete]
    on [dbo].[LabResult]
    after insert, update, delete
    as
begin

    set nocount on;

    declare @tableName nvarchar(100) = 'LabResult'
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
alter table [dbo].[LabResult] enable trigger [Trg_LabResult_Insert_Update_Delete]
go