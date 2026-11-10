-- seed-round3-data.sql (Mon Nov 9): fills the data the Round 3 features show but the database was missing.
-- Safe to run twice: every step only fills what is empty or adds rows that are not there yet.
-- One transaction: if any business rule (trigger) refuses a row, nothing is saved.
-- Azure: sqlcmd ... -d MedicalClinic -i database\seed-round3-data.sql   (no USE on Azure)

SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;

------------------------------------------------------------------------------------------
-- 1. Sample-data records (patient30xx) all had the same vitals and the same notes.
--    Give each one its own vitals and notes that match its diagnosis.
------------------------------------------------------------------------------------------
UPDATE mr
SET SystolicBP   = CASE dx.DiagnosisDescription WHEN 'Hypertension' THEN 138 + mr.RecordID % 14 ELSE 108 + mr.RecordID % 24 END,
    DiastolicBP  = CASE dx.DiagnosisDescription WHEN 'Hypertension' THEN 88 + mr.RecordID % 8 ELSE 68 + mr.RecordID % 14 END,
    HeartRate    = 64 + (mr.RecordID * 7) % 26,
    Temperature  = CASE dx.DiagnosisDescription WHEN 'Upper Respiratory Infection' THEN 99.6 + (mr.RecordID % 8) * 0.2
                                                ELSE 97.8 + (mr.RecordID % 7) * 0.2 END,
    WeightPounds = 118 + (mr.RecordID * 13) % 92,
    HeightInches = 61 + (mr.RecordID * 3) % 13,
    ClinicalNotes = CASE dx.DiagnosisDescription
        WHEN 'Hypertension'                THEN 'Blood pressure above goal. Reviewed salt intake and exercise.'
        WHEN 'Type 2 Diabetes'             THEN 'A1C slightly high. Reviewed diet and home glucose checks.'
        WHEN 'Asthma'                      THEN 'Mild wheezing on exam. Inhaler technique reviewed.'
        WHEN 'Seasonal Allergies'          THEN 'Congestion and itchy eyes, worse outdoors.'
        WHEN 'Upper Respiratory Infection' THEN 'Cough and sore throat for 4 days; lungs clear.'
        ELSE mr.ClinicalNotes END,
    TreatmentPlan = CASE dx.DiagnosisDescription
        WHEN 'Hypertension'                THEN 'Continue blood pressure medication; check it at home twice a week.'
        WHEN 'Type 2 Diabetes'             THEN 'Continue metformin; walk 30 minutes a day.'
        WHEN 'Asthma'                      THEN 'Use the rescue inhaler as needed; avoid triggers.'
        WHEN 'Seasonal Allergies'          THEN 'Daily antihistamine during allergy season.'
        WHEN 'Upper Respiratory Infection' THEN 'Rest, fluids and over-the-counter cough medicine.'
        ELSE mr.TreatmentPlan END
FROM dbo.MedicalRecord AS mr
JOIN dbo.Appointment AS a ON a.AppointmentID = mr.AppointmentID
JOIN dbo.Member AS pm ON pm.MemberID = a.PatientID
JOIN dbo.Diagnosis AS dx ON dx.RecordID = mr.RecordID AND dx.DiagnosisType = 'Primary' AND dx.DeletionFlag = 0
WHERE pm.Email LIKE 'patient30%@example.com'
  AND mr.ClinicalNotes = 'Routine clinical examination completed.'
  AND mr.SystolicBP = 120 AND mr.DiastolicBP = 80 AND mr.HeartRate = 72;

------------------------------------------------------------------------------------------
-- 2. Nursing notes on past visits (new column, empty on every old record)
------------------------------------------------------------------------------------------
UPDATE mr
SET NursingNotes = CASE
        WHEN mr.Temperature >= 100.4 THEN 'Patient feels feverish and tired. Temperature taken twice.'
        WHEN mr.SystolicBP >= 140 OR mr.DiastolicBP >= 90 THEN 'Blood pressure high on arrival; rechecked after 5 minutes, still high.'
        WHEN mr.HeartRate >= 100 THEN 'Heart rate fast on arrival; patient says they rushed to the visit.'
        ELSE CHOOSE(mr.RecordID % 4 + 1,
             'No new complaints. Patient resting comfortably.',
             'Patient reports mild pain, 3 out of 10.',
             'Patient says symptoms improved since the last visit.',
             'Patient asked about refilling a current medication.')
    END
FROM dbo.MedicalRecord AS mr
JOIN dbo.Appointment AS a ON a.AppointmentID = mr.AppointmentID
WHERE mr.NursingNotes IS NULL
  AND mr.DeletionFlag = 0
  AND a.AppointStatus = 'Completed';

------------------------------------------------------------------------------------------
-- 3. Pharmacy on old prescriptions (new column)
------------------------------------------------------------------------------------------
UPDATE dbo.Prescription
SET Pharmacy = CHOOSE(PrescriptionID % 4 + 1,
        'CVS Pharmacy, Main Street', 'Walgreens, Westheimer Road',
        'H-E-B Pharmacy, Richmond Avenue', 'Clarity Health Pharmacy, Main Street')
WHERE Pharmacy IS NULL;

------------------------------------------------------------------------------------------
-- 4. Tidy reasons typed during testing
------------------------------------------------------------------------------------------
UPDATE dbo.Appointment SET VisitReason = 'Back pain'        WHERE VisitReason = 'hurt';
UPDATE dbo.Appointment SET VisitReason = 'Chest pain'       WHERE VisitReason = 'heart pain';
UPDATE dbo.Appointment SET VisitReason = 'Cough'            WHERE VisitReason = 'cough';
UPDATE dbo.Appointment SET VisitReason = 'Follow-up visit'  WHERE VisitReason = 'follow up';
UPDATE dbo.Appointment SET CancelReason = 'Running late'    WHERE CancelReason IN ('late', 'Test late cancel');
UPDATE dbo.Appointment SET CancelReason = 'Transportation problems'
WHERE CancelReason IN ('transportation issue', 'Transportation Problems');

------------------------------------------------------------------------------------------
-- 5. Reason for visit on every visit that has none (new column): from the diagnosis
--    when there is one, otherwise a usual reason for the doctor's specialty
------------------------------------------------------------------------------------------
UPDATE a
SET VisitReason = COALESCE(
    CASE dx.DiagnosisDescription
        WHEN 'Hypertension'                    THEN 'Blood pressure check'
        WHEN 'Type 2 Diabetes'                 THEN 'Diabetes follow-up'
        WHEN 'Asthma'                          THEN 'Shortness of breath'
        WHEN 'Seasonal Allergies'              THEN 'Allergy symptoms'
        WHEN 'Upper Respiratory Infection'     THEN 'Cough and sore throat'
        WHEN 'Preventive wellness examination' THEN 'Annual checkup'
    END,
    CASE d.Specialty
        WHEN 'Family Medicine'   THEN CHOOSE(a.AppointmentID % 6 + 1, 'Annual checkup', 'Cough and sore throat', 'Follow-up visit', 'Back pain', 'Flu symptoms', 'Blood pressure check')
        WHEN 'Internal Medicine' THEN CHOOSE(a.AppointmentID % 6 + 1, 'Diabetes follow-up', 'Annual physical', 'Fatigue', 'Blood pressure check', 'Lab results review', 'Stomach pain')
        WHEN 'Cardiology'        THEN CHOOSE(a.AppointmentID % 6 + 1, 'Chest pain', 'Heart palpitations', 'Blood pressure follow-up', 'Heart checkup', 'Shortness of breath', 'Follow-up after tests')
        WHEN 'Pediatrics'        THEN CHOOSE(a.AppointmentID % 6 + 1, 'Wellness checkup', 'Fever', 'Ear pain', 'Vaccination', 'Rash', 'Follow-up visit')
        WHEN 'Dermatology'       THEN CHOOSE(a.AppointmentID % 6 + 1, 'Skin rash', 'Mole check', 'Acne', 'Eczema flare-up', 'Itchy skin', 'Follow-up visit')
        WHEN 'Orthopedics'       THEN CHOOSE(a.AppointmentID % 6 + 1, 'Knee pain', 'Back pain', 'Shoulder pain', 'Ankle sprain', 'Follow-up visit', 'Wrist pain')
    END,
    'Follow-up visit')
FROM dbo.Appointment AS a
JOIN dbo.Doctor AS d ON d.DoctorID = a.DoctorID
OUTER APPLY (SELECT TOP 1 dg.DiagnosisDescription
             FROM dbo.MedicalRecord AS mr
             JOIN dbo.Diagnosis AS dg ON dg.RecordID = mr.RecordID AND dg.DeletionFlag = 0
             WHERE mr.AppointmentID = a.AppointmentID AND mr.DeletionFlag = 0
             ORDER BY CASE dg.DiagnosisType WHEN 'Primary' THEN 0 ELSE 1 END, dg.DiagnosisID) AS dx
WHERE a.VisitReason IS NULL;

------------------------------------------------------------------------------------------
-- 6. Pending payments with no amount ("Not recorded" in payment history):
--    record them as an insurance claim for what is still owed (pending money is not
--    counted as paid, so balances do not change)
------------------------------------------------------------------------------------------
INSERT INTO dbo.PaymentDetail (PaymentID, MethodID, AmountApplied, DeletionFlag)
SELECT p.PaymentID, 4,
       a.TotalCost - ISNULL(paid.Amount, 0),
       0
FROM dbo.Payment AS p
JOIN dbo.Appointment AS a ON a.AppointmentID = p.AppointmentID
OUTER APPLY (SELECT SUM(pd2.AmountApplied) AS Amount
             FROM dbo.Payment AS p2
             JOIN dbo.PaymentDetail AS pd2 ON pd2.PaymentID = p2.PaymentID AND pd2.DeletionFlag = 0
             WHERE p2.AppointmentID = a.AppointmentID AND p2.PayStatus = 'Completed' AND p2.DeletionFlag = 0) AS paid
WHERE p.PayStatus = 'Pending'
  AND p.DeletionFlag = 0
  AND a.AppointStatus = 'Completed'
  AND NOT EXISTS (SELECT 1 FROM dbo.PaymentDetail AS pd WHERE pd.PaymentID = p.PaymentID)
  AND a.TotalCost - ISNULL(paid.Amount, 0) > 0;

------------------------------------------------------------------------------------------
-- 7. Visits for the four doctors who had none (Kim, Martinez, Brooks, Nguyen), so their
--    logins, My visits, the reports and the Westheimer nurse (kthomas) have something to show.
--    Plus the Tue Nov 10 demo visit (Alex Rivera with Dr. Wilson) again: a test cancelled it.
--    Every specialist visit gets a referral from the patient's primary doctor, as the rules require.
------------------------------------------------------------------------------------------
DECLARE @New TABLE (
    Seq INT IDENTITY(1,1), DoctorEmail VARCHAR(60), DoctorID INT, PatientEmail VARCHAR(60), PatientID INT,
    VisitAt DATETIME2(0), Status VARCHAR(9), Channel VARCHAR(10), Reason VARCHAR(200),
    Diagnosis VARCHAR(100), ClinicalNotes VARCHAR(500), TreatmentPlan VARCHAR(200), FollowUp VARCHAR(200), NursingNotes VARCHAR(500),
    Sys SMALLINT, Dia SMALLINT, HR SMALLINT, Temp NUMERIC(4,1), Wt NUMERIC(5,1), Ht NUMERIC(4,1),
    RxName VARCHAR(50), RxDose VARCHAR(20), RxFreq VARCHAR(20), RxDur VARCHAR(20), RxNote VARCHAR(100), RxPharmacy VARCHAR(60),
    PaidAmount NUMERIC(10,2), PayMethod INT, ConditionName VARCHAR(60), ConditionType VARCHAR(10), Severity VARCHAR(8));

INSERT INTO @New (DoctorEmail, PatientEmail, VisitAt, Status, Channel, Reason, Diagnosis, ClinicalNotes, TreatmentPlan, FollowUp, NursingNotes,
                  Sys, Dia, HR, Temp, Wt, Ht, RxName, RxDose, RxFreq, RxDur, RxNote, RxPharmacy, PaidAmount, PayMethod, ConditionName, ConditionType, Severity)
VALUES
-- Dr. Robert Kim, Pediatrics, Westheimer (Mon, Wed)
('robert.kim@example.com', 'patient3007@example.com', '2026-10-14T10:00:00', 'Completed', 'Web Portal', 'Fever and sore throat',
 'Strep throat', 'Red throat with white patches; rapid strep test positive.', 'Antibiotic for 5 days, rest and fluids.', 'Return if the fever lasts more than 3 days.',
 'Temperature high on arrival; patient says the throat hurts when swallowing.', 118, 76, 96, 101.2, 128, 64,
 'Azithromycin', '250 mg', 'Once a day', '5 days', 'Take with food', 'Walgreens, Westheimer Road', 150, 2, 'Strep throat', 'Acute', 'Low'),
('robert.kim@example.com', 'patient3013@example.com', '2026-10-26T14:00:00', 'Completed', 'Phone', 'Ear pain',
 'Ear infection', 'Left eardrum red and bulging.', 'Ear drops and pain relief.', 'Follow up in 2 weeks if the pain continues.',
 'Patient reports left ear pain for 2 days, 5 out of 10.', 112, 72, 84, 99.5, 118, 63,
 'Ciprofloxacin ear drops', '4 drops', 'Twice a day', '7 days', 'Left ear only', 'CVS Pharmacy, Main Street', 150, 3, 'Ear infection', 'Acute', 'Low'),
('robert.kim@example.com', 'patient3017@example.com', '2026-11-11T10:30:00', 'Scheduled', 'Web Portal', 'Wellness checkup',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('robert.kim@example.com', 'patient3007@example.com', '2026-11-16T11:00:00', 'Scheduled', 'Phone', 'Follow-up after strep throat',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
-- Dr. Sophia Martinez, Dermatology, Westheimer (Tue, Thu)
('sophia.martinez@example.com', 'patient3003@example.com', '2026-10-13T11:00:00', 'Completed', 'Web Portal', 'Itchy rash on arms',
 'Atopic dermatitis (eczema)', 'Dry, scaly patches on both forearms.', 'Moisturize twice a day; steroid cream for flare-ups.', 'Follow up in 6 weeks.',
 'Patient says the itching is worse at night.', 116, 74, 70, 98.4, 132, 65,
 'Hydrocortisone cream 1%', 'Thin layer', 'Twice a day', '14 days', 'Apply to the rash only', 'H-E-B Pharmacy, Richmond Avenue', 200, 2, 'Eczema', 'Chronic', 'Moderate'),
('sophia.martinez@example.com', 'patient3004@example.com', '2026-10-29T15:00:00', 'Completed', 'Phone', 'Mole check',
 'Benign mole', 'Mole on the back is even in color with smooth borders.', 'No treatment needed; use sunscreen.', 'Skin check again in 1 year.',
 'Patient worried about a mole on his back he noticed last month.', 134, 86, 76, 98.2, 186, 70,
 NULL, NULL, NULL, NULL, NULL, NULL, 200, 4, NULL, NULL, NULL),
('sophia.martinez@example.com', 'patient3015@example.com', '2026-11-10T10:00:00', 'Scheduled', 'Web Portal', 'Acne',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('sophia.martinez@example.com', 'patient3004@example.com', '2026-11-12T13:00:00', 'Scheduled', 'Phone', 'New spot on shoulder',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
-- Dr. Daniel Brooks, Orthopedics, Main Street (Tue, Thu)
('daniel.brooks@example.com', 'patient3006@example.com', '2026-10-20T09:30:00', 'Completed', 'Web Portal', 'Knee pain',
 'Knee sprain', 'Right knee swollen; ligaments stable.', 'Rest, ice and compression; knee brace.', 'Follow up in 4 weeks.',
 'Patient hurt his right knee playing basketball; pain 6 out of 10.', 128, 82, 78, 98.6, 178, 71,
 'Ibuprofen', '600 mg', 'Three times a day', '7 days', 'Take with food', 'CVS Pharmacy, Main Street', 275, 2, 'Knee sprain', 'Acute', 'Moderate'),
('daniel.brooks@example.com', 'patient3016@example.com', '2026-10-22T13:30:00', 'Completed', 'Phone', 'Lower back pain',
 'Osteoarthritis of the spine', 'Lower back stiff, worse in the morning; X-ray shows mild arthritis.', 'Physical therapy twice a week; stretching at home.', 'Follow up in 6 weeks.',
 'Patient says the back pain started 3 months ago, 4 out of 10.', 142, 88, 74, 98.1, 201, 69,
 'Naproxen', '500 mg', 'Twice a day', '14 days', 'Take with food', 'Clarity Health Pharmacy, Main Street', 137.50, 2, 'Osteoarthritis', 'Chronic', 'Moderate'),
('daniel.brooks@example.com', 'patient3011@example.com', '2026-11-12T10:00:00', 'Scheduled', 'Web Portal', 'Wrist pain',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('daniel.brooks@example.com', 'patient3006@example.com', '2026-11-17T11:00:00', 'Scheduled', 'Phone', 'Knee follow-up',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
-- Dr. Angela Nguyen, Cardiology, Westheimer (Mon, Fri)
('angela.nguyen@example.com', 'patient3008@example.com', '2026-10-16T10:00:00', 'Completed', 'Web Portal', 'Chest pain',
 'Stable angina', 'Chest tightness with exercise; ECG normal at rest.', 'Nitroglycerin as needed; stress test.', 'Follow up after the stress test.',
 'Patient reports chest tightness when climbing stairs.', 148, 92, 88, 98.4, 196, 70,
 'Nitroglycerin', '0.4 mg', 'As needed', '30 days', 'Under the tongue for chest pain', 'Walgreens, Westheimer Road', 300, 4, 'Coronary artery disease', 'Chronic', 'Moderate'),
('angela.nguyen@example.com', 'patient3022@example.com', '2026-10-19T15:00:00', 'Completed', 'Phone', 'Heart palpitations',
 'Atrial fibrillation', 'Irregular heartbeat on ECG.', 'Rate control medicine; wear a heart monitor for 2 weeks.', 'Follow up in 1 month.',
 'Patient says his heart has been racing on and off for a week.', 138, 84, 112, 98.0, 189, 68,
 'Metoprolol', '25 mg', 'Twice a day', '30 days', NULL, 'H-E-B Pharmacy, Richmond Avenue', 150, 4, 'Atrial fibrillation', 'Chronic', 'Moderate'),
('angela.nguyen@example.com', 'patient3012@example.com', '2026-11-13T09:30:00', 'Scheduled', 'Web Portal', 'Shortness of breath',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('angela.nguyen@example.com', 'patient3014@example.com', '2026-11-16T14:00:00', 'Scheduled', 'Phone', 'Blood pressure follow-up',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
-- Demo visit: Alex Rivera with Dr. Wilson, Westheimer, Tue Nov 10 9:00 (the first one was cancelled by a test)
('james.wilson', 'test.demopatient@example.com', '2026-11-10T09:00:00', 'Scheduled', 'Phone', 'Follow-up on cough',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

UPDATE n SET DoctorID = d.DoctorID
FROM @New AS n JOIN dbo.Member AS m ON m.Email = n.DoctorEmail JOIN dbo.Doctor AS d ON d.DoctorID = m.MemberID;
UPDATE @New SET DoctorID = 1000001 WHERE DoctorEmail = 'james.wilson';   -- Dr. James Wilson
UPDATE n SET PatientID = p.PatientID
FROM @New AS n JOIN dbo.Member AS m ON m.Email = n.PatientEmail JOIN dbo.Patient AS p ON p.PatientID = m.MemberID;

DECLARE @Refs TABLE (ReferralID INT);
DECLARE @Added INT = 0, @Skipped INT = 0;
DECLARE @Seq INT = 1, @Max INT = (SELECT MAX(Seq) FROM @New);
DECLARE @DoctorID INT, @PatientID INT, @VisitAt DATETIME2(0), @Status VARCHAR(9), @OfficeID INT, @Fee NUMERIC(10,2),
        @PrimaryID INT, @ReferralID INT, @ApptID INT, @RecordID INT, @PayID INT, @RxID INT, @Day VARCHAR(3);

WHILE @Seq <= @Max
BEGIN
    SELECT @DoctorID = DoctorID, @PatientID = PatientID, @VisitAt = VisitAt, @Status = Status FROM @New WHERE Seq = @Seq;
    SET @Day = CHOOSE(DATEDIFF(DAY, '19000101', @VisitAt) % 7 + 1, 'Mon','Tue','Wed','Thu','Fri','Sat','Sun');
    SET @OfficeID = (SELECT TOP 1 OfficeID FROM dbo.DoctorSchedule WHERE DoctorID = @DoctorID AND DayOfWeek = @Day AND DeletionFlag = 0);
    SET @Fee = (SELECT s.VisitFee FROM dbo.Doctor AS d JOIN dbo.Specialty AS s ON s.SpecialtyName = d.Specialty WHERE d.DoctorID = @DoctorID);
    SET @PrimaryID = (SELECT TOP 1 DoctorID FROM dbo.PatientDoctor WHERE PatientID = @PatientID AND RolePlayed = 'Primary' AND DeletionFlag = 0);

    IF @DoctorID IS NULL OR @PatientID IS NULL OR @OfficeID IS NULL OR @Fee IS NULL OR @PrimaryID IS NULL
       OR EXISTS (SELECT 1 FROM dbo.Appointment WHERE DoctorID = @DoctorID AND Date_Time = @VisitAt AND AppointStatus <> 'Cancelled' AND DeletionFlag = 0)
       OR EXISTS (SELECT 1 FROM dbo.Appointment WHERE PatientID = @PatientID AND Date_Time = @VisitAt AND AppointStatus <> 'Cancelled' AND DeletionFlag = 0)
    BEGIN
        SET @Skipped += 1;   -- already added, or someone/something is missing: leave it
    END
    ELSE
    BEGIN
        -- Referral from the primary doctor (reuse an open one when there is one)
        SET @ReferralID = NULL;
        IF @DoctorID <> @PrimaryID
        BEGIN
            SET @ReferralID = (SELECT TOP 1 ReferralID FROM dbo.Referral
                               WHERE PatientID = @PatientID AND SpecialistID = @DoctorID AND RefStatus = 'Scheduled'
                                 AND DeletionFlag = 0 AND DateIssued <= CAST(@VisitAt AS DATE)
                               ORDER BY DateIssued);
            IF @ReferralID IS NULL
            BEGIN
                INSERT INTO dbo.Referral (PatientID, SpecialistID, PrimaryID, DateIssued, RefStatus, DeletionFlag)
                VALUES (@PatientID, @DoctorID, @PrimaryID, DATEADD(DAY, -10, CAST(@VisitAt AS DATE)), 'Scheduled', 0);
                SET @ReferralID = SCOPE_IDENTITY();
                INSERT INTO @Refs VALUES (@ReferralID);
            END
        END

        INSERT INTO dbo.Appointment (OfficeID, DoctorID, PatientID, ReferralID, Date_Time, AppointStatus, TotalCost, Channel,
                                     CancelReason, CancelledBy, CancellationFee, VisitReason, CheckInStatus, DeletionFlag)
        SELECT @OfficeID, @DoctorID, @PatientID, @ReferralID, @VisitAt, @Status, @Fee, Channel,
               NULL, NULL, NULL, Reason, NULL, 0
        FROM @New WHERE Seq = @Seq;
        SET @ApptID = SCOPE_IDENTITY();
        SET @Added += 1;

        IF @Status = 'Completed'
        BEGIN
            INSERT INTO dbo.MedicalRecord (AppointmentID, ClinicalNotes, SystolicBP, DiastolicBP, HeartRate, Temperature,
                                           WeightPounds, HeightInches, TreatmentPlan, FollowUp, NursingNotes, DeletionFlag)
            SELECT @ApptID, ClinicalNotes, Sys, Dia, HR, Temp, Wt, Ht, TreatmentPlan, FollowUp, NursingNotes, 0
            FROM @New WHERE Seq = @Seq;
            SET @RecordID = SCOPE_IDENTITY();

            INSERT INTO dbo.Diagnosis (DiagnosisID, RecordID, DiagnosisDescription, DiagnosisType, DeletionFlag)
            SELECT 1, @RecordID, Diagnosis, 'Primary', 0 FROM @New WHERE Seq = @Seq;

            IF EXISTS (SELECT 1 FROM @New WHERE Seq = @Seq AND RxName IS NOT NULL)
            BEGIN
                SET @RxID = (SELECT ISNULL(MAX(PrescriptionID), 0) + 1 FROM dbo.Prescription WITH (UPDLOCK, HOLDLOCK));
                INSERT INTO dbo.Prescription (PrescriptionID, RecordID, MedicationName, Dosage, Frequency, Duration, Instructions, Pharmacy, DeletionFlag)
                SELECT @RxID, @RecordID, RxName, RxDose, RxFreq, RxDur, RxNote, RxPharmacy, 0 FROM @New WHERE Seq = @Seq;
            END

            INSERT INTO dbo.Payment (AppointmentID, InstallmentNumber, PaymentDate, PayStatus, DeletionFlag)
            VALUES (@ApptID, 1, CAST(@VisitAt AS DATE), 'Completed', 0);
            SET @PayID = SCOPE_IDENTITY();
            INSERT INTO dbo.PaymentDetail (PaymentID, MethodID, AmountApplied, DeletionFlag)
            SELECT @PayID, PayMethod, PaidAmount, 0 FROM @New WHERE Seq = @Seq;

            INSERT INTO dbo.PatientCondition (PatientID, ConditionName, ConditionType, IsHereditary, Severity, DateDiagnosed, DeletionFlag)
            SELECT @PatientID, ConditionName, ConditionType, 0, Severity, CAST(@VisitAt AS DATE), 0
            FROM @New AS n
            WHERE n.Seq = @Seq AND n.ConditionName IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM dbo.PatientCondition AS pc
                              WHERE pc.PatientID = @PatientID AND pc.ConditionName = n.ConditionName AND pc.DeletionFlag = 0);
        END
    END
    SET @Seq += 1;
END

-- A referral whose visits are all completed is finished
UPDATE r SET RefStatus = 'Finished'
FROM dbo.Referral AS r
JOIN @Refs AS x ON x.ReferralID = r.ReferralID
WHERE NOT EXISTS (SELECT 1 FROM dbo.Appointment AS a
                  WHERE a.ReferralID = r.ReferralID AND a.AppointStatus = 'Scheduled' AND a.DeletionFlag = 0);

COMMIT TRANSACTION;

------------------------------------------------------------------------------------------
-- What it did
------------------------------------------------------------------------------------------
SELECT @Added AS VisitsAdded, @Skipped AS VisitsSkipped;
SELECT
    (SELECT COUNT(*) FROM dbo.Appointment WHERE VisitReason IS NULL AND DeletionFlag = 0)          AS VisitsWithoutReason,
    (SELECT COUNT(*) FROM dbo.MedicalRecord AS mr JOIN dbo.Appointment AS a ON a.AppointmentID = mr.AppointmentID
      WHERE mr.NursingNotes IS NULL AND a.AppointStatus = 'Completed')                                AS PastRecordsWithoutNursingNotes,
    (SELECT COUNT(*) FROM dbo.Prescription WHERE Pharmacy IS NULL)                                    AS PrescriptionsWithoutPharmacy,
    (SELECT COUNT(*) FROM dbo.Appointment AS a WHERE a.AppointStatus = 'Completed' AND a.DeletionFlag = 0
      AND NOT EXISTS (SELECT 1 FROM dbo.MedicalRecord AS mr WHERE mr.AppointmentID = a.AppointmentID)) AS CompletedVisitsWithoutRecord;
SELECT m.FirstName + ' ' + m.LastName AS Doctor, COUNT(a.AppointmentID) AS Visits
FROM dbo.Doctor AS d
JOIN dbo.Member AS m ON m.MemberID = d.DoctorID
LEFT JOIN dbo.Appointment AS a ON a.DoctorID = d.DoctorID AND a.DeletionFlag = 0
GROUP BY m.FirstName, m.LastName
ORDER BY Visits;
