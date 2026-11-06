USE MedicalClinic;
GO

-- Nurse 1: visits at the nurse's own office.
CREATE OR ALTER PROCEDURE usp_NurseOfficeAppointments
    @NurseID INT,
    @FromDate DATE,
    @Days INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT a.AppointmentID,
           a.PatientID,
           a.Date_Time,
           pm.FirstName + ' ' + pm.LastName AS PatientName,
           dm.FirstName + ' ' + dm.LastName AS DoctorName,
           CASE WHEN mr.RecordID IS NULL THEN 0 ELSE 1 END AS VitalsRecorded
    FROM Nurse AS n
    JOIN Appointment AS a ON a.OfficeID = n.OfficeID
    JOIN Member AS pm ON pm.MemberID = a.PatientID
    JOIN Member AS dm ON dm.MemberID = a.DoctorID
    LEFT JOIN MedicalRecord AS mr
        ON mr.AppointmentID = a.AppointmentID
        AND mr.DeletionFlag = 0
    WHERE n.NurseID = @NurseID
    AND n.DeletionFlag = 0
    AND a.AppointStatus = 'Scheduled'
    AND a.DeletionFlag = 0
    AND a.Date_Time >= @FromDate
    AND a.Date_Time < DATEADD(DAY, @Days, @FromDate)
    ORDER BY a.Date_Time;
END;
GO

-- Nurse 2: record vitals for the doctor before seeing patient (this should create the MedicalRecord row).
CREATE OR ALTER PROCEDURE usp_NurseRecordVitals
    @NurseID INT,
    @AppointmentID INT,
    @SystolicBP SMALLINT,
    @DiastolicBP SMALLINT,
    @HeartRate SMALLINT,
    @Temperature NUMERIC(4,1),
    @WeightPounds NUMERIC(5,1),
    @HeightInches NUMERIC(4,1)
AS
BEGIN
    SET NOCOUNT ON;

    -- The appointment must be a scheduled one at this nurse's office
    IF NOT EXISTS (
        SELECT 1
        FROM Nurse AS n
        JOIN Appointment AS a ON a.OfficeID = n.OfficeID
        WHERE n.NurseID = @NurseID
        AND n.DeletionFlag = 0
        AND a.AppointmentID = @AppointmentID
        AND a.AppointStatus = 'Scheduled'
        AND a.DeletionFlag = 0
    )
        THROW 50001, 'Appointment not found at your office, or it is not scheduled.', 1;

    -- MedicalRecord allows one row per appointment (UQ_MedicalRecord_AppointmentID)
    IF EXISTS (SELECT 1 FROM MedicalRecord WHERE AppointmentID = @AppointmentID)
        THROW 50002, 'Vitals have already been recorded for this appointment.', 1;

    INSERT INTO MedicalRecord
        (AppointmentID, SystolicBP, DiastolicBP, HeartRate, Temperature, WeightPounds, HeightInches, DeletionFlag)
    VALUES
        (@AppointmentID, @SystolicBP, @DiastolicBP, @HeartRate, @Temperature, @WeightPounds, @HeightInches, 0);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS RecordID;
END;
GO

-- Nurse 3: a patient's chart, as three result sets: allergies, conditions, past visits.
-- Only patients who have an appointment at the nurse's office can be opened. otherwise whomp whomp
CREATE OR ALTER PROCEDURE usp_NursePatientChart
    @NurseID INT,
    @PatientID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM Nurse AS n
        JOIN Appointment AS a ON a.OfficeID = n.OfficeID
        WHERE n.NurseID = @NurseID
        AND n.DeletionFlag = 0
        AND a.PatientID = @PatientID
        AND a.DeletionFlag = 0
    )
        THROW 50003, 'This patient has no appointments at your office.', 1;

    -- Result set 1: allergies
    SELECT AllergyID, Allergen, ReactionType, Severity, DateIdentified
    FROM Allergy
    WHERE PatientID = @PatientID
    AND DeletionFlag = 0
    ORDER BY Allergen;

    -- Result set 2: conditions
    SELECT ConditionID, ConditionName, ConditionType, Severity, IsHereditary, DateDiagnosed
    FROM PatientCondition
    WHERE PatientID = @PatientID
    AND DeletionFlag = 0
    ORDER BY ConditionName;

    -- Result set 3: past (completed) visits, newest first, with the vitals taken at each
    SELECT a.AppointmentID,
           a.Date_Time,
           dm.FirstName + ' ' + dm.LastName AS DoctorName,
           o.StreetAddress AS Office,
           mr.SystolicBP,
           mr.DiastolicBP,
           mr.HeartRate,
           mr.WeightPounds
    FROM Appointment AS a
    JOIN Member AS dm ON dm.MemberID = a.DoctorID
    JOIN Office AS o ON o.OfficeID = a.OfficeID
    LEFT JOIN MedicalRecord AS mr
        ON mr.AppointmentID = a.AppointmentID
        AND mr.DeletionFlag = 0
    WHERE a.PatientID = @PatientID
    AND a.AppointStatus = 'Completed'
    AND a.DeletionFlag = 0
    ORDER BY a.Date_Time DESC;
END;
GO

-- Testing calls
EXEC usp_NurseOfficeAppointments @NurseID = 1000000, @FromDate = '2026-11-04', @Days = 7;
EXEC usp_NurseRecordVitals @NurseID = 1000000, @AppointmentID = 1000000,
     @SystolicBP = 120, @DiastolicBP = 80, @HeartRate = 72,
     @Temperature = 98.6, @WeightPounds = 165.0, @HeightInches = 68.0;
EXEC usp_NursePatientChart @NurseID = 1000000, @PatientID = 1000000;
GO
