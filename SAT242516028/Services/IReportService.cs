namespace Services;

using Entities;

public interface IReportService
{
    byte[] GeneratePatientReport(IEnumerable<Patients> patients);
    // İkinci tablo raporu (Yönerge gereği 2 tablo lazım)
    byte[] GenerateTestDefReport(IEnumerable<TestDefinitions> tests);
}