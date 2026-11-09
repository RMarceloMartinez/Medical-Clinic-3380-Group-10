USE MedicalClinic;
GO

-- N2: nursing notes, saved on the visit's medical record (max 500 characters)
IF COL_LENGTH('dbo.MedicalRecord', 'NursingNotes') IS NULL
    ALTER TABLE dbo.MedicalRecord ADD NursingNotes VARCHAR(500) NULL;
GO

-- N4: check-in status on the appointment.
-- NULL means "not checked in yet" (no DEFAULT constraints).
IF COL_LENGTH('dbo.Appointment', 'CheckInStatus') IS NULL
    ALTER TABLE dbo.Appointment ADD CheckInStatus VARCHAR(16) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Appointment_CheckInStatus')
    ALTER TABLE dbo.Appointment ADD CONSTRAINT CK_Appointment_CheckInStatus
        CHECK (CheckInStatus IN ('Checked in', 'Waiting', 'Ready for doctor'));
GO
