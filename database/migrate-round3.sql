USE MedicalClinic;
GO

-- Round 3 (Nov 9): columns and table for the new feedback items. Safe to run twice.
--   Prescription.Pharmacy        where the doctor sends a prescription
--   MedicalRecord.NursingNotes   the nurse's symptoms, complaints and observations
--   Appointment.VisitReason      why the patient booked
--   Appointment.CheckInStatus    the nurse's patient status for the day
--   ChartRequest                 a patient asking their doctor for their chart
-- No DEFAULT constraints (project rule): every new column allows NULL.

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Prescription') AND name = 'Pharmacy')
    ALTER TABLE dbo.Prescription ADD Pharmacy VARCHAR(60) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MedicalRecord') AND name = 'NursingNotes')
    ALTER TABLE dbo.MedicalRecord ADD NursingNotes VARCHAR(500) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Appointment') AND name = 'VisitReason')
    ALTER TABLE dbo.Appointment ADD VisitReason VARCHAR(200) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Appointment') AND name = 'CheckInStatus')
    ALTER TABLE dbo.Appointment ADD CheckInStatus VARCHAR(16) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Appointment_CheckInStatus')
    ALTER TABLE dbo.Appointment ADD CONSTRAINT CK_Appointment_CheckInStatus
        CHECK (CheckInStatus IN ('Checked in', 'Waiting', 'Ready for doctor'));
GO

IF OBJECT_ID('dbo.ChartRequest', 'U') IS NULL
BEGIN
    CREATE TABLE ChartRequest(
        RequestID INT IDENTITY(1000000,1) NOT NULL,
        PatientID INT NOT NULL,
        DoctorID INT NOT NULL,
        RequestDate DATE NOT NULL,
        RequestStatus VARCHAR(9) NOT NULL,
        DeletionFlag BIT NOT NULL,

        CONSTRAINT PK_ChartRequest PRIMARY KEY(RequestID),
        CONSTRAINT CK_ChartRequest_RequestID CHECK(RequestID BETWEEN 1000000 AND 9999999),
        CONSTRAINT FK_ChartRequest_Patient FOREIGN KEY(PatientID) REFERENCES Patient(PatientID) ON DELETE NO ACTION,
        CONSTRAINT FK_ChartRequest_Doctor FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE NO ACTION,
        CONSTRAINT CK_ChartRequest_Status CHECK (RequestStatus IN ('Pending', 'Sent')),
        CONSTRAINT CK_ChartRequest_DeletionFlag CHECK (DeletionFlag IN (0, 1))
    );
END;
GO

-- Demo data: the test patient (renamed Alex Rivera for the demo) is allergic to penicillin,
-- so the doctor's prescription warning can be shown on a patient we own.
INSERT INTO dbo.Allergy (PatientID, Allergen, ReactionType, Severity, DateIdentified, DeletionFlag)
SELECT p.PatientID, 'Penicillin', 'Hives', 'Severe', '2019-06-01', 0
FROM dbo.Patient AS p
JOIN dbo.Member AS m ON m.MemberID = p.PatientID
WHERE m.Email = 'test.demopatient@example.com'
  AND NOT EXISTS (SELECT 1 FROM dbo.Allergy AS al
                  WHERE al.PatientID = p.PatientID AND al.Allergen = 'Penicillin' AND al.DeletionFlag = 0);
GO
