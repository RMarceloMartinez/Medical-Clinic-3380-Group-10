USE MedicalClinic;
GO

-- seed-logins.sql: gives a login to every active person who doesn't have one yet
-- (the extra doctors and nurses from seed-extra.sql, the sample patients, and anyone
-- an admin added without a login). Safe to run twice: people who already have an
-- account are skipped.
--
-- Username: first initial + last name, lowercase (David Chen -> dchen).
-- If that name is taken, the last 3 digits of their ID are added (dchen011).
-- Password for every new account: Clinic2026!  (same bcrypt hash as the seed accounts)

DECLARE @DemoHash VARCHAR(60) = '$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i';

WITH People AS (
    SELECT m.MemberID,
           LEFT(LOWER(LEFT(m.FirstName, 1)
                + REPLACE(REPLACE(REPLACE(m.LastName, ' ', ''), '''', ''), '-', '')), 20) AS BaseName,
           CASE
               WHEN EXISTS (SELECT 1 FROM dbo.Doctor AS d       WHERE d.DoctorID = m.MemberID AND d.DeletionFlag = 0) THEN 'Doctor'
               WHEN EXISTS (SELECT 1 FROM dbo.Nurse AS n        WHERE n.NurseID = m.MemberID AND n.DeletionFlag = 0) THEN 'Nurse'
               WHEN EXISTS (SELECT 1 FROM dbo.Receptionist AS r WHERE r.ReceptionistID = m.MemberID AND r.DeletionFlag = 0) THEN 'Receptionist'
               WHEN EXISTS (SELECT 1 FROM dbo.Patient AS p      WHERE p.PatientID = m.MemberID AND p.DeletionFlag = 0) THEN 'Patient'
           END AS Role
    FROM dbo.Member AS m
    WHERE m.DeletionFlag = 0
      AND NOT EXISTS (SELECT 1 FROM dbo.UserAccount AS ua WHERE ua.UserID = m.MemberID)
),
Named AS (
    SELECT MemberID, BaseName, Role,
           ROW_NUMBER() OVER (PARTITION BY BaseName ORDER BY MemberID) AS Nth
    FROM People
    WHERE Role IS NOT NULL
)
INSERT INTO dbo.UserAccount (UserID, Username, PasswordHash, LastLogin, Role, IsActive, DeletionFlag)
SELECT n.MemberID,
       CASE WHEN n.Nth = 1
                 AND NOT EXISTS (SELECT 1 FROM dbo.UserAccount AS ua WHERE ua.Username = n.BaseName)
            THEN n.BaseName
            ELSE n.BaseName + RIGHT(CAST(n.MemberID AS VARCHAR(7)), 3)
       END,
       @DemoHash, NULL, n.Role, 1, 0
FROM Named AS n;
GO

-- Every login that works now (password Clinic2026! for all of them, unless someone
-- made their own account through Sign up)
SELECT ua.Username, ua.Role, m.FirstName + ' ' + m.LastName AS Name,
       COALESCE(o.StreetAddress, '') AS NurseOffice
FROM dbo.UserAccount AS ua
JOIN dbo.Member AS m ON m.MemberID = ua.UserID
LEFT JOIN dbo.Nurse AS n ON n.NurseID = ua.UserID
LEFT JOIN dbo.Office AS o ON o.OfficeID = n.OfficeID
WHERE ua.IsActive = 1 AND ua.DeletionFlag = 0 AND m.DeletionFlag = 0
ORDER BY CASE ua.Role WHEN 'Admin' THEN 1 WHEN 'Receptionist' THEN 2 WHEN 'Doctor' THEN 3
                      WHEN 'Nurse' THEN 4 ELSE 5 END,
         ua.Username;
GO
