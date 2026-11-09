USE MedicalClinic;
GO

CREATE OR ALTER TRIGGER TR_Appointment_DoctorSchedule 
ON dbo.Appointment 
AFTER INSERT, UPDATE 
AS 
BEGIN 
SET NOCOUNT ON;
    
    IF NOT(UPDATE(Date_Time) OR UPDATE(DoctorID) OR UPDATE(OfficeID) OR UPDATE(AppointStatus)) RETURN;

IF EXISTS(
    SELECT 1
    FROM inserted AS i
    WHERE i.AppointStatus <> 'Cancelled'
        AND NOT EXISTS (
            SELECT 1
            FROM DoctorSchedule as ds
            WHERE ds.DoctorID  = i.DoctorID
            AND ds.OfficeID = i.OfficeID
            AND ds.DayOfWeek = CHOOSE(DATEDIFF(DAY, '19000101', i.Date_Time) % 7 + 1,
                                                'Mon','Tue','Wed','Thu','Fri','Sat','Sun')
            AND ds.DeletionFlag = 0
        )
)

BEGIN
    ROLLBACK TRANSACTION;
        THROW 50001, 'This doctor doesn''t work at this office on that day. Pick another day or office.', 1;
    END;

    IF EXISTS(
        SELECT 1
        FROM inserted AS i 
        JOIN Office AS o ON o.OfficeID=i.OfficeID
        WHERE i.AppointStatus <> 'Cancelled'
        AND (CAST(i.Date_Time AS TIME) < o.OpeningTime 
        OR CAST(i.Date_Time AS TIME) >= o.ClosingTime)

    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50002, 'The office is closed at that time. Pick a time within its opening hours.', 1;
        END;
    END;
    GO

-- Trigger 2

-- New/edited payment 
CREATE OR ALTER TRIGGER dbo.TR_PaymentDetail_PreventOverpayment
ON dbo.PaymentDetail
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;

    IF EXISTS (
        SELECT 1
        FROM dbo.Appointment AS a WITH (UPDLOCK, HOLDLOCK)
        WHERE a.AppointmentID IN (
            SELECT p.AppointmentID
            FROM dbo.Payment AS p WITH (UPDLOCK, HOLDLOCK)
            INNER JOIN inserted AS i
                ON i.PaymentID = p.PaymentID
        )
        AND (
            SELECT COALESCE(SUM(pd.AmountApplied), 0)
            FROM dbo.Payment AS p WITH (UPDLOCK, HOLDLOCK)
            INNER JOIN dbo.PaymentDetail AS pd WITH (UPDLOCK, HOLDLOCK)
                ON pd.PaymentID = p.PaymentID
            WHERE p.AppointmentID = a.AppointmentID
              AND p.PayStatus = 'Completed'
              AND p.DeletionFlag = 0
              AND pd.DeletionFlag = 0
        ) > CASE
                WHEN a.AppointStatus = 'Cancelled'
                    THEN ISNULL(a.CancellationFee, 0)
                ELSE a.TotalCost
            END
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50003,
            'Completed payments cannot exceed the appointment total cost.',
            1;
    END;
END;
GO

-- Payment status and appointments reassignment
CREATE OR ALTER TRIGGER dbo.TR_Payment_PreventOverpayment
ON dbo.Payment
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;

    IF NOT (UPDATE(PayStatus) OR UPDATE(AppointmentID)) RETURN;

    IF EXISTS (
        SELECT 1
        FROM dbo.Appointment AS a WITH (UPDLOCK, HOLDLOCK)
        WHERE a.AppointmentID IN (
            SELECT AppointmentID
            FROM inserted
        )
        AND (
            SELECT COALESCE(SUM(pd.AmountApplied), 0)
            FROM dbo.Payment AS p WITH (UPDLOCK, HOLDLOCK)
            INNER JOIN dbo.PaymentDetail AS pd WITH (UPDLOCK, HOLDLOCK)
                ON pd.PaymentID = p.PaymentID
            WHERE p.AppointmentID = a.AppointmentID
              AND p.PayStatus = 'Completed'
              AND p.DeletionFlag = 0
              AND pd.DeletionFlag = 0
        ) > CASE
                WHEN a.AppointStatus = 'Cancelled'
                    THEN ISNULL(a.CancellationFee, 0)
                ELSE a.TotalCost
            END
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50003,
            'Completed payments cannot exceed the appointment total cost.',
            1;
    END;
END;
GO

-- Check changes in appointment
CREATE OR ALTER TRIGGER dbo.TR_Appointment_PreventOverpayment
ON dbo.Appointment
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;

    IF NOT UPDATE(TotalCost) RETURN;

    IF EXISTS (
        SELECT 1
        FROM dbo.Appointment AS a WITH (UPDLOCK, HOLDLOCK)
        WHERE a.AppointmentID IN (
            SELECT AppointmentID
            FROM inserted
        )
        AND (
            SELECT COALESCE(SUM(pd.AmountApplied), 0)
            FROM dbo.Payment AS p WITH (UPDLOCK, HOLDLOCK)
            INNER JOIN dbo.PaymentDetail AS pd WITH (UPDLOCK, HOLDLOCK)
                ON pd.PaymentID = p.PaymentID
            WHERE p.AppointmentID = a.AppointmentID
              AND p.PayStatus = 'Completed'
              AND p.DeletionFlag = 0
              AND pd.DeletionFlag = 0
        ) > CASE
                WHEN a.AppointStatus = 'Cancelled'
                    THEN ISNULL(a.CancellationFee, 0)
                ELSE a.TotalCost
            END
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50003,
            'Appointment cost cannot be less than completed payments.',
            1;
    END;
END;
GO

CREATE OR ALTER TRIGGER TR_Appointment_StatusTransition
ON dbo.Appointment
AFTER UPDATE
AS BEGIN
SET NOCOUNT ON;

    IF NOT(UPDATE(AppointStatus)) RETURN;

IF EXISTS(
    SELECT 1
    FROM deleted AS d
    JOIN inserted AS i ON i.AppointmentID = d.AppointmentID
    WHERE d.AppointStatus IN('Cancelled', 'Completed')
    AND i.AppointStatus <> d.AppointStatus
)
BEGIN 
    ROLLBACK TRANSACTION;
    THROW 50005, 'A completed or cancelled appointment cannot change status.', 1;
    END;
END;
GO

CREATE OR ALTER TRIGGER TR_Referral_IssuedByPrimary
ON dbo.Referral
AFTER INSERT, UPDATE
AS BEGIN
SET NOCOUNT ON;
    IF NOT(UPDATE(PatientID) OR UPDATE(PrimaryID)) RETURN;
IF EXISTS(
    SELECT 1
    FROM inserted AS i
    WHERE NOT EXISTS(
                SELECT 1
                FROM PatientDoctor AS pd 
                WHERE pd.PatientID = i.PatientID
                AND pd.DoctorID = i.PrimaryID
                AND pd.RolePlayed = 'Primary'
                AND pd.DeletionFlag = 0
              )
)
BEGIN 
    ROLLBACK TRANSACTION;
    THROW 50004, 'Only the patient''s primary doctor can issue a referral.', 1;
    END;
END;
GO

CREATE OR ALTER TRIGGER TR_Appointment_SpecialistReferral
ON dbo.Appointment
AFTER INSERT, UPDATE
AS BEGIN
SET NOCOUNT ON;
    IF NOT(UPDATE(PatientID) OR UPDATE(DoctorID) OR UPDATE(Date_Time) OR UPDATE(AppointStatus)) RETURN;
IF EXISTS(
    SELECT 1
    FROM inserted AS i
    WHERE i.AppointStatus <> 'Cancelled'
    AND NOT EXISTS (
                    SELECT 1
                    FROM PatientDoctor AS pd
                    WHERE i.PatientID = pd.PatientID
                    AND i.DoctorID = pd.DoctorID
                    AND pd.RolePlayed = 'Primary'
                    AND pd.DeletionFlag = 0
                    )
    AND NOT EXISTS (
                    SELECT 1
                    FROM Referral AS r
                    WHERE r.PatientID = i.PatientID
                    AND r.SpecialistID = i.DoctorID
                    AND r.RefStatus = 'Scheduled'
                    AND r.DateIssued <= CAST(i.Date_Time AS DATE)
                    )
)
BEGIN 
    ROLLBACK TRANSACTION;
    THROW 50006, 'Seeing a specialist requires a valid referral from the patient''s primary doctor.', 1;
    END;
END;
GO

CREATE OR ALTER TRIGGER TR_Payment_CancelledAppointment
ON dbo.Payment
AFTER INSERT, UPDATE
AS BEGIN
    SET NOCOUNT ON;

    IF NOT(UPDATE(PayStatus) OR UPDATE(AppointmentID)) RETURN;

IF EXISTS(
    SELECT 1
    FROM inserted AS i
    JOIN Appointment AS a ON a.AppointmentID = i.AppointmentID
    WHERE a.AppointStatus = 'Cancelled'
    AND ISNULL(a.CancellationFee, 0) = 0
    AND i.PayStatus <> 'Refunded'
)
BEGIN 
    ROLLBACK TRANSACTION;
    THROW 50007, 'A payment cannot be recorded for a cancelled appointment.', 1;
    END;
END;
GO

--Cannot mark completion before date of appt
CREATE OR ALTER TRIGGER dbo.TR_Appointment_PreventEarlyCompletion
ON dbo.Appointment
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT (UPDATE(AppointStatus) OR UPDATE(Date_Time)) RETURN;

    DECLARE @CentralNow DATETIME2 =
        CAST(
            SYSUTCDATETIME() AT TIME ZONE 'UTC'
            AT TIME ZONE 'Central Standard Time'
            AS DATETIME2
        );

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        WHERE i.AppointStatus = 'Completed'
          AND i.Date_Time > @CentralNow
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50008,
            'An appointment cannot be completed before its scheduled date and time.',
            1;
    END;
END;
GO

--Cannot delete a completed or paid appointment
CREATE OR ALTER TRIGGER dbo.TR_Appointment_PreventDeleteCompletedOrPaid
ON dbo.Appointment
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT (UPDATE(DeletionFlag)) RETURN;

    IF EXISTS (
        SELECT 1
        FROM deleted AS d
        JOIN inserted AS i ON i.AppointmentID = d.AppointmentID
        WHERE d.DeletionFlag = 0
          AND i.DeletionFlag = 1
          AND (    i.AppointStatus = 'Completed'
                OR EXISTS (SELECT 1
                           FROM dbo.Payment AS p
                           WHERE p.AppointmentID = i.AppointmentID
                             AND p.PayStatus = 'Completed'
                             AND p.DeletionFlag = 0))
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50009,
            'A completed or paid visit can''t be deleted, because it is part of the clinic''s records.',
            1;
    END;
END;
GO
-- R5: $25 late-cancellation/no show fee
CREATE OR ALTER TRIGGER dbo.TR_Appointment_LateCancelFee
ON dbo.Appointment
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(AppointStatus) RETURN;

    -- Central time
    DECLARE @CentralNow DATETIME2 =
        CAST(
            SYSUTCDATETIME() AT TIME ZONE 'UTC'
            AT TIME ZONE 'Central Standard Time'
            AS DATETIME2
        );

    UPDATE a
    SET CancellationFee = 25.00
    FROM dbo.Appointment AS a
    INNER JOIN inserted AS i
        ON i.AppointmentID = a.AppointmentID
    INNER JOIN deleted AS d
        ON d.AppointmentID = i.AppointmentID
    WHERE d.AppointStatus = 'Scheduled'
        AND i.AppointStatus = 'Cancelled'
        AND ISNULL(i.CancelledBy, '') <> 'Doctor'
        -- under 24 h away, or already past (a no-show)
        AND i.Date_Time < DATEADD(HOUR, 24, @CentralNow);
END;
GO