USE MedicalClinic;
GO

-- R3: report table for "Visits in this report". Safe to run twice.
IF OBJECT_ID('dbo.VisitDetailsReport', 'U') IS NULL
BEGIN
    CREATE TABLE VisitDetailsReport(
        AppointmentID INT NOT NULL,
        VisitDateTime DATETIME2(0) NOT NULL,
        PatientID INT NOT NULL,
        PatientFirstName VARCHAR(15) NOT NULL,
        PatientLastName VARCHAR(31) NOT NULL,
        DoctorFirstName VARCHAR(15) NOT NULL,
        DoctorLastName VARCHAR(31) NOT NULL,
        Specialty VARCHAR(30) NOT NULL,
        OfficeStreetAddress VARCHAR(80) NOT NULL,
        AppointStatus VARCHAR(9) NOT NULL,
        CancelledBy VARCHAR(7) NULL,
        TotalCost NUMERIC(10,2) NOT NULL,
        AmountPaid NUMERIC(12,2) NOT NULL,
        CancellationFee NUMERIC(10,2) NULL,
        Diagnoses VARCHAR(2000) NULL,
        DeletionFlag BIT NOT NULL,

        CONSTRAINT PK_VisitDetailsReport PRIMARY KEY(AppointmentID),
        CONSTRAINT CK_VisitDetailsReport_DeletionFlag CHECK (DeletionFlag IN (0, 1))
    );
END;
GO
