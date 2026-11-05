
USE MedicalClinic;
GO

-- Package 6: Additional Sample Data
-- Keertana
-- Run after seed.sql

-- 1. Additional Doctors

-- Additional doctor: David Chen
IF NOT EXISTS (
    SELECT 1
    FROM dbo.Member
    WHERE Email = 'david.chen@example.com'
)
BEGIN
    INSERT INTO dbo.Member
    (
        SSN, FirstName, MiddleName, LastName,
        StreetAddress, ApartmentNum, City,
        State, ZipCode, Country, Phone,
        Sex, DateOfBirth, Email, DeletionFlag
    )
    VALUES
    (
        '900-20-0001', 'David', NULL, 'Chen',
        '810 Oak Street', NULL, 'Houston',
        'Texas', '77002', 'USA', '7135552001',
        'M', '1982-04-12',
        'david.chen@example.com', 0
    );
END;

-- Add David Chen as an employee
DECLARE @DavidID INT;

SELECT @DavidID = MemberID
FROM dbo.Member
WHERE Email = 'david.chen@example.com';

IF NOT EXISTS (
    SELECT 1
    FROM dbo.Employee
    WHERE EmployeeID = @DavidID
)
BEGIN
    INSERT INTO dbo.Employee
        (EmployeeID, HiringDate, DeletionFlag)
    VALUES
        (@DavidID, '2023-06-01', 0);
END;

-- Add David Chen as a doctor
IF NOT EXISTS (
    SELECT 1
    FROM dbo.Doctor
    WHERE DoctorID = @DavidID
)
BEGIN
    INSERT INTO dbo.Doctor
        (DoctorID, LicenseNum, Specialty, DeletionFlag)
    VALUES
        (@DavidID, 'TX-MD-20001', 'Internal Medicine', 0);
END;

-- ADDITIONAL FIVE DOCTORS

-- 1. Add members
INSERT INTO dbo.Member
(
    SSN, FirstName, MiddleName, LastName,
    StreetAddress, ApartmentNum, City, State,
    ZipCode, Country, Phone, Sex,
    DateOfBirth, Email, DeletionFlag
)
SELECT
    v.SSN, v.FirstName, NULL, v.LastName,
    v.StreetAddress, NULL, 'Houston', 'Texas',
    '77002', 'USA', v.Phone, v.Sex,
    v.DateOfBirth, v.Email, 0
FROM (VALUES
    ('900-20-0002', 'Priya', 'Shah',
     '820 Oak Street', '7135552002', 'F',
     CAST('1985-03-15' AS DATE),
     'priya.shah@example.com'),

    ('900-20-0003', 'Robert', 'Kim',
     '830 Oak Street', '7135552003', 'M',
     CAST('1979-07-22' AS DATE),
     'robert.kim@example.com'),

    ('900-20-0004', 'Sophia', 'Martinez',
     '840 Oak Street', '7135552004', 'F',
     CAST('1988-09-10' AS DATE),
     'sophia.martinez@example.com'),

    ('900-20-0005', 'Daniel', 'Brooks',
     '850 Oak Street', '7135552005', 'M',
     CAST('1981-11-05' AS DATE),
     'daniel.brooks@example.com'),

    ('900-20-0006', 'Angela', 'Nguyen',
     '860 Oak Street', '7135552006', 'F',
     CAST('1984-06-18' AS DATE),
     'angela.nguyen@example.com')
) AS v(
    SSN, FirstName, LastName,
    StreetAddress, Phone, Sex,
    DateOfBirth, Email
)
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Member m
    WHERE m.Email = v.Email
);

-- 2. Add employees
INSERT INTO dbo.Employee
    (EmployeeID, HiringDate, DeletionFlag)
SELECT
    m.MemberID, '2023-06-01', 0
FROM dbo.Member m
WHERE m.Email IN (
    'priya.shah@example.com',
    'robert.kim@example.com',
    'sophia.martinez@example.com',
    'daniel.brooks@example.com',
    'angela.nguyen@example.com'
)
AND NOT EXISTS (
    SELECT 1
    FROM dbo.Employee e
    WHERE e.EmployeeID = m.MemberID
);

-- 3. Add doctors
INSERT INTO dbo.Doctor
    (DoctorID, LicenseNum, Specialty, DeletionFlag)
SELECT
    m.MemberID, v.LicenseNum, v.Specialty, 0
FROM (VALUES
    ('priya.shah@example.com',
     'TX-MD-20002', 'Family Medicine'),

    ('robert.kim@example.com',
     'TX-MD-20003', 'Pediatrics'),

    ('sophia.martinez@example.com',
     'TX-MD-20004', 'Dermatology'),

    ('daniel.brooks@example.com',
     'TX-MD-20005', 'Orthopedics'),

    ('angela.nguyen@example.com',
     'TX-MD-20006', 'Cardiology')
) AS v(Email, LicenseNum, Specialty)
JOIN dbo.Member m
    ON m.Email = v.Email
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Doctor d
    WHERE d.DoctorID = m.MemberID
);



-- 2. Additional Nurses


-- =========================================
-- PACKAGE 6: ADDITIONAL NURSES
-- =========================================

-- 1. Add nurse members
INSERT INTO dbo.Member
(
    SSN, FirstName, MiddleName, LastName,
    StreetAddress, ApartmentNum, City, State,
    ZipCode, Country, Phone, Sex,
    DateOfBirth, Email, DeletionFlag
)
SELECT
    v.SSN, v.FirstName, NULL, v.LastName,
    v.StreetAddress, NULL, 'Houston', 'Texas',
    '77002', 'USA', v.Phone, v.Sex,
    v.DateOfBirth, v.Email, 0
FROM (VALUES
    ('900-20-0007', 'Hannah', 'Williams',
     '870 Oak Street', '7135552007', 'F',
     CAST('1993-05-14' AS DATE),
     'hannah.williams@example.com'),

    ('900-20-0008', 'Kevin', 'Thomas',
     '880 Oak Street', '7135552008', 'M',
     CAST('1991-08-20' AS DATE),
     'kevin.thomas@example.com')
) AS v(
    SSN, FirstName, LastName,
    StreetAddress, Phone, Sex,
    DateOfBirth, Email
)
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Member m
    WHERE m.Email = v.Email
);

-- 2. Add employee records
INSERT INTO dbo.Employee
    (EmployeeID, HiringDate, DeletionFlag)
SELECT
    m.MemberID, '2024-01-15', 0
FROM dbo.Member m
WHERE m.Email IN (
    'hannah.williams@example.com',
    'kevin.thomas@example.com'
)
AND NOT EXISTS (
    SELECT 1
    FROM dbo.Employee e
    WHERE e.EmployeeID = m.MemberID
);

-- 3. Add nurses and assign offices
INSERT INTO dbo.Nurse
    (NurseID, OfficeID, LicenseNum, DeletionFlag)
SELECT
    m.MemberID,
    o.OfficeID,
    v.LicenseNum,
    0
FROM (VALUES
    ('hannah.williams@example.com',
     '1234 Main Street', 'TXRN20001'),

    ('kevin.thomas@example.com',
     '5678 Westheimer Road', 'TXRN20002')
) AS v(Email, OfficeAddress, LicenseNum)
JOIN dbo.Member m
    ON m.Email = v.Email
JOIN dbo.Office o
    ON o.StreetAddress = v.OfficeAddress
   AND o.City = 'Houston'
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Nurse n
    WHERE n.NurseID = m.MemberID
);

-- 3. Additional Patients


INSERT INTO dbo.Member
(
    SSN, FirstName, MiddleName, LastName,
    StreetAddress, ApartmentNum, City, State,
    ZipCode, Country, Phone, Sex,
    DateOfBirth, Email, DeletionFlag
)
SELECT
    v.SSN,
    v.FirstName,
    NULL,
    v.LastName,
    CONCAT(v.PatientNum, ' Houston Avenue'),
    NULL,
    'Houston',
    'Texas',
    '77002',
    'USA',
    CONCAT('713555', RIGHT('0000' + CAST(v.PatientNum AS VARCHAR(4)), 4)),
    v.Sex,
    v.DateOfBirth,
    CONCAT('patient', v.PatientNum, '@example.com'),
    0
FROM (VALUES
    (3001, 'Emma', 'Johnson', 'F', CAST('1995-02-14' AS DATE), '900-30-0001'),
    (3002, 'Liam', 'Anderson', 'M', CAST('1988-06-20' AS DATE), '900-30-0002'),
    (3003, 'Ava', 'Thompson', 'F', CAST('2000-09-12' AS DATE), '900-30-0003'),
    (3004, 'Noah', 'Robinson', 'M', CAST('1975-04-08' AS DATE), '900-30-0004'),
    (3005, 'Mia', 'Clark', 'F', CAST('1992-11-25' AS DATE), '900-30-0005'),
    (3006, 'Ethan', 'Lewis', 'M', CAST('1983-07-17' AS DATE), '900-30-0006'),
    (3007, 'Isabella', 'Walker', 'F', CAST('2003-01-30' AS DATE), '900-30-0007'),
    (3008, 'Lucas', 'Hall', 'M', CAST('1969-03-22' AS DATE), '900-30-0008'),
    (3009, 'Amelia', 'Allen', 'F', CAST('1998-12-05' AS DATE), '900-30-0009'),
    (3010, 'Mason', 'Young', 'M', CAST('1986-08-19' AS DATE), '900-30-0010'),
    (3011, 'Harper', 'King', 'F', CAST('1990-05-11' AS DATE), '900-30-0011'),
    (3012, 'Logan', 'Wright', 'M', CAST('1978-10-16' AS DATE), '900-30-0012'),
    (3013, 'Evelyn', 'Scott', 'F', CAST('2002-02-28' AS DATE), '900-30-0013'),
    (3014, 'Jacob', 'Green', 'M', CAST('1981-09-09' AS DATE), '900-30-0014'),
    (3015, 'Abigail', 'Baker', 'F', CAST('1996-06-06' AS DATE), '900-30-0015'),
    (3016, 'Henry', 'Adams', 'M', CAST('1972-12-14' AS DATE), '900-30-0016'),
    (3017, 'Ella', 'Nelson', 'F', CAST('2001-07-21' AS DATE), '900-30-0017'),

    -- Patients without SSNs
    (3018, 'Benjamin', 'Carter', 'M', CAST('1989-04-10' AS DATE), NULL),
    (3019, 'Sofia', 'Mitchell', 'F', CAST('1994-08-03' AS DATE), NULL),
    (3020, 'Alexander', 'Perez', 'M', CAST('1980-01-18' AS DATE), NULL),
    (3021, 'Charlotte', 'Roberts', 'F', CAST('1999-05-27' AS DATE), NULL),
    (3022, 'William', 'Turner', 'M', CAST('1965-11-02' AS DATE), NULL),
    (3023, 'Grace', 'Phillips', 'F', CAST('2004-03-15' AS DATE), NULL),
    (3024, 'Samuel', 'Campbell', 'M', CAST('1987-09-23' AS DATE), NULL),
    (3025, 'Chloe', 'Parker', 'F', CAST('1993-12-07' AS DATE), NULL)
) AS v(PatientNum, FirstName, LastName, Sex, DateOfBirth, SSN)
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Member m
    WHERE m.Email = CONCAT('patient', v.PatientNum, '@example.com')
);

-- Add the members to Patient table
INSERT INTO dbo.Patient
    (PatientID, DeletionFlag)
SELECT
    m.MemberID,
    0
FROM dbo.Member m
WHERE m.Email LIKE 'patient30[0-2][0-9]@example.com'
  AND m.Email IN (
      SELECT CONCAT('patient', n.PatientNum, '@example.com')
      FROM (VALUES
          (3001),(3002),(3003),(3004),(3005),
          (3006),(3007),(3008),(3009),(3010),
          (3011),(3012),(3013),(3014),(3015),
          (3016),(3017),(3018),(3019),(3020),
          (3021),(3022),(3023),(3024),(3025)
      ) AS n(PatientNum)
  )
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Patient p
      WHERE p.PatientID = m.MemberID
  );

-- 4. Doctor Schedules and Patient Relationships


INSERT INTO dbo.DoctorSchedule
    (DoctorID, OfficeID, DayOfWeek, DeletionFlag)
SELECT
    d.DoctorID,
    o.OfficeID,
    v.DayOfWeek,
    0
FROM (VALUES
    ('david.chen@example.com', '1234 Main Street', 'Tue'),
    ('david.chen@example.com', '1234 Main Street', 'Thu'),

    ('priya.shah@example.com', '1234 Main Street', 'Mon'),
    ('priya.shah@example.com', '1234 Main Street', 'Wed'),
    ('priya.shah@example.com', '1234 Main Street', 'Fri'),

    ('robert.kim@example.com', '5678 Westheimer Road', 'Mon'),
    ('robert.kim@example.com', '5678 Westheimer Road', 'Wed'),

    ('sophia.martinez@example.com', '5678 Westheimer Road', 'Tue'),
    ('sophia.martinez@example.com', '5678 Westheimer Road', 'Thu'),

    ('daniel.brooks@example.com', '1234 Main Street', 'Tue'),
    ('daniel.brooks@example.com', '1234 Main Street', 'Thu'),

    ('angela.nguyen@example.com', '5678 Westheimer Road', 'Mon'),
    ('angela.nguyen@example.com', '5678 Westheimer Road', 'Fri')
) AS v(Email, OfficeAddress, DayOfWeek)
JOIN dbo.Member m
    ON m.Email = v.Email
JOIN dbo.Doctor d
    ON d.DoctorID = m.MemberID
JOIN dbo.Office o
    ON o.StreetAddress = v.OfficeAddress
   AND o.City = 'Houston'
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.DoctorSchedule ds
    WHERE ds.DoctorID = d.DoctorID
      AND ds.OfficeID = o.OfficeID
      AND ds.DayOfWeek = v.DayOfWeek
);



INSERT INTO dbo.PatientDoctor
    (PatientID, DoctorID, RolePlayed, StartDate, DeletionFlag)
SELECT
    p.PatientID,
    d.DoctorID,
    'Primary',
    CAST('2026-01-15' AS DATE),
    0
FROM dbo.Patient p
JOIN dbo.Member pm
    ON pm.MemberID = p.PatientID
JOIN dbo.Member dm
    ON dm.Email = CASE
        WHEN CAST(SUBSTRING(pm.Email, 8, 4) AS INT) % 2 = 0
            THEN 'david.chen@example.com'
        ELSE 'priya.shah@example.com'
    END
JOIN dbo.Doctor d
    ON d.DoctorID = dm.MemberID
WHERE pm.Email IN (
    SELECT CONCAT('patient', n.PatientNum, '@example.com')
    FROM (VALUES
        (3001),(3002),(3003),(3004),(3005),
        (3006),(3007),(3008),(3009),(3010),
        (3011),(3012),(3013),(3014),(3015),
        (3016),(3017),(3018),(3019),(3020),
        (3021),(3022),(3023),(3024),(3025)
    ) AS n(PatientNum)
)
AND NOT EXISTS (
    SELECT 1
    FROM dbo.PatientDoctor pd
    WHERE pd.PatientID = p.PatientID
      AND pd.RolePlayed = 'Primary'
);


-- 5. Appointments

;WITH Numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM Numbers
    WHERE n < 30
),
Visits AS (
    SELECT
        n,
        3001 + ((n - 1) % 25) AS PatientNum,
        CASE
            WHEN (3001 + ((n - 1) % 25)) % 2 = 0
                THEN 'david.chen@example.com'
            ELSE 'priya.shah@example.com'
        END AS DoctorEmail,
        -- Alternate between Tuesday and Thursday for David;
        -- Monday, Wednesday and Friday for Priya.
        DATEADD(
            DAY,
            ((n - 1) / 5) * 7 +
            CASE
                WHEN (3001 + ((n - 1) % 25)) % 2 = 0
                    THEN CASE WHEN n % 2 = 0 THEN 1 ELSE 3 END
                ELSE CASE
                    WHEN n % 3 = 0 THEN 0
                    WHEN n % 3 = 1 THEN 2
                    ELSE 4
                END
            END,
            CAST('2026-09-07' AS DATE)
        ) AS VisitDate
    FROM Numbers
),
AppointmentsToAdd AS (
    SELECT
        n,
        PatientNum,
        DoctorEmail,
        DATEADD(
            HOUR,
            9 + ((n - 1) % 6),
            CAST(VisitDate AS DATETIME2(0))
        ) AS VisitTime
    FROM Visits
)
INSERT INTO dbo.Appointment
(
    OfficeID, DoctorID, PatientID, ReferralID,
    Date_Time, AppointStatus, TotalCost,
    Channel, CancelReason, CancelledBy, DeletionFlag
)
SELECT
    o.OfficeID,
    d.DoctorID,
    p.PatientID,
    NULL,
    v.VisitTime,
    CASE
        WHEN v.VisitTime > SYSDATETIME()
            THEN 'Scheduled'
        WHEN v.n % 10 = 0
            THEN 'Cancelled'
        ELSE 'Completed'
    END,
    150.00,
    CASE WHEN v.n % 2 = 0 THEN 'Phone'
         ELSE 'Web Portal' END,
    CASE
        WHEN v.VisitTime <= SYSDATETIME()
             AND v.n % 10 = 0
            THEN 'Patient unavailable'
        ELSE NULL
    END,
    CASE
        WHEN v.VisitTime <= SYSDATETIME()
             AND v.n % 10 = 0
            THEN 'Patient'
        ELSE NULL
    END,
    0
FROM AppointmentsToAdd v
JOIN dbo.Member dm
    ON dm.Email = v.DoctorEmail
JOIN dbo.Doctor d
    ON d.DoctorID = dm.MemberID
JOIN dbo.Member pm
    ON pm.Email = CONCAT('patient', v.PatientNum, '@example.com')
JOIN dbo.Patient p
    ON p.PatientID = pm.MemberID
JOIN dbo.Office o
    ON o.StreetAddress = '1234 Main Street'
   AND o.City = 'Houston'
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Appointment a
    WHERE a.DoctorID = d.DoctorID
      AND a.Date_Time = v.VisitTime
)
OPTION (MAXRECURSION 30);



-- 6. Medical Records and Diagnoses

INSERT INTO dbo.MedicalRecord
(
    AppointmentID, ClinicalNotes,
    SystolicBP, DiastolicBP, HeartRate,
    Temperature, WeightPounds, HeightInches,
    TreatmentPlan, FollowUp, DeletionFlag
)
SELECT
    a.AppointmentID,
    'Routine clinical examination completed.',
    120, 80, 72,
    98.6, 150.0, 66.0,
    'Continue care and monitor symptoms.',
    'Follow up as needed.',
    0
FROM dbo.Appointment a
JOIN dbo.Member pm
    ON pm.MemberID = a.PatientID
WHERE a.AppointStatus = 'Completed'
  AND pm.Email IN (
      SELECT CONCAT('patient', n.PatientNum, '@example.com')
      FROM (VALUES
          (3001),(3002),(3003),(3004),(3005),
          (3006),(3007),(3008),(3009),(3010),
          (3011),(3012),(3013),(3014),(3015),
          (3016),(3017),(3018),(3019),(3020),
          (3021),(3022),(3023),(3024),(3025)
      ) AS n(PatientNum)
  )
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.MedicalRecord mr
      WHERE mr.AppointmentID = a.AppointmentID
  );

  



INSERT INTO dbo.Diagnosis
(
    DiagnosisID, RecordID,
    DiagnosisDescription, DiagnosisType,
    DeletionFlag
)
SELECT
    1,
    mr.RecordID,
    CASE
        WHEN a.PatientID % 5 = 0 THEN 'Hypertension'
        WHEN a.PatientID % 5 = 1 THEN 'Type 2 Diabetes'
        WHEN a.PatientID % 5 = 2 THEN 'Asthma'
        WHEN a.PatientID % 5 = 3 THEN 'Seasonal Allergies'
        ELSE 'Upper Respiratory Infection'
    END,
    'Primary',
    0
FROM dbo.MedicalRecord mr
JOIN dbo.Appointment a
    ON a.AppointmentID = mr.AppointmentID
JOIN dbo.Member pm
    ON pm.MemberID = a.PatientID
WHERE a.AppointStatus = 'Completed'
  AND pm.Email LIKE 'patient30[0-2][0-9]@example.com'
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Diagnosis d
      WHERE d.RecordID = mr.RecordID
        AND d.DiagnosisID = 1
  );


-- 7. Patient Conditions


;WITH ExtraPatients AS (
    SELECT
        p.PatientID,
        TRY_CONVERT(
            INT,
            SUBSTRING(m.Email, 8, 4)
        ) AS PatientNum
    FROM dbo.Patient p
    JOIN dbo.Member m
        ON m.MemberID = p.PatientID
    WHERE m.Email IN (
        SELECT CONCAT('patient', n.PatientNum, '@example.com')
        FROM (VALUES
            (3001),(3002),(3003),(3004),(3005),
            (3006),(3007),(3008),(3009),(3010),
            (3011),(3012),(3013),(3014),(3015),
            (3016),(3017),(3018),(3019),(3020),
            (3021),(3022),(3023),(3024),(3025)
        ) AS n(PatientNum)
    )
),
ConditionsToAdd AS (
    SELECT
        PatientID,
        CASE
            WHEN PatientNum % 4 = 0 THEN 'Hypertension'
            WHEN PatientNum % 4 = 1 THEN 'Type 2 Diabetes'
            WHEN PatientNum % 4 = 2 THEN 'Asthma'
            ELSE 'High Cholesterol'
        END AS ConditionName,
        'Chronic' AS ConditionType,
        CAST('2025-03-15' AS DATE) AS DateDiagnosed
    FROM ExtraPatients
    WHERE PatientNum <= 3015

    UNION ALL

    SELECT
        PatientID,
        CASE
            WHEN PatientNum % 3 = 0 THEN 'Common Cold'
            WHEN PatientNum % 3 = 1 THEN 'Seasonal Flu'
            ELSE 'Sinus Infection'
        END,
        'Acute',
        CAST('2026-09-01' AS DATE)
    FROM ExtraPatients
    WHERE PatientNum >= 3010
)
INSERT INTO dbo.PatientCondition
(
    PatientID,
    ConditionName,
    ConditionType,
    IsHereditary,
    Severity,
    DateDiagnosed,
    DeletionFlag
)
SELECT
    c.PatientID,
    c.ConditionName,
    c.ConditionType,
    0,
    CASE
        WHEN c.ConditionType = 'Chronic'
            THEN 'Moderate'
        ELSE 'Low'
    END,
    c.DateDiagnosed,
    0
FROM ConditionsToAdd c
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.PatientCondition pc
    WHERE pc.PatientID = c.PatientID
      AND pc.ConditionName = c.ConditionName
      AND pc.ConditionType = c.ConditionType
);

-- 8. Payments and Payment Details



INSERT INTO dbo.Payment
(
    AppointmentID,
    InstallmentNumber,
    PaymentDate,
    PayStatus,
    DeletionFlag
)
SELECT
    a.AppointmentID,
    1,
    CAST(a.Date_Time AS DATE),
    CASE
        WHEN a.AppointmentID % 3 = 0
            THEN 'Pending'
        ELSE 'Completed'
    END,
    0
FROM dbo.Appointment a
JOIN dbo.Member m
    ON m.MemberID = a.PatientID
WHERE a.AppointStatus = 'Completed'
  AND m.Email IN (
      SELECT CONCAT('patient', n.PatientNum, '@example.com')
      FROM (VALUES
          (3001),(3002),(3003),(3004),(3005),
          (3006),(3007),(3008),(3009),(3010),
          (3011),(3012),(3013),(3014),(3015),
          (3016),(3017),(3018),(3019),(3020),
          (3021),(3022),(3023),(3024),(3025)
      ) AS n(PatientNum)
  )
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Payment pay
      WHERE pay.AppointmentID = a.AppointmentID
        AND pay.InstallmentNumber = 1
  );
  


INSERT INTO dbo.PaymentDetail
(
    PaymentID,
    MethodID,
    AmountApplied,
    DeletionFlag
)
SELECT
    pay.PaymentID,
    CASE
        WHEN a.AppointmentID % 2 = 0 THEN 2
        ELSE 1
    END,
    CASE
        WHEN a.AppointmentID % 3 = 1
            THEN a.TotalCost
        ELSE a.TotalCost * 0.50
    END,
    0
FROM dbo.Payment pay
JOIN dbo.Appointment a
    ON a.AppointmentID = pay.AppointmentID
JOIN dbo.Member m
    ON m.MemberID = a.PatientID
WHERE a.AppointStatus = 'Completed'
  AND pay.PayStatus = 'Completed'
  AND m.Email IN (
      SELECT CONCAT('patient', n.PatientNum, '@example.com')
      FROM (VALUES
          (3001),(3002),(3003),(3004),(3005),
          (3006),(3007),(3008),(3009),(3010),
          (3011),(3012),(3013),(3014),(3015),
          (3016),(3017),(3018),(3019),(3020),
          (3021),(3022),(3023),(3024),(3025)
      ) AS n(PatientNum)
  )
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.PaymentDetail pd
      WHERE pd.PaymentID = pay.PaymentID
  );

  





SELECT
    a.DoctorID,
    m.FirstName,
    m.LastName,
    a.Date_Time,
    COUNT(*) AS AppointmentCount
FROM dbo.Appointment a
JOIN dbo.Member m
    ON m.MemberID = a.DoctorID
WHERE m.Email IN (
    'david.chen@example.com',
    'priya.shah@example.com'
)
AND a.DeletionFlag = 0
AND a.AppointStatus <> 'Cancelled'
GROUP BY
    a.DoctorID,
    m.FirstName,
    m.LastName,
    a.Date_Time
HAVING COUNT(*) > 1;


