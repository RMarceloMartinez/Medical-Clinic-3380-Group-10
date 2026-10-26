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
}
