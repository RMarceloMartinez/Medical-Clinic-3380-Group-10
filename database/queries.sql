-- queries.sql: the 3 data queries for the Medical Clinic app
USE MedicalClinic;
GO

-- Query 1: a doctor's appointments for a given week
CREATE OR ALTER PROCEDURE usp_DoctorWeekAppointments
    @DoctorID INT,
    @WeekStart DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT a.Date_Time, m.FirstName + ' ' + m.LastName AS PatientName, o.StreetAddress AS Office, a.AppointStatus
    FROM Appointment AS a
    JOIN Member AS m
    ON m.MemberID = a.PatientID
    JOIN Office AS o ON o.OfficeID = a.OfficeID
    WHERE a.DoctorID = @DoctorID
    AND a.Date_Time >= @WeekStart
    AND a.Date_Time < DATEADD(DAY,7,@WeekStart)
    AND a.DeletionFlag = 0
    AND m.DeletionFlag = 0
    AND o.DeletionFlag = 0
    ORDER BY a.Date_Time;

END;
GO
-- Test call (the backend runs this with the user's input)
EXEC usp_DoctorWeekAppointments @DoctorID = 1000001, @WeekStart = '2026-10-05';  -- James Wilson: Oct 6, Michael Brown, Completed
GO
CREATE OR ALTER PROCEDURE usp_PatientBalance
    @PatientID INT

AS BEGIN
    SET NOCOUNT ON;

    DECLARE @Billed NUMERIC(10,2), @Paid NUMERIC(10,2);

    --Billed completed visits only
    SELECT @Billed = ISNULL(SUM (a.TotalCost), 0)
    FROM Appointment AS a
    WHERE a.PatientID = @PatientID
    AND a.AppointStatus = 'Completed'
    AND a.DeletionFlag = 0;

-- Paid: payment lines on those visits, refunds excluded
SELECT @Paid = ISNULL(SUM(pd.AmountApplied), 0)
FROM PaymentDetail  AS pd
JOIN Payment AS p ON p.PaymentID = pd.PaymentID
JOIN Appointment AS a ON a.AppointmentID = p.AppointmentID
WHERE a.PatientID = @PatientID
AND a.AppointStatus = 'Completed'
AND p.PayStatus = 'Completed'
AND a.DeletionFlag = 0
AND p.DeletionFlag = 0;

SELECT @Billed AS Billed, @Paid AS Paid, @Billed - @Paid AS Balance;
END;
GO

EXEC usp_PatientBalance @PatientID = 1000002;   -- Emily Garcia: 600.00 / 600.00 / 0.00
EXEC usp_PatientBalance @PatientID = 1000004;   -- Olivia Davis: 375.00 / 375.00 / 0.00

GO

-- Query 2: patient's balance

WITH VisitBalance AS (
        SELECT a.AppointmentID,
               CAST(a.Date_Time AS DATE) AS VisitDate,
               a.TotalCost,
               ISNULL(SUM(pd.AmountApplied), 0) AS Paid
        FROM Appointment AS a
        LEFT JOIN Payment AS p
            ON p.AppointmentID = a.AppointmentID
            AND p.PayStatus = 'Completed'
            AND p.DeletionFlag = 0
        LEFT JOIN PaymentDetail AS pd
            ON pd.PaymentID = p.PaymentID
            AND pd.DeletionFlag = 0
        WHERE a.PatientID = @PatientID
        AND a.AppointStatus = 'Completed'
        AND a.DeletionFlag = 0
        GROUP BY a.AppointmentID, CAST(a.Date_Time AS DATE), a.TotalCost
    )
    SELECT m.MemberID AS PatientID,
           m.FirstName + ' ' + m.LastName AS PatientName,
           m.Phone,
           COUNT(CASE WHEN vb.TotalCost > vb.Paid THEN 1 END) AS UnpaidVisits,
           MIN(CASE WHEN vb.TotalCost > vb.Paid THEN vb.VisitDate END) AS OldestUnpaidVisit,
           ISNULL(SUM(vb.TotalCost), 0) AS Billed,
           ISNULL(SUM(vb.Paid), 0) AS Paid,
           -- Overpaid visits count as 0 so they don't offset what is owed on other visits
           ISNULL(SUM(CASE WHEN vb.TotalCost > vb.Paid
                           THEN vb.TotalCost - vb.Paid
                           ELSE 0 END), 0) AS Balance
    FROM Member AS m
    JOIN Patient AS pt ON pt.PatientID = m.MemberID
    LEFT JOIN VisitBalance AS vb ON 1 = 1   -- VisitBalance already holds only this patient's visits
    WHERE m.MemberID = @PatientID
    AND m.DeletionFlag = 0
    AND pt.DeletionFlag = 0
    GROUP BY m.MemberID, m.FirstName, m.LastName, m.Phone;

END;
GO

EXEC usp_PatientOutstandingBalance_FromReport @PatientID = 1000000;
GO

-- Query 3: search patients by name and/or date of birth
CREATE OR ALTER PROCEDURE usp_SearchPatients
    @Name VARCHAR(50),
    @DateOfBirth DATE

AS BEGIN
    SET NOCOUNT ON;

    SELECT p.PatientID, m.FirstName + ' ' + m.LastName AS PatientName,
    m.DateOfBirth AS DateOfBirth,
    m.Phone AS Phone
    FROM Patient AS p
    JOIN Member AS m ON m.MemberID = p.PatientID
    WHERE (@Name IS NULL OR m.FirstName + ' ' + m.LastName LIKE '%' + @Name + '%' )
    AND (@DateOfBirth IS NULL OR m.DateOfBirth = @DateOfBirth)
    AND p.DeletionFlag = 0
    AND m.DeletionFlag = 0
    ORDER BY m.LastName, m.FirstName

END;
GO

EXEC usp_SearchPatients @Name = 'gar', @DateOfBirth = NULL;           -- Emily Garcia
EXEC usp_SearchPatients @Name = NULL,  @DateOfBirth = '1990-07-08';   -- Michael Brown
EXEC usp_SearchPatients @Name = 'zzz', @DateOfBirth = NULL;           -- no rows