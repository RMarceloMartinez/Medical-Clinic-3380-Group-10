USE MedicalClinic;
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
         ZipCode, Country, Phone, OpeningTime, ClosingTime, DeletionFlag)
    VALUES
        ('1234 Main Street', '100', 'Houston', 'Texas',
         '77002', 'USA', '7135550100', '08:00', '17:00', 0);
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
         ZipCode, Country, Phone, OpeningTime, ClosingTime, DeletionFlag)
    VALUES
        ('5678 Westheimer Road', '200', 'Houston', 'Texas',
         '77056', 'USA', '7135550200', '09:00', '18:00', 0);
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
         ZipCode, Country, Phone, Sex, DateOfBirth, Email, DeletionFlag)
    VALUES
        ('900-10-0001', 'Sarah', NULL, 'Patel',
         '100 Oak Street', NULL, 'Houston', 'Texas',
         '77002', 'USA', '7135551001', 'F',
         '1980-05-12', 'sarah.patel@example.com', 0);
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
         ZipCode, Country, Phone, Sex, DateOfBirth, Email, DeletionFlag)
    VALUES
        ('900-10-0002', 'James', NULL, 'Wilson',
         '200 Pine Street', NULL, 'Houston', 'Texas',
         '77056', 'USA', '7135551002', 'M',
         '1975-09-21', 'james.wilson@example.com', 0);
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
         ZipCode, Country, Phone, Sex, DateOfBirth, Email, DeletionFlag)
    VALUES
        ('900-10-0003', 'Emily', NULL, 'Garcia',
         '300 Elm Street', '12', 'Houston', 'Texas',
         '77003', 'USA', '7135551003', 'F',
         '1998-03-15', 'emily.garcia@example.com', 0);
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
         ZipCode, Country, Phone, Sex, DateOfBirth, Email, DeletionFlag)
    VALUES
        ('900-10-0004', 'Michael', NULL, 'Brown',
         '400 Maple Street', NULL, 'Houston', 'Texas',
         '77004', 'USA', '7135551004', 'M',
         '1990-07-08', 'michael.brown@example.com', 0);
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
         ZipCode, Country, Phone, Sex, DateOfBirth, Email, DeletionFlag)
    VALUES
        ('900-10-0005', 'Olivia', NULL, 'Davis',
         '500 Cedar Street', '4B', 'Houston', 'Texas',
         '77005', 'USA', '7135551005', 'F',
         '2001-11-25', 'olivia.davis@example.com', 0);
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
        (EmployeeID, HiringDate, DeletionFlag)
    VALUES
        (@SarahID, '2022-06-01', 0);
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Employee
    WHERE EmployeeID = @JamesID
)
BEGIN
    INSERT INTO dbo.Employee
        (EmployeeID, HiringDate, DeletionFlag)
    VALUES
        (@JamesID, '2021-03-15', 0);
END;

-- 3A. ADD NURSE AND RECEPTIONIST MEMBERS

-- Nurse: Jessica Lee
IF NOT EXISTS (
    SELECT 1 FROM dbo.Member
    WHERE SSN = '900-10-0006'
)
BEGIN
    INSERT INTO dbo.Member
        (SSN, FirstName, MiddleName, LastName,
         StreetAddress, ApartmentNum, City, State,
         ZipCode, Country, Phone, Sex, DateOfBirth, Email, DeletionFlag)
    VALUES
        ('900-10-0006', 'Jessica', NULL, 'Lee',
         '600 Willow Street', NULL, 'Houston', 'Texas',
         '77006', 'USA', '7135551006', 'F',
         '1992-04-18', 'jessica.lee@example.com', 0);
END;

-- Receptionist: Daniel Martinez
IF NOT EXISTS (
    SELECT 1 FROM dbo.Member
    WHERE SSN = '900-10-0007'
)
BEGIN
    INSERT INTO dbo.Member
        (SSN, FirstName, MiddleName, LastName,
         StreetAddress, ApartmentNum, City, State,
         ZipCode, Country, Phone, Sex, DateOfBirth, Email, DeletionFlag)
    VALUES
        ('900-10-0007', 'Daniel', NULL, 'Martinez',
         '700 Birch Street', NULL, 'Houston', 'Texas',
         '77007', 'USA', '7135551007', 'M',
         '1995-08-22', 'daniel.martinez@example.com', 0);
END;

-- 3B. ADD EMPLOYEE RECORDS

DECLARE @JessicaID INT;
DECLARE @DanielID INT;

SELECT @JessicaID = MemberID
FROM dbo.Member
WHERE SSN = '900-10-0006';

SELECT @DanielID = MemberID
FROM dbo.Member
WHERE SSN = '900-10-0007';

IF NOT EXISTS (
    SELECT 1 FROM dbo.Employee
    WHERE EmployeeID = @JessicaID
)
BEGIN
    INSERT INTO dbo.Employee (EmployeeID, HiringDate, DeletionFlag)
    VALUES (@JessicaID, '2023-01-10', 0);
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Employee
    WHERE EmployeeID = @DanielID
)
BEGIN
    INSERT INTO dbo.Employee (EmployeeID, HiringDate, DeletionFlag)
    VALUES (@DanielID, '2024-05-15', 0);
END;

-- 3C. ADD NURSE

IF NOT EXISTS (
    SELECT 1 FROM dbo.Nurse
    WHERE NurseID = @JessicaID
)
BEGIN
    INSERT INTO dbo.Nurse
        (NurseID, OfficeID, LicenseNum, DeletionFlag)
    SELECT
        @JessicaID, OfficeID, 'TXRN10001',
    0
    FROM dbo.Office
    WHERE StreetAddress = '1234 Main Street'
      AND SuiteNum = '100'
      AND City = 'Houston';
END;

-- 3D. ADD RECEPTIONIST

IF NOT EXISTS (
    SELECT 1 FROM dbo.Receptionist
    WHERE ReceptionistID = @DanielID
)
BEGIN
    INSERT INTO dbo.Receptionist
        (ReceptionistID, OfficeID, DeletionFlag)
    SELECT
        @DanielID, OfficeID,
    0
    FROM dbo.Office
    WHERE StreetAddress = '5678 Westheimer Road'
      AND SuiteNum = '200'
      AND City = 'Houston';
END;


-- 4. SAMPLE DOCTORS

IF NOT EXISTS (
    SELECT 1 FROM dbo.Doctor
    WHERE DoctorID = @SarahID
)
BEGIN
    INSERT INTO dbo.Doctor
        (DoctorID, LicenseNum, Specialty, DeletionFlag)
    VALUES
        (@SarahID, 'TX-MD-10001', 'Family Medicine', 0);
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Doctor
    WHERE DoctorID = @JamesID
)
BEGIN
    INSERT INTO dbo.Doctor
        (DoctorID, LicenseNum, Specialty, DeletionFlag)
    VALUES
        (@JamesID, 'TX-MD-10002', 'Cardiology', 0);
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
    INSERT INTO dbo.Patient (PatientID, DeletionFlag)
    VALUES (@EmilyID, 0);
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Patient
    WHERE PatientID = @MichaelID
)
BEGIN
    INSERT INTO dbo.Patient (PatientID, DeletionFlag)
    VALUES (@MichaelID, 0);
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.Patient
    WHERE PatientID = @OliviaID
)
BEGIN
    INSERT INTO dbo.Patient (PatientID, DeletionFlag)
    VALUES (@OliviaID, 0);
END;
-- 6. SAMPLE DOCTOR SCHEDULES
-- Sarah Patel: Monday, Wednesday, Friday
-- James Wilson: Tuesday, Thursday

DECLARE @Office1ID INT;
DECLARE @Office2ID INT;

SELECT @Office1ID = OfficeID
FROM dbo.Office
WHERE StreetAddress = '1234 Main Street'
  AND SuiteNum = '100'
  AND City = 'Houston';

SELECT @Office2ID = OfficeID
FROM dbo.Office
WHERE StreetAddress = '5678 Westheimer Road'
  AND SuiteNum = '200'
  AND City = 'Houston';

INSERT INTO dbo.DoctorSchedule
    (DoctorID, OfficeID, DayOfWeek, DeletionFlag)
SELECT v.DoctorID, v.OfficeID, v.DayOfWeek,
    0
FROM (VALUES
    (@SarahID, @Office1ID, 'Mon'),
    (@SarahID, @Office1ID, 'Wed'),
    (@SarahID, @Office1ID, 'Fri'),
    (@JamesID, @Office2ID, 'Tue'),
    (@JamesID, @Office2ID, 'Thu')
) AS v(DoctorID, OfficeID, DayOfWeek)
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.DoctorSchedule ds
    WHERE ds.DoctorID = v.DoctorID
      AND ds.OfficeID = v.OfficeID
      AND ds.DayOfWeek = v.DayOfWeek
);

-- 6B. SAMPLE PATIENT-DOCTOR RELATIONSHIPS
-- Must come before Referrals and Appointments (triggers 3 and 4 read it)

INSERT INTO dbo.PatientDoctor
    (PatientID, DoctorID, RolePlayed, StartDate, DeletionFlag)
SELECT
    v.PatientID,
    v.DoctorID,
    v.RolePlayed,
    v.StartDate,
    0
FROM (VALUES
    -- Emily: Sarah is primary, James is specialist
    (@EmilyID, @SarahID, 'Primary',
     CAST('2026-01-15' AS DATE)),

    (@EmilyID, @JamesID, 'Specialist',
     CAST('2026-07-01' AS DATE)),

    -- Michael: Sarah is primary, James is specialist
    (@MichaelID, @SarahID, 'Primary',
     CAST('2026-02-10' AS DATE)),

    (@MichaelID, @JamesID, 'Specialist',
     CAST('2026-07-01' AS DATE)),

    -- Olivia: Sarah is primary, James is specialist
    (@OliviaID, @SarahID, 'Primary',
     CAST('2026-03-05' AS DATE)),

    (@OliviaID, @JamesID, 'Specialist',
     CAST('2026-07-01' AS DATE))

) AS v(PatientID, DoctorID, RolePlayed, StartDate)
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.PatientDoctor pd
    WHERE pd.PatientID = v.PatientID
      AND pd.DoctorID = v.DoctorID
);

-- 6C. SAMPLE REFERRALS
-- Must come after PatientDoctor (trigger 4: issued by the patient's primary)
-- and before Appointments (trigger 3: specialist visits need an open referral)

INSERT INTO dbo.Referral
    (PatientID, SpecialistID, PrimaryID,
     DateIssued, RefStatus, DeletionFlag)
SELECT
    v.PatientID,
    v.SpecialistID,
    v.PrimaryID,
    v.DateIssued,
    v.RefStatus,
    0
FROM (VALUES

    -- Emily referred to James by Sarah
    -- (stays open: Emily still has a visit with James on Dec 3)
    (@EmilyID, @JamesID, @SarahID,
     CAST('2026-06-15' AS DATE),
     'Scheduled'),

    -- Michael referred to James by Sarah
    -- (issued before his first James visit on Jul 7)
    (@MichaelID, @JamesID, @SarahID,
     CAST('2026-06-20' AS DATE),
     'Scheduled'),

    -- Olivia referred to James by Sarah
    -- (needed for her Sep 8 visit with James)
    (@OliviaID, @JamesID, @SarahID,
     CAST('2026-08-20' AS DATE),
     'Scheduled')

) AS v(
    PatientID, SpecialistID, PrimaryID,
    DateIssued, RefStatus
)
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Referral r
    WHERE r.PatientID = v.PatientID
      AND r.SpecialistID = v.SpecialistID
      AND r.PrimaryID = v.PrimaryID
      AND r.DateIssued = v.DateIssued
);

--7. SAMPLE APPOINTMENTS
-- Appointments across July to October 2026, plus two upcoming in December

INSERT INTO dbo.Appointment
    (OfficeID, DoctorID, PatientID, ReferralID,
     Date_Time, AppointStatus, TotalCost, Channel,
     CancelReason, CancelledBy, DeletionFlag)
SELECT
    v.OfficeID,
    v.DoctorID,
    v.PatientID,
    NULL,
    v.Date_Time,
    v.AppointStatus,
    v.TotalCost,
    v.Channel,
    v.CancelReason,
    v.CancelledBy,
    0
FROM (VALUES

    -- JULY 2026
    (@Office1ID, @SarahID, @EmilyID,
     CAST('2026-07-06T09:00:00' AS datetime2),
     'Completed', 150.00, 'Web Portal',
     CAST(NULL AS varchar(200)),
     CAST(NULL AS varchar(7))),

    (@Office2ID, @JamesID, @MichaelID,
     CAST('2026-07-07T10:00:00' AS datetime2),
     'Completed', 250.00, 'Phone', NULL, NULL),

    -- AUGUST 2026
    (@Office1ID, @SarahID, @OliviaID,
     CAST('2026-08-03T11:00:00' AS datetime2),
     'Completed', 125.00, 'Phone', NULL, NULL),

    (@Office2ID, @JamesID, @EmilyID,
     CAST('2026-08-04T14:00:00' AS datetime2),
     'Completed', 300.00, 'Web Portal', NULL, NULL),

    -- SEPTEMBER 2026
    (@Office1ID, @SarahID, @MichaelID,
     CAST('2026-09-07T09:00:00' AS datetime2),
     'Completed', 175.00, 'Phone', NULL, NULL),

    (@Office2ID, @JamesID, @OliviaID,
     CAST('2026-09-08T10:30:00' AS datetime2),
     'Completed', 250.00, 'Web Portal', NULL, NULL),

    -- OCTOBER 2026
    (@Office1ID, @SarahID, @EmilyID,
     CAST('2026-10-05T09:00:00' AS datetime2),
     'Completed', 150.00, 'Web Portal', NULL, NULL),

    (@Office2ID, @JamesID, @MichaelID,
     CAST('2026-10-06T09:30:00' AS datetime2),
     'Completed', 250.00, 'Phone', NULL, NULL),

    (@Office1ID, @SarahID, @MichaelID,
     CAST('2026-10-12T09:00:00' AS datetime2),
     'Cancelled', 175.00, 'Phone',
     'Patient unavailable', 'Patient'),

    (@Office2ID, @JamesID, @OliviaID,
     CAST('2026-10-13T14:00:00' AS datetime2),
     'Cancelled', 250.00, 'Web Portal',
     'Schedule conflict', 'Patient'),

    -- DECEMBER 2026 (upcoming: must stay in the future for edit demos)
    -- Sarah works Mon/Wed/Fri, James Tue/Thu (trigger 1)
    (@Office1ID, @SarahID, @OliviaID,
     CAST('2026-12-02T09:00:00' AS datetime2),
     'Scheduled', 125.00, 'Web Portal', NULL, NULL),

    (@Office2ID, @JamesID, @EmilyID,
     CAST('2026-12-03T11:00:00' AS datetime2),
     'Scheduled', 300.00, 'Phone', NULL, NULL)

) AS v(
    OfficeID, DoctorID, PatientID, Date_Time,
    AppointStatus, TotalCost, Channel,
    CancelReason, CancelledBy
)
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Appointment a
    WHERE a.DoctorID = v.DoctorID
      AND a.Date_Time = v.Date_Time
);

-- 7B. CLOSE REFERRALS WHOSE VISITS ARE DONE
-- Michael and Olivia have no upcoming visits with James.
-- Changing only RefStatus is skipped by trigger 4.
UPDATE dbo.Referral
SET RefStatus = 'Finished'
WHERE SpecialistID = @JamesID
  AND PatientID IN (@MichaelID, @OliviaID)
  AND RefStatus = 'Scheduled';
-- 8, SAMPLE PAYMENTS
-- Add payments for completed appointments
-- PaymentID is generated automatically

INSERT INTO dbo.Payment
    (AppointmentID, InstallmentNumber,
     PaymentDate, PayStatus, DeletionFlag)
SELECT
    a.AppointmentID,
    1,
    CAST(a.Date_Time AS DATE),
    'Completed',
    0
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
     PaymentDate, PayStatus, DeletionFlag)
SELECT
    a.AppointmentID,
    1,
    CAST(a.Date_Time AS DATE),
    'Pending',
    0
FROM dbo.Appointment a
WHERE a.AppointStatus = 'Scheduled'
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Payment p
      WHERE p.AppointmentID = a.AppointmentID
        AND p.InstallmentNumber = 1
  );

  -- 9. SAMPLE MEDICAL RECORDS
-- Add records for completed appointments only

INSERT INTO dbo.MedicalRecord
    (AppointmentID, ClinicalNotes,
     SystolicBP, DiastolicBP, HeartRate,
     Temperature, WeightPounds, HeightInches,
     TreatmentPlan, FollowUp, DeletionFlag)
SELECT
    a.AppointmentID,
    CASE
        WHEN a.PatientID = @EmilyID
            THEN 'Routine examination completed.'
        WHEN a.PatientID = @MichaelID
            THEN 'Patient attended follow-up examination.'
        WHEN a.PatientID = @OliviaID
            THEN 'Annual wellness examination completed.'
    END,
    120, 80, 72, 98.6, 150.0, 66.0,
    'Continue routine preventive care.',
    'Schedule follow-up as needed.',
    0
FROM dbo.Appointment a
WHERE a.AppointStatus = 'Completed'
  AND a.PatientID IN
      (@EmilyID, @MichaelID, @OliviaID)
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.MedicalRecord mr
      WHERE mr.AppointmentID = a.AppointmentID
  );

--10.SAMPLE PAYMENT DETAILS
-- Add payment amounts for completed appointments
INSERT INTO dbo.PaymentDetail
    (PaymentID, MethodID, AmountApplied, DeletionFlag)
SELECT
    p.PaymentID,
    CASE
        WHEN a.Channel = 'Web Portal' THEN 2
        ELSE 1
    END,
    a.TotalCost,
    0
FROM dbo.Payment p
INNER JOIN dbo.Appointment a
    ON p.AppointmentID = a.AppointmentID
WHERE p.PayStatus = 'Completed'
  AND a.AppointStatus = 'Completed'
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.PaymentDetail pd
      WHERE pd.PaymentID = p.PaymentID
  );

-- 12. SAMPLE PATIENT CONDITIONS
INSERT INTO dbo.PatientCondition
    (PatientID, ConditionName, ConditionType,
     IsHereditary, Severity, DateDiagnosed, DeletionFlag)
SELECT
    v.PatientID, v.ConditionName, v.ConditionType,
    v.IsHereditary, v.Severity, v.DateDiagnosed,
    0
FROM (VALUES
    (@EmilyID, 'Asthma', 'Chronic', 0, 'Moderate',
     CAST('2020-04-15' AS DATE)),
    (@MichaelID, 'Hypertension', 'Chronic', 1, 'Moderate',
     CAST('2022-06-10' AS DATE)),
    (@OliviaID, 'Seasonal Influenza', 'Acute', 0, 'Low',
     CAST('2026-02-12' AS DATE))
) AS v(PatientID, ConditionName, ConditionType,
       IsHereditary, Severity, DateDiagnosed)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.PatientCondition pc
    WHERE pc.PatientID = v.PatientID
      AND pc.ConditionName = v.ConditionName
);

-- 13. SAMPLE ALLERGIES

INSERT INTO dbo.Allergy
    (PatientID, Allergen, ReactionType,
     Severity, DateIdentified, DeletionFlag)
SELECT
    v.PatientID, v.Allergen, v.ReactionType,
    v.Severity, v.DateIdentified,
    0
FROM (VALUES
    (@EmilyID, 'Peanuts', 'Hives', 'Moderate',
     CAST('2018-05-10' AS DATE)),
    (@MichaelID, 'Penicillin', 'Skin Rash', 'Mild',
     CAST('2015-03-20' AS DATE)),
    (@OliviaID, 'Pollen', 'Sneezing', 'Mild',
     CAST('2021-04-05' AS DATE))
) AS v(PatientID, Allergen, ReactionType,
       Severity, DateIdentified)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Allergy a
    WHERE a.PatientID = v.PatientID
      AND a.Allergen = v.Allergen
);

-- 14. SAMPLE FAMILY CONDITIONS

INSERT INTO dbo.FamilyCondition
    (PatientID, ConditionName,
     FamilyRelationship, Notes, DeletionFlag)
SELECT
    v.PatientID, v.ConditionName,
    v.FamilyRelationship, v.Notes,
    0
FROM (VALUES
    (@EmilyID, 'Diabetes', 'Mother',
     CAST('Family history of type 2 diabetes.'
          AS VARCHAR(200))),
    (@MichaelID, 'Hypertension', 'Father',
     CAST('Father diagnosed with hypertension.'
          AS VARCHAR(200)))
) AS v(PatientID, ConditionName,
       FamilyRelationship, Notes)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.FamilyCondition fc
    WHERE fc.PatientID = v.PatientID
      AND fc.ConditionName = v.ConditionName
      AND fc.FamilyRelationship = v.FamilyRelationship
);
-- 16. SAMPLE DIAGNOSES
-- One diagnosis for each completed appointment record

INSERT INTO dbo.Diagnosis
    (DiagnosisID, RecordID, DiagnosisDescription, DiagnosisType, DeletionFlag)
SELECT
    1,
    mr.RecordID,
    CASE
        WHEN a.PatientID = @EmilyID
            THEN 'Routine health examination'
        WHEN a.PatientID = @MichaelID
            THEN 'Follow-up health examination'
        WHEN a.PatientID = @OliviaID
            THEN 'Preventive wellness examination'
    END,
    'Primary',
    0
FROM dbo.MedicalRecord mr
INNER JOIN dbo.Appointment a
    ON mr.AppointmentID = a.AppointmentID
WHERE a.AppointStatus = 'Completed'
  AND a.PatientID IN (@EmilyID, @MichaelID, @OliviaID)
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Diagnosis d
      WHERE d.RecordID = mr.RecordID
        AND d.DiagnosisID = 1
  );

-- 17. SAMPLE PRESCRIPTIONS
-- Illustrative prescriptions linked to existing records

INSERT INTO dbo.Prescription
    (PrescriptionID, RecordID, MedicationName,
     Dosage, Frequency, Duration, Instructions, DeletionFlag)
SELECT
    1,
    mr.RecordID,
    CASE
        WHEN a.PatientID = @EmilyID THEN 'Albuterol'
        WHEN a.PatientID = @MichaelID THEN 'Lisinopril'
    END,
    CASE
        WHEN a.PatientID = @EmilyID THEN '90 mcg'
        WHEN a.PatientID = @MichaelID THEN '10 mg'
    END,
    CASE
        WHEN a.PatientID = @EmilyID THEN 'As needed'
        WHEN a.PatientID = @MichaelID THEN 'Once daily'
    END,
    'As directed',
    'Sample educational record only',
    0
FROM dbo.MedicalRecord mr
INNER JOIN dbo.Appointment a
    ON mr.AppointmentID = a.AppointmentID
WHERE a.AppointStatus = 'Completed'
  AND a.PatientID IN (@EmilyID, @MichaelID)
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Prescription p
      WHERE p.RecordID = mr.RecordID
        AND p.PrescriptionID = 1
  );

-- 18. SAMPLE INSURANCE

INSERT INTO dbo.Insurance
    (PatientID, ProviderCompany, PolicyNum,
     GroupNum, PlanType, EffectiveDate,
     ExpirationDate, IsPrimary, DeletionFlag)
SELECT
    v.PatientID, v.ProviderCompany, v.PolicyNum,
    v.GroupNum, v.PlanType, v.EffectiveDate,
    v.ExpirationDate, v.IsPrimary,
    0
FROM (VALUES
    (@EmilyID, 'Blue Cross', '1234567890001',
     '123456789012345', 'PPO',
     CAST('2026-01-01' AS DATE),
     CAST('2026-12-31' AS DATE), 1),

    (@MichaelID, 'Aetna', '1234567890002',
     '123456789012346', 'HMO',
     CAST('2026-01-01' AS DATE),
     CAST('2026-12-31' AS DATE), 1),

    (@OliviaID, 'Cigna', '1234567890003',
     '123456789012347', 'PPO',
     CAST('2026-01-01' AS DATE),
     CAST('2026-12-31' AS DATE), 1)
) AS v(
    PatientID, ProviderCompany, PolicyNum,
    GroupNum, PlanType, EffectiveDate,
    ExpirationDate, IsPrimary
)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Insurance i
    WHERE i.PatientID = v.PatientID
      AND i.PolicyNum = v.PolicyNum
);

-- 19. SAMPLE EMERGENCY CONTACTS

INSERT INTO dbo.EmergencyContact
    (PatientID, FirstName, MiddleName,
     LastName, Phone, Relationship, DeletionFlag)
SELECT
    v.PatientID, v.FirstName, NULL,
    v.LastName, v.Phone, v.Relationship,
    0
FROM (VALUES
    (@EmilyID, 'Robert', 'Garcia',
     '7135552001', 'Father'),

    (@MichaelID, 'Linda', 'Brown',
     '7135552002', 'Mother'),

    (@OliviaID, 'Sophia', 'Davis',
     '7135552003', 'Sister')
) AS v(
    PatientID, FirstName, LastName,
    Phone, Relationship
)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.EmergencyContact ec
    WHERE ec.PatientID = v.PatientID
      AND ec.FirstName = v.FirstName
      AND ec.LastName = v.LastName
);

-- 19B. ADMIN MEMBER
-- Grace Kim: clinic administrator (Employee only, no clinical subtype)

IF NOT EXISTS (
    SELECT 1 FROM dbo.Member
    WHERE SSN = '900-10-0008'
)
BEGIN
    INSERT INTO dbo.Member
        (SSN, FirstName, MiddleName, LastName,
         StreetAddress, ApartmentNum, City, State,
         ZipCode, Country, Phone, Sex, DateOfBirth, Email, DeletionFlag)
    VALUES
        ('900-10-0008', 'Grace', NULL, 'Kim',
         '800 Spruce Street', NULL, 'Houston', 'Texas',
         '77008', 'USA', '7135551008', 'F',
         '1985-02-14', 'grace.kim@example.com', 0);
END;

DECLARE @AdminID INT;

SELECT @AdminID = MemberID
FROM dbo.Member
WHERE SSN = '900-10-0008';

IF NOT EXISTS (
    SELECT 1 FROM dbo.Employee
    WHERE EmployeeID = @AdminID
)
BEGIN
    INSERT INTO dbo.Employee (EmployeeID, HiringDate, DeletionFlag)
    VALUES (@AdminID, '2020-08-01', 0);
END;

-- 19C. USER ACCOUNTS
-- Demo password for every account: Clinic2026!
-- PasswordHash = bcrypt (cost 11), verified by BCrypt.Net in AuthService.

INSERT INTO dbo.UserAccount
    (UserID, Username, PasswordHash, LastLogin, Role, IsActive, DeletionFlag)
SELECT
    v.UserID, v.Username, v.PasswordHash, NULL, v.Role, 1,
    0
FROM (VALUES
    (@SarahID, 'spatel', '$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', 'Doctor'),
    (@JamesID, 'jwilson', '$2a$11$9CovlETjB5YcciYjy2Y9lOq6CE/PKrNu0GgEmfonjstG5yZmvHsxu', 'Doctor'),
    (@JessicaID, 'jlee', '$2a$11$Vbodz.USI.mYXu62C8rome4iXk4afUVVxxmowmwCOHmoVMWrHyUcq', 'Nurse'),
    (@DanielID, 'dmartinez', '$2a$11$dRCQROqEzqOOvG4nT1ClUuerptG6E66xj723s.RMrnExHprlRDB7m', 'Receptionist'),
    (@EmilyID, 'egarcia', '$2a$11$wnjb9Gw7U.RUU8nOYkjhIeneswzval8Z80SONUYmIt77vffn.UmRe', 'Patient'),
    (@MichaelID, 'mbrown', '$2a$11$3S3aEWM9kNv8FFgINzxwlOmHI0c6MjhnECi37LSFakJ7G06plC3Jq', 'Patient'),
    (@OliviaID, 'odavis', '$2a$11$SeiT78I.KCUCIyA.Tekz3.6iGvRYMB36uEwWHIaUOnpk1LHVEojBC', 'Patient'),
    (@AdminID, 'admin', '$2a$11$bAMpwulL0gHQHs8KjUhXOuQx1H8..srJtpaZvIYgSho1.7h.sJzgO', 'Admin')
) AS v(UserID, Username, PasswordHash, Role)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.UserAccount ua
    WHERE ua.Username = v.Username
       OR ua.UserID = v.UserID
);

-- 20. VERIFY SAMPLE DATA

SELECT 'Office' AS TableName, COUNT(*) AS TotalRows FROM dbo.Office
UNION ALL
SELECT 'Member', COUNT(*) FROM dbo.Member
UNION ALL
SELECT 'Employee', COUNT(*) FROM dbo.Employee
UNION ALL
SELECT 'Doctor', COUNT(*) FROM dbo.Doctor
UNION ALL
SELECT 'Nurse', COUNT(*) FROM dbo.Nurse
UNION ALL
SELECT 'Receptionist', COUNT(*) FROM dbo.Receptionist
UNION ALL
SELECT 'Patient', COUNT(*) FROM dbo.Patient
UNION ALL
SELECT 'DoctorSchedule', COUNT(*) FROM dbo.DoctorSchedule
UNION ALL
SELECT 'Appointment', COUNT(*) FROM dbo.Appointment
UNION ALL
SELECT 'Payment', COUNT(*) FROM dbo.Payment
UNION ALL
SELECT 'PaymentDetail', COUNT(*) FROM dbo.PaymentDetail
UNION ALL
SELECT 'MedicalRecord', COUNT(*) FROM dbo.MedicalRecord
UNION ALL
SELECT 'PatientDoctor', COUNT(*) FROM dbo.PatientDoctor
UNION ALL
SELECT 'PatientCondition', COUNT(*) FROM dbo.PatientCondition
UNION ALL
SELECT 'Allergy', COUNT(*) FROM dbo.Allergy
UNION ALL
SELECT 'FamilyCondition', COUNT(*) FROM dbo.FamilyCondition
UNION ALL
SELECT 'Referral', COUNT(*) FROM dbo.Referral
UNION ALL
SELECT 'Diagnosis', COUNT(*) FROM dbo.Diagnosis
UNION ALL
SELECT 'Prescription', COUNT(*) FROM dbo.Prescription
UNION ALL
SELECT 'Insurance', COUNT(*) FROM dbo.Insurance
UNION ALL
SELECT 'EmergencyContact', COUNT(*) FROM dbo.EmergencyContact
UNION ALL
SELECT 'PaymentMethod', COUNT(*) FROM dbo.PaymentMethod
UNION ALL
SELECT 'UserAccount', COUNT(*) FROM dbo.UserAccount;