-- seed-round3-more.sql (Tue Nov 10): more sample data, including TODAY's visits so the nurse and
-- doctor "Today" lists show visits that are finished (Seen), waiting for the doctor and waiting for the nurse.
-- Safe to run twice: rows that already exist are skipped. One transaction: if any business rule
-- (trigger) refuses a row, nothing is saved.
-- Azure: sqlcmd ... -d MedicalClinic -b -i database\seed-round3-more.sql   (no USE on Azure)

SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;

------------------------------------------------------------------------------------------
-- 1. More allergies (the doctor's allergy box and trigger 50011 have more to show)
------------------------------------------------------------------------------------------
INSERT INTO dbo.Allergy (PatientID, Allergen, ReactionType, Severity, DateIdentified, DeletionFlag)
SELECT m.MemberID, v.Allergen, v.Reaction, v.Severity, v.Identified, 0
FROM (VALUES
    ('patient3004@example.com', 'Sulfa',     'Rash',                 'Moderate', CAST('2017-08-14' AS DATE)),
    ('patient3016@example.com', 'Codeine',   'Nausea and vomiting',  'Severe',   CAST('2012-02-03' AS DATE)),
    ('patient3022@example.com', 'Aspirin',   'Stomach upset',        'Mild',     CAST('2020-11-19' AS DATE)),
    ('patient3014@example.com', 'Latex',     'Skin rash',            'Moderate', CAST('2016-05-30' AS DATE)),
    ('patient3008@example.com', 'Shellfish', 'Swelling',             'Severe',   CAST('2009-07-04' AS DATE)),
    ('patient3018@example.com', 'Penicillin','Hives',                'Severe',   CAST('2014-03-11' AS DATE))
) AS v (Email, Allergen, Reaction, Severity, Identified)
JOIN dbo.Member AS m ON m.Email = v.Email
JOIN dbo.Patient AS p ON p.PatientID = m.MemberID
WHERE NOT EXISTS (SELECT 1 FROM dbo.Allergy AS al
                  WHERE al.PatientID = m.MemberID AND al.Allergen = v.Allergen AND al.DeletionFlag = 0);

------------------------------------------------------------------------------------------
-- 2. Visits. Doctor = a name, or 'PRIMARY' = the patient's primary doctor on the first day
--    on/after the date that doctor works. Kind:
--      Done   = completed visit (vitals, nurse + doctor notes, diagnosis, maybe a prescription and payment)
--      Ready  = today, vitals and nursing notes recorded, checked in "Ready for doctor"
--      Arrived= today, checked in, waiting for the nurse
--      Booked = upcoming, nothing recorded yet
--    ExistingID = complete a visit that is already booked (today's demo visits)
------------------------------------------------------------------------------------------
DECLARE @New TABLE (
    Seq INT IDENTITY(1,1), ExistingID INT, DoctorName VARCHAR(60), PatientEmail VARCHAR(60), VisitDate DATE, VisitTime TIME(0),
    Kind VARCHAR(7), Channel VARCHAR(10), Reason VARCHAR(200),
    Diagnosis VARCHAR(100), ClinicalNotes VARCHAR(500), TreatmentPlan VARCHAR(200), FollowUp VARCHAR(200), NursingNotes VARCHAR(500),
    Sys SMALLINT, Dia SMALLINT, HR SMALLINT, Temp NUMERIC(4,1), Wt NUMERIC(5,1), Ht NUMERIC(4,1),
    RxName VARCHAR(50), RxDose VARCHAR(20), RxFreq VARCHAR(20), RxDur VARCHAR(20), RxPharmacy VARCHAR(60),
    PaidAmount NUMERIC(10,2), PayMethod INT);

INSERT INTO @New (ExistingID, DoctorName, PatientEmail, VisitDate, VisitTime, Kind, Channel, Reason,
                  Diagnosis, ClinicalNotes, TreatmentPlan, FollowUp, NursingNotes, Sys, Dia, HR, Temp, Wt, Ht,
                  RxName, RxDose, RxFreq, RxDur, RxPharmacy, PaidAmount, PayMethod)
VALUES
-- ===== TODAY, Tue Nov 10, 1234 Main Street (nurse jlee): Dr. Chen and Dr. Brooks =====
(NULL, 'David Chen', 'patient3012@example.com', '2026-11-10', '08:30', 'Done', 'Web Portal', 'Annual physical',
 'Preventive wellness examination', 'Healthy exam; labs ordered.', 'Keep exercising; recheck labs in a year.', 'Annual physical next year.',
 'No complaints today. Patient fasted for labs.', 122, 78, 70, 98.2, 182, 70,
 NULL, NULL, NULL, NULL, NULL, 150, 2),
(NULL, 'David Chen', 'patient3014@example.com', '2026-11-10', '09:30', 'Done', 'Phone', 'Diabetes follow-up',
 'Type 2 Diabetes', 'A1C up to 7.4; feet and eyes checked.', 'Start metformin; walk 30 minutes a day.', 'Follow up in 3 months with labs.',
 'Patient reports more thirst lately. Latex allergy: used non-latex gloves.', 134, 84, 78, 98.4, 214, 69,
 'Metformin', '500 mg', 'Twice a day', '90 days', 'CVS Pharmacy, Main Street', NULL, NULL),
(NULL, 'David Chen', 'patient3008@example.com', '2026-11-10', '11:00', 'Done', 'Web Portal', 'Blood pressure check',
 'Hypertension', 'Blood pressure still above goal on two readings.', 'Start lisinopril; cut salt.', 'Blood pressure check in 4 weeks.',
 'Blood pressure high on arrival; rechecked after 5 minutes, still high.', 152, 96, 82, 98.0, 196, 70,
 'Lisinopril', '10 mg', 'Once a day', '30 days', 'Clarity Health Pharmacy, Main Street', 150, 4),
(NULL, 'Daniel Brooks', 'patient3011@example.com', '2026-11-10', '13:30', 'Done', 'Web Portal', 'Wrist pain',
 'Wrist sprain', 'Tender right wrist, full motion, X-ray normal.', 'Wrist brace for 2 weeks; ice after use.', 'Keep the Thursday visit to recheck.',
 'Patient fell on her right hand on Saturday; pain 5 out of 10.', 118, 74, 72, 98.3, 141, 65,
 'Ibuprofen', '400 mg', 'Three times a day', '7 days', 'CVS Pharmacy, Main Street', 100, 2),
(NULL, 'David Chen', 'patient3022@example.com', '2026-11-10', '16:00', 'Ready', 'Phone', 'Follow-up after heart monitor',
 NULL, NULL, NULL, NULL,
 'Wore the heart monitor for 2 weeks; says the racing is less often. Aspirin upsets his stomach.', 136, 82, 88, 98.1, 188, 68,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(NULL, 'David Chen', 'patient3016@example.com', '2026-11-10', '16:30', 'Arrived', 'Web Portal', 'Cough',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
-- ===== TODAY, Tue Nov 10, 5678 Westheimer Road (nurse kthomas): Dr. Wilson and Dr. Martinez =====
(1000194, 'James Wilson', 'test.demopatient@example.com', '2026-11-10', '09:00', 'Done', 'Phone', 'Follow-up on cough',
 'Acute bronchitis', 'Lungs with mild wheeze; heart sounds normal; ECG normal.', 'Azithromycin (no penicillin: severe allergy); inhaler as needed.', 'Back to Dr. Patel if the cough lasts 2 more weeks.',
 'Cough for 10 days, worse at night. Reminded the doctor of the penicillin allergy.', 124, 80, 86, 99.4, 168, 69,
 'Azithromycin', '250 mg', 'Once a day', '5 days', 'Walgreens, Westheimer Road', 300, 4),
(1000184, 'Sophia Martinez', 'patient3015@example.com', '2026-11-10', '10:00', 'Done', 'Web Portal', 'Acne',
 'Acne vulgaris', 'Mild acne on the forehead and cheeks.', 'Retinoid cream at night; gentle cleanser.', 'Follow up in 8 weeks.',
 'Patient says over-the-counter washes have not helped.', 112, 70, 74, 98.5, 128, 64,
 'Tretinoin cream 0.025%', 'Pea-sized amount', 'Every night', '8 weeks', 'H-E-B Pharmacy, Richmond Avenue', 200, 3),
(NULL, 'James Wilson', 'patient3004@example.com', '2026-11-10', '11:30', 'Done', 'Phone', 'Chest pain',
 'Costochondritis', 'Chest wall tender to touch; ECG normal.', 'Anti-inflammatory medicine and rest; no heavy lifting.', 'Return right away if the pain spreads or comes with shortness of breath.',
 'Sharp chest pain when he breathes in deeply, 4 out of 10. Sulfa allergy noted.', 132, 84, 80, 98.6, 186, 70,
 'Ibuprofen', '600 mg', 'Three times a day', '7 days', 'Walgreens, Westheimer Road', 50, 1),
(NULL, 'Sophia Martinez', 'patient3003@example.com', '2026-11-10', '14:00', 'Done', 'Web Portal', 'Eczema flare-up',
 'Atopic dermatitis (eczema)', 'Flare on both elbows; no infection.', 'Stronger steroid cream for 2 weeks, then back to moisturizer.', 'Follow up in 6 weeks.',
 'Patient says the itching came back after the weather turned cold.', 114, 72, 70, 98.3, 133, 65,
 'Triamcinolone cream 0.1%', 'Thin layer', 'Twice a day', '14 days', 'H-E-B Pharmacy, Richmond Avenue', 200, 2),
(NULL, 'James Wilson', 'patient3006@example.com', '2026-11-10', '16:30', 'Ready', 'Web Portal', 'Heart palpitations',
 NULL, NULL, NULL, NULL,
 'Says his heart skips a beat a few times a day, mostly after coffee.', 128, 80, 94, 98.4, 179, 71,
 NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(NULL, 'Sophia Martinez', 'patient3017@example.com', '2026-11-10', '17:00', 'Arrived', 'Phone', 'Skin rash',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(NULL, 'James Wilson', 'patient3020@example.com', '2026-11-10', '17:30', 'Booked', 'Web Portal', 'Heart checkup',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
-- ===== LAST WEEK (Nov 2-6), each patient's primary doctor =====
(NULL, 'PRIMARY', 'patient3010@example.com', '2026-11-02', '10:00', 'Done', 'Web Portal', 'Flu symptoms',
 'Influenza', 'Fever, body aches; flu test positive.', 'Rest, fluids, antiviral for 5 days.', 'Return if breathing gets hard.',
 'Temperature high on arrival; patient feels achy and tired.', 118, 76, 98, 101.6, 171, 70,
 'Oseltamivir', '75 mg', 'Twice a day', '5 days', 'CVS Pharmacy, Main Street', 150, 2),
(NULL, 'PRIMARY', 'patient3018@example.com', '2026-11-02', '11:30', 'Done', 'Phone', 'Sinus pressure',
 'Sinus Infection', 'Facial tenderness and congestion for 12 days.', 'Antibiotic (no penicillin: severe allergy); saline rinse.', 'Follow up if not better in 10 days.',
 'Patient says the congestion has lasted almost two weeks. Penicillin allergy noted.', 126, 80, 76, 99.1, 192, 72,
 'Doxycycline', '100 mg', 'Twice a day', '10 days', 'Walgreens, Westheimer Road', 75, 2),
(NULL, 'PRIMARY', 'patient3020@example.com', '2026-11-03', '14:00', 'Done', 'Web Portal', 'Blood pressure check',
 'Hypertension', 'Blood pressure better since last visit, still a little high.', 'Raise amlodipine dose.', 'Recheck in 6 weeks.',
 'Patient takes his blood pressure at home most mornings.', 144, 90, 74, 98.2, 205, 70,
 'Amlodipine', '10 mg', 'Once a day', '30 days', 'Clarity Health Pharmacy, Main Street', 150, 4),
(NULL, 'PRIMARY', 'patient3021@example.com', '2026-11-04', '09:00', 'Done', 'Web Portal', 'Allergy symptoms',
 'Seasonal Allergies', 'Itchy eyes and sneezing, worse outdoors.', 'Daily antihistamine; nasal spray.', 'Follow up in the spring if needed.',
 'Patient says symptoms started with the ragweed season.', 112, 72, 68, 98.0, 134, 66,
 'Cetirizine', '10 mg', 'Once a day', '30 days', 'H-E-B Pharmacy, Richmond Avenue', 150, 3),
(NULL, 'PRIMARY', 'patient3024@example.com', '2026-11-04', '15:30', 'Done', 'Phone', 'Shortness of breath',
 'Asthma', 'Wheezing on exam; peak flow lower than usual.', 'Rescue inhaler as needed; start a daily controller inhaler.', 'Follow up in 4 weeks.',
 'Patient used the rescue inhaler three times this week.', 120, 78, 92, 98.4, 176, 69,
 'Albuterol inhaler', '90 mcg', 'As needed', '30 days', 'CVS Pharmacy, Main Street', NULL, NULL),
(NULL, 'PRIMARY', 'patient3025@example.com', '2026-11-05', '10:30', 'Done', 'Web Portal', 'Cough and sore throat',
 'Upper Respiratory Infection', 'Red throat, clear lungs, no fever.', 'Rest, fluids and throat lozenges.', 'Return if the fever starts or it lasts 10 more days.',
 'Patient says the sore throat started 4 days ago.', 110, 70, 80, 99.8, 129, 64,
 NULL, NULL, NULL, NULL, NULL, 150, 1),
-- ===== NEXT WEEK (Nov 16-20), each patient's primary doctor =====
(NULL, 'PRIMARY', 'patient3010@example.com', '2026-11-16', '09:30', 'Booked', 'Web Portal', 'Follow-up after the flu',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(NULL, 'PRIMARY', 'patient3021@example.com', '2026-11-16', '13:30', 'Booked', 'Phone', 'Annual checkup',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(NULL, 'PRIMARY', 'patient3024@example.com', '2026-11-17', '10:30', 'Booked', 'Web Portal', 'Asthma follow-up',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(NULL, 'PRIMARY', 'patient3020@example.com', '2026-11-18', '11:00', 'Booked', 'Phone', 'Blood pressure follow-up',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(NULL, 'PRIMARY', 'patient3025@example.com', '2026-11-19', '14:30', 'Booked', 'Web Portal', 'Cough follow-up',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(NULL, 'PRIMARY', 'patient3018@example.com', '2026-11-20', '09:00', 'Booked', 'Phone', 'Sinus follow-up',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

DECLARE @Refs TABLE (ReferralID INT);
DECLARE @Added INT = 0, @Completed INT = 0, @Skipped INT = 0;
DECLARE @Seq INT = 1, @Max INT = (SELECT MAX(Seq) FROM @New);
DECLARE @ExistingID INT, @DoctorName VARCHAR(60), @PatientID INT, @DoctorID INT, @OfficeID INT, @Fee NUMERIC(10,2),
        @PrimaryID INT, @ReferralID INT, @ApptID INT, @RecordID INT, @PayID INT, @RxID INT,
        @Date DATE, @Time TIME(0), @VisitAt DATETIME2(0), @Kind VARCHAR(7), @Try INT;

WHILE @Seq <= @Max
BEGIN
    SELECT @ExistingID = ExistingID, @DoctorName = DoctorName, @Date = VisitDate, @Time = VisitTime, @Kind = Kind
    FROM @New WHERE Seq = @Seq;

    SET @PatientID = (SELECT p.PatientID FROM @New AS n JOIN dbo.Member AS m ON m.Email = n.PatientEmail
                      JOIN dbo.Patient AS p ON p.PatientID = m.MemberID WHERE n.Seq = @Seq);
    SET @PrimaryID = (SELECT TOP 1 DoctorID FROM dbo.PatientDoctor
                      WHERE PatientID = @PatientID AND RolePlayed = 'Primary' AND DeletionFlag = 0);
    SET @DoctorID = CASE WHEN @DoctorName = 'PRIMARY' THEN @PrimaryID
                         ELSE (SELECT d.DoctorID FROM dbo.Doctor AS d JOIN dbo.Member AS m ON m.MemberID = d.DoctorID
                               WHERE m.FirstName + ' ' + m.LastName = @DoctorName AND d.DeletionFlag = 0) END;

    -- 'PRIMARY': move forward to the first day (within a week) this doctor works
    SET @OfficeID = NULL; SET @Try = 0;
    WHILE @OfficeID IS NULL AND @Try < 7 AND @DoctorID IS NOT NULL
    BEGIN
        SET @OfficeID = (SELECT TOP 1 OfficeID FROM dbo.DoctorSchedule
                         WHERE DoctorID = @DoctorID AND DeletionFlag = 0
                           AND DayOfWeek = CHOOSE(DATEDIFF(DAY, '19000101', @Date) % 7 + 1, 'Mon','Tue','Wed','Thu','Fri','Sat','Sun'));
        IF @OfficeID IS NULL
        BEGIN
            IF @DoctorName <> 'PRIMARY' SET @Try = 7;   -- named doctor: the date is exact
            ELSE BEGIN SET @Date = DATEADD(DAY, 1, @Date); SET @Try += 1; END
        END
    END
    SET @VisitAt = DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00', @Time), CAST(@Date AS DATETIME2(0)));
    SET @Fee = (SELECT s.VisitFee FROM dbo.Doctor AS d JOIN dbo.Specialty AS s ON s.SpecialtyName = d.Specialty WHERE d.DoctorID = @DoctorID);
    SET @ApptID = NULL;

    IF @ExistingID IS NOT NULL
    BEGIN
        -- Complete a visit that is already booked (only if it is still Scheduled)
        IF EXISTS (SELECT 1 FROM dbo.Appointment WHERE AppointmentID = @ExistingID AND AppointStatus = 'Scheduled' AND DeletionFlag = 0)
        BEGIN
            UPDATE dbo.Appointment SET AppointStatus = 'Completed', CheckInStatus = 'Ready for doctor'
            WHERE AppointmentID = @ExistingID;
            SET @ApptID = @ExistingID;
            SET @ReferralID = (SELECT ReferralID FROM dbo.Appointment WHERE AppointmentID = @ExistingID);
            IF @ReferralID IS NOT NULL INSERT INTO @Refs VALUES (@ReferralID);
            SET @Completed += 1;
        END
        ELSE SET @Skipped += 1;
    END
    ELSE IF @DoctorID IS NULL OR @PatientID IS NULL OR @OfficeID IS NULL OR @Fee IS NULL OR @PrimaryID IS NULL
       OR EXISTS (SELECT 1 FROM dbo.Appointment WHERE DoctorID = @DoctorID AND AppointStatus <> 'Cancelled' AND DeletionFlag = 0
                  AND Date_Time > DATEADD(MINUTE, -30, @VisitAt) AND Date_Time < DATEADD(MINUTE, 30, @VisitAt))
       OR EXISTS (SELECT 1 FROM dbo.Appointment WHERE PatientID = @PatientID AND AppointStatus <> 'Cancelled' AND DeletionFlag = 0
                  AND Date_Time > DATEADD(MINUTE, -60, @VisitAt) AND Date_Time < DATEADD(MINUTE, 60, @VisitAt))
    BEGIN
        SET @Skipped += 1;   -- already added, the doctor is busy, or someone is missing: leave it
    END
    ELSE
    BEGIN
        SET @ReferralID = NULL;
        IF @DoctorID <> @PrimaryID
        BEGIN
            SET @ReferralID = (SELECT TOP 1 ReferralID FROM dbo.Referral
                               WHERE PatientID = @PatientID AND SpecialistID = @DoctorID AND RefStatus = 'Scheduled'
                                 AND DeletionFlag = 0 AND DateIssued <= @Date
                               ORDER BY DateIssued);
            IF @ReferralID IS NULL
            BEGIN
                INSERT INTO dbo.Referral (PatientID, SpecialistID, PrimaryID, DateIssued, RefStatus, DeletionFlag)
                VALUES (@PatientID, @DoctorID, @PrimaryID, DATEADD(DAY, -7, @Date), 'Scheduled', 0);
                SET @ReferralID = SCOPE_IDENTITY();
            END
            INSERT INTO @Refs VALUES (@ReferralID);
        END

        INSERT INTO dbo.Appointment (OfficeID, DoctorID, PatientID, ReferralID, Date_Time, AppointStatus, TotalCost, Channel,
                                     CancelReason, CancelledBy, CancellationFee, VisitReason, CheckInStatus, DeletionFlag)
        SELECT @OfficeID, @DoctorID, @PatientID, @ReferralID, @VisitAt,
               CASE WHEN @Kind = 'Done' THEN 'Completed' ELSE 'Scheduled' END,
               @Fee, Channel, NULL, NULL, NULL, Reason,
               CASE @Kind WHEN 'Done' THEN 'Ready for doctor' WHEN 'Ready' THEN 'Ready for doctor'
                          WHEN 'Arrived' THEN 'Checked in' ELSE NULL END,
               0
        FROM @New WHERE Seq = @Seq;
        SET @ApptID = SCOPE_IDENTITY();
        SET @Added += 1;
    END

    IF @ApptID IS NOT NULL AND @Kind IN ('Done', 'Ready')
       AND NOT EXISTS (SELECT 1 FROM dbo.MedicalRecord WHERE AppointmentID = @ApptID)
    BEGIN
        INSERT INTO dbo.MedicalRecord (AppointmentID, ClinicalNotes, SystolicBP, DiastolicBP, HeartRate, Temperature,
                                       WeightPounds, HeightInches, TreatmentPlan, FollowUp, NursingNotes, DeletionFlag)
        SELECT @ApptID, ClinicalNotes, Sys, Dia, HR, Temp, Wt, Ht, TreatmentPlan, FollowUp, NursingNotes, 0
        FROM @New WHERE Seq = @Seq;
        SET @RecordID = SCOPE_IDENTITY();

        IF @Kind = 'Done'
        BEGIN
            INSERT INTO dbo.Diagnosis (DiagnosisID, RecordID, DiagnosisDescription, DiagnosisType, DeletionFlag)
            SELECT 1, @RecordID, Diagnosis, 'Primary', 0 FROM @New WHERE Seq = @Seq;

            IF EXISTS (SELECT 1 FROM @New WHERE Seq = @Seq AND RxName IS NOT NULL)
            BEGIN
                SET @RxID = (SELECT ISNULL(MAX(PrescriptionID), 0) + 1 FROM dbo.Prescription WITH (UPDLOCK, HOLDLOCK) WHERE RecordID = @RecordID);
                INSERT INTO dbo.Prescription (PrescriptionID, RecordID, MedicationName, Dosage, Frequency, Duration, Instructions, Pharmacy, DeletionFlag)
                SELECT @RxID, @RecordID, RxName, RxDose, RxFreq, RxDur, NULL, RxPharmacy, 0 FROM @New WHERE Seq = @Seq;
            END

            IF EXISTS (SELECT 1 FROM @New WHERE Seq = @Seq AND PaidAmount IS NOT NULL)
            BEGIN
                INSERT INTO dbo.Payment (AppointmentID, InstallmentNumber, PaymentDate, PayStatus, DeletionFlag)
                VALUES (@ApptID, (SELECT ISNULL(MAX(InstallmentNumber), 0) + 1 FROM dbo.Payment WHERE AppointmentID = @ApptID),
                        @Date, 'Completed', 0);
                SET @PayID = SCOPE_IDENTITY();
                INSERT INTO dbo.PaymentDetail (PaymentID, MethodID, AmountApplied, DeletionFlag)
                SELECT @PayID, PayMethod, PaidAmount, 0 FROM @New WHERE Seq = @Seq;
            END
        END
    END
    SET @Seq += 1;
END

-- A referral whose visits are all completed is finished
UPDATE r SET RefStatus = 'Finished'
FROM dbo.Referral AS r
WHERE r.ReferralID IN (SELECT ReferralID FROM @Refs)
  AND NOT EXISTS (SELECT 1 FROM dbo.Appointment AS a
                  WHERE a.ReferralID = r.ReferralID AND a.AppointStatus = 'Scheduled' AND a.DeletionFlag = 0);

------------------------------------------------------------------------------------------
-- 3. A few chart requests (patients asking a doctor they have seen for their chart)
------------------------------------------------------------------------------------------
INSERT INTO dbo.ChartRequest (PatientID, DoctorID, RequestDate, RequestStatus, DeletionFlag)
SELECT pm.MemberID, d.DoctorID, v.RequestDate, v.RequestStatus, 0
FROM (VALUES
    ('patient3007@example.com', 'Robert Kim',    CAST('2026-10-20' AS DATE), 'Sent'),
    ('patient3016@example.com', 'Daniel Brooks', CAST('2026-11-03' AS DATE), 'Pending'),
    ('patient3022@example.com', 'Angela Nguyen', CAST('2026-11-06' AS DATE), 'Pending'),
    ('patient3003@example.com', 'Sophia Martinez', CAST('2026-10-21' AS DATE), 'Sent')
) AS v (Email, DoctorName, RequestDate, RequestStatus)
JOIN dbo.Member AS pm ON pm.Email = v.Email
JOIN dbo.Member AS dm ON dm.FirstName + ' ' + dm.LastName = v.DoctorName
JOIN dbo.Doctor AS d ON d.DoctorID = dm.MemberID
WHERE NOT EXISTS (SELECT 1 FROM dbo.ChartRequest AS cr
                  WHERE cr.PatientID = pm.MemberID AND cr.DoctorID = d.DoctorID AND cr.DeletionFlag = 0);

COMMIT TRANSACTION;

------------------------------------------------------------------------------------------
-- What it did
------------------------------------------------------------------------------------------
SELECT @Added AS VisitsAdded, @Completed AS BookedVisitsCompleted, @Skipped AS Skipped;
SELECT o.StreetAddress AS Office, CONVERT(VARCHAR(5), a.Date_Time, 108) AS Time,
       pm.FirstName + ' ' + pm.LastName AS Patient, 'Dr. ' + dm.LastName AS Doctor, a.AppointStatus, a.CheckInStatus,
       CASE WHEN a.AppointStatus = 'Completed' THEN 'Seen'
            WHEN mr.RecordID IS NULL THEN 'Waiting for nurse' ELSE 'Waiting for doctor' END AS NurseSees
FROM dbo.Appointment AS a
JOIN dbo.Office AS o ON o.OfficeID = a.OfficeID
JOIN dbo.Member AS pm ON pm.MemberID = a.PatientID
JOIN dbo.Member AS dm ON dm.MemberID = a.DoctorID
LEFT JOIN dbo.MedicalRecord AS mr ON mr.AppointmentID = a.AppointmentID AND mr.DeletionFlag = 0
WHERE CAST(a.Date_Time AS DATE) = '2026-11-10' AND a.AppointStatus <> 'Cancelled' AND a.DeletionFlag = 0
ORDER BY o.StreetAddress, a.Date_Time;
