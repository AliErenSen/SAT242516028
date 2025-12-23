namespace Services;

using Entities;
using MyDbModels;
using Providers;

public class PatientService(IMyDbModel_Provider provider) : IPatientService
{
    public async ValueTask<IMyDbModel<Patients>> GetList(IMyDbModel<Patients> model)
    {
        // SQL tarafında oluşturduğumuz 'sp_Patients_List' prosedürünü çağırır
        return await provider.Execute(model, "sp_Patients_List", isPagination: true);
    }

    public async ValueTask<IEnumerable<Patients>> Save(Patients patient)
    {
        // TestDefinitions'da nasıl yaptıysak aynısı:
        return await provider.SetItems<Patients>("sp_Patients_Upsert",
            ("Id", patient.Id),
            ("TCNumber", patient.TCNumber),
            ("FirstName", patient.FirstName),
            ("LastName", patient.LastName),
            ("Phone", patient.Phone)
            
        );
    }

    public async ValueTask<IEnumerable<Patients>> Delete(int id)
    {
        // Silme (SQL'de sp_Patients_Delete oluşturulmalı)
        return await provider.SetItems<Patients>("sp_Patients_Delete", ("Id", id));
    }

    public async ValueTask<Patients> GetById(int id)
    {
        var result = await provider.GetItems<Patients>("sp_Patients_GetById", ("Id", id));
        return result.FirstOrDefault() ?? new Patients();
    }
}