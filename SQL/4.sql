use [SAT242516028]
go

create or alter procedure [dbo].[Sp_Patients_Chart]
as
begin

    with cte_data as
             (
                 select p.Id as PatientId
                      -- Ad ve Soyadı birleştirip tabloya basıyoruz
                      , (p.FirstName + ' ' + p.LastName) as PatientName
                      
                      -- SENARYO: Tahlillerin hangi aya denk geldiğini buluyoruz.
                      -- Normalde projemizde 'ResultDate' var, yani MONTH(r.ResultDate) kullanabilirdik.
                      -- Ancak senin şablonuna sadık kalarak, verilerin aylara dağılması için 
                      -- ID modülasyonu (Demo amaçlı) kullanıyorum:
                      , case 
                            when r.Id is null then 0 
                            else (r.Id % 12) + 1 
                        end as MonthNum
                      , r.Id as ResultId
                 from Patient p
                      -- Hastadan Sonuçlara (LabResult) geçiş
                      left join LabResult r on p.Id = r.PatientId
             )
    select PatientId, PatientName
           -- 1'den 12'ye kadar olan aylar (Ocak - Aralık)
         , isnull([1], 0) as Ocak
         , isnull([2], 0) as Subat
         , isnull([3], 0) as Mart
         , isnull([4], 0) as Nisan
         , isnull([5], 0) as Mayis
         , isnull([6], 0) as Haziran
         , isnull([7], 0) as Temmuz
         , isnull([8], 0) as Agustos
         , isnull([9], 0) as Eylul
         , isnull([10], 0) as Ekim
         , isnull([11], 0) as Kasim
         , isnull([12], 0) as Aralik
    from cte_data
             pivot
             (
             -- Hangi ayda (MonthNum) bu hasta kaç tahlil (ResultId) yaptırmış sayıyoruz
             count(ResultId) for MonthNum in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
             ) p
    order by PatientId

end
go