
-- reports.sql: report views and refresh procedures
USE MedicalClinic;
GO

-- R2 base: one row per appointment
CREATE OR ALTER VIEW vw_AppointmentActivity
AS
SELECT a.AppointmentID,
       a.DoctorID,
       m.FirstName     AS DoctorFirstName,
       m.LastName      AS DoctorLastName,
       a.OfficeID,
       o.StreetAddress AS OfficeStreetAddress,
       a.Date_Time,
       a.AppointStatus,
       a.CancelledBy
FROM Appointment AS a
JOIN Member AS m ON m.MemberID = a.DoctorID
JOIN Office AS o ON o.OfficeID = a.OfficeID
WHERE a.DeletionFlag = 0
  AND m.DeletionFlag = 0
  AND o.DeletionFlag = 0;
GO

CREATE OR ALTER PROCEDURE usp_RefreshAppointmentActivityReport
    @FromDate DATE,
    @ToDate DATE
AS BEGIN
    SET NOCOUNT ON;

    DELETE FROM AppointmentActivityReport;

    INSERT INTO AppointmentActivityReport
                (DoctorID, DoctorFirstName, DoctorLastName, OfficeID, OfficeStreetAddress,
                FromDate, ToDate, TotalAppointments, Scheduled, Completed, Cancelled,
                CancelledByPatient, CancelledByDoctor, CancelledByStaff,
                CancellationRate, DeletionFlag)
    
    Select DoctorID, DoctorFirstName, DoctorLastName, OfficeID, OfficeStreetAddress,
           @FromDate, @ToDate,
           COUNT(*),
           SUM(CASE WHEN AppointStatus = 'Scheduled' THEN 1 ELSE 0 END),
           SUM(CASE WHEN AppointStatus = 'Completed'      THEN 1 ELSE 0 END),
           SUM(CASE WHEN AppointStatus = 'Cancelled'      THEN 1 ELSE 0 END),
           SUM(CASE WHEN CancelledBy = 'Patient' THEN 1 ELSE 0 END),
           SUM(CASE WHEN CancelledBy = 'Doctor'    THEN 1 ELSE 0 END),
           SUM(CASE WHEN CancelledBy = 'Staff'    THEN 1 ELSE 0 END),
           CAST(100.0 * SUM(CASE WHEN AppointStatus = 'Cancelled' THEN 1 ELSE 0 END)
                / COUNT(*) AS NUMERIC(5,2)),
            0
    
    FROM vw_AppointmentActivity
    WHERE Date_Time >= @FromDate
      AND Date_Time <  DATEADD(DAY, 1, @ToDate)
    GROUP BY DoctorID, DoctorFirstName, DoctorLastName, OfficeID, OfficeStreetAddress;
END;
GO

-- Test: refresh, then read the table like the page will
EXEC usp_RefreshAppointmentActivityReport @FromDate = '2026-07-01', @ToDate = '2026-10-31';
SELECT DoctorFirstName, DoctorLastName, OfficeStreetAddress,
       TotalAppointments, Scheduled, Completed, Cancelled, CancellationRate
FROM AppointmentActivityReport
ORDER BY DoctorLastName;
GO

CREATE OR ALTER VIEW vw_OfficeBilling
AS
SELECT a.OfficeID, o.StreetAddress AS OfficeStreetAddress, a.Date_Time, a.TotalCost
FROM Appointment AS a
JOIN Office AS o ON o.OfficeID = a.OfficeID
WHERE a.AppointStatus = 'Completed'
AND a.DeletionFlag = 0
AND o.DeletionFlag = 0;

GO

CREATE OR ALTER VIEW vw_OfficePayments
AS
SELECT a.OfficeID, a.Date_Time, p.PayStatus, pm.MethodName, pd.AmountApplied 
FROM PaymentDetail AS pd
JOIN Payment AS p ON p.PaymentID = pd.PaymentID
JOIN Appointment AS a ON a.AppointmentID = p.AppointmentID
JOIN PaymentMethod AS pm ON pm.MethodID = pd.MethodID
WHERE pd.DeletionFlag = 0
AND p.DeletionFlag = 0
AND a.DeletionFlag = 0;

GO

CREATE OR ALTER PROCEDURE usp_RefreshOfficeRevenueReport
  @FromDate DATE,
  @ToDate DATE
AS BEGIN
    SET NOCOUNT ON;
    DELETE FROM OfficeRevenueReport;;

    WITH Billing AS (
        SELECT OfficeID, OfficeStreetAddress,
        Count(*) AS CompletedVisits,
        SUM(TotalCost) AS Billed
        FROM vw_OfficeBilling
        WHERE Date_Time >= @FromDate AND Date_Time < DATEADD(DAY, 1, @ToDate)
        GROUP BY OfficeID, OfficeStreetAddress
    ),
    Paid AS(
      SELECT OfficeID,
               SUM(CASE WHEN PayStatus = 'Completed' THEN AmountApplied ELSE 0 END) AS Collected,
               SUM(CASE WHEN PayStatus = 'Refunded'      THEN AmountApplied ELSE 0 END) AS Refunded,
               SUM(CASE WHEN PayStatus = 'Completed' AND MethodName = 'Cash'        THEN AmountApplied ELSE 0 END) AS CashCollected,
               SUM(CASE WHEN PayStatus = 'Completed' AND MethodName = 'Credit Card'        THEN AmountApplied ELSE 0 END) AS CreditCardCollected,
               SUM(CASE WHEN PayStatus = 'Completed' AND MethodName = 'Debit Card'        THEN AmountApplied ELSE 0 END) AS DebitCardCollected,
               SUM(CASE WHEN PayStatus = 'Completed' AND MethodName = 'Insurance'        THEN AmountApplied ELSE 0 END) AS InsuranceCollected,
               SUM(CASE WHEN PayStatus = 'Completed' AND MethodName = 'Check'        THEN AmountApplied ELSE 0 END) AS CheckCollected
        FROM vw_OfficePayments
        WHERE Date_Time >= @FromDate AND Date_Time < DATEADD(DAY, 1, @ToDate)
        GROUP BY OfficeID
    )
    INSERT INTO OfficeRevenueReport
                (OfficeID, OfficeStreetAddress, FromDate, ToDate, CompletedVisits,
                Billed, Collected, Refunded, Outstanding,
                CashCollected, CreditCardCollected, DebitCardCollected,
                InsuranceCollected, CheckCollected, DeletionFlag
                )
    SELECT b.OfficeID, b.OfficeStreetAddress, @FromDate, @ToDate, b.CompletedVisits, 
          b.Billed,
          ISNULL(p.Collected,0),
          ISNULL(p.Refunded,0),
          b.Billed - ISNULL(p.Collected, 0),
          ISNULL(p.CashCollected, 0),
          ISNULL(p.CreditCardCollected, 0),
          ISNULL(p.DebitCardCollected, 0),
          ISNULL(p.InsuranceCollected, 0),
          ISNULL(p.CheckCollected, 0),
          0
    FROM Billing AS b
    LEFT JOIN Paid AS p ON p.OfficeID = b.OfficeID;
END;
GO

EXEC usp_RefreshOfficeRevenueReport @FromDate = '2026-07-01', @ToDate = '2026-10-31';
SELECT OfficeStreetAddress, CompletedVisits, Billed, Collected, Refunded, Outstanding,
       CashCollected, CreditCardCollected
FROM OfficeRevenueReport
ORDER BY OfficeID;

GO

CREATE OR ALTER VIEW  vw_PatientVisitPayments
AS
SELECT a.AppointmentID, a.PatientID, m.FirstName, m.LastName, m.Phone,
      a.Date_Time, a.TotalCost, ISNULL(SUM(pd.AmountApplied), 0)  AS Paid

FROM Appointment AS a
JOIN Member AS m ON m.MemberID = a.PatientID
LEFT JOIN Payment AS p ON p.AppointmentID = a.AppointmentID
AND p.PayStatus = 'Completed' AND p.DeletionFlag = 0
LEFT JOIN PaymentDetail AS pd ON pd.PaymentID = p.PaymentID AND pd.DeletionFlag = 0
WHERE a.AppointStatus = 'Completed' AND a.DeletionFlag = 0 AND m.DeletionFlag = 0
GROUP BY a.AppointmentID, a.PatientID, m.FirstName, m.LastName, m.Phone,
         a.Date_Time, a.TotalCost;

GO

CREATE OR ALTER PROCEDURE usp_RefreshOutstandingBalanceReport
AS BEGIN
    SET NOCOUNT ON;

    DELETE FROM OutstandingBalanceReport;

    INSERT INTO OutstandingBalanceReport 
                (
                 PatientID, PatientFirstName, PatientLastName, Phone,
                 UnpaidVisits, OldestUnpaidVisit, Billed,
                 Paid, Balance, DeletionFlag
                 )
    SELECT v.PatientID, v.FirstName, v.LastName, v.Phone,
          SUM(CASE WHEN v.Paid < v.TotalCost THEN 1 ELSE 0 END),
          MIN(CASE WHEN v.Paid < v.TotalCost THEN CAST(v.Date_Time AS DATE) END),
          SUM(v.TotalCost),
          SUM(v.Paid),
          SUM(v.TotalCost) - SUM(v.Paid),
          0
    FROM vw_PatientVisitPayments AS v
    GROUP BY v.PatientID, v.FirstName, v.LastName, v.Phone
    HAVING SUM(v.TotalCost) - SUM(v.Paid) > 0;
END;
GO

EXEC usp_RefreshOutstandingBalanceReport;
SELECT * FROM OutstandingBalanceReport ORDER BY Balance DESC;

GO

CREATE OR ALTER VIEW vw_ReferralVisits
AS
SELECT r.ReferralID, r.SpecialistID, m.FirstName AS SpecialistFirstName,
      m.LastName AS SpecialistLastName, d.Specialty AS Specialty,
      r.DateIssued, r.RefStatus,
      CASE WHEN EXISTS(SELECT 1
                       FROM Appointment AS a
                       WHERE a.ReferralID = r.ReferralID
                       AND a.AppointStatus <> 'Cancelled'
                       AND a.DeletionFlag = 0
                      )
      THEN 1 ELSE 0 END AS LedToVisit   
FROM Referral AS r
JOIN Member AS m ON m.MemberID = r.SpecialistID
JOIN Doctor AS d ON d.DoctorID = r.SpecialistID
WHERE r.DeletionFlag = 0
AND m.DeletionFlag = 0
AND d.DeletionFlag = 0;

GO

CREATE OR ALTER PROCEDURE usp_RefreshReferralTrackingReport
AS BEGIN
  SET NOCOUNT ON;
  DELETE FROM ReferralTrackingReport;

  INSERT INTO ReferralTrackingReport(
              SpecialistID, SpecialistFirstName, SpecialistLastName, Specialty,
              TotalReferrals, OpenReferrals, FinishedReferrals, CancelledReferrals,
              ReferralsWithVisit, DeletionFlag
              )
  SELECT SpecialistID, SpecialistFirstName, SpecialistLastName, Specialty,
        COUNT(*),
        SUM(CASE WHEN RefStatus = 'Scheduled' THEN 1 ELSE 0 END),
        SUM(CASE WHEN RefStatus = 'Finished'  THEN 1 ELSE 0 END),
        SUM(CASE WHEN RefStatus = 'Cancelled' THEN 1 ELSE 0 END),
        SUM(LedToVisit),
        0
  FROM vw_ReferralVisits
  GROUP BY SpecialistID, SpecialistFirstName, SpecialistLastName, Specialty;
END;
GO
EXEC usp_RefreshReferralTrackingReport;
SELECT * FROM ReferralTrackingReport ORDER BY SpecialistLastName;
GO

CREATE OR ALTER VIEW vw_PatientHealthItems
AS
SELECT pc.PatientID, 'Condition' AS Category, pc.ConditionName AS ItemName,
      CONCAT_WS(', ', pc.ConditionType, pc.Severity,
                CASE WHEN pc.IsHereditary = 1 THEN 'Hereditary' END) AS Detail,
      pc.DateDiagnosed AS ItemDate
FROM PatientCondition as pc
WHERE   pc.DeletionFlag = 0

UNION ALL

SELECT al.PatientID, 'Allergy', al.Allergen,
      CONCAT_WS(', ', al.Severity, al.ReactionType),
      al.DateIdentified
FROM Allergy AS al
WHERE al.DeletionFlag = 0

UNION ALL
SELECT a.PatientID, 'Diagnosis', d.DiagnosisDescription,
       d.DiagnosisType,
       CAST(a.Date_Time AS DATE)
FROM Diagnosis AS d
JOIN MedicalRecord AS mr ON mr.RecordID = d.RecordID
JOIN Appointment   AS a  ON a.AppointmentID = mr.AppointmentID
WHERE d.DeletionFlag = 0 AND mr.DeletionFlag = 0 AND a.DeletionFlag = 0

UNION ALL

SELECT a.PatientID, 'Prescription', p.MedicationName,
       CONCAT_WS(', ', p.Dosage, p.Frequency, p.Duration),
       CAST(a.Date_Time AS DATE)
FROM Prescription AS p
JOIN MedicalRecord AS mr ON mr.RecordID = p.RecordID
JOIN Appointment   AS a  ON a.AppointmentID = mr.AppointmentID
WHERE p.DeletionFlag = 0 AND mr.DeletionFlag = 0 AND a.DeletionFlag = 0;
GO

CREATE OR ALTER PROCEDURE usp_RefreshPatientHealthSummaryReport
    @PatientID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM PatientHealthSummaryReport;

    INSERT INTO PatientHealthSummaryReport
        (PatientID, PatientFirstName, PatientLastName,
         Category, ItemName, Detail, ItemDate, DeletionFlag)
    SELECT v.PatientID, m.FirstName, m.LastName,
           v.Category, v.ItemName, v.Detail, v.ItemDate, 0
    FROM vw_PatientHealthItems AS v
    JOIN Member AS m ON m.MemberID = v.PatientID
    WHERE v.PatientID = @PatientID
      AND m.DeletionFlag = 0;
END;
GO

EXEC usp_RefreshPatientHealthSummaryReport @PatientID = 1000002;   -- Emily
SELECT Category, ItemName, Detail, ItemDate
FROM PatientHealthSummaryReport
ORDER BY Category, ItemDate DESC;
GO


-- R3: Visit details behind every report
-- One row per visit with all its data: who, where, status, money, diagnoses
CREATE OR ALTER VIEW vw_VisitDetails
AS
SELECT a.AppointmentID,
       a.Date_Time,
       a.PatientID,
       pm.FirstName AS PatientFirstName,
       pm.LastName  AS PatientLastName,
       dm.FirstName AS DoctorFirstName,
       dm.LastName  AS DoctorLastName,
       d.Specialty,
       o.StreetAddress AS OfficeStreetAddress,
       a.AppointStatus,
       a.CancelledBy,
       a.TotalCost,
       a.CancellationFee,
       ISNULL((SELECT SUM(pd.AmountApplied)              -- completed payments on THIS visit
               FROM Payment AS p
               JOIN PaymentDetail AS pd ON pd.PaymentID = p.PaymentID
               WHERE p.AppointmentID = a.AppointmentID
                 AND p.PayStatus = 'Completed'
                 AND p.DeletionFlag = 0
                 AND pd.DeletionFlag = 0), 0) AS AmountPaid,
       (SELECT LEFT(STRING_AGG(CAST(dg.DiagnosisDescription AS VARCHAR(MAX)), '; ')
                    WITHIN GROUP (ORDER BY dg.DiagnosisType, dg.DiagnosisID), 2000)
        FROM MedicalRecord AS mr
        JOIN Diagnosis AS dg ON dg.RecordID = mr.RecordID
        WHERE mr.AppointmentID = a.AppointmentID
          AND mr.DeletionFlag = 0
          AND dg.DeletionFlag = 0) AS Diagnoses     -- NULL when the visit has none
FROM Appointment AS a
JOIN Member AS pm ON pm.MemberID = a.PatientID
JOIN Member AS dm ON dm.MemberID = a.DoctorID
JOIN Doctor AS d  ON d.DoctorID  = a.DoctorID
JOIN Office AS o  ON o.OfficeID  = a.OfficeID
WHERE a.DeletionFlag = 0
  AND dm.DeletionFlag = 0
  AND o.DeletionFlag = 0;                            -- same filters as vw_AppointmentActivity
GO

-- Fills VisitDetailsReport for a date range and/or one patient (NULL = no filter)
CREATE OR ALTER PROCEDURE usp_RefreshVisitDetailsReport
    @FromDate DATE,
    @ToDate DATE,
    @PatientID INT
AS BEGIN
    SET NOCOUNT ON;
    DELETE FROM VisitDetailsReport;

    INSERT INTO VisitDetailsReport
        (AppointmentID, VisitDateTime, PatientID, PatientFirstName, PatientLastName,
         DoctorFirstName, DoctorLastName, Specialty, OfficeStreetAddress,
         AppointStatus, CancelledBy, TotalCost, AmountPaid, CancellationFee,
         Diagnoses, DeletionFlag)
    SELECT AppointmentID, Date_Time, PatientID, PatientFirstName, PatientLastName,
           DoctorFirstName, DoctorLastName, Specialty, OfficeStreetAddress,
           AppointStatus, CancelledBy, TotalCost, AmountPaid, CancellationFee,
           Diagnoses, 0
    FROM vw_VisitDetails
    WHERE (@PatientID IS NULL OR PatientID = @PatientID)
      AND (@FromDate IS NULL OR Date_Time >= @FromDate)
      AND (@ToDate IS NULL OR Date_Time < DATEADD(DAY, 1, @ToDate));
END;
GO

-- Test: the visit count here should match the activity report's total for the same range
EXEC usp_RefreshVisitDetailsReport @FromDate = '2026-07-01', @ToDate = '2026-12-31', @PatientID = NULL;
SELECT COUNT(*) AS Visits,
       SUM(CASE WHEN AppointStatus = 'Completed' THEN 1 ELSE 0 END) AS Completed
FROM VisitDetailsReport;
GO
