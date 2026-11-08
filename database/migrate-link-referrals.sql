-- Link existing specialist visits to the referral that allowed them.
-- Older bookings (seed data and staff bookings) left Appointment.ReferralID empty,
-- so the site couldn't show "Referred by Dr. ..." and the referral report counted no visits.
-- For each visit with no referral, pick the patient's newest referral to that same doctor
-- issued on or before the visit date. Visits with a primary doctor find no match and stay NULL.
-- Safe to run more than once: it only touches rows where ReferralID is still NULL.
-- No Appointment trigger fires on a ReferralID-only change.

UPDATE a
SET a.ReferralID = pick.ReferralID
FROM dbo.Appointment AS a
CROSS APPLY (
    SELECT TOP (1) r.ReferralID
    FROM dbo.Referral AS r
    WHERE r.PatientID = a.PatientID
      AND r.SpecialistID = a.DoctorID
      AND r.DeletionFlag = 0
      AND r.DateIssued <= CAST(a.Date_Time AS DATE)
    ORDER BY r.DateIssued DESC, r.ReferralID DESC
) AS pick
WHERE a.ReferralID IS NULL;

PRINT CONCAT('Visits linked to a referral: ', @@ROWCOUNT);
GO

-- Check: specialist visits still without a referral (should be none, or only old data with no referral at all)
SELECT a.AppointmentID, a.PatientID, a.DoctorID, a.Date_Time, a.AppointStatus
FROM dbo.Appointment AS a
WHERE a.ReferralID IS NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.PatientDoctor AS pd
                  WHERE pd.PatientID = a.PatientID
                    AND pd.DoctorID = a.DoctorID
                    AND pd.RolePlayed = 'Primary'
                    AND pd.DeletionFlag = 0);
GO
