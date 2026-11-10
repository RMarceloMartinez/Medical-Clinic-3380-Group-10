-- seed-round3-weeks.sql (Tue Nov 10): booked visits on every day each doctor works,
-- Wed Nov 11 through Wed Nov 25 (no Thanksgiving week Thu/Fri), so "Doctor's week" shows several days.
-- Each visit goes with a patient whose primary doctor it is, or (for a specialist) a patient who gets
-- a referral from their own primary doctor, as the business rules require.
-- Patients used in the demo script are left alone. Safe to run twice: slots that are taken are skipped.
-- One transaction: if any business rule refuses a row, nothing is saved.
-- Azure: sqlcmd ... -d MedicalClinic -b -i database\seed-round3-weeks.sql

SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;

DECLARE @Days TABLE (D DATE PRIMARY KEY);
INSERT INTO @Days VALUES ('2026-11-11'), ('2026-11-12'), ('2026-11-13'),
                         ('2026-11-16'), ('2026-11-17'), ('2026-11-18'), ('2026-11-19'), ('2026-11-20'),
                         ('2026-11-23'), ('2026-11-24'), ('2026-11-25');

-- Patients we may book: the sample patients, minus the ones the demo script uses
DECLARE @Pool TABLE (N INT IDENTITY(1,1), PatientID INT, PrimaryID INT);
INSERT INTO @Pool (PatientID, PrimaryID)
SELECT p.PatientID, pd.DoctorID
FROM dbo.Patient AS p
JOIN dbo.Member AS m ON m.MemberID = p.PatientID AND m.DeletionFlag = 0
JOIN dbo.PatientDoctor AS pd ON pd.PatientID = p.PatientID AND pd.RolePlayed = 'Primary' AND pd.DeletionFlag = 0
WHERE m.Email LIKE 'patient30%@example.com'
  AND m.Email NOT IN ('patient3001@example.com', 'patient3002@example.com', 'patient3005@example.com',
                      'patient3009@example.com', 'patient3019@example.com', 'patient3023@example.com')
ORDER BY p.PatientID;
DECLARE @PoolSize INT = (SELECT COUNT(*) FROM @Pool);

-- Every (day, doctor, office) the doctor works
DECLARE @Slots TABLE (S INT IDENTITY(1,1), D DATE, DoctorID INT, OfficeID INT, Specialty VARCHAR(30),
                      IsPrimaryCare BIT, Fee NUMERIC(10,2));
INSERT INTO @Slots (D, DoctorID, OfficeID, Specialty, IsPrimaryCare, Fee)
SELECT dy.D, ds.DoctorID, ds.OfficeID, d.Specialty, sp.IsPrimaryCare, sp.VisitFee
FROM @Days AS dy
JOIN dbo.DoctorSchedule AS ds
  ON ds.DayOfWeek = CHOOSE(DATEDIFF(DAY, '19000101', dy.D) % 7 + 1, 'Mon','Tue','Wed','Thu','Fri','Sat','Sun')
 AND ds.DeletionFlag = 0
JOIN dbo.Doctor AS d ON d.DoctorID = ds.DoctorID AND d.DeletionFlag = 0
JOIN dbo.Specialty AS sp ON sp.SpecialtyName = d.Specialty
ORDER BY dy.D, ds.DoctorID;

DECLARE @S INT = 1, @MaxS INT = (SELECT MAX(S) FROM @Slots), @K INT, @Try INT, @Pick INT = 0;
DECLARE @OwnPatients BIT;
DECLARE @D DATE, @DoctorID INT, @OfficeID INT, @Specialty VARCHAR(30), @IsPrimaryCare BIT, @Fee NUMERIC(10,2);
DECLARE @VisitAt DATETIME2(0), @PatientID INT, @PrimaryID INT, @ReferralID INT, @Added INT = 0, @Skipped INT = 0;

WHILE @S <= @MaxS
BEGIN
    SELECT @D = D, @DoctorID = DoctorID, @OfficeID = OfficeID, @Specialty = Specialty,
           @IsPrimaryCare = IsPrimaryCare, @Fee = Fee
    FROM @Slots WHERE S = @S;

    -- A primary-care doctor sees their own patients; a specialist (or a primary-care doctor with
    -- no sample patients of their own, like Pediatrics) sees patients referred by their primary doctor
    SET @OwnPatients = CASE WHEN @IsPrimaryCare = 1
                             AND EXISTS (SELECT 1 FROM @Pool WHERE PrimaryID = @DoctorID) THEN 1 ELSE 0 END;

    SET @K = 1;
    WHILE @K <= 3          -- up to 3 visits per doctor per working day
    BEGIN
        -- times differ a little per doctor so the offices don't all book the same minute
        SET @VisitAt = DATEADD(MINUTE,
                         CHOOSE(@K, 570, 690, 870) + (@DoctorID % 3) * 30,     -- 9:30/11:30/14:30 (+0, 30 or 60 min)
                         CAST(@D AS DATETIME2(0)));

        IF EXISTS (SELECT 1 FROM dbo.Appointment WHERE DoctorID = @DoctorID AND AppointStatus <> 'Cancelled' AND DeletionFlag = 0
                   AND Date_Time > DATEADD(MINUTE, -30, @VisitAt) AND Date_Time < DATEADD(MINUTE, 30, @VisitAt))
        BEGIN
            SET @Skipped += 1;    -- the doctor already has a visit then (or this ran before)
        END
        ELSE
        BEGIN
            -- next patient in the pool who fits: own primary doctor, or (specialist) anyone not seeing them as primary;
            -- and no other visit that day
            SET @PatientID = NULL; SET @Try = 0;
            WHILE @PatientID IS NULL AND @Try < @PoolSize
            BEGIN
                SET @Pick = @Pick % @PoolSize + 1;
                SET @Try += 1;
                SELECT @PatientID = p.PatientID, @PrimaryID = p.PrimaryID
                FROM @Pool AS p
                WHERE p.N = @Pick
                  AND ((@OwnPatients = 1 AND p.PrimaryID = @DoctorID)
                       OR (@OwnPatients = 0 AND p.PrimaryID <> @DoctorID))
                  AND NOT EXISTS (SELECT 1 FROM dbo.Appointment AS a
                                  WHERE a.PatientID = p.PatientID AND CAST(a.Date_Time AS DATE) = @D
                                    AND a.AppointStatus <> 'Cancelled' AND a.DeletionFlag = 0);
            END

            IF @PatientID IS NULL
                SET @Skipped += 1;
            ELSE
            BEGIN
                SET @ReferralID = NULL;
                IF @DoctorID <> @PrimaryID
                BEGIN
                    SET @ReferralID = (SELECT TOP 1 ReferralID FROM dbo.Referral
                                       WHERE PatientID = @PatientID AND SpecialistID = @DoctorID AND RefStatus = 'Scheduled'
                                         AND DeletionFlag = 0 AND DateIssued <= @D ORDER BY DateIssued);
                    IF @ReferralID IS NULL
                    BEGIN
                        INSERT INTO dbo.Referral (PatientID, SpecialistID, PrimaryID, DateIssued, RefStatus, DeletionFlag)
                        VALUES (@PatientID, @DoctorID, @PrimaryID, '2026-11-06', 'Scheduled', 0);
                        SET @ReferralID = SCOPE_IDENTITY();
                    END
                END

                INSERT INTO dbo.Appointment (OfficeID, DoctorID, PatientID, ReferralID, Date_Time, AppointStatus, TotalCost, Channel,
                                             CancelReason, CancelledBy, CancellationFee, VisitReason, CheckInStatus, DeletionFlag)
                VALUES (@OfficeID, @DoctorID, @PatientID, @ReferralID, @VisitAt, 'Scheduled', @Fee,
                        CASE WHEN (@PatientID + @K) % 2 = 0 THEN 'Web Portal' ELSE 'Phone' END,
                        NULL, NULL, NULL,
                        CASE @Specialty
                            WHEN 'Family Medicine'   THEN CHOOSE((@PatientID + @K) % 6 + 1, 'Annual checkup', 'Cough and sore throat', 'Follow-up visit', 'Back pain', 'Flu symptoms', 'Blood pressure check')
                            WHEN 'Internal Medicine' THEN CHOOSE((@PatientID + @K) % 6 + 1, 'Diabetes follow-up', 'Annual physical', 'Fatigue', 'Blood pressure check', 'Lab results review', 'Stomach pain')
                            WHEN 'Cardiology'        THEN CHOOSE((@PatientID + @K) % 6 + 1, 'Chest pain', 'Heart palpitations', 'Blood pressure follow-up', 'Heart checkup', 'Shortness of breath', 'Follow-up after tests')
                            WHEN 'Pediatrics'        THEN CHOOSE((@PatientID + @K) % 6 + 1, 'Wellness checkup', 'Fever', 'Ear pain', 'Vaccination', 'Rash', 'Follow-up visit')
                            WHEN 'Dermatology'       THEN CHOOSE((@PatientID + @K) % 6 + 1, 'Skin rash', 'Mole check', 'Acne', 'Eczema flare-up', 'Itchy skin', 'Follow-up visit')
                            WHEN 'Orthopedics'       THEN CHOOSE((@PatientID + @K) % 6 + 1, 'Knee pain', 'Back pain', 'Shoulder pain', 'Ankle sprain', 'Follow-up visit', 'Wrist pain')
                            ELSE 'Follow-up visit' END,
                        NULL, 0);
                SET @Added += 1;
            END
        END
        SET @K += 1;
    END
    SET @S += 1;
END

COMMIT TRANSACTION;

-- What it did: visits per doctor per day (Wed Nov 11 - Wed Nov 25)
SELECT @Added AS VisitsAdded, @Skipped AS SlotsSkipped;
SELECT 'Dr. ' + m.LastName AS Doctor,
       SUM(CASE WHEN CAST(a.Date_Time AS DATE) BETWEEN '2026-11-09' AND '2026-11-15' THEN 1 ELSE 0 END) AS ThisWeek,
       SUM(CASE WHEN CAST(a.Date_Time AS DATE) BETWEEN '2026-11-16' AND '2026-11-22' THEN 1 ELSE 0 END) AS NextWeek,
       SUM(CASE WHEN CAST(a.Date_Time AS DATE) BETWEEN '2026-11-23' AND '2026-11-29' THEN 1 ELSE 0 END) AS WeekOfNov23,
       COUNT(DISTINCT CASE WHEN CAST(a.Date_Time AS DATE) BETWEEN '2026-11-09' AND '2026-11-15'
                           THEN CAST(a.Date_Time AS DATE) END) AS DaysThisWeek
FROM dbo.Doctor AS d
JOIN dbo.Member AS m ON m.MemberID = d.DoctorID
LEFT JOIN dbo.Appointment AS a ON a.DoctorID = d.DoctorID AND a.AppointStatus <> 'Cancelled' AND a.DeletionFlag = 0
GROUP BY m.LastName
ORDER BY m.LastName;
