namespace Services;

using Entities;
using MyDbModels;

public interface IPatientService
{
    ValueTask<IMyDbModel<Patients>> GetList(IMyDbModel<Patients> model);
    ValueTask<IEnumerable<Patients>> Save(Patients patient);
    ValueTask<IEnumerable<Patients>> Delete(int id);
    ValueTask<Patients> GetById(int id);
}