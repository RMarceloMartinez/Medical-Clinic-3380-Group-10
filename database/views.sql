USE MedicalClinic
GO

CREATE OR ALTER VIEW vw_DoctorWeeklySchedule
AS
SELECT ds.DoctorID,
    m.FirstName + ' ' + m.LastName AS DoctorName,
    ds.OfficeID,
    o.StreetAddress AS Office,
    ds.DayOfWeek AS DayName,
    (CHARINDEX(ds.DayOfWeek, 'MonTueWedThuFriSatSun') + 2) / 3 AS DayNumber
FROM DoctorSchedule AS ds
JOIN Member AS m ON m.MemberID = ds.DoctorID
JOIN Office AS o ON o.OfficeID = ds.OfficeID
WHERE ds.DeletionFlag = 0
  AND m.DeletionFlag = 0
  AND o.DeletionFlag = 0;
GO

-- Office schedule page (staff pick an office)
SELECT DayName, DoctorName
FROM vw_DoctorWeeklySchedule
WHERE OfficeID = 1000000
ORDER BY DayNumber, DoctorName;

-- My schedule page (logged-in doctor; the backend passes their own ID)
SELECT DayName, Office
FROM vw_DoctorWeeklySchedule
WHERE DoctorID = 1000000
ORDER BY DayNumber;