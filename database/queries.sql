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