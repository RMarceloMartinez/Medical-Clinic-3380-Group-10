USE MedicalClinicDB;
GO

-- 1. SAMPLE OFFICES

IF NOT EXISTS (
    SELECT 1 FROM dbo.Office
    WHERE StreetAddress = '1234 Main Street'
      AND SuiteNum = '100'
      AND City = 'Houston'
)
BEGIN
    INSERT INTO dbo.Office
        (StreetAddress, SuiteNum, City, State,
         ZipCode, Country, Phone, OpeningTime, ClosingTime)
    VALUES
        ('1234 Main Street', '100', 'Houston', 'Texas',
         '77002', 'USA', '7135550100', '08:00', '17:00');
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Office
    WHERE StreetAddress = '5678 Westheimer Road'
      AND SuiteNum = '200'
      AND City = 'Houston'
)
BEGIN
    INSERT INTO dbo.Office
        (StreetAddress, SuiteNum, City, State,
         ZipCode, Country, Phone, OpeningTime, ClosingTime)
    VALUES
        ('5678 Westheimer Road', '200', 'Houston', 'Texas',
         '77056', 'USA', '7135550200', '09:00', '18:00');
END;

-- 2. SAMPLE MEMBERS

-- Sarah Patel (Doctor)
IF NOT EXISTS (
    SELECT 1 FROM dbo.Member
    WHERE SSN = '900-10-0001'
)
BEGIN
    INSERT INTO dbo.Member
        (SSN, FirstName, MiddleName, LastName,
         StreetAddress, ApartmentNum, City, State,
         ZipCode, Country, Phone, Sex, DateOfBirth, Email)
    VALUES
        ('900-10-0001', 'Sarah', NULL, 'Patel',
         '100 Oak Street', NULL, 'Houston', 'Texas',
         '77002', 'USA', '7135551001', 'F',
         '1980-05-12', 'sarah.patel@example.com');
END;

-- James Wilson (Doctor)
IF NOT EXISTS (
    SELECT 1 FROM dbo.Member
    WHERE SSN = '900-10-0002'
)
BEGIN
    INSERT INTO dbo.Member
        (SSN, FirstName, MiddleName, LastName,
         StreetAddress, ApartmentNum, City, State,
         ZipCode, Country, Phone, Sex, DateOfBirth, Email)
    VALUES
        ('900-10-0002', 'James', NULL, 'Wilson',
         '200 Pine Street', NULL, 'Houston', 'Texas',
         '77056', 'USA', '7135551002', 'M',
         '1975-09-21', 'james.wilson@example.com');
END;

-- Emily Garcia (Patient)
IF NOT EXISTS (
    SELECT 1 FROM dbo.Member
    WHERE SSN = '900-10-0003'
)
BEGIN
    INSERT INTO dbo.Member
        (SSN, FirstName, MiddleName, LastName,
         StreetAddress, ApartmentNum, City, State,
         ZipCode, Country, Phone, Sex, DateOfBirth, Email)
    VALUES
        ('900-10-0003', 'Emily', NULL, 'Garcia',
         '300 Elm Street', '12', 'Houston', 'Texas',
         '77003', 'USA', '7135551003', 'F',
         '1998-03-15', 'emily.garcia@example.com');
END;

-- Michael Brown (Patient)
IF NOT EXISTS (
    SELECT 1 FROM dbo.Member
    WHERE SSN = '900-10-0004'
)
BEGIN
    INSERT INTO dbo.Member
        (SSN, FirstName, MiddleName, LastName,
         StreetAddress, ApartmentNum, City, State,
         ZipCode, Country, Phone, Sex, DateOfBirth, Email)
    VALUES
        ('900-10-0004', 'Michael', NULL, 'Brown',
         '400 Maple Street', NULL, 'Houston', 'Texas',
         '77004', 'USA', '7135551004', 'M',
         '1990-07-08', 'michael.brown@example.com');
END;

-- Olivia Davis (Patient)
IF NOT EXISTS (
    SELECT 1 FROM dbo.Member
    WHERE SSN = '900-10-0005'
)
BEGIN
    INSERT INTO dbo.Member
        (SSN, FirstName, MiddleName, LastName,
         StreetAddress, ApartmentNum, City, State,
         ZipCode, Country, Phone, Sex, DateOfBirth, Email)
    VALUES
        ('900-10-0005', 'Olivia', NULL, 'Davis',
         '500 Cedar Street', '4B', 'Houston', 'Texas',
         '77005', 'USA', '7135551005', 'F',
         '2001-11-25', 'olivia.davis@example.com');
END;

-- 3. SAMPLE EMPLOYEES

-- EmployeeID references MemberID.
-- EmployeeID is an IDENTITY column, so
-- IDENTITY_INSERT is required for explicit IDs.

DECLARE @SarahID INT;
DECLARE @JamesID INT;

SELECT @SarahID = MemberID
FROM dbo.Member
WHERE SSN = '900-10-0001';

SELECT @JamesID = MemberID
FROM dbo.Member
WHERE SSN = '900-10-0002';

IF NOT EXISTS (
    SELECT 1 FROM dbo.Employee
    WHERE EmployeeID = @SarahID
)
BEGIN
    INSERT INTO dbo.Employee
        (EmployeeID, HiringDate)
    VALUES
        (@SarahID, '2022-06-01');
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Employee
    WHERE EmployeeID = @JamesID
)
BEGIN
    INSERT INTO dbo.Employee
        (EmployeeID, HiringDate)
    VALUES
        (@JamesID, '2021-03-15');
END;


-- 4. SAMPLE DOCTORS

IF NOT EXISTS (
    SELECT 1 FROM dbo.Doctor
    WHERE DoctorID = @SarahID
)
BEGIN
    INSERT INTO dbo.Doctor
        (DoctorID, LicenseNum, Specialty)
    VALUES
        (@SarahID, 'TX-MD-10001', 'Family Medicine');
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Doctor
    WHERE DoctorID = @JamesID
)
BEGIN
    INSERT INTO dbo.Doctor
        (DoctorID, LicenseNum, Specialty)
    VALUES
        (@JamesID, 'TX-MD-10002', 'Cardiology');
END;

-- 5. SAMPLE PATIENTS

DECLARE @EmilyID INT;
DECLARE @MichaelID INT;
DECLARE @OliviaID INT;

SELECT @EmilyID = MemberID
FROM dbo.Member
WHERE SSN = '900-10-0003';

SELECT @MichaelID = MemberID
FROM dbo.Member
WHERE SSN = '900-10-0004';

SELECT @OliviaID = MemberID
FROM dbo.Member
WHERE SSN = '900-10-0005';

IF NOT EXISTS (
    SELECT 1 FROM dbo.Patient
    WHERE PatientID = @EmilyID
)
BEGIN
    INSERT INTO dbo.Patient (PatientID)
    VALUES (@EmilyID);
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Patient
    WHERE PatientID = @MichaelID
)
BEGIN
    INSERT INTO dbo.Patient (PatientID)
    VALUES (@MichaelID);
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Patient
    WHERE PatientID = @OliviaID
)
BEGIN
    INSERT INTO dbo.Patient (PatientID)
    VALUES (@OliviaID);
END;
-- 6. SAMPLE DOCTOR SCHEDULES
-- Sarah Patel: Monday, Wednesday, Friday
-- James Wilson: Tuesday, Thursday

INSERT INTO dbo.DoctorSchedule
    (DoctorID, OfficeID, DayOfWeek)
SELECT v.DoctorID, v.OfficeID, v.DayOfWeek
FROM (VALUES
    (1000000, 1000000, 'Mon'),
    (1000000, 1000000, 'Wed'),
    (1000000, 1000000, 'Fri'),
    (1000001, 1000001, 'Tue'),
    (1000001, 1000001, 'Thu')
) AS v(DoctorID, OfficeID, DayOfWeek)
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.DoctorSchedule ds
    WHERE ds.DoctorID = v.DoctorID
      AND ds.OfficeID = v.OfficeID
      AND ds.DayOfWeek = v.DayOfWeek
);

--7. SAMPLE APPOINTMENTS
INSERT INTO dbo.Appointment
    (OfficeID, DoctorID, PatientID, ReferralID,
     Date_Time, AppointStatus, TotalCost, Channel,
     CancelReason, CancelledBy)
SELECT
    v.OfficeID, v.DoctorID, v.PatientID, NULL,
    v.Date_Time, v.AppointStatus, v.TotalCost,
    v.Channel, v.CancelReason, v.CancelledBy
FROM (VALUES
    (1000000, 1000000, 1000002,
     CAST('2026-10-05T09:00:00' AS datetime2),
     'Completed', 150.00, 'Web Portal',
     CAST(NULL AS varchar(200)),
     CAST(NULL AS varchar(100))),

    (1000000, 1000000, 1000003,
     CAST('2026-10-07T10:00:00' AS datetime2),
     'Completed', 175.00, 'Phone', NULL, NULL),

    (1000000, 1000000, 1000004,
     CAST('2026-10-09T11:00:00' AS datetime2),
     'Completed', 125.00, 'Web Portal', NULL, NULL),

    (1000001, 1000001, 1000002,
     CAST('2026-10-06T09:30:00' AS datetime2),
     'Completed', 250.00, 'Phone', NULL, NULL),

    (1000001, 1000001, 1000003,
     CAST('2026-10-08T14:00:00' AS datetime2),
     'Completed', 300.00, 'Web Portal', NULL, NULL),

    (1000000, 1000000, 1000002,
     CAST('2026-10-23T09:00:00' AS datetime2),
     'Scheduled', 150.00, 'Web Portal', NULL, NULL),

    (1000000, 1000000, 1000003,
     CAST('2026-10-26T10:00:00' AS datetime2),
     'Scheduled', 175.00, 'Phone', NULL, NULL),

    (1000001, 1000001, 1000004,
     CAST('2026-10-27T11:00:00' AS datetime2),
     'Scheduled', 250.00, 'Web Portal', NULL, NULL),

    (1000000, 1000000, 1000004,
     CAST('2026-10-12T09:00:00' AS datetime2),
     'Cancelled', 125.00, 'Phone',
     'Patient unavailable', 'Patient'),

    (1000001, 1000001, 1000002,
     CAST('2026-10-13T14:00:00' AS datetime2),
     'Cancelled', 250.00, 'Web Portal',
     'Schedule conflict', 'Patient')
) AS v(
    OfficeID, DoctorID, PatientID, Date_Time,
    AppointStatus, TotalCost, Channel,
    CancelReason, CancelledBy
)
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Appointment a
    WHERE a.DoctorID = v.DoctorID
      AND a.PatientID = v.PatientID
      AND a.Date_Time = v.Date_Time
);

-- 8, SAMPLE PAYMENTS
-- Add payments for completed appointments
-- PaymentID is generated automatically

INSERT INTO dbo.Payment
    (AppointmentID, InstallmentNumber,
     PaymentDate, PayStatus)
SELECT
    a.AppointmentID,
    1,
    CAST(a.Date_Time AS DATE),
    'Completed'
FROM dbo.Appointment a
WHERE a.AppointStatus = 'Completed'
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Payment p
      WHERE p.AppointmentID = a.AppointmentID
        AND p.InstallmentNumber = 1
  );

-- Add pending payments for scheduled appointments

INSERT INTO dbo.Payment
    (AppointmentID, InstallmentNumber,
     PaymentDate, PayStatus)
SELECT
    a.AppointmentID,
    1,
    CAST(a.Date_Time AS DATE),
    'Pending'
FROM dbo.Appointment a
WHERE a.AppointStatus = 'Scheduled'
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Payment p
      WHERE p.AppointmentID = a.AppointmentID
        AND p.InstallmentNumber = 1
  );

-- 6. VERIFY SAMPLE DATA

SELECT 'Office' AS TableName, COUNT(*) AS TotalRows
FROM dbo.Office

UNION ALL

SELECT 'Member', COUNT(*)
FROM dbo.Member

UNION ALL

SELECT 'Employee', COUNT(*)
FROM dbo.Employee

UNION ALL

SELECT 'Doctor', COUNT(*)
FROM dbo.Doctor

UNION ALL

SELECT 'Patient', COUNT(*)
FROM dbo.Patient;
