
USE MedicalClinic;
GO

-- Query 1: Doctor's appointments for a selected week

DECLARE @DoctorID INT = 1000000;
DECLARE @WeekStart DATE = '2026-10-05';

SELECT
    a.AppointmentID,
    a.Date_Time,
    a.AppointStatus,
    m.FirstName AS PatientFirstName,
    m.LastName AS PatientLastName,
    o.StreetAddress AS OfficeAddress,
    a.Channel,
    a.TotalCost
FROM dbo.Appointment a
INNER JOIN dbo.Patient p
    ON a.PatientID = p.PatientID
INNER JOIN dbo.Member m
    ON p.PatientID = m.MemberID
INNER JOIN dbo.Office o
    ON a.OfficeID = o.OfficeID
WHERE a.DoctorID = @DoctorID
  AND a.Date_Time >= @WeekStart
  AND a.Date_Time < DATEADD(DAY, 7, @WeekStart)
ORDER BY a.Date_Time;



-- REPORT 1: Revenue Per Office

SELECT
    o.OfficeID,
    o.StreetAddress,
    o.City,
    o.State,
    COUNT(DISTINCT CASE
        WHEN p.PayStatus = 'Completed'
        THEN a.AppointmentID
    END) AS PaidAppointments,
    COALESCE(SUM(CASE
        WHEN p.PayStatus = 'Completed'
        THEN pd.AmountApplied
        ELSE 0
    END), 0) AS TotalRevenue
FROM dbo.Office o
LEFT JOIN dbo.Appointment a
    ON o.OfficeID = a.OfficeID
LEFT JOIN dbo.Payment p
    ON a.AppointmentID = p.AppointmentID
LEFT JOIN dbo.PaymentDetail pd
    ON p.PaymentID = pd.PaymentID
GROUP BY
    o.OfficeID,
    o.StreetAddress,
    o.City,
    o.State
ORDER BY TotalRevenue DESC;


-- REPORT 2: Appointment Activity

SELECT
    o.OfficeID,
    o.StreetAddress,
    COUNT(a.AppointmentID) AS TotalAppointments,
    SUM(CASE
        WHEN a.AppointStatus = 'Completed'
        THEN 1 ELSE 0
    END) AS CompletedAppointments,
    SUM(CASE
        WHEN a.AppointStatus = 'Scheduled'
        THEN 1 ELSE 0
    END) AS ScheduledAppointments,
    SUM(CASE
        WHEN a.AppointStatus = 'Cancelled'
        THEN 1 ELSE 0
    END) AS CancelledAppointments
FROM dbo.Office o
LEFT JOIN dbo.Appointment a
    ON o.OfficeID = a.OfficeID
GROUP BY
    o.OfficeID,
    o.StreetAddress
ORDER BY o.OfficeID;


-- REPORT 3: Patient Health Summary

SELECT
    p.PatientID,
    m.FirstName,
    m.LastName,
    m.DateOfBirth,
    (
        SELECT COUNT(*)
        FROM dbo.Appointment a
        WHERE a.PatientID = p.PatientID
    ) AS TotalAppointments,
    (
        SELECT STRING_AGG(
            CAST(pc.ConditionName AS VARCHAR(MAX)), ', '
        )
        FROM dbo.PatientCondition pc
        WHERE pc.PatientID = p.PatientID
    ) AS MedicalConditions,
    (
        SELECT STRING_AGG(
            CAST(al.Allergen AS VARCHAR(MAX)), ', '
        )
        FROM dbo.Allergy al
        WHERE al.PatientID = p.PatientID
    ) AS Allergies,
    (
        SELECT MAX(a.Date_Time)
        FROM dbo.Appointment a
        WHERE a.PatientID = p.PatientID
          AND a.AppointStatus = 'Completed'
    ) AS LastCompletedVisit
FROM dbo.Patient p
INNER JOIN dbo.Member m
    ON p.PatientID = m.MemberID
ORDER BY m.LastName, m.FirstName;

