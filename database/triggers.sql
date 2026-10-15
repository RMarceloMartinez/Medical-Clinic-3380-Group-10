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

