namespace Services;

using Entities;
using MyDbModels;

public interface ILabService
{
    // Test Tanımları
    ValueTask<IMyDbModel<TestDefinitions>> GetTestList(IMyDbModel<TestDefinitions> model);
    ValueTask<IEnumerable<TestDefinitions>> SaveTest(TestDefinitions test);

    // Laboratuvar Talepleri
    ValueTask<IMyDbModel<LabRequests>> GetRequestList(IMyDbModel<LabRequests> model);
    ValueTask<IEnumerable<LabRequests>> CreateRequest(LabRequests request);
    // Mevcut satırların altına ekle:
    ValueTask<IEnumerable<TestDefinitions>> DeleteTest(int id);
    Task<DashboardStats> GetDashboardStats();
}