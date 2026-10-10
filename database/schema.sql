SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
   USE MedicalClinic;
   GO
CREATE TABLE Office (
    OfficeID INT IDENTITY(1000000, 1) NOT NULL,
    --<Address> (Composite Attribute)
    BuildingNum VARCHAR(5) NOT NULL,
    SuiteNum VARCHAR(5) NULL,
    Street VARCHAR(38) NOT NULL,
    City VARCHAR(48) NOT NULL,
    State VARCHAR(20) NOT NULL,
    ZipCode VARCHAR(5) NOT NULL,     
    Country VARCHAR(56) NOT NULL,
    Phone VARCHAR(10) NOT NULL,
    OpeningTime TIME NOT NULL,
    ClosingTime TIME NOT NULL,

    CONSTRAINT PK_Office PRIMARY KEY(OfficeID),
    CONSTRAINT CK_Office_OfficeID CHECK(OfficeID BETWEEN 1000000 AND 9999999),
    CONSTRAINT CK_Office_ZipCode CHECK(LEN(ZipCode) = 5 AND ZipCode NOT LIKE '%[^0-9]%'),
    CONSTRAINT CK_Office_Phone CHECK(LEN(Phone) = 10 AND Phone NOT LIKE '%[^0-9]%'),
    CONSTRAINT CK_Office_Time CHECK(ClosingTime > OpeningTime)
);

CREATE TABLE Member(
    MemberID  INT IDENTITY(1000000, 1) NOT NULL,
    SSN VARCHAR(11) NOT NULL,
    FirstName VARCHAR(15) NOT NULL,  
    MiddleName VARCHAR(15) NULL,
    LastName VARCHAR(31) NOT NULL,
    --<Address> (Composite Attribute)
    ApartmentNum VARCHAR(5) NULL,
    HouseNum VARCHAR(5) NULL,
    Street VARCHAR(38) NOT NULL,
    City VARCHAR(48) NOT NULL,
    State VARCHAR(20) NOT NULL,
    ZipCode VARCHAR(5) NOT NULL,
    Country VARCHAR(56) NOT NULL,
    Phone VARCHAR(10) NOT NULL,
    Sex CHAR(1) NOT NULL,
    DateOfBirth DATE NOT NULL,     
    Email VARCHAR(100) NOT NULL,

    CONSTRAINT PK_Member PRIMARY KEY(MemberID),
    CONSTRAINT CK_Member_MemberID CHECK(MemberID BETWEEN 1000000 AND 9999999),
    CONSTRAINT CK_Member_SSN CHECK (SSN LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'),
    CONSTRAINT UQ_Member_SSN UNIQUE (SSN),
    CONSTRAINT CK_Member_FirstName CHECK(FirstName NOT LIKE '%[0-9]%'),
    CONSTRAINT CK_Member_MiddleName CHECK(MiddleName NOT LIKE '%[0-9]%'),
    CONSTRAINT CK_Member_LastName CHECK(LastName NOT LIKE '%[0-9]%'),
    CONSTRAINT CK_Member_ZipCode CHECK(LEN(ZipCode) = 5 AND ZipCode NOT LIKE '%[^0-9]%'),
    CONSTRAINT CK_Member_Phone CHECK(LEN(Phone) = 10 AND Phone NOT LIKE '%[^0-9]%'),
    CONSTRAINT CK_Member_Sex CHECK(Sex IN('M','F','I')),
    CONSTRAINT CK_Member_DateOfBirth CHECK(DateOfBirth <= CAST(GETDATE() AS DATE)),
    CONSTRAINT UQ_Member_Email UNIQUE(Email),
    CONSTRAINT CK_Member_Email CHECK(Email LIKE '%_@_%._%' AND Email NOT LIKE '% %')
);

CREATE TABLE Employee(
    EmployeeID  INT NOT NULL,
    HiringDate DATE NOT NULL,

    CONSTRAINT PK_Employee PRIMARY KEY(EmployeeID),
    CONSTRAINT FK_Employee_Member FOREIGN KEY(EmployeeID) REFERENCES Member(MemberID) ON DELETE NO ACTION,
    CONSTRAINT CK_Employee_HiringDate CHECK(HiringDate <= CAST(GETDATE() AS DATE))
);

CREATE TABLE Doctor(
    DoctorID INT NOT NULL,
    LicenseNum VARCHAR(11) NOT NULL,
    Specialty VARCHAR(30) NOT NULL,

    CONSTRAINT PK_Doctor PRIMARY KEY(DoctorID),
    CONSTRAINT FK_Doctor_Employee FOREIGN KEY(DoctorID) REFERENCES Employee(EmployeeID) ON DELETE NO ACTION,
    CONSTRAINT UQ_Doctor_LicenseNum UNIQUE(LicenseNum)
);

CREATE TABLE Nurse(
    NurseID INT NOT NULL,
    OfficeID INT NOT NULL,
    LicenseNum VARCHAR(10) NOT NULL,

    CONSTRAINT PK_Nurse PRIMARY KEY(NurseID),
    CONSTRAINT FK_Nurse_Employee FOREIGN KEY(NurseID) REFERENCES Employee(EmployeeID) ON DELETE NO ACTION,
    CONSTRAINT FK_Nurse_Office FOREIGN KEY(OfficeID) REFERENCES Office(OfficeID) ON DELETE NO ACTION,
    CONSTRAINT UQ_Nurse_LicenseNum UNIQUE(LicenseNum)
);

CREATE TABLE Receptionist(
    ReceptionistID INT NOT NULL,
    OfficeID INT NOT NULL,

    CONSTRAINT PK_Receptionist PRIMARY KEY(ReceptionistID),
    CONSTRAINT FK_Receptionist_Employee FOREIGN KEY(ReceptionistID) REFERENCES Employee(EmployeeID) ON DELETE NO ACTION,
    CONSTRAINT FK_Receptionist_Office FOREIGN KEY(OfficeID) REFERENCES Office(OfficeID) ON DELETE NO ACTION
);

CREATE TABLE Patient(
    PatientID INT NOT NULL,
    
    CONSTRAINT PK_Patient PRIMARY KEY(PatientID),
    CONSTRAINT FK_Patient_Member FOREIGN KEY(PatientID) REFERENCES Member(MemberID) ON DELETE NO ACTION
);

CREATE TABLE UserAccount(
    AccountID INT IDENTITY (1000000,1) NOT NULL, 
    UserID INT NOT NULL,
    Username VARCHAR(25) NOT NULL,
    PasswordHash VARCHAR(60) NOT NULL, --bcrypt algo for hashing password
    LastLogin  DATETIME2(0) NULL,
    Role VARCHAR(12) NOT NULL,
    IsActive BIT NOT NULL,

    CONSTRAINT PK_UserAccount PRIMARY KEY(AccountID),
    CONSTRAINT CK_UserAccount_AccountID CHECK(AccountID BETWEEN 1000000 AND 9999999),
    CONSTRAINT FK_UserAccount_Member FOREIGN KEY(UserID) REFERENCES Member(MemberID) ON DELETE NO ACTION,
    CONSTRAINT UQ_UserAccount_UserID UNIQUE(UserID),
    CONSTRAINT UQ_UserAccount_Username UNIQUE(Username),
    CONSTRAINT CK_UserAccount_Role CHECK (Role IN ('Patient', 'Doctor', 'Nurse', 'Receptionist', 'Admin'))
);

CREATE TABLE Insurance(
    InsuranceID INT IDENTITY(1000000,1) NOT NULL,
    PatientID INT NOT NULL,
    ProviderCompany VARCHAR(30) NOT NULL,
    PolicyNum VARCHAR(13) NOT NULL,
    GroupNum VARCHAR(15) NULL,
    PlanType VARCHAR(20) NOT NULL,
    EffectiveDate DATE NULL,
    ExpirationDate DATE NULL,
    IsPrimary BIT NOT NULL,

    CONSTRAINT PK_Insurance PRIMARY KEY(InsuranceID),
    CONSTRAINT CK_Insurance_InsuranceID CHECK(InsuranceID BETWEEN 1000000 AND 9999999),
    CONSTRAINT FK_Insurance_Patient FOREIGN KEY(PatientID) REFERENCES Patient(PatientID) ON DELETE NO ACTION,
    CONSTRAINT CK_Insurance_PolicyNum CHECK(LEN(PolicyNum) = 13 AND PolicyNum NOT LIKE '%[^0-9]%'),
    CONSTRAINT CK_Insurance_GroupNum CHECK(LEN(GroupNum) = 15 AND GroupNum NOT LIKE '%[^0-9]%'),
    CONSTRAINT CK_Insurance_EffectiveDate CHECK(EffectiveDate <= CAST(GETDATE() AS DATE)),
    CONSTRAINT CK_Insurance_ExpirationDate CHECK(ExpirationDate > EffectiveDate)
);

CREATE UNIQUE INDEX UX_Insurance_OnePrimary
    ON Insurance (PatientID)
    WHERE IsPrimary = 1;

CREATE TABLE EmergencyContact(
    ContactID INT IDENTITY(1000000,1) NOT NULL,
    PatientID INT NOT NULL,
    FirstName VARCHAR(15) NOT NULL,
    MiddleName VARCHAR(15) NULL,
    LastName VARCHAR(31) NOT NULL,
    Phone VARCHAR(10) NOT NULL,
    Relationship VARCHAR(20) NOT NULL,

    CONSTRAINT PK_EmergencyContact PRIMARY KEY(ContactID),
    CONSTRAINT CK_EmergencyContact_ContactID CHECK(ContactID BETWEEN 1000000 AND 9999999),
    CONSTRAINT FK_EmergencyContact_Patient FOREIGN KEY(PatientID) REFERENCES Patient(PatientID) ON DELETE NO ACTION,
    CONSTRAINT CK_EmergencyContact_FirstName CHECK(FirstName NOT LIKE '%[0-9]%'),
    CONSTRAINT CK_EmergencyContact_MiddleName CHECK(MiddleName NOT LIKE '%[0-9]%'),
    CONSTRAINT CK_EmergencyContact_LastName CHECK(LastName NOT LIKE '%[0-9]%'),
    CONSTRAINT CK_EmergencyContact_Phone CHECK(LEN(Phone) = 10 AND Phone NOT LIKE '%[^0-9]%')
);

CREATE TABLE PatientCondition(
    ConditionID INT IDENTITY(1000000,1) NOT NULL,
    PatientID INT NOT NULL,
    ConditionName VARCHAR(60) NOT NULL,
    ConditionType VARCHAR(10) NOT NULL,
    IsHereditary BIT NOT NULL,
    Severity VARCHAR(8) NOT NULL,
    DateDiagnosed DATE NULL,
    
    CONSTRAINT PK_PatientCondition PRIMARY KEY(ConditionID),
    CONSTRAINT CK_PatientCondition_ConditionID CHECK(ConditionID BETWEEN 1000000 AND 9999999),
    CONSTRAINT FK_PatientCondition_Patient FOREIGN KEY(PatientID) REFERENCES Patient(PatientID) ON DELETE NO ACTION,
    CONSTRAINT CK_PatientCondition_ConditionType CHECK (ConditionType IN ('Acute', 'Chronic')),
    CONSTRAINT CK_PatientCondition_Severity CHECK(Severity IN('Low','Moderate','Critical')),
    CONSTRAINT CK_PatientCondition_DateDiagnosed CHECK(DateDiagnosed <= CAST(GETDATE() AS DATE))
);

CREATE TABLE Allergy(
    AllergyID INT IDENTITY(1000000,1) NOT NULL,
    PatientID INT NOT NULL,
    Allergen VARCHAR(60) NOT NULL,
    ReactionType VARCHAR(60) NOT NULL,
    Severity VARCHAR(17) NOT NULL,
    DateIdentified  DATE NULL,

    CONSTRAINT PK_Allergy PRIMARY KEY(AllergyID),
    CONSTRAINT CK_Allergy_AllergyID CHECK(AllergyID BETWEEN 1000000 AND 9999999),
    CONSTRAINT FK_Allergy_Patient FOREIGN KEY(PatientID) REFERENCES Patient(PatientID) ON DELETE NO ACTION,
    CONSTRAINT CK_Allergy_Severity CHECK(Severity IN('Mild','Moderate','Severe', 'Life Threatening', 'Fatal')), 
    CONSTRAINT CK_Allergy_DateIdentified CHECK(DateIdentified <= CAST(GETDATE() AS DATE))
);

CREATE TABLE FamilyCondition(
    FamilyConditionID INT IDENTITY(1000000,1) NOT NULL,
    PatientID INT NOT NULL,
    ConditionName VARCHAR(60) NOT NULL,
    FamilyRelationship VARCHAR(20) NOT NULL ,
    Notes VARCHAR(200) NULL,

    CONSTRAINT PK_FamilyCondition PRIMARY KEY(FamilyConditionID),
    CONSTRAINT CK_FamilyCondition_FamilyConditionID CHECK(FamilyConditionID BETWEEN 1000000 AND 9999999),
    CONSTRAINT FK_FamilyCondition_Patient FOREIGN KEY(PatientID) REFERENCES Patient(PatientID) ON DELETE NO ACTION,
);

CREATE TABLE Surgery(
    SurgeryID INT IDENTITY(1000000,1) NOT NULL,
    PatientID INT NOT NULL,
    SurgeryName VARCHAR(80) NOT NULL,
    SurgeryDate DATE NOT NULL,
    Facility VARCHAR(80) NOT NULL,
    Surgeon VARCHAR(30) NOT NULL,
    Notes VARCHAR(200) NULL,

    CONSTRAINT PK_Surgery PRIMARY KEY(SurgeryID),
    CONSTRAINT CK_Surgery_SurgeryID CHECK(SurgeryID BETWEEN 1000000 AND 9999999),
    CONSTRAINT FK_Surgery_Patient FOREIGN KEY(PatientID) REFERENCES Patient(PatientID) ON DELETE NO ACTION,
    CONSTRAINT CK_Surgery_SurgeryDate CHECK(SurgeryDate <= CAST(GETDATE() AS DATE))
);

CREATE TABLE DoctorSchedule(
    DoctorID INT NOT NULL,
    OfficeID INT NOT NULL,
    DayOfWeek CHAR(3) NOT NULL,

    CONSTRAINT PK_DoctorSchedule PRIMARY KEY(DoctorID, OfficeID, DayOfWeek),
    CONSTRAINT FK_DoctorSchedule_Doctor FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE CASCADE,
    CONSTRAINT FK_DoctorSchedule_Office FOREIGN KEY(OfficeID) REFERENCES Office(OfficeID) ON DELETE NO ACTION,
    CONSTRAINT CK_DoctorSchedule_DayOfWeek CHECK(DayOfWeek IN('Mon','Tue','Wed','Thu','Fri','Sat','Sun'))
);

CREATE TABLE PatientDoctor(
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    RolePlayed VARCHAR(10) NOT NULL,
    StartDate DATE NOT NULL,

    CONSTRAINT PK_PatientDoctor PRIMARY KEY(PatientID, DoctorID),
    CONSTRAINT FK_PatientDoctor_Patient FOREIGN KEY(PatientID) REFERENCES Patient(PatientID) ON DELETE NO ACTION,
    CONSTRAINT FK_PatientDoctor_Doctor FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE NO ACTION,
    CONSTRAINT CK_PatientDoctor_RolePlayed CHECK(RolePlayed IN('Primary','Specialist')),
    CONSTRAINT CK_PatientDoctor_StartDate CHECK(StartDate <= CAST(GETDATE() AS DATE))
);
-- A patient can only have one primary doctor
CREATE UNIQUE INDEX UX_PatientDoctor_OnePrimary
    ON PatientDoctor (PatientID)
    WHERE RolePlayed = 'Primary';

CREATE TABLE Referral(
    ReferralID INT IDENTITY(1000000,1) NOT NULL,
    PatientID INT NOT NULL,
    SpecialistID INT NOT NULL,
    PrimaryID INT NOT NULL,
    DateIssued DATE NOT NULL,
    RefStatus VARCHAR(9) NOT NULL,

    CONSTRAINT PK_Referral PRIMARY KEY(ReferralID),
    CONSTRAINT CK_Referral_ReferralID CHECK(ReferralID BETWEEN 1000000 AND 9999999),
    CONSTRAINT FK_Referral_Patient FOREIGN KEY(PatientID) REFERENCES Patient(PatientID) ON DELETE NO ACTION,
    CONSTRAINT FK_Referral_Specialist FOREIGN KEY(SpecialistID) REFERENCES Doctor(DoctorID) ON DELETE NO ACTION,
    CONSTRAINT FK_Referral_Primary FOREIGN KEY(PrimaryID) REFERENCES Doctor(DoctorID) ON DELETE NO ACTION,
    CONSTRAINT CK_Referral_DateIssued CHECK(DateIssued <= CAST(GETDATE() AS DATE)),
    CONSTRAINT CK_Referral_RefStatus CHECK(RefStatus IN('Scheduled', 'Finished', 'Cancelled')),
    CONSTRAINT CK_Referral_DifferentDoctors CHECK (PrimaryID <> SpecialistID)
);

CREATE TABLE Appointment(
    AppointmentID INT IDENTITY(1000000,1) NOT NULL,
    OfficeID INT NOT NULL,
    DoctorID INT NOT NULL,
    PatientID INT NOT NULL,
    ReferralID INT NULL,
    Date_Time DATETIME2(0) NOT NULL,
    AppointStatus VARCHAR(9) NOT NULL,
    TotalCost NUMERIC(10,2) NOT NULL,
    Channel VARCHAR(10) NOT NULL,
    CancelReason VARCHAR(200) NULL,
    CancelledBy VARCHAR(7) NULL,
        
    CONSTRAINT PK_Appointment PRIMARY KEY(AppointmentID),
    CONSTRAINT CK_Appointment_AppointmentID CHECK(AppointmentID BETWEEN 1000000 AND 9999999),
    CONSTRAINT FK_Appointment_Office FOREIGN KEY(OfficeID) REFERENCES Office(OfficeID) ON DELETE NO ACTION,
    CONSTRAINT FK_Appointment_Doctor FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE NO ACTION,
    CONSTRAINT FK_Appointment_Patient FOREIGN KEY(PatientID) REFERENCES Patient(PatientID) ON DELETE NO ACTION,
    CONSTRAINT FK_Appointment_Referral FOREIGN KEY(ReferralID) REFERENCES Referral(ReferralID) ON DELETE SET NULL,
    CONSTRAINT CK_Appointment_AppointStatus CHECK(AppointStatus IN('Scheduled','Completed','Cancelled')),
    CONSTRAINT CK_Appointment_TotalCost CHECK(TotalCost >= 0),
    CONSTRAINT CK_Appointment_Channel CHECK(Channel IN('Phone', 'Web Portal')),
    CONSTRAINT CK_Appointment_Cancellation CHECK (
        (AppointStatus = 'Cancelled'
            AND CancelReason IS NOT NULL
            AND CancelledBy IS NOT NULL)
        OR
        (AppointStatus <> 'Cancelled'
            AND CancelReason IS NULL
            AND CancelledBy IS NULL)
    )
);

CREATE TABLE MedicalRecord(
    RecordID INT IDENTITY(1000000,1) NOT NULL,
    AppointmentID INT NOT NULL,
    ClinicalNotes VARCHAR(500) NULL,
    --Vitals (Composite Attribute)
    SystolicBP SMALLINT NOT NULL,
    DiastolicBP SMALLINT NOT NULL,
    HeartRate SMALLINT NOT NULL,
    Temperature NUMERIC(4,1) NOT NULL,
    WeightPounds NUMERIC(5,1) NOT NULL,
    HeightInches NUMERIC(4,1) NOT NULL,
    TreatmentPlan VARCHAR(200) NULL,
    FollowUp VARCHAR(200) NULL,
        
    CONSTRAINT PK_MedicalRecord PRIMARY KEY(RecordID),
    CONSTRAINT CK_MedicalRecord_RecordID CHECK(RecordID BETWEEN 1000000 AND 9999999),
    CONSTRAINT FK_MedicalRecord_Appointment FOREIGN KEY(AppointmentID) REFERENCES Appointment(AppointmentID) ON DELETE NO ACTION,
    CONSTRAINT UQ_MedicalRecord_AppointmentID UNIQUE(AppointmentID),
    CONSTRAINT CK_MedicalRecord_SystolicBP CHECK (SystolicBP BETWEEN 50 AND 300),
    CONSTRAINT CK_MedicalRecord_DiastolicBP CHECK (DiastolicBP BETWEEN 20 AND 200),
    CONSTRAINT CK_MedicalRecord_HeartRate CHECK (HeartRate BETWEEN 20 AND 300),
    CONSTRAINT CK_MedicalRecord_Temperature CHECK(Temperature BETWEEN 56 AND 110),
    CONSTRAINT CK_MedicalRecord_BloodPressure CHECK (SystolicBP > DiastolicBP),
    CONSTRAINT CK_MedicalRecord_WeightPounds CHECK (WeightPounds > 0),
    CONSTRAINT CK_MedicalRecord_HeightInches CHECK (HeightInches > 0)
);

CREATE TABLE Diagnosis(
    DiagnosisID INT NOT NULL,
    RecordID INT NOT NULL,
    DiagnosisDescription VARCHAR(100) NOT NULL,
    DiagnosisType VARCHAR(9) NOT NULL,

    CONSTRAINT PK_Diagnosis PRIMARY KEY(DiagnosisID, RecordID),
    CONSTRAINT CK_Diagnosis_DiagnosisID CHECK (DiagnosisID >= 1),
    CONSTRAINT FK_Diagnosis_MedicalRecord FOREIGN KEY(RecordID) REFERENCES MedicalRecord(RecordID) ON DELETE CASCADE,
    CONSTRAINT CK_Diagnosis_DiagnosisType CHECK(DiagnosisType IN('Primary', 'Secondary'))
);

CREATE TABLE Prescription(
    PrescriptionID INT NOT NULL,
    RecordID INT NOT NULL,
    MedicationName VARCHAR(50) NOT NULL,
    Dosage  VARCHAR(20) NOT NULL,
    Frequency VARCHAR(20) NOT NULL,
    Duration VARCHAR(20) NOT NULL,
    Instructions VARCHAR(100) NULL,

    CONSTRAINT PK_Prescription PRIMARY KEY(PrescriptionID, RecordID),
    CONSTRAINT CK_Prescription_PrescriptionID CHECK (PrescriptionID >= 1),
    CONSTRAINT FK_Prescription_MedicalRecord FOREIGN KEY(RecordID) REFERENCES MedicalRecord(RecordID) ON DELETE CASCADE
);

CREATE TABLE PaymentMethod(
    MethodID INT NOT NULL,
    MethodName VARCHAR(20) NOT NULL,

    CONSTRAINT PK_PaymentMethod PRIMARY KEY(MethodID),
    CONSTRAINT UQ_PaymentMethod_MethodName UNIQUE(MethodName)
);

INSERT INTO PaymentMethod (MethodID, MethodName) VALUES
    (1, 'Cash'),
    (2, 'Credit Card'),
    (3, 'Debit Card'),
    (4, 'Insurance'),
    (5, 'Check');

CREATE TABLE Payment(
    PaymentID INT IDENTITY (1000000,1) NOT NULL,
    AppointmentID INT NOT NULL,
    InstallmentNumber INT NOT NULL,
    PaymentDate DATE NOT NULL,
    PayStatus VARCHAR(9) NOT NULL,
        
    CONSTRAINT PK_Payment PRIMARY KEY(PaymentID),
    CONSTRAINT CK_Payment_PaymentID CHECK(PaymentID BETWEEN 1000000 AND 9999999),
    CONSTRAINT FK_Payment_Appointment FOREIGN KEY(AppointmentID) REFERENCES Appointment(AppointmentID) ON DELETE NO ACTION,
    CONSTRAINT CK_Payment_InstallmentNumber CHECK(InstallmentNumber >= 1),
    CONSTRAINT UQ_Payment_AppointmentInstallment UNIQUE (AppointmentID, InstallmentNumber),
    CONSTRAINT CK_Payment_PayStatus CHECK (PayStatus IN ('Pending', 'Completed', 'Refunded'))
);

CREATE TABLE PaymentDetail(
    PaymentID INT NOT NULL,
    MethodID INT NOT NULL,
    AmountApplied NUMERIC(10,2) NOT NULL,

    CONSTRAINT PK_PaymentDetail PRIMARY KEY(PaymentID, MethodID),
    CONSTRAINT FK_PaymentDetail_Payment FOREIGN KEY(PaymentID) REFERENCES Payment(PaymentID) ON DELETE CASCADE,
    CONSTRAINT FK_PaymentDetail_PaymentMethod FOREIGN KEY(MethodID) REFERENCES PaymentMethod(MethodID) ON DELETE NO ACTION,
    CONSTRAINT CK_PaymentDetail_AmountApplied CHECK(AmountApplied >= 0)
);
