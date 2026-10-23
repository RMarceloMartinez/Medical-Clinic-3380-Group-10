
-- reports.sql: report views and refresh procedures
USE MedicalClinic;
GO

-- R2 base: one row per appointment
CREATE OR ALTER VIEW vw_AppointmentActivity
AS
SELECT a.AppointmentID,
       a.DoctorID,
       m.FirstName     AS DoctorFirstName,
       m.LastName      AS DoctorLastName,
       a.OfficeID,
       o.StreetAddress AS OfficeStreetAddress,
       a.Date_Time,
       a.AppointStatus,
       a.CancelledBy
FROM Appointment AS a
JOIN Member AS m ON m.MemberID = a.DoctorID
JOIN Office AS o ON o.OfficeID = a.OfficeID
WHERE a.DeletionFlag = 0
  AND m.DeletionFlag = 0
  AND o.DeletionFlag = 0;
GO

CREATE OR ALTER PROCEDURE usp_RefreshAppointmentActivityReport
    @FromDate DATE,
    @ToDate DATE
AS BEGIN
    SET NOCOUNT ON;

    DELETE FROM AppointmentActivityReport;

    INSERT INTO AppointmentActivityReport
                (DoctorID, DoctorFirstName, DoctorLastName, OfficeID, OfficeStreetAddress,
                FromDate, ToDate, TotalAppointments, Scheduled, Completed, Cancelled,
                CancelledByPatient, CancelledByDoctor, CancelledByStaff,
                CancellationRate, DeletionFlag)
    
    Select DoctorID, DoctorFirstName, DoctorLastName, OfficeID, OfficeStreetAddress,
           @FromDate, @ToDate,
           COUNT(*),
           SUM(CASE WHEN AppointStatus = 'Scheduled' THEN 1 ELSE 0 END),
           SUM(CASE WHEN AppointStatus = 'Completed'      THEN 1 ELSE 0 END),
           SUM(CASE WHEN AppointStatus = 'Cancelled'      THEN 1 ELSE 0 END),
           SUM(CASE WHEN CancelledBy = 'Patient' THEN 1 ELSE 0 END),
           SUM(CASE WHEN CancelledBy = 'Doctor'    THEN 1 ELSE 0 END),
           SUM(CASE WHEN CancelledBy = 'Staff'    THEN 1 ELSE 0 END),
           CAST(100.0 * SUM(CASE WHEN AppointStatus = 'Cancelled' THEN 1 ELSE 0 END)
                / COUNT(*) AS NUMERIC(5,2)),
            0
    
    FROM vw_AppointmentActivity
    WHERE Date_Time >= @FromDate
      AND Date_Time <  DATEADD(DAY, 1, @ToDate)
    GROUP BY DoctorID, DoctorFirstName, DoctorLastName, OfficeID, OfficeStreetAddress;
END;
GO

-- Test: refresh, then read the table like the page will
EXEC usp_RefreshAppointmentActivityReport @FromDate = '2026-07-01', @ToDate = '2026-10-31';
SELECT DoctorFirstName, DoctorLastName, OfficeStreetAddress,
       TotalAppointments, Scheduled, Completed, Cancelled, CancellationRate
FROM AppointmentActivityReport
ORDER BY DoctorLastName;
GO

CREATE OR ALTER VIEW vw_OfficeBilling
AS
SELECT a.OfficeID, o.StreetAddress AS OfficeStreetAddress, a.Date_Time, a.TotalCost
FROM Appointment AS a
JOIN Office AS o ON o.OfficeID = a.OfficeID
WHERE a.AppointStatus = 'Completed'
AND a.DeletionFlag = 0
AND o.DeletionFlag = 0;

GO

CREATE OR ALTER VIEW vw_OfficePayments
AS
SELECT a.OfficeID, a.Date_Time, p.PayStatus, pm.MethodName, pd.AmountApplied 
FROM PaymentDetail AS pd
JOIN Payment AS p ON p.PaymentID = pd.PaymentID
JOIN Appointment AS a ON a.AppointmentID = p.AppointmentID
JOIN PaymentMethod AS pm ON pm.MethodID = pd.MethodID
WHERE pd.DeletionFlag = 0
AND p.DeletionFlag = 0
AND a.DeletionFlag = 0;

GO

CREATE OR ALTER PROCEDURE usp_RefreshOfficeRevenueReport
  @FromDate DATE,
  @ToDate DATE
AS BEGIN
    SET NOCOUNT ON;
    DELETE FROM OfficeRevenueReport;

    WITH Billing AS (
        SELECT OfficeID, OfficeStreetAddress,
        Count(*) AS CompletedVisits,
        SUM(TotalCost) AS Billed
        FROM vw_OfficeBilling
        WHERE Date_Time >= @FromDate AND Date_Time < DATEADD(DAY, 1, @ToDate)
        GROUP BY OfficeID, OfficeStreetAddress
    ),
    Paid AS(
      SELECT OfficeID,
               SUM(CASE WHEN PayStatus = 'Completed' THEN AmountApplied ELSE 0 END) AS Collected,
               SUM(CASE WHEN PayStatus = 'Refunded'      THEN AmountApplied ELSE 0 END) AS Refunded,
               SUM(CASE WHEN PayStatus = 'Completed' AND MethodName = 'Cash'        THEN AmountApplied ELSE 0 END) AS CashCollected,
               SUM(CASE WHEN PayStatus = 'Completed' AND MethodName = 'Credit Card'        THEN AmountApplied ELSE 0 END) AS CreditCardCollected,
               SUM(CASE WHEN PayStatus = 'Completed' AND MethodName = 'Debit Card'        THEN AmountApplied ELSE 0 END) AS DebitCardCollected,
               SUM(CASE WHEN PayStatus = 'Completed' AND MethodName = 'Insurance'        THEN AmountApplied ELSE 0 END) AS InsuranceCollected,
               SUM(CASE WHEN PayStatus = 'Completed' AND MethodName = 'Check'        THEN AmountApplied ELSE 0 END) AS CheckCollected
        FROM vw_OfficePayments
        WHERE Date_Time >= @FromDate AND Date_Time < DATEADD(DAY, 1, @ToDate)
        GROUP BY OfficeID
    )
    INSERT INTO OfficeRevenueReport
                (OfficeID, OfficeStreetAddress, FromDate, ToDate, CompletedVisits,
                Billed, Collected, Refunded, Outstanding,
                CashCollected, CreditCardCollected, DebitCardCollected,
                InsuranceCollected, CheckCollected, DeletionFlag
                )
    SELECT b.OfficeID, b.OfficeStreetAddress, @FromDate, @ToDate, b.CompletedVisits, 
          b.Billed,
          ISNULL(p.Collected,0),
          ISNULL(p.Refunded,0),
          b.Billed - ISNULL(p.Collected, 0),
          ISNULL(p.CashCollected, 0),
          ISNULL(p.CreditCardCollected, 0),
          ISNULL(p.DebitCardCollected, 0),
          ISNULL(p.InsuranceCollected, 0),
          ISNULL(p.CheckCollected, 0),
          0
    FROM Billing AS b
    LEFT JOIN Paid AS p ON p.OfficeID = b.OfficeID;
END;
GO

EXEC usp_RefreshOfficeRevenueReport @FromDate = '2026-07-01', @ToDate = '2026-10-31';
SELECT OfficeStreetAddress, CompletedVisits, Billed, Collected, Refunded, Outstanding,
       CashCollected, CreditCardCollected
FROM OfficeRevenueReport
ORDER BY OfficeID;

