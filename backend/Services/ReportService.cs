using System.Data;
using ClinicApi.Data;
using ClinicApi.Models;
using Microsoft.Data.SqlClient;

namespace ClinicApi.Services;

public class ReportService
{
    private readonly SqlConnectionFactory _connectionFactory;

     public ReportService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }
    public async Task<List<OfficeRevenueRow>> GetOfficeRevenueAsync(DateTime from, DateTime to, 
                                                CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
                              EXEC dbo.usp_RefreshOfficeRevenueReport
                              @FromDate = @FromDate, @ToDate = @ToDate;
                              SELECT OfficeID, OfficeStreetAddress, CompletedVisits,
                              Billed, Collected, Refunded, Outstanding, CashCollected,
                              CreditCardCollected, DebitCardCollected,
                              InsuranceCollected, CheckCollected
                              FROM dbo.OfficeRevenueReport
                              WHERE DeletionFlag = 0
                              ORDER BY OfficeStreetAddress;
                              """;

        command.Parameters.Add("@FromDate", SqlDbType.Date).Value = from;
        command.Parameters.Add("@ToDate", SqlDbType.Date).Value = to;

        var items = new List<OfficeRevenueRow>();
        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            items.Add(new OfficeRevenueRow
            {
                OfficeID = reader.GetInt32(reader.GetOrdinal("OfficeID")),
                OfficeStreetAddress = reader.GetString(reader.GetOrdinal("OfficeStreetAddress")),
                CompletedVisits = reader.GetInt32(reader.GetOrdinal("CompletedVisits")),
                Billed = reader.GetDecimal(reader.GetOrdinal("Billed")),
                Collected = reader.GetDecimal(reader.GetOrdinal("Collected")),
                Refunded = reader.GetDecimal(reader.GetOrdinal("Refunded")),
                Outstanding = reader.GetDecimal(reader.GetOrdinal("Outstanding")),
                CashCollected = reader.GetDecimal(reader.GetOrdinal("CashCollected")),
                CreditCardCollected = reader.GetDecimal(reader.GetOrdinal("CreditCardCollected")),
                DebitCardCollected = reader.GetDecimal(reader.GetOrdinal("DebitCardCollected")),
                InsuranceCollected = reader.GetDecimal(reader.GetOrdinal("InsuranceCollected")),
                CheckCollected = reader.GetDecimal(reader.GetOrdinal("CheckCollected"))
                
            });
        }

        return items;
    }
    public async Task<List<AppointmentActivityRow>> GetAppointmentActivityAsync(DateTime from, DateTime to, 
                                                CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();

        command.CommandText = """
                              EXEC dbo.usp_RefreshAppointmentActivityReport
                              @FromDate = @FromDate, @ToDate = @ToDate;
                              SELECT DoctorID, DoctorFirstName, DoctorLastName,
                              OfficeID, OfficeStreetAddress, TotalAppointments,
                              Scheduled, Completed, Cancelled, CancelledByPatient,
                              CancelledByDoctor, CancelledByStaff, CancellationRate
                              FROM dbo.AppointmentActivityReport
                              WHERE DeletionFlag = 0
                              ORDER BY DoctorLastName;
                              """;

        command.Parameters.Add("@FromDate", SqlDbType.Date).Value = from;
        command.Parameters.Add("@ToDate", SqlDbType.Date).Value = to;

        var items = new List<AppointmentActivityRow>();
        using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            items.Add(new AppointmentActivityRow
            {
                DoctorID = reader.GetInt32(reader.GetOrdinal("DoctorID")),
                DoctorFirstName = reader.GetString(reader.GetOrdinal("DoctorFirstName")),
                DoctorLastName = reader.GetString(reader.GetOrdinal("DoctorLastName")),
                OfficeID = reader.GetInt32(reader.GetOrdinal("OfficeID")),
                OfficeStreetAddress = reader.GetString(reader.GetOrdinal("OfficeStreetAddress")),
                TotalAppointments = reader.GetInt32(reader.GetOrdinal("TotalAppointments")),
                Scheduled = reader.GetInt32(reader.GetOrdinal("Scheduled")),
                Completed = reader.GetInt32(reader.GetOrdinal("Completed")),
                Cancelled = reader.GetInt32(reader.GetOrdinal("Cancelled")),
                CancelledByPatient = reader.GetInt32(reader.GetOrdinal("CancelledByPatient")),
                CancelledByDoctor = reader.GetInt32(reader.GetOrdinal("CancelledByDoctor")),
                CancelledByStaff = reader.GetInt32(reader.GetOrdinal("CancelledByStaff")),
                CancellationRate = reader.GetDecimal(reader.GetOrdinal("CancellationRate"))
                
            });
        }

        return items;
    }
}
