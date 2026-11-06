USE MedicalClinic;
GO

-- REPORT 1: CHRONIC VS ACUTE CONDITIONS


CREATE OR ALTER VIEW dbo.vw_HealthConditionSummary
AS
SELECT
    pc.ConditionType,
    COUNT(*) AS TotalConditions,
    COUNT(DISTINCT pc.PatientID) AS PatientsAffected,
    SUM(
        CASE WHEN pc.IsHereditary = 1 THEN 1 ELSE 0 END
    ) AS HereditaryConditions
FROM dbo.PatientCondition AS pc
INNER JOIN dbo.Patient AS p
    ON p.PatientID = pc.PatientID
INNER JOIN dbo.Member AS m
    ON m.MemberID = p.PatientID
WHERE pc.DeletionFlag = 0
  AND p.DeletionFlag = 0
  AND m.DeletionFlag = 0
GROUP BY pc.ConditionType;
GO

-- REPORT 2: MOST COMMON PATIENT CONDITIONS


CREATE OR ALTER VIEW dbo.vw_CommonHealthConditions
AS
SELECT
    pc.ConditionName,
    pc.ConditionType,
    COUNT(*) AS TotalCases,
    COUNT(DISTINCT pc.PatientID) AS PatientsAffected,
    SUM(
        CASE WHEN pc.Severity = 'Severe'
        THEN 1 ELSE 0 END
    ) AS SevereCases,
    SUM(
        CASE WHEN pc.IsHereditary = 1
        THEN 1 ELSE 0 END
    ) AS HereditaryCases
FROM dbo.PatientCondition AS pc
INNER JOIN dbo.Patient AS p
    ON p.PatientID = pc.PatientID
INNER JOIN dbo.Member AS m
    ON m.MemberID = p.PatientID
WHERE pc.DeletionFlag = 0
  AND p.DeletionFlag = 0
  AND m.DeletionFlag = 0
GROUP BY
    pc.ConditionName,
    pc.ConditionType;
GO

-- REPORT 3: MONTHLY DIAGNOSIS TRENDS


CREATE OR ALTER VIEW dbo.vw_MonthlyDiagnosisTrends
AS
SELECT
    YEAR(a.Date_Time) AS DiagnosisYear,
    MONTH(a.Date_Time) AS DiagnosisMonth,
    DATEFROMPARTS(
        YEAR(a.Date_Time),
        MONTH(a.Date_Time),
        1
    ) AS MonthStart,
    d.DiagnosisType,
    COUNT(*) AS TotalDiagnoses,
    COUNT(DISTINCT a.PatientID) AS PatientsDiagnosed
FROM dbo.Diagnosis AS d
INNER JOIN dbo.MedicalRecord AS mr
    ON mr.RecordID = d.RecordID
INNER JOIN dbo.Appointment AS a
    ON a.AppointmentID = mr.AppointmentID
INNER JOIN dbo.Patient AS p
    ON p.PatientID = a.PatientID
WHERE d.DeletionFlag = 0
  AND mr.DeletionFlag = 0
  AND a.DeletionFlag = 0
  AND p.DeletionFlag = 0
  AND a.AppointStatus = 'Completed'
GROUP BY
    YEAR(a.Date_Time),
    MONTH(a.Date_Time),
    d.DiagnosisType;
GO


-- REPORT 4: PATIENT HEALTH HISTORY


CREATE OR ALTER VIEW dbo.vw_PatientHealthTrends
AS
SELECT
    pc.PatientID,
    m.FirstName,
    m.LastName,
    pc.ConditionName,
    pc.ConditionType,
    pc.Severity,
    pc.IsHereditary,
    pc.DateDiagnosed
FROM dbo.PatientCondition AS pc
INNER JOIN dbo.Patient AS p
    ON p.PatientID = pc.PatientID
INNER JOIN dbo.Member AS m
    ON m.MemberID = pc.PatientID
WHERE pc.DeletionFlag = 0
  AND p.DeletionFlag = 0
  AND m.DeletionFlag = 0;
GO

-- PROCEDURE 1: CONDITION SUMMARY


CREATE OR ALTER PROCEDURE dbo.usp_GetHealthConditionSummary
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ConditionType,
        TotalConditions,
        PatientsAffected,
        HereditaryConditions
    FROM dbo.vw_HealthConditionSummary
    ORDER BY TotalConditions DESC;
END;
GO

-- PROCEDURE 2: MOST COMMON CONDITIONS


CREATE OR ALTER PROCEDURE dbo.usp_GetCommonHealthConditions
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ConditionName,
        ConditionType,
        TotalCases,
        PatientsAffected,
        SevereCases,
        HereditaryCases
    FROM dbo.vw_CommonHealthConditions
    ORDER BY
        TotalCases DESC,
        ConditionName ASC;
END;
GO


-- PROCEDURE 3: MONTHLY DIAGNOSIS TRENDS


CREATE OR ALTER PROCEDURE dbo.usp_GetMonthlyDiagnosisTrends
    @FromDate DATE,
    @ToDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @FromDate IS NULL
       OR @ToDate IS NULL
       OR @FromDate > @ToDate
    BEGIN
        THROW 50020, 'Invalid report date range.', 1;
    END;

    SELECT
        DiagnosisYear,
        DiagnosisMonth,
        MonthStart,
        DiagnosisType,
        TotalDiagnoses,
        PatientsDiagnosed
    FROM dbo.vw_MonthlyDiagnosisTrends
    WHERE MonthStart >= DATEFROMPARTS(
        YEAR(@FromDate), MONTH(@FromDate), 1
    )
      AND MonthStart <= DATEFROMPARTS(
        YEAR(@ToDate), MONTH(@ToDate), 1
    )
    ORDER BY MonthStart, DiagnosisType;
END;
GO

-- PROCEDURE 4: INDIVIDUAL PATIENT HEALTH TRENDS

CREATE OR ALTER PROCEDURE dbo.usp_GetPatientHealthTrends
    @PatientID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        PatientID,
        FirstName,
        LastName,
        ConditionName,
        ConditionType,
        Severity,
        IsHereditary,
        DateDiagnosed
    FROM dbo.vw_PatientHealthTrends
    WHERE PatientID = @PatientID
    ORDER BY DateDiagnosed DESC, ConditionName;
END;
GO


-- PROCEDURE 5: HEALTH TRENDS DASHBOARD
--
-- Returns three result sets:
-- 1. Chronic vs acute conditions
-- 2. Most common conditions
-- 3. Monthly diagnoses


CREATE OR ALTER PROCEDURE dbo.usp_GetHealthTrendsDashboard
    @FromDate DATE,
    @ToDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @FromDate IS NULL
       OR @ToDate IS NULL
       OR @FromDate > @ToDate
    BEGIN
        THROW 50021, 'Invalid dashboard date range.', 1;
    END;

    -- Result set 1: condition types
    SELECT
        ConditionType,
        TotalConditions,
        PatientsAffected,
        HereditaryConditions
    FROM dbo.vw_HealthConditionSummary
    ORDER BY TotalConditions DESC;

    -- Result set 2: most common conditions
    SELECT
        TOP (10)
        ConditionName,
        ConditionType,
        TotalCases,
        PatientsAffected,
        SevereCases,
        HereditaryCases
    FROM dbo.vw_CommonHealthConditions
    ORDER BY TotalCases DESC, ConditionName;

    -- Result set 3: monthly diagnosis trends
    SELECT
        DiagnosisYear,
        DiagnosisMonth,
        MonthStart,
        DiagnosisType,
        TotalDiagnoses,
        PatientsDiagnosed
    FROM dbo.vw_MonthlyDiagnosisTrends
    WHERE MonthStart >= DATEFROMPARTS(
        YEAR(@FromDate), MONTH(@FromDate), 1
    )
      AND MonthStart <= DATEFROMPARTS(
        YEAR(@ToDate), MONTH(@ToDate), 1
    )
    ORDER BY MonthStart, DiagnosisType;
END;
GO