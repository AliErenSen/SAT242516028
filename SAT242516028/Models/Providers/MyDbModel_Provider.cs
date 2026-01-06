using Microsoft.EntityFrameworkCore;
using MyDbModels;
using SAT242516028.Models.DbContexts;
using SAT242516028.Entities;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using UnitOfWorks;

namespace Providers;

public interface IMyDbModel_Provider
{
    // EF Core tabanlý iþlemler
    Task<IEnumerable<Patient>> GetAllCampaignsAsync();
    Task AddCampaignAsync(Patient patient);
    Task DeleteCampaignAsync(int id);
    Task<Patient?> CampaignGetByIdAsync(int id);

    // Generic UnitOfWork tabanlý iþlemler
    ValueTask<IMyDbModel<TResult>> Execute<TResult>(
        IMyDbModel<TResult> myResultModel,
        string spName = "",
        bool isPagination = true)
        where TResult : class, new();

    ValueTask<IMyDbModel<TResult>> Execute<TResult>(
        string spName = "",
        params (string Key, object Value)[] parameters)
        where TResult : class, new();

    ValueTask<IEnumerable<TResult>> GetItems<TResult>(
        string spName = "",
        params (string Key, object Value)[] parameters)
        where TResult : class, new();

    ValueTask<IEnumerable<TResult>> SetItems<TResult>(
        string spName = "",
        params (string Key, object Value)[] parameters)
        where TResult : class, new();
}

public class MyDbModel_Provider : IMyDbModel_Provider
{
    private readonly IMyDbModel_UnitOfWork _myDbModel_UnitOfWork;
    private readonly MyDbModel_DbContext _context;

    public MyDbModel_Provider(IMyDbModel_UnitOfWork myDbModel_UnitOfWork, MyDbModel_DbContext context)
    {
        _myDbModel_UnitOfWork = myDbModel_UnitOfWork;
        _context = context;
    }

    #region EF Core Tabanlý Ýþlemler

    public async Task<IEnumerable<Patient>> GetAllCampaignsAsync()
    {
        return await _context.Patients
            .OrderByDescending(c => c.Id)
            .ToListAsync();
    }

    public async Task AddCampaignAsync(Patient patients)
    {
        _context.Patients.Add(patients);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteCampaignAsync(int id)
    {
        var campaign = await _context.Patients.FindAsync(id);
        if (campaign != null)
        {
            _context.Patients.Remove(campaign);
            await _context.SaveChangesAsync();
        }
    }

    public async Task<Patient?> CampaignGetByIdAsync(int id)
    {
        return await _context.Patients
            .FirstOrDefaultAsync(c => c.Id == id);
    }

    #endregion

    #region Execute : Pagination=true

    public async ValueTask<IMyDbModel<TResult>> Execute<TResult>(
        IMyDbModel<TResult> myResultModel,
        string spName = "",
        bool isPagination = true)
        where TResult : class, new()
    {
        myResultModel ??= new MyDbModel<TResult>();
        await _myDbModel_UnitOfWork.Execute(myResultModel, spName, isPagination);
        return myResultModel;
    }

    #endregion

    #region Execute : Pagination=false

    public async ValueTask<IMyDbModel<TResult>> Execute<TResult>(
        string spName = "",
        params (string Key, object Value)[] parameters)
        where TResult : class, new()
    {
        var myResultModel = new MyDbModel<TResult>();
        if (parameters != null)
            foreach (var item in parameters)
                myResultModel.Parameters.Params.Add(item.Key, item.Value);

        await _myDbModel_UnitOfWork.Execute(myResultModel, spName, false);
        return myResultModel;
    }

    #endregion

    #region GetItems / SetItems

    public async ValueTask<IEnumerable<TResult>> GetItems<TResult>(
        string spName = "",
        params (string Key, object Value)[] parameters)
        where TResult : class, new() =>
        (await Execute<TResult>(spName, parameters)).Items;

    public async ValueTask<IEnumerable<TResult>> SetItems<TResult>(
        string spName = "",
        params (string Key, object Value)[] parameters)
        where TResult : class, new() =>
        (await Execute<TResult>(spName, parameters)).Items;

    #endregion
}
