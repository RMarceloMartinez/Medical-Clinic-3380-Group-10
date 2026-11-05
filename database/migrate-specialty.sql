-- migrate-specialty.sql: adds the Specialty table to an existing database.
-- Safe to run more than once. Run this on Azure, never reset.sql.

-- 1. Create the table only if it doesn't exist yet
IF OBJECT_ID('dbo.Specialty', 'U') IS NULL
BEGIN
    CREATE TABLE Specialty(
        SpecialtyName VARCHAR(30) NOT NULL,
        VisitFee NUMERIC(10,2) NOT NULL,
        IsPrimaryCare BIT NOT NULL,
        DeletionFlag BIT NOT NULL,

        CONSTRAINT PK_Specialty PRIMARY KEY(SpecialtyName),
        CONSTRAINT CK_Specialty_VisitFee CHECK (VisitFee > 0),
        CONSTRAINT CK_Specialty_IsPrimaryCare CHECK (IsPrimaryCare IN (0, 1)),
        CONSTRAINT CK_Specialty_DeletionFlag CHECK (DeletionFlag IN (0, 1))
    );
END;
GO

-- 2. Insert only the rows that are missing
INSERT INTO Specialty (SpecialtyName, VisitFee, IsPrimaryCare, DeletionFlag)
SELECT v.SpecialtyName, v.VisitFee, v.IsPrimaryCare, v.DeletionFlag
FROM (VALUES
    ('Family Medicine', 150.00, 1, 0),
    ('Internal Medicine', 150.00, 1, 0),
    ('Pediatrics', 150.00, 1, 0),
    ('Dermatology', 200.00, 0, 0),
    ('Orthopedics', 275.00, 0, 0),
    ('Cardiology', 300.00, 0, 0)
) AS v (SpecialtyName, VisitFee, IsPrimaryCare, DeletionFlag)
WHERE NOT EXISTS (SELECT 1 FROM Specialty s WHERE s.SpecialtyName = v.SpecialtyName);
GO

-- 3. Show any doctor whose specialty has no matching row (should return nothing)
SELECT d.DoctorID, d.Specialty AS UnknownSpecialty
FROM Doctor d
LEFT JOIN Specialty s ON s.SpecialtyName = d.Specialty
WHERE s.SpecialtyName IS NULL;
GO

-- 4. Add the FK only if it isn't there yet
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Doctor_Specialty')
BEGIN
    ALTER TABLE Doctor ADD CONSTRAINT FK_Doctor_Specialty
        FOREIGN KEY (Specialty) REFERENCES Specialty(SpecialtyName) ON DELETE NO ACTION;
END;
GO