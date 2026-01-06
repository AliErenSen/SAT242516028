using Microsoft.EntityFrameworkCore;
using SAT242516028.Entities;

namespace SAT242516028.Models.DbContexts;

public class MyDbModel_DbContext : DbContext
{
    public MyDbModel_DbContext(DbContextOptions<MyDbModel_DbContext> options)
        : base(options)
    {
    }

    public DbSet<Patient> Patients { get; set; }
    public DbSet<LabTest> LabTests { get; set; }
    public DbSet<LabResult> labResults { get; set; }

}
