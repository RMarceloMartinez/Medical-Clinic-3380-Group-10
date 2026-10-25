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
        )
)

BEGIN
    ROLLBACK TRANSACTION;
        THROW 50001, 'The Doctor is not scheduled at this office that day', 1;
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
        THROW 50002, 'The Office is not open at that time', 1;
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
        ) > a.TotalCost
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
        ) > a.TotalCost
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
        ) > a.TotalCost
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50003,
            'Appointment cost cannot be less than completed payments.',
            1;
    END;
END;
GO
