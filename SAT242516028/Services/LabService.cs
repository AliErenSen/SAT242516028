namespace Services;

using Entities;
using MyDbModels;
using Providers;

public class LabService(IMyDbModel_Provider provider) : ILabService
{
    #region Test Definitions
    public async ValueTask<IMyDbModel<TestDefinitions>> GetTestList(IMyDbModel<TestDefinitions> model)
    {
        return await provider.Execute(model, "sp_TestDefinitions_List", isPagination: true);
    }

    public async ValueTask<IEnumerable<TestDefinitions>> SaveTest(TestDefinitions test)
    {
        return await provider.SetItems<TestDefinitions>("sp_TestDefinitions_Upsert",
            ("Id", test.Id),
            ("Code", test.Code),
            ("Name", test.Name),
            ("Price", test.Price),
            ("Unit", test.Unit)
        );
    }

    public async ValueTask<IEnumerable<TestDefinitions>> DeleteTest(int id)
    {
        return await provider.SetItems<TestDefinitions>("sp_TestDefinitions_Delete", ("Id", id));
    }
    #endregion

    #region Lab Requests
    public async ValueTask<IMyDbModel<LabRequests>> GetRequestList(IMyDbModel<LabRequests> model)
    {
        return await provider.Execute(model, "sp_LabRequests_List", isPagination: true);
    }

    public async ValueTask<IEnumerable<LabRequests>> CreateRequest(LabRequests request)
    {
        return await provider.SetItems<LabRequests>("sp_LabRequests_Insert",
            ("PatientId", request.PatientId),
            ("DoctorName", request.DoctorName)
        );
    }
    #endregion

    // --- YENİ EKLENEN KISIM: DASHBOARD İSTATİSTİKLERİ ---
    public async Task<DashboardStats> GetDashboardStats()
    {
        // Provider'daki GetItems metodunu kullanarak tek satırlık veriyi çekiyoruz
        var list = await provider.GetItems<DashboardStats>("sp_GetDashboardStats");

        // İlk kaydı döndür, eğer veri yoksa boş bir nesne döndür
        return list.FirstOrDefault() ?? new DashboardStats();
    }
}