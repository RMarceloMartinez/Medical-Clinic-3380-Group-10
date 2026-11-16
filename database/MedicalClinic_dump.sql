/****** Cannot script Unresolved Entities : Server[@Name='clinic3380-rm-sql']/Database[@Name='MedicalClinic']/UnresolvedEntity[@Name='inserted'] ******/
GO
/****** Cannot script Unresolved Entities : Server[@Name='clinic3380-rm-sql']/Database[@Name='MedicalClinic']/UnresolvedEntity[@Name='deleted'] ******/
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Diagnosis](
	[DiagnosisID] [int] NOT NULL,
	[RecordID] [int] NOT NULL,
	[DiagnosisDescription] [varchar](100) NOT NULL,
	[DiagnosisType] [varchar](9) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_Diagnosis] PRIMARY KEY CLUSTERED 
(
	[DiagnosisID] ASC,
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicalRecord](
	[RecordID] [int] IDENTITY(1000000,1) NOT NULL,
	[AppointmentID] [int] NOT NULL,
	[ClinicalNotes] [varchar](500) NULL,
	[SystolicBP] [smallint] NOT NULL,
	[DiastolicBP] [smallint] NOT NULL,
	[HeartRate] [smallint] NOT NULL,
	[Temperature] [numeric](4, 1) NOT NULL,
	[WeightPounds] [numeric](5, 1) NOT NULL,
	[HeightInches] [numeric](4, 1) NOT NULL,
	[TreatmentPlan] [varchar](200) NULL,
	[FollowUp] [varchar](200) NULL,
	[DeletionFlag] [bit] NOT NULL,
	[NursingNotes] [varchar](500) NULL,
 CONSTRAINT [PK_MedicalRecord] PRIMARY KEY CLUSTERED 
(
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_MedicalRecord_AppointmentID] UNIQUE NONCLUSTERED 
(
	[AppointmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Member](
	[MemberID] [int] IDENTITY(1000000,1) NOT NULL,
	[SSN] [varchar](11) NULL,
	[FirstName] [varchar](15) NOT NULL,
	[MiddleName] [varchar](15) NULL,
	[LastName] [varchar](31) NOT NULL,
	[StreetAddress] [varchar](80) NOT NULL,
	[ApartmentNum] [varchar](5) NULL,
	[City] [varchar](48) NOT NULL,
	[State] [varchar](20) NOT NULL,
	[ZipCode] [varchar](5) NOT NULL,
	[Country] [varchar](56) NOT NULL,
	[Phone] [varchar](10) NOT NULL,
	[Sex] [char](1) NOT NULL,
	[DateOfBirth] [date] NOT NULL,
	[Email] [varchar](100) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_Member] PRIMARY KEY CLUSTERED 
(
	[MemberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Member_Email] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentMethod](
	[MethodID] [int] NOT NULL,
	[MethodName] [varchar](20) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_PaymentMethod] PRIMARY KEY CLUSTERED 
(
	[MethodID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_PaymentMethod_MethodName] UNIQUE NONCLUSTERED 
(
	[MethodName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppointmentActivityReport](
	[DoctorID] [int] NOT NULL,
	[DoctorFirstName] [varchar](15) NOT NULL,
	[DoctorLastName] [varchar](31) NOT NULL,
	[OfficeID] [int] NOT NULL,
	[OfficeStreetAddress] [varchar](80) NOT NULL,
	[FromDate] [date] NOT NULL,
	[ToDate] [date] NOT NULL,
	[TotalAppointments] [int] NOT NULL,
	[Scheduled] [int] NOT NULL,
	[Completed] [int] NOT NULL,
	[Cancelled] [int] NOT NULL,
	[CancelledByPatient] [int] NOT NULL,
	[CancelledByDoctor] [int] NOT NULL,
	[CancelledByStaff] [int] NOT NULL,
	[CancellationRate] [numeric](5, 2) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_AppointmentActivityReport] PRIMARY KEY CLUSTERED 
(
	[DoctorID] ASC,
	[OfficeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Specialty](
	[SpecialtyName] [varchar](30) NOT NULL,
	[VisitFee] [numeric](10, 2) NOT NULL,
	[IsPrimaryCare] [bit] NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_Specialty] PRIMARY KEY CLUSTERED 
(
	[SpecialtyName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReferralTrackingReport](
	[SpecialistID] [int] NOT NULL,
	[SpecialistFirstName] [varchar](15) NOT NULL,
	[SpecialistLastName] [varchar](31) NOT NULL,
	[Specialty] [varchar](30) NOT NULL,
	[TotalReferrals] [int] NOT NULL,
	[OpenReferrals] [int] NOT NULL,
	[FinishedReferrals] [int] NOT NULL,
	[CancelledReferrals] [int] NOT NULL,
	[ReferralsWithVisit] [int] NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_ReferralTrackingReport] PRIMARY KEY CLUSTERED 
(
	[SpecialistID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VisitDetailsReport](
	[AppointmentID] [int] NOT NULL,
	[VisitDateTime] [datetime2](0) NOT NULL,
	[PatientID] [int] NOT NULL,
	[PatientFirstName] [varchar](15) NOT NULL,
	[PatientLastName] [varchar](31) NOT NULL,
	[DoctorFirstName] [varchar](15) NOT NULL,
	[DoctorLastName] [varchar](31) NOT NULL,
	[Specialty] [varchar](30) NOT NULL,
	[OfficeStreetAddress] [varchar](80) NOT NULL,
	[AppointStatus] [varchar](9) NOT NULL,
	[CancelledBy] [varchar](7) NULL,
	[TotalCost] [numeric](10, 2) NOT NULL,
	[AmountPaid] [numeric](12, 2) NOT NULL,
	[CancellationFee] [numeric](10, 2) NULL,
	[Diagnoses] [varchar](2000) NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_VisitDetailsReport] PRIMARY KEY CLUSTERED 
(
	[AppointmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PatientHealthSummaryReport](
	[ReportRowID] [int] IDENTITY(1,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[PatientFirstName] [varchar](15) NOT NULL,
	[PatientLastName] [varchar](31) NOT NULL,
	[Category] [varchar](12) NOT NULL,
	[ItemName] [varchar](100) NOT NULL,
	[Detail] [varchar](100) NULL,
	[ItemDate] [date] NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_PatientHealthSummaryReport] PRIMARY KEY CLUSTERED 
(
	[ReportRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentDetail](
	[PaymentID] [int] NOT NULL,
	[MethodID] [int] NOT NULL,
	[AmountApplied] [numeric](10, 2) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_PaymentDetail] PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC,
	[MethodID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payment](
	[PaymentID] [int] IDENTITY(1000000,1) NOT NULL,
	[AppointmentID] [int] NOT NULL,
	[InstallmentNumber] [int] NOT NULL,
	[PaymentDate] [date] NOT NULL,
	[PayStatus] [varchar](9) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_Payment] PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Payment_AppointmentInstallment] UNIQUE NONCLUSTERED 
(
	[AppointmentID] ASC,
	[InstallmentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InsuranceMixReport](
	[ProviderCompany] [varchar](30) NOT NULL,
	[PlanType] [varchar](20) NOT NULL,
	[Patients] [int] NOT NULL,
	[CompletedVisits] [int] NOT NULL,
	[Billed] [numeric](12, 2) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_InsuranceMixReport] PRIMARY KEY CLUSTERED 
(
	[ProviderCompany] ASC,
	[PlanType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OutstandingBalanceReport](
	[PatientID] [int] NOT NULL,
	[PatientFirstName] [varchar](15) NOT NULL,
	[PatientLastName] [varchar](31) NOT NULL,
	[Phone] [varchar](10) NOT NULL,
	[UnpaidVisits] [int] NOT NULL,
	[OldestUnpaidVisit] [date] NOT NULL,
	[Billed] [numeric](12, 2) NOT NULL,
	[Paid] [numeric](12, 2) NOT NULL,
	[Balance] [numeric](12, 2) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_OutstandingBalanceReport] PRIMARY KEY CLUSTERED 
(
	[PatientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OfficeRevenueReport](
	[OfficeID] [int] NOT NULL,
	[OfficeStreetAddress] [varchar](80) NOT NULL,
	[FromDate] [date] NOT NULL,
	[ToDate] [date] NOT NULL,
	[CompletedVisits] [int] NOT NULL,
	[Billed] [numeric](12, 2) NOT NULL,
	[Collected] [numeric](12, 2) NOT NULL,
	[Refunded] [numeric](12, 2) NOT NULL,
	[Outstanding] [numeric](12, 2) NOT NULL,
	[CashCollected] [numeric](12, 2) NOT NULL,
	[CreditCardCollected] [numeric](12, 2) NOT NULL,
	[DebitCardCollected] [numeric](12, 2) NOT NULL,
	[InsuranceCollected] [numeric](12, 2) NOT NULL,
	[CheckCollected] [numeric](12, 2) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_OfficeRevenueReport] PRIMARY KEY CLUSTERED 
(
	[OfficeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Office](
	[OfficeID] [int] IDENTITY(1000000,1) NOT NULL,
	[StreetAddress] [varchar](80) NOT NULL,
	[SuiteNum] [varchar](5) NULL,
	[City] [varchar](48) NOT NULL,
	[State] [varchar](20) NOT NULL,
	[ZipCode] [varchar](5) NOT NULL,
	[Country] [varchar](56) NOT NULL,
	[Phone] [varchar](10) NOT NULL,
	[OpeningTime] [time](7) NOT NULL,
	[ClosingTime] [time](7) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_Office] PRIMARY KEY CLUSTERED 
(
	[OfficeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DoctorWorkloadReport](
	[DoctorID] [int] NOT NULL,
	[DoctorFirstName] [varchar](15) NOT NULL,
	[DoctorLastName] [varchar](31) NOT NULL,
	[MonthStart] [date] NOT NULL,
	[WorkDaysPerWeek] [int] NOT NULL,
	[Appointments] [int] NOT NULL,
	[Completed] [int] NOT NULL,
	[Cancelled] [int] NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_DoctorWorkloadReport] PRIMARY KEY CLUSTERED 
(
	[DoctorID] ASC,
	[MonthStart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee](
	[EmployeeID] [int] NOT NULL,
	[HiringDate] [date] NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Patient](
	[PatientID] [int] NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_Patient] PRIMARY KEY CLUSTERED 
(
	[PatientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserAccount](
	[AccountID] [int] IDENTITY(1000000,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[Username] [varchar](25) NOT NULL,
	[PasswordHash] [varchar](60) NOT NULL,
	[LastLogin] [datetime2](0) NULL,
	[Role] [varchar](12) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_UserAccount] PRIMARY KEY CLUSTERED 
(
	[AccountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_UserAccount_UserID] UNIQUE NONCLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_UserAccount_Username] UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PatientCondition](
	[ConditionID] [int] IDENTITY(1000000,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[ConditionName] [varchar](60) NOT NULL,
	[ConditionType] [varchar](10) NOT NULL,
	[IsHereditary] [bit] NOT NULL,
	[Severity] [varchar](8) NOT NULL,
	[DateDiagnosed] [date] NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_PatientCondition] PRIMARY KEY CLUSTERED 
(
	[ConditionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Receptionist](
	[ReceptionistID] [int] NOT NULL,
	[OfficeID] [int] NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_Receptionist] PRIMARY KEY CLUSTERED 
(
	[ReceptionistID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Surgery](
	[SurgeryID] [int] IDENTITY(1000000,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[SurgeryName] [varchar](80) NOT NULL,
	[SurgeryDate] [date] NOT NULL,
	[Facility] [varchar](80) NOT NULL,
	[Surgeon] [varchar](30) NOT NULL,
	[Notes] [varchar](200) NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_Surgery] PRIMARY KEY CLUSTERED 
(
	[SurgeryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Nurse](
	[NurseID] [int] NOT NULL,
	[OfficeID] [int] NOT NULL,
	[LicenseNum] [varchar](10) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_Nurse] PRIMARY KEY CLUSTERED 
(
	[NurseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Nurse_LicenseNum] UNIQUE NONCLUSTERED 
(
	[LicenseNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Insurance](
	[InsuranceID] [int] IDENTITY(1000000,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[ProviderCompany] [varchar](30) NOT NULL,
	[PolicyNum] [varchar](13) NOT NULL,
	[GroupNum] [varchar](15) NULL,
	[PlanType] [varchar](20) NOT NULL,
	[EffectiveDate] [date] NULL,
	[ExpirationDate] [date] NULL,
	[IsPrimary] [bit] NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_Insurance] PRIMARY KEY CLUSTERED 
(
	[InsuranceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FamilyCondition](
	[FamilyConditionID] [int] IDENTITY(1000000,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[ConditionName] [varchar](60) NOT NULL,
	[FamilyRelationship] [varchar](20) NOT NULL,
	[Notes] [varchar](200) NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_FamilyCondition] PRIMARY KEY CLUSTERED 
(
	[FamilyConditionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Doctor](
	[DoctorID] [int] NOT NULL,
	[LicenseNum] [varchar](11) NOT NULL,
	[Specialty] [varchar](30) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_Doctor] PRIMARY KEY CLUSTERED 
(
	[DoctorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Doctor_LicenseNum] UNIQUE NONCLUSTERED 
(
	[LicenseNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Prescription](
	[PrescriptionID] [int] NOT NULL,
	[RecordID] [int] NOT NULL,
	[MedicationName] [varchar](50) NOT NULL,
	[Dosage] [varchar](20) NOT NULL,
	[Frequency] [varchar](20) NOT NULL,
	[Duration] [varchar](20) NOT NULL,
	[Instructions] [varchar](100) NULL,
	[DeletionFlag] [bit] NOT NULL,
	[Pharmacy] [varchar](60) NULL,
 CONSTRAINT [PK_Prescription] PRIMARY KEY CLUSTERED 
(
	[PrescriptionID] ASC,
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Allergy](
	[AllergyID] [int] IDENTITY(1000000,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[Allergen] [varchar](60) NOT NULL,
	[ReactionType] [varchar](60) NOT NULL,
	[Severity] [varchar](17) NOT NULL,
	[DateIdentified] [date] NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_Allergy] PRIMARY KEY CLUSTERED 
(
	[AllergyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmergencyContact](
	[ContactID] [int] IDENTITY(1000000,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[FirstName] [varchar](15) NOT NULL,
	[MiddleName] [varchar](15) NULL,
	[LastName] [varchar](31) NOT NULL,
	[Phone] [varchar](10) NOT NULL,
	[Relationship] [varchar](20) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_EmergencyContact] PRIMARY KEY CLUSTERED 
(
	[ContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DoctorSchedule](
	[DoctorID] [int] NOT NULL,
	[OfficeID] [int] NOT NULL,
	[DayOfWeek] [char](3) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_DoctorSchedule] PRIMARY KEY CLUSTERED 
(
	[DoctorID] ASC,
	[OfficeID] ASC,
	[DayOfWeek] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChartRequest](
	[RequestID] [int] IDENTITY(1000000,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[DoctorID] [int] NOT NULL,
	[RequestDate] [date] NOT NULL,
	[RequestStatus] [varchar](9) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_ChartRequest] PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PatientDoctor](
	[PatientID] [int] NOT NULL,
	[DoctorID] [int] NOT NULL,
	[RolePlayed] [varchar](10) NOT NULL,
	[StartDate] [date] NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_PatientDoctor] PRIMARY KEY CLUSTERED 
(
	[PatientID] ASC,
	[DoctorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Appointment](
	[AppointmentID] [int] IDENTITY(1000000,1) NOT NULL,
	[OfficeID] [int] NOT NULL,
	[DoctorID] [int] NOT NULL,
	[PatientID] [int] NOT NULL,
	[ReferralID] [int] NULL,
	[Date_Time] [datetime2](0) NOT NULL,
	[AppointStatus] [varchar](9) NOT NULL,
	[TotalCost] [numeric](10, 2) NOT NULL,
	[Channel] [varchar](10) NOT NULL,
	[CancelReason] [varchar](200) NULL,
	[CancelledBy] [varchar](7) NULL,
	[DeletionFlag] [bit] NOT NULL,
	[CancellationFee] [numeric](10, 2) NULL,
	[VisitReason] [varchar](200) NULL,
	[CheckInStatus] [varchar](16) NULL,
 CONSTRAINT [PK_Appointment] PRIMARY KEY CLUSTERED 
(
	[AppointmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Referral](
	[ReferralID] [int] IDENTITY(1000000,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[SpecialistID] [int] NOT NULL,
	[PrimaryID] [int] NOT NULL,
	[DateIssued] [date] NOT NULL,
	[RefStatus] [varchar](9) NOT NULL,
	[DeletionFlag] [bit] NOT NULL,
 CONSTRAINT [PK_Referral] PRIMARY KEY CLUSTERED 
(
	[ReferralID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Member_SSN] ON [dbo].[Member]
(
	[SSN] ASC
)
WHERE ([SSN] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Insurance_OnePrimary] ON [dbo].[Insurance]
(
	[PatientID] ASC
)
WHERE ([IsPrimary]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PatientDoctor_OnePrimary] ON [dbo].[PatientDoctor]
(
	[PatientID] ASC
)
WHERE ([RolePlayed]='Primary')
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Diagnosis]  WITH CHECK ADD  CONSTRAINT [FK_Diagnosis_MedicalRecord] FOREIGN KEY([RecordID])
REFERENCES [dbo].[MedicalRecord] ([RecordID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Diagnosis] CHECK CONSTRAINT [FK_Diagnosis_MedicalRecord]
GO
ALTER TABLE [dbo].[MedicalRecord]  WITH CHECK ADD  CONSTRAINT [FK_MedicalRecord_Appointment] FOREIGN KEY([AppointmentID])
REFERENCES [dbo].[Appointment] ([AppointmentID])
GO
ALTER TABLE [dbo].[MedicalRecord] CHECK CONSTRAINT [FK_MedicalRecord_Appointment]
GO
ALTER TABLE [dbo].[PaymentDetail]  WITH CHECK ADD  CONSTRAINT [FK_PaymentDetail_Payment] FOREIGN KEY([PaymentID])
REFERENCES [dbo].[Payment] ([PaymentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PaymentDetail] CHECK CONSTRAINT [FK_PaymentDetail_Payment]
GO
ALTER TABLE [dbo].[PaymentDetail]  WITH CHECK ADD  CONSTRAINT [FK_PaymentDetail_PaymentMethod] FOREIGN KEY([MethodID])
REFERENCES [dbo].[PaymentMethod] ([MethodID])
GO
ALTER TABLE [dbo].[PaymentDetail] CHECK CONSTRAINT [FK_PaymentDetail_PaymentMethod]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_Appointment] FOREIGN KEY([AppointmentID])
REFERENCES [dbo].[Appointment] ([AppointmentID])
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_Appointment]
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Member] FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Member] ([MemberID])
GO
ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [FK_Employee_Member]
GO
ALTER TABLE [dbo].[Patient]  WITH CHECK ADD  CONSTRAINT [FK_Patient_Member] FOREIGN KEY([PatientID])
REFERENCES [dbo].[Member] ([MemberID])
GO
ALTER TABLE [dbo].[Patient] CHECK CONSTRAINT [FK_Patient_Member]
GO
ALTER TABLE [dbo].[UserAccount]  WITH CHECK ADD  CONSTRAINT [FK_UserAccount_Member] FOREIGN KEY([UserID])
REFERENCES [dbo].[Member] ([MemberID])
GO
ALTER TABLE [dbo].[UserAccount] CHECK CONSTRAINT [FK_UserAccount_Member]
GO
ALTER TABLE [dbo].[PatientCondition]  WITH CHECK ADD  CONSTRAINT [FK_PatientCondition_Patient] FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patient] ([PatientID])
GO
ALTER TABLE [dbo].[PatientCondition] CHECK CONSTRAINT [FK_PatientCondition_Patient]
GO
ALTER TABLE [dbo].[Receptionist]  WITH CHECK ADD  CONSTRAINT [FK_Receptionist_Employee] FOREIGN KEY([ReceptionistID])
REFERENCES [dbo].[Employee] ([EmployeeID])
GO
ALTER TABLE [dbo].[Receptionist] CHECK CONSTRAINT [FK_Receptionist_Employee]
GO
ALTER TABLE [dbo].[Receptionist]  WITH CHECK ADD  CONSTRAINT [FK_Receptionist_Office] FOREIGN KEY([OfficeID])
REFERENCES [dbo].[Office] ([OfficeID])
GO
ALTER TABLE [dbo].[Receptionist] CHECK CONSTRAINT [FK_Receptionist_Office]
GO
ALTER TABLE [dbo].[Surgery]  WITH CHECK ADD  CONSTRAINT [FK_Surgery_Patient] FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patient] ([PatientID])
GO
ALTER TABLE [dbo].[Surgery] CHECK CONSTRAINT [FK_Surgery_Patient]
GO
ALTER TABLE [dbo].[Nurse]  WITH CHECK ADD  CONSTRAINT [FK_Nurse_Employee] FOREIGN KEY([NurseID])
REFERENCES [dbo].[Employee] ([EmployeeID])
GO
ALTER TABLE [dbo].[Nurse] CHECK CONSTRAINT [FK_Nurse_Employee]
GO
ALTER TABLE [dbo].[Nurse]  WITH CHECK ADD  CONSTRAINT [FK_Nurse_Office] FOREIGN KEY([OfficeID])
REFERENCES [dbo].[Office] ([OfficeID])
GO
ALTER TABLE [dbo].[Nurse] CHECK CONSTRAINT [FK_Nurse_Office]
GO
ALTER TABLE [dbo].[Insurance]  WITH CHECK ADD  CONSTRAINT [FK_Insurance_Patient] FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patient] ([PatientID])
GO
ALTER TABLE [dbo].[Insurance] CHECK CONSTRAINT [FK_Insurance_Patient]
GO
ALTER TABLE [dbo].[FamilyCondition]  WITH CHECK ADD  CONSTRAINT [FK_FamilyCondition_Patient] FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patient] ([PatientID])
GO
ALTER TABLE [dbo].[FamilyCondition] CHECK CONSTRAINT [FK_FamilyCondition_Patient]
GO
ALTER TABLE [dbo].[Doctor]  WITH CHECK ADD  CONSTRAINT [FK_Doctor_Employee] FOREIGN KEY([DoctorID])
REFERENCES [dbo].[Employee] ([EmployeeID])
GO
ALTER TABLE [dbo].[Doctor] CHECK CONSTRAINT [FK_Doctor_Employee]
GO
ALTER TABLE [dbo].[Doctor]  WITH CHECK ADD  CONSTRAINT [FK_Doctor_Specialty] FOREIGN KEY([Specialty])
REFERENCES [dbo].[Specialty] ([SpecialtyName])
GO
ALTER TABLE [dbo].[Doctor] CHECK CONSTRAINT [FK_Doctor_Specialty]
GO
ALTER TABLE [dbo].[Prescription]  WITH CHECK ADD  CONSTRAINT [FK_Prescription_MedicalRecord] FOREIGN KEY([RecordID])
REFERENCES [dbo].[MedicalRecord] ([RecordID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Prescription] CHECK CONSTRAINT [FK_Prescription_MedicalRecord]
GO
ALTER TABLE [dbo].[Allergy]  WITH CHECK ADD  CONSTRAINT [FK_Allergy_Patient] FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patient] ([PatientID])
GO
ALTER TABLE [dbo].[Allergy] CHECK CONSTRAINT [FK_Allergy_Patient]
GO
ALTER TABLE [dbo].[EmergencyContact]  WITH CHECK ADD  CONSTRAINT [FK_EmergencyContact_Patient] FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patient] ([PatientID])
GO
ALTER TABLE [dbo].[EmergencyContact] CHECK CONSTRAINT [FK_EmergencyContact_Patient]
GO
ALTER TABLE [dbo].[DoctorSchedule]  WITH CHECK ADD  CONSTRAINT [FK_DoctorSchedule_Doctor] FOREIGN KEY([DoctorID])
REFERENCES [dbo].[Doctor] ([DoctorID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DoctorSchedule] CHECK CONSTRAINT [FK_DoctorSchedule_Doctor]
GO
ALTER TABLE [dbo].[DoctorSchedule]  WITH CHECK ADD  CONSTRAINT [FK_DoctorSchedule_Office] FOREIGN KEY([OfficeID])
REFERENCES [dbo].[Office] ([OfficeID])
GO
ALTER TABLE [dbo].[DoctorSchedule] CHECK CONSTRAINT [FK_DoctorSchedule_Office]
GO
ALTER TABLE [dbo].[ChartRequest]  WITH CHECK ADD  CONSTRAINT [FK_ChartRequest_Doctor] FOREIGN KEY([DoctorID])
REFERENCES [dbo].[Doctor] ([DoctorID])
GO
ALTER TABLE [dbo].[ChartRequest] CHECK CONSTRAINT [FK_ChartRequest_Doctor]
GO
ALTER TABLE [dbo].[ChartRequest]  WITH CHECK ADD  CONSTRAINT [FK_ChartRequest_Patient] FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patient] ([PatientID])
GO
ALTER TABLE [dbo].[ChartRequest] CHECK CONSTRAINT [FK_ChartRequest_Patient]
GO
ALTER TABLE [dbo].[PatientDoctor]  WITH CHECK ADD  CONSTRAINT [FK_PatientDoctor_Doctor] FOREIGN KEY([DoctorID])
REFERENCES [dbo].[Doctor] ([DoctorID])
GO
ALTER TABLE [dbo].[PatientDoctor] CHECK CONSTRAINT [FK_PatientDoctor_Doctor]
GO
ALTER TABLE [dbo].[PatientDoctor]  WITH CHECK ADD  CONSTRAINT [FK_PatientDoctor_Patient] FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patient] ([PatientID])
GO
ALTER TABLE [dbo].[PatientDoctor] CHECK CONSTRAINT [FK_PatientDoctor_Patient]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [FK_Appointment_Doctor] FOREIGN KEY([DoctorID])
REFERENCES [dbo].[Doctor] ([DoctorID])
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [FK_Appointment_Doctor]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [FK_Appointment_Office] FOREIGN KEY([OfficeID])
REFERENCES [dbo].[Office] ([OfficeID])
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [FK_Appointment_Office]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [FK_Appointment_Patient] FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patient] ([PatientID])
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [FK_Appointment_Patient]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [FK_Appointment_Referral] FOREIGN KEY([ReferralID])
REFERENCES [dbo].[Referral] ([ReferralID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [FK_Appointment_Referral]
GO
ALTER TABLE [dbo].[Referral]  WITH CHECK ADD  CONSTRAINT [FK_Referral_Patient] FOREIGN KEY([PatientID])
REFERENCES [dbo].[Patient] ([PatientID])
GO
ALTER TABLE [dbo].[Referral] CHECK CONSTRAINT [FK_Referral_Patient]
GO
ALTER TABLE [dbo].[Referral]  WITH CHECK ADD  CONSTRAINT [FK_Referral_Primary] FOREIGN KEY([PrimaryID])
REFERENCES [dbo].[Doctor] ([DoctorID])
GO
ALTER TABLE [dbo].[Referral] CHECK CONSTRAINT [FK_Referral_Primary]
GO
ALTER TABLE [dbo].[Referral]  WITH CHECK ADD  CONSTRAINT [FK_Referral_Specialist] FOREIGN KEY([SpecialistID])
REFERENCES [dbo].[Doctor] ([DoctorID])
GO
ALTER TABLE [dbo].[Referral] CHECK CONSTRAINT [FK_Referral_Specialist]
GO
ALTER TABLE [dbo].[Diagnosis]  WITH CHECK ADD  CONSTRAINT [CK_Diagnosis_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Diagnosis] CHECK CONSTRAINT [CK_Diagnosis_DeletionFlag]
GO
ALTER TABLE [dbo].[Diagnosis]  WITH CHECK ADD  CONSTRAINT [CK_Diagnosis_DiagnosisID] CHECK  (([DiagnosisID]>=(1)))
GO
ALTER TABLE [dbo].[Diagnosis] CHECK CONSTRAINT [CK_Diagnosis_DiagnosisID]
GO
ALTER TABLE [dbo].[Diagnosis]  WITH CHECK ADD  CONSTRAINT [CK_Diagnosis_DiagnosisType] CHECK  (([DiagnosisType]='Secondary' OR [DiagnosisType]='Primary'))
GO
ALTER TABLE [dbo].[Diagnosis] CHECK CONSTRAINT [CK_Diagnosis_DiagnosisType]
GO
ALTER TABLE [dbo].[MedicalRecord]  WITH CHECK ADD  CONSTRAINT [CK_MedicalRecord_BloodPressure] CHECK  (([SystolicBP]>[DiastolicBP]))
GO
ALTER TABLE [dbo].[MedicalRecord] CHECK CONSTRAINT [CK_MedicalRecord_BloodPressure]
GO
ALTER TABLE [dbo].[MedicalRecord]  WITH CHECK ADD  CONSTRAINT [CK_MedicalRecord_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[MedicalRecord] CHECK CONSTRAINT [CK_MedicalRecord_DeletionFlag]
GO
ALTER TABLE [dbo].[MedicalRecord]  WITH CHECK ADD  CONSTRAINT [CK_MedicalRecord_DiastolicBP] CHECK  (([DiastolicBP]>=(20) AND [DiastolicBP]<=(200)))
GO
ALTER TABLE [dbo].[MedicalRecord] CHECK CONSTRAINT [CK_MedicalRecord_DiastolicBP]
GO
ALTER TABLE [dbo].[MedicalRecord]  WITH CHECK ADD  CONSTRAINT [CK_MedicalRecord_HeartRate] CHECK  (([HeartRate]>=(20) AND [HeartRate]<=(300)))
GO
ALTER TABLE [dbo].[MedicalRecord] CHECK CONSTRAINT [CK_MedicalRecord_HeartRate]
GO
ALTER TABLE [dbo].[MedicalRecord]  WITH CHECK ADD  CONSTRAINT [CK_MedicalRecord_HeightInches] CHECK  (([HeightInches]>(0)))
GO
ALTER TABLE [dbo].[MedicalRecord] CHECK CONSTRAINT [CK_MedicalRecord_HeightInches]
GO
ALTER TABLE [dbo].[MedicalRecord]  WITH CHECK ADD  CONSTRAINT [CK_MedicalRecord_RecordID] CHECK  (([RecordID]>=(1000000) AND [RecordID]<=(9999999)))
GO
ALTER TABLE [dbo].[MedicalRecord] CHECK CONSTRAINT [CK_MedicalRecord_RecordID]
GO
ALTER TABLE [dbo].[MedicalRecord]  WITH CHECK ADD  CONSTRAINT [CK_MedicalRecord_SystolicBP] CHECK  (([SystolicBP]>=(50) AND [SystolicBP]<=(300)))
GO
ALTER TABLE [dbo].[MedicalRecord] CHECK CONSTRAINT [CK_MedicalRecord_SystolicBP]
GO
ALTER TABLE [dbo].[MedicalRecord]  WITH CHECK ADD  CONSTRAINT [CK_MedicalRecord_Temperature] CHECK  (([Temperature]>=(56) AND [Temperature]<=(110)))
GO
ALTER TABLE [dbo].[MedicalRecord] CHECK CONSTRAINT [CK_MedicalRecord_Temperature]
GO
ALTER TABLE [dbo].[MedicalRecord]  WITH CHECK ADD  CONSTRAINT [CK_MedicalRecord_WeightPounds] CHECK  (([WeightPounds]>(0)))
GO
ALTER TABLE [dbo].[MedicalRecord] CHECK CONSTRAINT [CK_MedicalRecord_WeightPounds]
GO
ALTER TABLE [dbo].[Member]  WITH CHECK ADD  CONSTRAINT [CK_Member_DateOfBirth] CHECK  (([DateOfBirth]<=CONVERT([date],getdate())))
GO
ALTER TABLE [dbo].[Member] CHECK CONSTRAINT [CK_Member_DateOfBirth]
GO
ALTER TABLE [dbo].[Member]  WITH CHECK ADD  CONSTRAINT [CK_Member_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Member] CHECK CONSTRAINT [CK_Member_DeletionFlag]
GO
ALTER TABLE [dbo].[Member]  WITH CHECK ADD  CONSTRAINT [CK_Member_Email] CHECK  (([Email] like '%_@_%._%' AND NOT [Email] like '% %'))
GO
ALTER TABLE [dbo].[Member] CHECK CONSTRAINT [CK_Member_Email]
GO
ALTER TABLE [dbo].[Member]  WITH CHECK ADD  CONSTRAINT [CK_Member_FirstName] CHECK  ((NOT [FirstName] like '%[0-9]%'))
GO
ALTER TABLE [dbo].[Member] CHECK CONSTRAINT [CK_Member_FirstName]
GO
ALTER TABLE [dbo].[Member]  WITH CHECK ADD  CONSTRAINT [CK_Member_LastName] CHECK  ((NOT [LastName] like '%[0-9]%'))
GO
ALTER TABLE [dbo].[Member] CHECK CONSTRAINT [CK_Member_LastName]
GO
ALTER TABLE [dbo].[Member]  WITH CHECK ADD  CONSTRAINT [CK_Member_MemberID] CHECK  (([MemberID]>=(1000000) AND [MemberID]<=(9999999)))
GO
ALTER TABLE [dbo].[Member] CHECK CONSTRAINT [CK_Member_MemberID]
GO
ALTER TABLE [dbo].[Member]  WITH CHECK ADD  CONSTRAINT [CK_Member_MiddleName] CHECK  ((NOT [MiddleName] like '%[0-9]%'))
GO
ALTER TABLE [dbo].[Member] CHECK CONSTRAINT [CK_Member_MiddleName]
GO
ALTER TABLE [dbo].[Member]  WITH CHECK ADD  CONSTRAINT [CK_Member_Phone] CHECK  ((len([Phone])=(10) AND NOT [Phone] like '%[^0-9]%'))
GO
ALTER TABLE [dbo].[Member] CHECK CONSTRAINT [CK_Member_Phone]
GO
ALTER TABLE [dbo].[Member]  WITH CHECK ADD  CONSTRAINT [CK_Member_Sex] CHECK  (([Sex]='I' OR [Sex]='F' OR [Sex]='M'))
GO
ALTER TABLE [dbo].[Member] CHECK CONSTRAINT [CK_Member_Sex]
GO
ALTER TABLE [dbo].[Member]  WITH CHECK ADD  CONSTRAINT [CK_Member_SSN] CHECK  (([SSN] like '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Member] CHECK CONSTRAINT [CK_Member_SSN]
GO
ALTER TABLE [dbo].[Member]  WITH CHECK ADD  CONSTRAINT [CK_Member_ZipCode] CHECK  ((len([ZipCode])=(5) AND NOT [ZipCode] like '%[^0-9]%'))
GO
ALTER TABLE [dbo].[Member] CHECK CONSTRAINT [CK_Member_ZipCode]
GO
ALTER TABLE [dbo].[PaymentMethod]  WITH CHECK ADD  CONSTRAINT [CK_PaymentMethod_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[PaymentMethod] CHECK CONSTRAINT [CK_PaymentMethod_DeletionFlag]
GO
ALTER TABLE [dbo].[AppointmentActivityReport]  WITH CHECK ADD  CONSTRAINT [CK_AppointmentActivityReport_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[AppointmentActivityReport] CHECK CONSTRAINT [CK_AppointmentActivityReport_DeletionFlag]
GO
ALTER TABLE [dbo].[Specialty]  WITH CHECK ADD  CONSTRAINT [CK_Specialty_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Specialty] CHECK CONSTRAINT [CK_Specialty_DeletionFlag]
GO
ALTER TABLE [dbo].[Specialty]  WITH CHECK ADD  CONSTRAINT [CK_Specialty_IsPrimaryCare] CHECK  (([IsPrimaryCare]=(1) OR [IsPrimaryCare]=(0)))
GO
ALTER TABLE [dbo].[Specialty] CHECK CONSTRAINT [CK_Specialty_IsPrimaryCare]
GO
ALTER TABLE [dbo].[Specialty]  WITH CHECK ADD  CONSTRAINT [CK_Specialty_VisitFee] CHECK  (([VisitFee]>(0)))
GO
ALTER TABLE [dbo].[Specialty] CHECK CONSTRAINT [CK_Specialty_VisitFee]
GO
ALTER TABLE [dbo].[ReferralTrackingReport]  WITH CHECK ADD  CONSTRAINT [CK_ReferralTrackingReport_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[ReferralTrackingReport] CHECK CONSTRAINT [CK_ReferralTrackingReport_DeletionFlag]
GO
ALTER TABLE [dbo].[VisitDetailsReport]  WITH CHECK ADD  CONSTRAINT [CK_VisitDetailsReport_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[VisitDetailsReport] CHECK CONSTRAINT [CK_VisitDetailsReport_DeletionFlag]
GO
ALTER TABLE [dbo].[PatientHealthSummaryReport]  WITH CHECK ADD  CONSTRAINT [CK_PatientHealthSummaryReport_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[PatientHealthSummaryReport] CHECK CONSTRAINT [CK_PatientHealthSummaryReport_DeletionFlag]
GO
ALTER TABLE [dbo].[PaymentDetail]  WITH CHECK ADD  CONSTRAINT [CK_PaymentDetail_AmountApplied] CHECK  (([AmountApplied]>=(0)))
GO
ALTER TABLE [dbo].[PaymentDetail] CHECK CONSTRAINT [CK_PaymentDetail_AmountApplied]
GO
ALTER TABLE [dbo].[PaymentDetail]  WITH CHECK ADD  CONSTRAINT [CK_PaymentDetail_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[PaymentDetail] CHECK CONSTRAINT [CK_PaymentDetail_DeletionFlag]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [CK_Payment_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [CK_Payment_DeletionFlag]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [CK_Payment_InstallmentNumber] CHECK  (([InstallmentNumber]>=(1)))
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [CK_Payment_InstallmentNumber]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [CK_Payment_PaymentID] CHECK  (([PaymentID]>=(1000000) AND [PaymentID]<=(9999999)))
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [CK_Payment_PaymentID]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [CK_Payment_PayStatus] CHECK  (([PayStatus]='Refunded' OR [PayStatus]='Completed' OR [PayStatus]='Pending'))
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [CK_Payment_PayStatus]
GO
ALTER TABLE [dbo].[InsuranceMixReport]  WITH CHECK ADD  CONSTRAINT [CK_InsuranceMixReport_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[InsuranceMixReport] CHECK CONSTRAINT [CK_InsuranceMixReport_DeletionFlag]
GO
ALTER TABLE [dbo].[OutstandingBalanceReport]  WITH CHECK ADD  CONSTRAINT [CK_OutstandingBalanceReport_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[OutstandingBalanceReport] CHECK CONSTRAINT [CK_OutstandingBalanceReport_DeletionFlag]
GO
ALTER TABLE [dbo].[OfficeRevenueReport]  WITH CHECK ADD  CONSTRAINT [CK_OfficeRevenueReport_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[OfficeRevenueReport] CHECK CONSTRAINT [CK_OfficeRevenueReport_DeletionFlag]
GO
ALTER TABLE [dbo].[Office]  WITH CHECK ADD  CONSTRAINT [CK_Office_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Office] CHECK CONSTRAINT [CK_Office_DeletionFlag]
GO
ALTER TABLE [dbo].[Office]  WITH CHECK ADD  CONSTRAINT [CK_Office_OfficeID] CHECK  (([OfficeID]>=(1000000) AND [OfficeID]<=(9999999)))
GO
ALTER TABLE [dbo].[Office] CHECK CONSTRAINT [CK_Office_OfficeID]
GO
ALTER TABLE [dbo].[Office]  WITH CHECK ADD  CONSTRAINT [CK_Office_Phone] CHECK  ((len([Phone])=(10) AND NOT [Phone] like '%[^0-9]%'))
GO
ALTER TABLE [dbo].[Office] CHECK CONSTRAINT [CK_Office_Phone]
GO
ALTER TABLE [dbo].[Office]  WITH CHECK ADD  CONSTRAINT [CK_Office_Time] CHECK  (([ClosingTime]>[OpeningTime]))
GO
ALTER TABLE [dbo].[Office] CHECK CONSTRAINT [CK_Office_Time]
GO
ALTER TABLE [dbo].[Office]  WITH CHECK ADD  CONSTRAINT [CK_Office_ZipCode] CHECK  ((len([ZipCode])=(5) AND NOT [ZipCode] like '%[^0-9]%'))
GO
ALTER TABLE [dbo].[Office] CHECK CONSTRAINT [CK_Office_ZipCode]
GO
ALTER TABLE [dbo].[DoctorWorkloadReport]  WITH CHECK ADD  CONSTRAINT [CK_DoctorWorkloadReport_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[DoctorWorkloadReport] CHECK CONSTRAINT [CK_DoctorWorkloadReport_DeletionFlag]
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD  CONSTRAINT [CK_Employee_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [CK_Employee_DeletionFlag]
GO
ALTER TABLE [dbo].[Employee]  WITH CHECK ADD  CONSTRAINT [CK_Employee_HiringDate] CHECK  (([HiringDate]<=CONVERT([date],getdate())))
GO
ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [CK_Employee_HiringDate]
GO
ALTER TABLE [dbo].[Patient]  WITH CHECK ADD  CONSTRAINT [CK_Patient_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Patient] CHECK CONSTRAINT [CK_Patient_DeletionFlag]
GO
ALTER TABLE [dbo].[UserAccount]  WITH CHECK ADD  CONSTRAINT [CK_UserAccount_AccountID] CHECK  (([AccountID]>=(1000000) AND [AccountID]<=(9999999)))
GO
ALTER TABLE [dbo].[UserAccount] CHECK CONSTRAINT [CK_UserAccount_AccountID]
GO
ALTER TABLE [dbo].[UserAccount]  WITH CHECK ADD  CONSTRAINT [CK_UserAccount_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[UserAccount] CHECK CONSTRAINT [CK_UserAccount_DeletionFlag]
GO
ALTER TABLE [dbo].[UserAccount]  WITH CHECK ADD  CONSTRAINT [CK_UserAccount_Role] CHECK  (([Role]='Admin' OR [Role]='Receptionist' OR [Role]='Nurse' OR [Role]='Doctor' OR [Role]='Patient'))
GO
ALTER TABLE [dbo].[UserAccount] CHECK CONSTRAINT [CK_UserAccount_Role]
GO
ALTER TABLE [dbo].[PatientCondition]  WITH CHECK ADD  CONSTRAINT [CK_PatientCondition_ConditionID] CHECK  (([ConditionID]>=(1000000) AND [ConditionID]<=(9999999)))
GO
ALTER TABLE [dbo].[PatientCondition] CHECK CONSTRAINT [CK_PatientCondition_ConditionID]
GO
ALTER TABLE [dbo].[PatientCondition]  WITH CHECK ADD  CONSTRAINT [CK_PatientCondition_ConditionType] CHECK  (([ConditionType]='Chronic' OR [ConditionType]='Acute'))
GO
ALTER TABLE [dbo].[PatientCondition] CHECK CONSTRAINT [CK_PatientCondition_ConditionType]
GO
ALTER TABLE [dbo].[PatientCondition]  WITH CHECK ADD  CONSTRAINT [CK_PatientCondition_DateDiagnosed] CHECK  (([DateDiagnosed]<=CONVERT([date],getdate())))
GO
ALTER TABLE [dbo].[PatientCondition] CHECK CONSTRAINT [CK_PatientCondition_DateDiagnosed]
GO
ALTER TABLE [dbo].[PatientCondition]  WITH CHECK ADD  CONSTRAINT [CK_PatientCondition_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[PatientCondition] CHECK CONSTRAINT [CK_PatientCondition_DeletionFlag]
GO
ALTER TABLE [dbo].[PatientCondition]  WITH CHECK ADD  CONSTRAINT [CK_PatientCondition_Severity] CHECK  (([Severity]='Critical' OR [Severity]='Moderate' OR [Severity]='Low'))
GO
ALTER TABLE [dbo].[PatientCondition] CHECK CONSTRAINT [CK_PatientCondition_Severity]
GO
ALTER TABLE [dbo].[Receptionist]  WITH CHECK ADD  CONSTRAINT [CK_Receptionist_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Receptionist] CHECK CONSTRAINT [CK_Receptionist_DeletionFlag]
GO
ALTER TABLE [dbo].[Surgery]  WITH CHECK ADD  CONSTRAINT [CK_Surgery_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Surgery] CHECK CONSTRAINT [CK_Surgery_DeletionFlag]
GO
ALTER TABLE [dbo].[Surgery]  WITH CHECK ADD  CONSTRAINT [CK_Surgery_SurgeryDate] CHECK  (([SurgeryDate]<=CONVERT([date],getdate())))
GO
ALTER TABLE [dbo].[Surgery] CHECK CONSTRAINT [CK_Surgery_SurgeryDate]
GO
ALTER TABLE [dbo].[Surgery]  WITH CHECK ADD  CONSTRAINT [CK_Surgery_SurgeryID] CHECK  (([SurgeryID]>=(1000000) AND [SurgeryID]<=(9999999)))
GO
ALTER TABLE [dbo].[Surgery] CHECK CONSTRAINT [CK_Surgery_SurgeryID]
GO
ALTER TABLE [dbo].[Nurse]  WITH CHECK ADD  CONSTRAINT [CK_Nurse_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Nurse] CHECK CONSTRAINT [CK_Nurse_DeletionFlag]
GO
ALTER TABLE [dbo].[Insurance]  WITH CHECK ADD  CONSTRAINT [CK_Insurance_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Insurance] CHECK CONSTRAINT [CK_Insurance_DeletionFlag]
GO
ALTER TABLE [dbo].[Insurance]  WITH CHECK ADD  CONSTRAINT [CK_Insurance_EffectiveDate] CHECK  (([EffectiveDate]<=CONVERT([date],getdate())))
GO
ALTER TABLE [dbo].[Insurance] CHECK CONSTRAINT [CK_Insurance_EffectiveDate]
GO
ALTER TABLE [dbo].[Insurance]  WITH CHECK ADD  CONSTRAINT [CK_Insurance_ExpirationDate] CHECK  (([ExpirationDate]>[EffectiveDate]))
GO
ALTER TABLE [dbo].[Insurance] CHECK CONSTRAINT [CK_Insurance_ExpirationDate]
GO
ALTER TABLE [dbo].[Insurance]  WITH CHECK ADD  CONSTRAINT [CK_Insurance_GroupNum] CHECK  ((len([GroupNum])=(15) AND NOT [GroupNum] like '%[^0-9]%'))
GO
ALTER TABLE [dbo].[Insurance] CHECK CONSTRAINT [CK_Insurance_GroupNum]
GO
ALTER TABLE [dbo].[Insurance]  WITH CHECK ADD  CONSTRAINT [CK_Insurance_InsuranceID] CHECK  (([InsuranceID]>=(1000000) AND [InsuranceID]<=(9999999)))
GO
ALTER TABLE [dbo].[Insurance] CHECK CONSTRAINT [CK_Insurance_InsuranceID]
GO
ALTER TABLE [dbo].[Insurance]  WITH CHECK ADD  CONSTRAINT [CK_Insurance_PolicyNum] CHECK  ((len([PolicyNum])=(13) AND NOT [PolicyNum] like '%[^0-9]%'))
GO
ALTER TABLE [dbo].[Insurance] CHECK CONSTRAINT [CK_Insurance_PolicyNum]
GO
ALTER TABLE [dbo].[FamilyCondition]  WITH CHECK ADD  CONSTRAINT [CK_FamilyCondition_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[FamilyCondition] CHECK CONSTRAINT [CK_FamilyCondition_DeletionFlag]
GO
ALTER TABLE [dbo].[FamilyCondition]  WITH CHECK ADD  CONSTRAINT [CK_FamilyCondition_FamilyConditionID] CHECK  (([FamilyConditionID]>=(1000000) AND [FamilyConditionID]<=(9999999)))
GO
ALTER TABLE [dbo].[FamilyCondition] CHECK CONSTRAINT [CK_FamilyCondition_FamilyConditionID]
GO
ALTER TABLE [dbo].[Doctor]  WITH CHECK ADD  CONSTRAINT [CK_Doctor_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Doctor] CHECK CONSTRAINT [CK_Doctor_DeletionFlag]
GO
ALTER TABLE [dbo].[Prescription]  WITH CHECK ADD  CONSTRAINT [CK_Prescription_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Prescription] CHECK CONSTRAINT [CK_Prescription_DeletionFlag]
GO
ALTER TABLE [dbo].[Prescription]  WITH CHECK ADD  CONSTRAINT [CK_Prescription_PrescriptionID] CHECK  (([PrescriptionID]>=(1)))
GO
ALTER TABLE [dbo].[Prescription] CHECK CONSTRAINT [CK_Prescription_PrescriptionID]
GO
ALTER TABLE [dbo].[Allergy]  WITH CHECK ADD  CONSTRAINT [CK_Allergy_AllergyID] CHECK  (([AllergyID]>=(1000000) AND [AllergyID]<=(9999999)))
GO
ALTER TABLE [dbo].[Allergy] CHECK CONSTRAINT [CK_Allergy_AllergyID]
GO
ALTER TABLE [dbo].[Allergy]  WITH CHECK ADD  CONSTRAINT [CK_Allergy_DateIdentified] CHECK  (([DateIdentified]<=CONVERT([date],getdate())))
GO
ALTER TABLE [dbo].[Allergy] CHECK CONSTRAINT [CK_Allergy_DateIdentified]
GO
ALTER TABLE [dbo].[Allergy]  WITH CHECK ADD  CONSTRAINT [CK_Allergy_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Allergy] CHECK CONSTRAINT [CK_Allergy_DeletionFlag]
GO
ALTER TABLE [dbo].[Allergy]  WITH CHECK ADD  CONSTRAINT [CK_Allergy_Severity] CHECK  (([Severity]='Fatal' OR [Severity]='Life Threatening' OR [Severity]='Severe' OR [Severity]='Moderate' OR [Severity]='Mild'))
GO
ALTER TABLE [dbo].[Allergy] CHECK CONSTRAINT [CK_Allergy_Severity]
GO
ALTER TABLE [dbo].[EmergencyContact]  WITH CHECK ADD  CONSTRAINT [CK_EmergencyContact_ContactID] CHECK  (([ContactID]>=(1000000) AND [ContactID]<=(9999999)))
GO
ALTER TABLE [dbo].[EmergencyContact] CHECK CONSTRAINT [CK_EmergencyContact_ContactID]
GO
ALTER TABLE [dbo].[EmergencyContact]  WITH CHECK ADD  CONSTRAINT [CK_EmergencyContact_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[EmergencyContact] CHECK CONSTRAINT [CK_EmergencyContact_DeletionFlag]
GO
ALTER TABLE [dbo].[EmergencyContact]  WITH CHECK ADD  CONSTRAINT [CK_EmergencyContact_FirstName] CHECK  ((NOT [FirstName] like '%[0-9]%'))
GO
ALTER TABLE [dbo].[EmergencyContact] CHECK CONSTRAINT [CK_EmergencyContact_FirstName]
GO
ALTER TABLE [dbo].[EmergencyContact]  WITH CHECK ADD  CONSTRAINT [CK_EmergencyContact_LastName] CHECK  ((NOT [LastName] like '%[0-9]%'))
GO
ALTER TABLE [dbo].[EmergencyContact] CHECK CONSTRAINT [CK_EmergencyContact_LastName]
GO
ALTER TABLE [dbo].[EmergencyContact]  WITH CHECK ADD  CONSTRAINT [CK_EmergencyContact_MiddleName] CHECK  ((NOT [MiddleName] like '%[0-9]%'))
GO
ALTER TABLE [dbo].[EmergencyContact] CHECK CONSTRAINT [CK_EmergencyContact_MiddleName]
GO
ALTER TABLE [dbo].[EmergencyContact]  WITH CHECK ADD  CONSTRAINT [CK_EmergencyContact_Phone] CHECK  ((len([Phone])=(10) AND NOT [Phone] like '%[^0-9]%'))
GO
ALTER TABLE [dbo].[EmergencyContact] CHECK CONSTRAINT [CK_EmergencyContact_Phone]
GO
ALTER TABLE [dbo].[DoctorSchedule]  WITH CHECK ADD  CONSTRAINT [CK_DoctorSchedule_DayOfWeek] CHECK  (([DayOfWeek]='Sun' OR [DayOfWeek]='Sat' OR [DayOfWeek]='Fri' OR [DayOfWeek]='Thu' OR [DayOfWeek]='Wed' OR [DayOfWeek]='Tue' OR [DayOfWeek]='Mon'))
GO
ALTER TABLE [dbo].[DoctorSchedule] CHECK CONSTRAINT [CK_DoctorSchedule_DayOfWeek]
GO
ALTER TABLE [dbo].[DoctorSchedule]  WITH CHECK ADD  CONSTRAINT [CK_DoctorSchedule_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[DoctorSchedule] CHECK CONSTRAINT [CK_DoctorSchedule_DeletionFlag]
GO
ALTER TABLE [dbo].[ChartRequest]  WITH CHECK ADD  CONSTRAINT [CK_ChartRequest_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[ChartRequest] CHECK CONSTRAINT [CK_ChartRequest_DeletionFlag]
GO
ALTER TABLE [dbo].[ChartRequest]  WITH CHECK ADD  CONSTRAINT [CK_ChartRequest_RequestID] CHECK  (([RequestID]>=(1000000) AND [RequestID]<=(9999999)))
GO
ALTER TABLE [dbo].[ChartRequest] CHECK CONSTRAINT [CK_ChartRequest_RequestID]
GO
ALTER TABLE [dbo].[ChartRequest]  WITH CHECK ADD  CONSTRAINT [CK_ChartRequest_Status] CHECK  (([RequestStatus]='Sent' OR [RequestStatus]='Pending'))
GO
ALTER TABLE [dbo].[ChartRequest] CHECK CONSTRAINT [CK_ChartRequest_Status]
GO
ALTER TABLE [dbo].[PatientDoctor]  WITH CHECK ADD  CONSTRAINT [CK_PatientDoctor_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[PatientDoctor] CHECK CONSTRAINT [CK_PatientDoctor_DeletionFlag]
GO
ALTER TABLE [dbo].[PatientDoctor]  WITH CHECK ADD  CONSTRAINT [CK_PatientDoctor_RolePlayed] CHECK  (([RolePlayed]='Specialist' OR [RolePlayed]='Primary'))
GO
ALTER TABLE [dbo].[PatientDoctor] CHECK CONSTRAINT [CK_PatientDoctor_RolePlayed]
GO
ALTER TABLE [dbo].[PatientDoctor]  WITH CHECK ADD  CONSTRAINT [CK_PatientDoctor_StartDate] CHECK  (([StartDate]<=CONVERT([date],getdate())))
GO
ALTER TABLE [dbo].[PatientDoctor] CHECK CONSTRAINT [CK_PatientDoctor_StartDate]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [CK_Appointment_AppointmentID] CHECK  (([AppointmentID]>=(1000000) AND [AppointmentID]<=(9999999)))
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [CK_Appointment_AppointmentID]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [CK_Appointment_AppointStatus] CHECK  (([AppointStatus]='Cancelled' OR [AppointStatus]='Completed' OR [AppointStatus]='Scheduled'))
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [CK_Appointment_AppointStatus]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [CK_Appointment_Cancellation] CHECK  (([AppointStatus]='Cancelled' AND [CancelReason] IS NOT NULL AND [CancelledBy] IS NOT NULL OR [AppointStatus]<>'Cancelled' AND [CancelReason] IS NULL AND [CancelledBy] IS NULL))
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [CK_Appointment_Cancellation]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [CK_Appointment_CancellationFee] CHECK  (([CancellationFee] IS NULL OR [CancellationFee]>=(0)))
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [CK_Appointment_CancellationFee]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [CK_Appointment_Channel] CHECK  (([Channel]='Web Portal' OR [Channel]='Phone'))
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [CK_Appointment_Channel]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [CK_Appointment_CheckInStatus] CHECK  (([CheckInStatus]='Ready for doctor' OR [CheckInStatus]='Waiting' OR [CheckInStatus]='Checked in'))
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [CK_Appointment_CheckInStatus]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [CK_Appointment_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [CK_Appointment_DeletionFlag]
GO
ALTER TABLE [dbo].[Appointment]  WITH CHECK ADD  CONSTRAINT [CK_Appointment_TotalCost] CHECK  (([TotalCost]>=(0)))
GO
ALTER TABLE [dbo].[Appointment] CHECK CONSTRAINT [CK_Appointment_TotalCost]
GO
ALTER TABLE [dbo].[Referral]  WITH CHECK ADD  CONSTRAINT [CK_Referral_DateIssued] CHECK  (([DateIssued]<=CONVERT([date],getdate())))
GO
ALTER TABLE [dbo].[Referral] CHECK CONSTRAINT [CK_Referral_DateIssued]
GO
ALTER TABLE [dbo].[Referral]  WITH CHECK ADD  CONSTRAINT [CK_Referral_DeletionFlag] CHECK  (([DeletionFlag]=(1) OR [DeletionFlag]=(0)))
GO
ALTER TABLE [dbo].[Referral] CHECK CONSTRAINT [CK_Referral_DeletionFlag]
GO
ALTER TABLE [dbo].[Referral]  WITH CHECK ADD  CONSTRAINT [CK_Referral_DifferentDoctors] CHECK  (([PrimaryID]<>[SpecialistID]))
GO
ALTER TABLE [dbo].[Referral] CHECK CONSTRAINT [CK_Referral_DifferentDoctors]
GO
ALTER TABLE [dbo].[Referral]  WITH CHECK ADD  CONSTRAINT [CK_Referral_ReferralID] CHECK  (([ReferralID]>=(1000000) AND [ReferralID]<=(9999999)))
GO
ALTER TABLE [dbo].[Referral] CHECK CONSTRAINT [CK_Referral_ReferralID]
GO
ALTER TABLE [dbo].[Referral]  WITH CHECK ADD  CONSTRAINT [CK_Referral_RefStatus] CHECK  (([RefStatus]='Cancelled' OR [RefStatus]='Finished' OR [RefStatus]='Scheduled'))
GO
ALTER TABLE [dbo].[Referral] CHECK CONSTRAINT [CK_Referral_RefStatus]
GO
INSERT [dbo].[Specialty] ([SpecialtyName], [VisitFee], [IsPrimaryCare], [DeletionFlag]) VALUES (N'Cardiology', CAST(300.00 AS Numeric(10, 2)), 0, 0)
INSERT [dbo].[Specialty] ([SpecialtyName], [VisitFee], [IsPrimaryCare], [DeletionFlag]) VALUES (N'Dermatology', CAST(200.00 AS Numeric(10, 2)), 0, 0)
INSERT [dbo].[Specialty] ([SpecialtyName], [VisitFee], [IsPrimaryCare], [DeletionFlag]) VALUES (N'Family Medicine', CAST(150.00 AS Numeric(10, 2)), 1, 0)
INSERT [dbo].[Specialty] ([SpecialtyName], [VisitFee], [IsPrimaryCare], [DeletionFlag]) VALUES (N'Internal Medicine', CAST(150.00 AS Numeric(10, 2)), 1, 0)
INSERT [dbo].[Specialty] ([SpecialtyName], [VisitFee], [IsPrimaryCare], [DeletionFlag]) VALUES (N'Orthopedics', CAST(275.00 AS Numeric(10, 2)), 0, 0)
INSERT [dbo].[Specialty] ([SpecialtyName], [VisitFee], [IsPrimaryCare], [DeletionFlag]) VALUES (N'Pediatrics', CAST(150.00 AS Numeric(10, 2)), 1, 0)
GO
SET IDENTITY_INSERT [dbo].[Member] ON 

INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000000, N'900-10-0001', N'Sarah', NULL, N'Patel', N'100 Oak Street', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135551001', N'F', CAST(N'1980-05-12' AS Date), N'sarah.patel@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000001, N'900-10-0002', N'James', NULL, N'Wilson', N'200 Pine Street', NULL, N'Houston', N'Texas', N'77056', N'USA', N'7135551002', N'M', CAST(N'1975-09-21' AS Date), N'james.wilson@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000002, N'900-10-0003', N'Emily', NULL, N'Garcia', N'300 Elm Street', N'12', N'Houston', N'Texas', N'77003', N'USA', N'7135551003', N'F', CAST(N'1998-03-15' AS Date), N'emily.garcia@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000003, N'900-10-0004', N'Michael', NULL, N'Brown', N'400 Maple Street', NULL, N'Houston', N'Texas', N'77004', N'USA', N'7135551004', N'M', CAST(N'1990-07-08' AS Date), N'michael.brown@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000004, N'900-10-0005', N'Olivia', NULL, N'Davis', N'500 Cedar Street', N'4B', N'Houston', N'Texas', N'77005', N'USA', N'7135551005', N'F', CAST(N'2001-11-25' AS Date), N'olivia.davis@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000005, N'900-10-0006', N'Jessica', NULL, N'Lee', N'600 Willow Street', NULL, N'Houston', N'Texas', N'77006', N'USA', N'7135551006', N'F', CAST(N'1992-04-18' AS Date), N'jessica.lee@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000006, N'900-10-0007', N'Daniel', NULL, N'Martinez', N'700 Birch Street', NULL, N'Houston', N'Texas', N'77007', N'USA', N'7135551007', N'M', CAST(N'1995-08-22' AS Date), N'daniel.martinez@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000007, N'900-10-0008', N'Grace', NULL, N'Kim', N'800 Spruce Street', NULL, N'Houston', N'Texas', N'77008', N'USA', N'7135551008', N'F', CAST(N'1985-02-14' AS Date), N'grace.kim@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000008, N'556-77-8778', N'Josh', N'A', N'Bossio', N'3252 W 70TH ST UNIT 201', NULL, N'Hialeah Gardens', N'FL', N'33018', N'USA', N'7888776889', N'M', CAST(N'2002-02-25' AS Date), N'trompoloco24@gmai.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000009, N'696-77-7777', N'Batman', N'Y', N'Robin', N'Baticueva 1411 st', NULL, N'Gotham', N'DC', N'77777', N'USA', N'4125639999', N'I', CAST(N'1938-12-27' AS Date), N'nosoybatman@gmail.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000010, N'999-65-6767', N'Lebron', NULL, N'James', N'23119 colonial parkway', NULL, N'Katy', N'TX', N'77449', N'USA', N'8327577583', N'M', CAST(N'1998-05-28' AS Date), N'chinitoxgod@gmail.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000011, N'900-20-0001', N'David', NULL, N'Chen', N'810 Oak Street', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135552001', N'M', CAST(N'1982-04-12' AS Date), N'david.chen@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000012, N'900-20-0002', N'Priya', NULL, N'Shah', N'820 Oak Street', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135552002', N'F', CAST(N'1985-03-15' AS Date), N'priya.shah@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000013, N'900-20-0003', N'Robert', NULL, N'Kim', N'830 Oak Street', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135552003', N'M', CAST(N'1979-07-22' AS Date), N'robert.kim@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000014, N'900-20-0004', N'Sophia', NULL, N'Martinez', N'840 Oak Street', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135552004', N'F', CAST(N'1988-09-10' AS Date), N'sophia.martinez@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000015, N'900-20-0005', N'Daniel', NULL, N'Brooks', N'850 Oak Street', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135552005', N'M', CAST(N'1981-11-05' AS Date), N'daniel.brooks@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000016, N'900-20-0006', N'Angela', NULL, N'Nguyen', N'860 Oak Street', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135552006', N'F', CAST(N'1984-06-18' AS Date), N'angela.nguyen@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000017, N'900-20-0007', N'Hannah', NULL, N'Williams', N'870 Oak Street', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135552007', N'F', CAST(N'1993-05-14' AS Date), N'hannah.williams@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000018, N'900-20-0008', N'Kevin', NULL, N'Thomas', N'880 Oak Street', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135552008', N'M', CAST(N'1991-08-20' AS Date), N'kevin.thomas@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000019, N'900-30-0001', N'Emma', NULL, N'Johnson', N'3001 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553001', N'F', CAST(N'1995-02-14' AS Date), N'patient3001@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000020, N'900-30-0002', N'Liam', NULL, N'Anderson', N'3002 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553002', N'M', CAST(N'1988-06-20' AS Date), N'patient3002@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000021, N'900-30-0003', N'Ava', NULL, N'Thompson', N'3003 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553003', N'F', CAST(N'2000-09-12' AS Date), N'patient3003@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000022, N'900-30-0004', N'Noah', NULL, N'Robinson', N'3004 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553004', N'M', CAST(N'1975-04-08' AS Date), N'patient3004@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000023, N'900-30-0005', N'Mia', NULL, N'Clark', N'3005 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553005', N'F', CAST(N'1992-11-25' AS Date), N'patient3005@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000024, N'900-30-0006', N'Ethan', NULL, N'Lewis', N'3006 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553006', N'M', CAST(N'1983-07-17' AS Date), N'patient3006@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000025, N'900-30-0007', N'Isabella', NULL, N'Walker', N'3007 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553007', N'F', CAST(N'2003-01-30' AS Date), N'patient3007@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000026, N'900-30-0008', N'Lucas', NULL, N'Hall', N'3008 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553008', N'M', CAST(N'1969-03-22' AS Date), N'patient3008@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000027, N'900-30-0009', N'Amelia', NULL, N'Allen', N'3009 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553009', N'F', CAST(N'1998-12-05' AS Date), N'patient3009@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000028, N'900-30-0010', N'Mason', NULL, N'Young', N'3010 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553010', N'M', CAST(N'1986-08-19' AS Date), N'patient3010@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000029, N'900-30-0011', N'Harper', NULL, N'King', N'3011 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553011', N'F', CAST(N'1990-05-11' AS Date), N'patient3011@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000030, N'900-30-0012', N'Logan', NULL, N'Wright', N'3012 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553012', N'M', CAST(N'1978-10-16' AS Date), N'patient3012@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000031, N'900-30-0013', N'Evelyn', NULL, N'Scott', N'3013 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553013', N'F', CAST(N'2002-02-28' AS Date), N'patient3013@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000032, N'900-30-0014', N'Jacob', NULL, N'Green', N'3014 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553014', N'M', CAST(N'1981-09-09' AS Date), N'patient3014@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000033, N'900-30-0015', N'Abigail', NULL, N'Baker', N'3015 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553015', N'F', CAST(N'1996-06-06' AS Date), N'patient3015@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000034, N'900-30-0016', N'Henry', NULL, N'Adams', N'3016 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553016', N'M', CAST(N'1972-12-14' AS Date), N'patient3016@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000035, N'900-30-0017', N'Ella', NULL, N'Nelson', N'3017 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553017', N'F', CAST(N'2001-07-21' AS Date), N'patient3017@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000036, NULL, N'Benjamin', NULL, N'Carter', N'3018 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553018', N'M', CAST(N'1989-04-10' AS Date), N'patient3018@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000037, NULL, N'Sofia', NULL, N'Mitchell', N'3019 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553019', N'F', CAST(N'1994-08-03' AS Date), N'patient3019@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000038, NULL, N'Alexander', NULL, N'Perez', N'3020 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553020', N'M', CAST(N'1980-01-18' AS Date), N'patient3020@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000039, NULL, N'Charlotte', NULL, N'Roberts', N'3021 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553021', N'F', CAST(N'1999-05-27' AS Date), N'patient3021@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000040, NULL, N'William', NULL, N'Turner', N'3022 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553022', N'M', CAST(N'1965-11-02' AS Date), N'patient3022@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000041, NULL, N'Grace', NULL, N'Phillips', N'3023 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553023', N'F', CAST(N'2004-03-15' AS Date), N'patient3023@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000042, NULL, N'Samuel', NULL, N'Campbell', N'3024 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553024', N'M', CAST(N'1987-09-23' AS Date), N'patient3024@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000043, NULL, N'Chloe', NULL, N'Parker', N'3025 Houston Avenue', NULL, N'Houston', N'Texas', N'77002', N'USA', N'7135553025', N'F', CAST(N'1993-12-07' AS Date), N'patient3025@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000044, NULL, N'Alex', NULL, N'Rivera', N'100 Test Street', NULL, N'Houston', N'TX', N'77001', N'USA', N'7135550000', N'F', CAST(N'1990-01-01' AS Date), N'test.demopatient@example.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000045, N'142-15-2356', N'Elvira', N'Dora', N'Cristal', N'2132 Main Street', NULL, N'Katy', N'Texas', N'13523', N'United States', N'9067123411', N'F', CAST(N'2000-02-09' AS Date), N'isnumelI@gmail.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000046, NULL, N'hey', NULL, N'l', N'9607 orchud spring lane', NULL, N'katy', N'TX', N'77584', N'US', N'1234567892', N'F', CAST(N'2026-11-09' AS Date), N'hey@gmail.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000047, NULL, N'Harris', NULL, N'Ali', N'16252626', NULL, N'Sugarland', N'Texas', N'77099', N'USA', N'1234567890', N'M', CAST(N'1961-09-10' AS Date), N'qweeheh@gmail.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000048, N'123-45-6788', N'john', NULL, N'doe', N'9607 orchud spring lane', NULL, N'katy', N'TX', N'77686', N'US', N'1237623472', N'F', CAST(N'2023-02-10' AS Date), N'john@gmail.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000050, N'123-45-6789', N'John', N'Martinez', N'Putam', N'9607 ochid', NULL, N'katy', N'TX', N'77585', N'United States', N'3467623472', N'M', CAST(N'2026-11-10' AS Date), N'jphndoe@gmail.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000053, N'123-45-6780', N'jphn', N'Martinez', N'doe', N'11423 Glenwick Haven Dr', NULL, N'Richmond', N'Texas', N'77406', N'United States', N'3467623472', N'M', CAST(N'2026-11-10' AS Date), N'jphndo1e@gmail.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000054, NULL, N'jane', NULL, N'doe', N'123 lakes dr', NULL, N'houston', N'tx', N'77054', N'usa', N'2222222222', N'M', CAST(N'2005-10-18' AS Date), N'jd@outlook.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000055, N'123-45-1234', N'john', N'Martinez', N'doe', N'11423 Glenwick Haven Dr', NULL, N'Richmond', N'Texas', N'77406', N'United States', N'3467623472', N'F', CAST(N'2026-11-10' AS Date), N'jdoet@gmail.com', 0)
INSERT [dbo].[Member] ([MemberID], [SSN], [FirstName], [MiddleName], [LastName], [StreetAddress], [ApartmentNum], [City], [State], [ZipCode], [Country], [Phone], [Sex], [DateOfBirth], [Email], [DeletionFlag]) VALUES (1000056, NULL, N'Tupu', NULL, N'Tamadre', N'Nobita 232', NULL, N'Andorra', N'Bucaramanga', N'45454', N'USA', N'1234567891', N'I', CAST(N'2000-11-11' AS Date), N'tupu@chupalo.com', 0)
SET IDENTITY_INSERT [dbo].[Member] OFF
GO
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000000, CAST(N'2022-06-01' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000001, CAST(N'2021-03-15' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000005, CAST(N'2023-01-10' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000006, CAST(N'2024-05-15' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000007, CAST(N'2020-08-01' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000011, CAST(N'2023-06-01' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000012, CAST(N'2023-06-01' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000013, CAST(N'2023-06-01' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000014, CAST(N'2023-06-01' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000015, CAST(N'2023-06-01' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000016, CAST(N'2023-06-01' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000017, CAST(N'2024-01-15' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000018, CAST(N'2024-01-15' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000048, CAST(N'2026-11-10' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000050, CAST(N'2026-11-10' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000053, CAST(N'2026-11-10' AS Date), 0)
INSERT [dbo].[Employee] ([EmployeeID], [HiringDate], [DeletionFlag]) VALUES (1000055, CAST(N'2026-11-10' AS Date), 0)
GO
INSERT [dbo].[Doctor] ([DoctorID], [LicenseNum], [Specialty], [DeletionFlag]) VALUES (1000000, N'TX-MD-10001', N'Family Medicine', 0)
INSERT [dbo].[Doctor] ([DoctorID], [LicenseNum], [Specialty], [DeletionFlag]) VALUES (1000001, N'TX-MD-10002', N'Cardiology', 0)
INSERT [dbo].[Doctor] ([DoctorID], [LicenseNum], [Specialty], [DeletionFlag]) VALUES (1000011, N'TX-MD-20001', N'Internal Medicine', 0)
INSERT [dbo].[Doctor] ([DoctorID], [LicenseNum], [Specialty], [DeletionFlag]) VALUES (1000012, N'TX-MD-20002', N'Family Medicine', 0)
INSERT [dbo].[Doctor] ([DoctorID], [LicenseNum], [Specialty], [DeletionFlag]) VALUES (1000013, N'TX-MD-20003', N'Pediatrics', 0)
INSERT [dbo].[Doctor] ([DoctorID], [LicenseNum], [Specialty], [DeletionFlag]) VALUES (1000014, N'TX-MD-20004', N'Dermatology', 0)
INSERT [dbo].[Doctor] ([DoctorID], [LicenseNum], [Specialty], [DeletionFlag]) VALUES (1000015, N'TX-MD-20005', N'Orthopedics', 0)
INSERT [dbo].[Doctor] ([DoctorID], [LicenseNum], [Specialty], [DeletionFlag]) VALUES (1000016, N'TX-MD-20006', N'Cardiology', 0)
GO
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000002, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000003, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000004, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000008, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000009, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000010, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000019, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000020, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000021, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000022, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000023, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000024, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000025, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000026, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000027, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000028, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000029, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000030, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000031, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000032, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000033, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000034, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000035, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000036, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000037, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000038, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000039, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000040, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000041, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000042, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000043, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000044, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000045, 1)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000046, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000047, 0)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000054, 1)
INSERT [dbo].[Patient] ([PatientID], [DeletionFlag]) VALUES (1000056, 0)
GO
SET IDENTITY_INSERT [dbo].[Referral] ON 

INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000000, 1000002, 1000001, 1000000, CAST(N'2026-06-15' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000001, 1000003, 1000001, 1000000, CAST(N'2026-06-20' AS Date), N'Finished', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000002, 1000004, 1000001, 1000000, CAST(N'2026-08-20' AS Date), N'Finished', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000003, 1000002, 1000001, 1000000, CAST(N'2026-11-08' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000004, 1000019, 1000016, 1000012, CAST(N'2026-11-08' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000006, 1000044, 1000001, 1000000, CAST(N'2026-11-08' AS Date), N'Finished', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000008, 1000044, 1000016, 1000000, CAST(N'2026-11-08' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000009, 1000009, 1000014, 1000000, CAST(N'2026-11-09' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000010, 1000025, 1000013, 1000012, CAST(N'2026-10-04' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000011, 1000031, 1000013, 1000012, CAST(N'2026-10-16' AS Date), N'Finished', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000012, 1000035, 1000013, 1000012, CAST(N'2026-11-01' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000013, 1000021, 1000014, 1000012, CAST(N'2026-10-03' AS Date), N'Finished', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000014, 1000022, 1000014, 1000011, CAST(N'2026-10-19' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000015, 1000033, 1000014, 1000012, CAST(N'2026-10-31' AS Date), N'Finished', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000016, 1000024, 1000015, 1000011, CAST(N'2026-10-10' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000017, 1000034, 1000015, 1000011, CAST(N'2026-10-12' AS Date), N'Finished', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000018, 1000029, 1000015, 1000012, CAST(N'2026-11-02' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000019, 1000026, 1000016, 1000011, CAST(N'2026-10-06' AS Date), N'Finished', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000020, 1000040, 1000016, 1000011, CAST(N'2026-10-09' AS Date), N'Finished', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000021, 1000030, 1000016, 1000011, CAST(N'2026-11-03' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000022, 1000032, 1000016, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000023, 1000022, 1000001, 1000011, CAST(N'2026-11-03' AS Date), N'Finished', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000024, 1000021, 1000014, 1000012, CAST(N'2026-11-03' AS Date), N'Finished', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000025, 1000024, 1000001, 1000011, CAST(N'2026-11-03' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000026, 1000035, 1000014, 1000012, CAST(N'2026-11-03' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000027, 1000038, 1000001, 1000011, CAST(N'2026-11-03' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000028, 1000021, 1000000, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000029, 1000022, 1000000, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000030, 1000024, 1000000, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000031, 1000026, 1000013, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000032, 1000028, 1000001, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000033, 1000030, 1000001, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000034, 1000031, 1000001, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000035, 1000038, 1000014, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000036, 1000039, 1000014, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000037, 1000040, 1000014, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000038, 1000042, 1000015, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000039, 1000043, 1000015, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000040, 1000033, 1000016, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000041, 1000034, 1000016, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000042, 1000035, 1000000, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000043, 1000036, 1000000, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000044, 1000038, 1000000, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000045, 1000030, 1000013, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000046, 1000031, 1000013, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000047, 1000033, 1000013, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000048, 1000040, 1000016, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000049, 1000042, 1000016, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000050, 1000043, 1000001, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000051, 1000021, 1000001, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000052, 1000022, 1000001, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000053, 1000031, 1000014, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000054, 1000032, 1000014, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000055, 1000033, 1000014, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000056, 1000034, 1000015, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000057, 1000035, 1000015, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000058, 1000036, 1000015, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000059, 1000039, 1000000, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000060, 1000040, 1000000, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000061, 1000028, 1000013, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000062, 1000029, 1000013, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000063, 1000032, 1000001, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000064, 1000042, 1000014, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000065, 1000043, 1000014, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000066, 1000021, 1000014, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000067, 1000022, 1000015, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000068, 1000025, 1000015, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000069, 1000026, 1000000, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000070, 1000028, 1000000, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000071, 1000029, 1000000, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000072, 1000036, 1000016, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000073, 1000038, 1000016, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000074, 1000039, 1000016, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000075, 1000042, 1000000, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000076, 1000043, 1000000, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000077, 1000032, 1000013, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000078, 1000035, 1000016, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000079, 1000039, 1000001, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000080, 1000040, 1000001, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000081, 1000025, 1000014, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000082, 1000026, 1000014, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000083, 1000028, 1000014, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000084, 1000030, 1000015, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000085, 1000031, 1000015, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000086, 1000032, 1000000, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000087, 1000033, 1000000, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000088, 1000034, 1000000, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000089, 1000021, 1000013, 1000012, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000090, 1000022, 1000013, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000091, 1000024, 1000013, 1000011, CAST(N'2026-11-06' AS Date), N'Scheduled', 0)
INSERT [dbo].[Referral] ([ReferralID], [PatientID], [SpecialistID], [PrimaryID], [DateIssued], [RefStatus], [DeletionFlag]) VALUES (1000092, 1000010, 1000001, 1000000, CAST(N'2026-11-10' AS Date), N'Scheduled', 0)
SET IDENTITY_INSERT [dbo].[Referral] OFF
GO
SET IDENTITY_INSERT [dbo].[Office] ON 

INSERT [dbo].[Office] ([OfficeID], [StreetAddress], [SuiteNum], [City], [State], [ZipCode], [Country], [Phone], [OpeningTime], [ClosingTime], [DeletionFlag]) VALUES (1000000, N'1234 Main Street', N'100', N'Houston', N'Texas', N'77002', N'USA', N'7135550100', CAST(N'08:00:00' AS Time), CAST(N'17:00:00' AS Time), 0)
INSERT [dbo].[Office] ([OfficeID], [StreetAddress], [SuiteNum], [City], [State], [ZipCode], [Country], [Phone], [OpeningTime], [ClosingTime], [DeletionFlag]) VALUES (1000001, N'5678 Westheimer Road', N'200', N'Houston', N'Texas', N'77056', N'USA', N'7135550200', CAST(N'09:00:00' AS Time), CAST(N'18:00:00' AS Time), 0)
SET IDENTITY_INSERT [dbo].[Office] OFF
GO
SET IDENTITY_INSERT [dbo].[Appointment] ON 

INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000000, 1000000, 1000000, 1000002, NULL, CAST(N'2026-07-06T09:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Flu symptoms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000001, 1000001, 1000001, 1000003, 1000001, CAST(N'2026-07-07T10:00:00.0000000' AS DateTime2), N'Completed', CAST(250.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up after tests', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000002, 1000000, 1000000, 1000004, NULL, CAST(N'2026-08-03T11:00:00.0000000' AS DateTime2), N'Completed', CAST(125.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000003, 1000001, 1000001, 1000002, 1000000, CAST(N'2026-08-04T14:00:00.0000000' AS DateTime2), N'Completed', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Heart palpitations', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000004, 1000000, 1000000, 1000003, NULL, CAST(N'2026-09-07T09:00:00.0000000' AS DateTime2), N'Completed', CAST(175.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000005, 1000001, 1000001, 1000004, 1000002, CAST(N'2026-09-08T10:30:00.0000000' AS DateTime2), N'Completed', CAST(250.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000006, 1000000, 1000000, 1000002, NULL, CAST(N'2026-10-05T09:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Flu symptoms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000007, 1000001, 1000001, 1000003, 1000001, CAST(N'2026-10-06T09:30:00.0000000' AS DateTime2), N'Completed', CAST(250.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up after tests', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000008, 1000000, 1000000, 1000003, NULL, CAST(N'2026-10-12T09:00:00.0000000' AS DateTime2), N'Cancelled', CAST(175.00 AS Numeric(10, 2)), N'Phone', N'Patient unavailable', N'Patient', 0, NULL, N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000009, 1000001, 1000001, 1000004, 1000002, CAST(N'2026-10-13T14:00:00.0000000' AS DateTime2), N'Cancelled', CAST(250.00 AS Numeric(10, 2)), N'Web Portal', N'Schedule conflict', N'Patient', 0, NULL, N'Heart palpitations', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000010, 1000000, 1000000, 1000004, NULL, CAST(N'2026-12-02T09:00:00.0000000' AS DateTime2), N'Scheduled', CAST(125.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000011, 1000001, 1000001, 1000002, 1000000, CAST(N'2026-12-03T11:00:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Heart checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000012, 1000000, 1000000, 1000008, NULL, CAST(N'2026-11-02T13:00:00.0000000' AS DateTime2), N'Cancelled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', N'Closed out by the clinic', N'Doctor', 0, NULL, N'Flu symptoms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000013, 1000000, 1000000, 1000009, NULL, CAST(N'2026-10-30T16:30:00.0000000' AS DateTime2), N'Cancelled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', N'Closed out by the clinic', N'Doctor', 0, NULL, N'Blood pressure check', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000016, 1000000, 1000000, 1000002, NULL, CAST(N'2026-11-16T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 1, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000017, 1000000, 1000000, 1000004, NULL, CAST(N'2026-11-06T10:00:00.0000000' AS DateTime2), N'Cancelled', CAST(150.00 AS Numeric(10, 2)), N'Phone', N'Closed out by the clinic', N'Doctor', 0, NULL, N'Back pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000018, 1000000, 1000012, 1000019, NULL, CAST(N'2026-09-09T09:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Cough and sore throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000019, 1000000, 1000011, 1000020, NULL, CAST(N'2026-09-08T10:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Blood pressure check', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000020, 1000000, 1000012, 1000021, NULL, CAST(N'2026-09-07T11:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Diabetes follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000021, 1000000, 1000011, 1000022, NULL, CAST(N'2026-09-08T12:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Shortness of breath', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000022, 1000000, 1000012, 1000023, NULL, CAST(N'2026-09-11T13:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Allergy symptoms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000023, 1000000, 1000011, 1000024, NULL, CAST(N'2026-09-15T14:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Cough and sore throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000024, 1000000, 1000012, 1000025, NULL, CAST(N'2026-09-16T09:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Blood pressure check', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000025, 1000000, 1000011, 1000026, NULL, CAST(N'2026-09-15T10:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Diabetes follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000026, 1000000, 1000012, 1000027, NULL, CAST(N'2026-09-14T11:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Shortness of breath', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000027, 1000000, 1000011, 1000028, NULL, CAST(N'2026-09-15T12:00:00.0000000' AS DateTime2), N'Cancelled', CAST(150.00 AS Numeric(10, 2)), N'Phone', N'Patient unavailable', N'Patient', 1, NULL, N'Annual physical', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000028, 1000000, 1000012, 1000029, NULL, CAST(N'2026-09-25T13:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Cough and sore throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000029, 1000000, 1000011, 1000030, NULL, CAST(N'2026-09-22T14:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Blood pressure check', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000030, 1000000, 1000012, 1000031, NULL, CAST(N'2026-09-23T09:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Diabetes follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000031, 1000000, 1000011, 1000032, NULL, CAST(N'2026-09-22T10:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Shortness of breath', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000032, 1000000, 1000012, 1000033, NULL, CAST(N'2026-09-21T11:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Allergy symptoms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000033, 1000000, 1000011, 1000034, NULL, CAST(N'2026-09-29T12:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Cough and sore throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000034, 1000000, 1000012, 1000035, NULL, CAST(N'2026-10-02T13:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Blood pressure check', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000035, 1000000, 1000011, 1000036, NULL, CAST(N'2026-09-29T14:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Diabetes follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000036, 1000000, 1000012, 1000037, NULL, CAST(N'2026-09-30T09:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Shortness of breath', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000037, 1000000, 1000011, 1000038, NULL, CAST(N'2026-09-29T10:00:00.0000000' AS DateTime2), N'Cancelled', CAST(150.00 AS Numeric(10, 2)), N'Phone', N'Patient unavailable', N'Patient', 0, NULL, N'Stomach pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000038, 1000000, 1000012, 1000039, NULL, CAST(N'2026-10-05T11:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Cough and sore throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000039, 1000000, 1000011, 1000040, NULL, CAST(N'2026-10-06T12:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Blood pressure check', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000040, 1000000, 1000012, 1000041, NULL, CAST(N'2026-10-09T13:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Diabetes follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000041, 1000000, 1000011, 1000042, NULL, CAST(N'2026-10-06T14:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Shortness of breath', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000042, 1000000, 1000012, 1000043, NULL, CAST(N'2026-10-07T09:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Allergy symptoms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000043, 1000000, 1000012, 1000019, NULL, CAST(N'2026-10-16T10:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Cough and sore throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000044, 1000000, 1000011, 1000020, NULL, CAST(N'2026-10-15T11:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Blood pressure check', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000045, 1000000, 1000012, 1000021, NULL, CAST(N'2026-10-14T12:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Diabetes follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000046, 1000000, 1000011, 1000022, NULL, CAST(N'2026-10-15T13:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Shortness of breath', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000047, 1000000, 1000012, 1000023, NULL, CAST(N'2026-10-12T14:00:00.0000000' AS DateTime2), N'Cancelled', CAST(150.00 AS Numeric(10, 2)), N'Phone', N'Patient unavailable', N'Patient', 0, NULL, N'Back pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000048, 1000000, 1000000, 1000002, NULL, CAST(N'2026-11-27T13:30:00.0000000' AS DateTime2), N'Cancelled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', N'Transportation problems', N'Patient', 0, NULL, N'Flu symptoms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000099, 1000001, 1000001, 1000002, 1000000, CAST(N'2026-11-19T16:00:00.0000000' AS DateTime2), N'Cancelled', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', N'Transportation problems', N'Patient', 0, NULL, N'Heart palpitations', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000101, 1000000, 1000000, 1000004, NULL, CAST(N'2026-11-09T11:26:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Back pain', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000105, 1000000, 1000012, 1000027, NULL, CAST(N'2026-11-11T11:35:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Cough and sore throat', N'Checked in')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000125, 1000000, 1000012, 1000041, NULL, CAST(N'2026-11-09T15:25:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Back pain', N'Waiting')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000126, 1000000, 1000012, 1000037, NULL, CAST(N'2026-11-11T15:26:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Flu symptoms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000134, 1000000, 1000000, 1000010, NULL, CAST(N'2026-11-11T14:26:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Annual checkup', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000135, 1000000, 1000012, 1000023, NULL, CAST(N'2026-11-06T10:00:00.0000000' AS DateTime2), N'Cancelled', CAST(150.00 AS Numeric(10, 2)), N'Phone', N'Cancelled same day', N'Patient', 0, CAST(25.00 AS Numeric(10, 2)), N'Cough and sore throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000136, 1000000, 1000012, 1000019, NULL, CAST(N'2026-11-11T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Follow-up visit', N'Checked in')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000140, 1000000, 1000000, 1000044, NULL, CAST(N'2026-11-09T15:00:00.0000000' AS DateTime2), N'Cancelled', CAST(150.00 AS Numeric(10, 2)), N'Phone', N'Running late', N'Patient', 0, CAST(25.00 AS Numeric(10, 2)), N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000141, 1000000, 1000000, 1000044, NULL, CAST(N'2026-11-11T13:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Cough and sore throat', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000149, 1000000, 1000000, 1000002, NULL, CAST(N'2026-11-30T12:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Back pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000150, 1000000, 1000000, 1000002, NULL, CAST(N'2026-11-09T10:00:00.0000000' AS DateTime2), N'Cancelled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', N'Transportation problems', N'Patient', 0, CAST(25.00 AS Numeric(10, 2)), N'Flu symptoms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000151, 1000001, 1000001, 1000044, 1000006, CAST(N'2026-11-10T09:00:00.0000000' AS DateTime2), N'Cancelled', CAST(300.00 AS Numeric(10, 2)), N'Phone', N'Running late', N'Patient', 0, CAST(25.00 AS Numeric(10, 2)), N'Follow-up on cough', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000152, 1000000, 1000000, 1000044, NULL, CAST(N'2026-11-18T15:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Back pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000164, 1000000, 1000000, 1000010, NULL, CAST(N'2027-01-06T10:08:00.0000000' AS DateTime2), N'Cancelled', CAST(150.00 AS Numeric(10, 2)), N'Phone', N'Running late', N'Patient', 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000169, 1000000, 1000000, 1000010, NULL, CAST(N'2027-01-06T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000170, 1000000, 1000000, 1000002, NULL, CAST(N'2026-11-25T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Cough', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000171, 1000001, 1000001, 1000002, 1000003, CAST(N'2026-11-24T13:00:00.0000000' AS DateTime2), N'Cancelled', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', N'Transportation Problems', N'Patient', 0, NULL, N'Chest pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000178, 1000001, 1000013, 1000025, 1000010, CAST(N'2026-10-14T10:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Fever and sore throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000179, 1000001, 1000013, 1000031, 1000011, CAST(N'2026-10-26T14:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Ear pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000180, 1000001, 1000013, 1000035, 1000012, CAST(N'2026-11-11T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Wellness checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000181, 1000001, 1000013, 1000025, 1000010, CAST(N'2026-11-16T11:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up after strep throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000182, 1000001, 1000014, 1000021, 1000013, CAST(N'2026-10-13T11:00:00.0000000' AS DateTime2), N'Completed', CAST(200.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Itchy rash on arms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000183, 1000001, 1000014, 1000022, 1000014, CAST(N'2026-10-29T15:00:00.0000000' AS DateTime2), N'Completed', CAST(200.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Mole check', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000184, 1000001, 1000014, 1000033, 1000015, CAST(N'2026-11-10T10:00:00.0000000' AS DateTime2), N'Completed', CAST(200.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Acne', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000185, 1000001, 1000014, 1000022, 1000014, CAST(N'2026-11-12T13:00:00.0000000' AS DateTime2), N'Scheduled', CAST(200.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'New spot on shoulder', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000186, 1000000, 1000015, 1000024, 1000016, CAST(N'2026-10-20T09:30:00.0000000' AS DateTime2), N'Completed', CAST(275.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Knee pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000187, 1000000, 1000015, 1000034, 1000017, CAST(N'2026-10-22T13:30:00.0000000' AS DateTime2), N'Completed', CAST(275.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Lower back pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000188, 1000000, 1000015, 1000029, 1000018, CAST(N'2026-11-12T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(275.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Wrist pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000189, 1000000, 1000015, 1000024, 1000016, CAST(N'2026-11-17T11:00:00.0000000' AS DateTime2), N'Scheduled', CAST(275.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Knee follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000190, 1000001, 1000016, 1000026, 1000019, CAST(N'2026-10-16T10:00:00.0000000' AS DateTime2), N'Completed', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Chest pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000191, 1000001, 1000016, 1000040, 1000020, CAST(N'2026-10-19T15:00:00.0000000' AS DateTime2), N'Completed', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Heart palpitations', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000192, 1000001, 1000016, 1000030, 1000021, CAST(N'2026-11-13T09:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Shortness of breath', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000193, 1000001, 1000016, 1000032, 1000022, CAST(N'2026-11-16T14:00:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Blood pressure follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000194, 1000001, 1000001, 1000044, 1000006, CAST(N'2026-11-10T09:00:00.0000000' AS DateTime2), N'Completed', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up on cough', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000198, 1000000, 1000011, 1000030, NULL, CAST(N'2026-11-10T08:30:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Annual physical', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000199, 1000000, 1000011, 1000032, NULL, CAST(N'2026-11-10T09:30:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Diabetes follow-up', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000200, 1000000, 1000011, 1000026, NULL, CAST(N'2026-11-10T11:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Blood pressure check', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000201, 1000000, 1000015, 1000029, 1000018, CAST(N'2026-11-10T13:30:00.0000000' AS DateTime2), N'Completed', CAST(275.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Wrist pain', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000202, 1000000, 1000011, 1000040, NULL, CAST(N'2026-11-10T16:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up after heart monitor', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000203, 1000000, 1000011, 1000034, NULL, CAST(N'2026-11-10T16:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Cough', N'Checked in')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000204, 1000001, 1000001, 1000022, 1000023, CAST(N'2026-11-10T11:30:00.0000000' AS DateTime2), N'Completed', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Chest pain', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000205, 1000001, 1000014, 1000021, 1000024, CAST(N'2026-11-10T14:00:00.0000000' AS DateTime2), N'Completed', CAST(200.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Eczema flare-up', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000206, 1000001, 1000001, 1000024, 1000025, CAST(N'2026-11-10T16:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Heart palpitations', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000207, 1000001, 1000014, 1000035, 1000026, CAST(N'2026-11-10T17:00:00.0000000' AS DateTime2), N'Scheduled', CAST(200.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Skin rash', N'Checked in')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000208, 1000001, 1000001, 1000038, 1000027, CAST(N'2026-11-10T17:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Heart checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000209, 1000000, 1000011, 1000028, NULL, CAST(N'2026-11-03T10:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Flu symptoms', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000210, 1000000, 1000011, 1000036, NULL, CAST(N'2026-11-03T11:30:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Sinus pressure', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000211, 1000000, 1000011, 1000038, NULL, CAST(N'2026-11-03T14:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Blood pressure check', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000212, 1000000, 1000012, 1000039, NULL, CAST(N'2026-11-04T09:00:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Allergy symptoms', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000213, 1000000, 1000011, 1000042, NULL, CAST(N'2026-11-05T15:30:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Shortness of breath', N'Ready for doctor')
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000214, 1000000, 1000012, 1000043, NULL, CAST(N'2026-11-06T10:30:00.0000000' AS DateTime2), N'Completed', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Cough and sore throat', N'Ready for doctor')
GO
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000215, 1000000, 1000011, 1000028, NULL, CAST(N'2026-11-17T09:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Follow-up after the flu', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000216, 1000000, 1000012, 1000039, NULL, CAST(N'2026-11-16T13:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000217, 1000000, 1000011, 1000042, NULL, CAST(N'2026-11-17T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Asthma follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000218, 1000000, 1000011, 1000038, NULL, CAST(N'2026-11-19T11:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Blood pressure follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000219, 1000000, 1000012, 1000043, NULL, CAST(N'2026-11-20T14:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Cough follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000220, 1000000, 1000011, 1000036, NULL, CAST(N'2026-11-24T09:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Sinus follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000221, 1000000, 1000000, 1000021, 1000028, CAST(N'2026-11-11T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000222, 1000000, 1000000, 1000022, 1000029, CAST(N'2026-11-11T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Flu symptoms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000223, 1000000, 1000000, 1000024, 1000030, CAST(N'2026-11-11T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Cough and sore throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000224, 1000001, 1000013, 1000025, 1000010, CAST(N'2026-11-11T12:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Fever', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000225, 1000001, 1000013, 1000026, 1000031, CAST(N'2026-11-11T15:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Vaccination', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000226, 1000001, 1000001, 1000028, 1000032, CAST(N'2026-11-12T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Heart checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000227, 1000001, 1000001, 1000030, 1000033, CAST(N'2026-11-12T12:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Chest pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000228, 1000001, 1000001, 1000031, 1000034, CAST(N'2026-11-12T15:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Blood pressure follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000229, 1000000, 1000011, 1000032, NULL, CAST(N'2026-11-12T09:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Annual physical', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000230, 1000000, 1000011, 1000034, NULL, CAST(N'2026-11-12T11:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Lab results review', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000231, 1000000, 1000011, 1000036, NULL, CAST(N'2026-11-12T14:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Annual physical', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000232, 1000001, 1000014, 1000038, 1000035, CAST(N'2026-11-12T09:30:00.0000000' AS DateTime2), N'Scheduled', CAST(200.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Mole check', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000233, 1000001, 1000014, 1000039, 1000036, CAST(N'2026-11-12T11:30:00.0000000' AS DateTime2), N'Scheduled', CAST(200.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Eczema flare-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000234, 1000001, 1000014, 1000040, 1000037, CAST(N'2026-11-12T14:30:00.0000000' AS DateTime2), N'Scheduled', CAST(200.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000235, 1000000, 1000015, 1000042, 1000038, CAST(N'2026-11-12T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(275.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Knee pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000236, 1000000, 1000015, 1000043, 1000039, CAST(N'2026-11-12T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(275.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Shoulder pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000237, 1000000, 1000000, 1000021, 1000028, CAST(N'2026-11-13T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000238, 1000000, 1000000, 1000022, 1000029, CAST(N'2026-11-13T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Flu symptoms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000239, 1000000, 1000000, 1000024, 1000030, CAST(N'2026-11-13T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Cough and sore throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000240, 1000000, 1000012, 1000025, NULL, CAST(N'2026-11-13T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000241, 1000000, 1000012, 1000029, NULL, CAST(N'2026-11-13T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Blood pressure check', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000242, 1000000, 1000012, 1000031, NULL, CAST(N'2026-11-13T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000243, 1000001, 1000016, 1000032, 1000022, CAST(N'2026-11-13T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Heart palpitations', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000244, 1000001, 1000016, 1000033, 1000040, CAST(N'2026-11-13T12:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Heart checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000245, 1000001, 1000016, 1000034, 1000041, CAST(N'2026-11-13T15:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up after tests', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000246, 1000000, 1000000, 1000035, 1000042, CAST(N'2026-11-16T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Flu symptoms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000247, 1000000, 1000000, 1000036, 1000043, CAST(N'2026-11-16T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000248, 1000000, 1000000, 1000038, 1000044, CAST(N'2026-11-16T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Back pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000249, 1000000, 1000012, 1000043, NULL, CAST(N'2026-11-16T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000250, 1000000, 1000012, 1000021, NULL, CAST(N'2026-11-16T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Back pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000251, 1000000, 1000012, 1000029, NULL, CAST(N'2026-11-16T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000252, 1000001, 1000013, 1000030, 1000045, CAST(N'2026-11-16T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000253, 1000001, 1000013, 1000031, 1000046, CAST(N'2026-11-16T12:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Fever', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000254, 1000001, 1000013, 1000033, 1000047, CAST(N'2026-11-16T15:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Rash', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000255, 1000001, 1000016, 1000034, 1000041, CAST(N'2026-11-16T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Heart checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000256, 1000001, 1000016, 1000040, 1000048, CAST(N'2026-11-16T12:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Shortness of breath', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000257, 1000001, 1000016, 1000042, 1000049, CAST(N'2026-11-16T15:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Heart palpitations', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000258, 1000001, 1000001, 1000043, 1000050, CAST(N'2026-11-17T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Chest pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000259, 1000001, 1000001, 1000021, 1000051, CAST(N'2026-11-17T12:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Heart checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000260, 1000001, 1000001, 1000022, 1000052, CAST(N'2026-11-17T15:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up after tests', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000261, 1000000, 1000011, 1000026, NULL, CAST(N'2026-11-17T11:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Fatigue', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000262, 1000000, 1000011, 1000030, NULL, CAST(N'2026-11-17T14:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Annual physical', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000263, 1000001, 1000014, 1000031, 1000053, CAST(N'2026-11-17T09:30:00.0000000' AS DateTime2), N'Scheduled', CAST(200.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Skin rash', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000264, 1000001, 1000014, 1000032, 1000054, CAST(N'2026-11-17T11:30:00.0000000' AS DateTime2), N'Scheduled', CAST(200.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Acne', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000265, 1000001, 1000014, 1000033, 1000055, CAST(N'2026-11-17T14:30:00.0000000' AS DateTime2), N'Scheduled', CAST(200.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Itchy skin', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000266, 1000000, 1000015, 1000034, 1000056, CAST(N'2026-11-17T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(275.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Ankle sprain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000267, 1000000, 1000015, 1000035, 1000057, CAST(N'2026-11-17T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(275.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Wrist pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000268, 1000000, 1000015, 1000036, 1000058, CAST(N'2026-11-17T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(275.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Back pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000269, 1000000, 1000000, 1000038, 1000044, CAST(N'2026-11-18T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Cough and sore throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000270, 1000000, 1000000, 1000039, 1000059, CAST(N'2026-11-18T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Back pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000271, 1000000, 1000000, 1000040, 1000060, CAST(N'2026-11-18T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Blood pressure check', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000272, 1000000, 1000012, 1000043, NULL, CAST(N'2026-11-18T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000273, 1000000, 1000012, 1000021, NULL, CAST(N'2026-11-18T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Back pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000274, 1000000, 1000012, 1000025, NULL, CAST(N'2026-11-18T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000275, 1000001, 1000013, 1000026, 1000031, CAST(N'2026-11-18T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Fever', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000276, 1000001, 1000013, 1000028, 1000061, CAST(N'2026-11-18T12:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Rash', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000277, 1000001, 1000013, 1000029, 1000062, CAST(N'2026-11-18T15:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Wellness checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000278, 1000001, 1000001, 1000030, 1000033, CAST(N'2026-11-19T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up after tests', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000279, 1000001, 1000001, 1000031, 1000034, CAST(N'2026-11-19T12:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Heart palpitations', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000280, 1000001, 1000001, 1000032, 1000063, CAST(N'2026-11-19T15:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Heart checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000281, 1000000, 1000011, 1000034, NULL, CAST(N'2026-11-19T09:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Blood pressure check', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000282, 1000000, 1000011, 1000036, NULL, CAST(N'2026-11-19T11:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Diabetes follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000283, 1000000, 1000011, 1000040, NULL, CAST(N'2026-11-19T14:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Stomach pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000284, 1000001, 1000014, 1000042, 1000064, CAST(N'2026-11-19T09:30:00.0000000' AS DateTime2), N'Scheduled', CAST(200.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000285, 1000001, 1000014, 1000043, 1000065, CAST(N'2026-11-19T11:30:00.0000000' AS DateTime2), N'Scheduled', CAST(200.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Mole check', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000286, 1000001, 1000014, 1000021, 1000066, CAST(N'2026-11-19T14:30:00.0000000' AS DateTime2), N'Scheduled', CAST(200.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Itchy skin', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000287, 1000000, 1000015, 1000022, 1000067, CAST(N'2026-11-19T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(275.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Ankle sprain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000288, 1000000, 1000015, 1000024, 1000016, CAST(N'2026-11-19T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(275.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Knee pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000289, 1000000, 1000015, 1000025, 1000068, CAST(N'2026-11-19T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(275.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Shoulder pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000290, 1000000, 1000000, 1000026, 1000069, CAST(N'2026-11-20T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Cough and sore throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000291, 1000000, 1000000, 1000028, 1000070, CAST(N'2026-11-20T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Flu symptoms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000292, 1000000, 1000000, 1000029, 1000071, CAST(N'2026-11-20T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000293, 1000000, 1000012, 1000031, NULL, CAST(N'2026-11-20T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000294, 1000000, 1000012, 1000033, NULL, CAST(N'2026-11-20T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Back pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000295, 1000000, 1000012, 1000035, NULL, CAST(N'2026-11-20T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000296, 1000001, 1000016, 1000036, 1000072, CAST(N'2026-11-20T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up after tests', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000297, 1000001, 1000016, 1000038, 1000073, CAST(N'2026-11-20T12:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Blood pressure follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000298, 1000001, 1000016, 1000039, 1000074, CAST(N'2026-11-20T15:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Shortness of breath', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000299, 1000000, 1000000, 1000040, 1000060, CAST(N'2026-11-23T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Back pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000300, 1000000, 1000000, 1000042, 1000075, CAST(N'2026-11-23T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000301, 1000000, 1000000, 1000043, 1000076, CAST(N'2026-11-23T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000302, 1000000, 1000012, 1000021, NULL, CAST(N'2026-11-23T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000303, 1000000, 1000012, 1000025, NULL, CAST(N'2026-11-23T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Cough and sore throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000304, 1000000, 1000012, 1000029, NULL, CAST(N'2026-11-23T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Annual checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000305, 1000001, 1000013, 1000030, 1000045, CAST(N'2026-11-23T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000306, 1000001, 1000013, 1000031, 1000046, CAST(N'2026-11-23T12:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Fever', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000307, 1000001, 1000013, 1000032, 1000077, CAST(N'2026-11-23T15:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Vaccination', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000308, 1000001, 1000016, 1000033, 1000040, CAST(N'2026-11-23T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Blood pressure follow-up', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000309, 1000001, 1000016, 1000034, 1000041, CAST(N'2026-11-23T12:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Shortness of breath', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000310, 1000001, 1000016, 1000035, 1000078, CAST(N'2026-11-23T15:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Chest pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000311, 1000001, 1000001, 1000038, 1000027, CAST(N'2026-11-24T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Heart palpitations', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000312, 1000001, 1000001, 1000039, 1000079, CAST(N'2026-11-24T12:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Heart checkup', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000313, 1000001, 1000001, 1000040, 1000080, CAST(N'2026-11-24T15:30:00.0000000' AS DateTime2), N'Scheduled', CAST(300.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up after tests', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000314, 1000000, 1000011, 1000042, NULL, CAST(N'2026-11-24T09:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Stomach pain', NULL)
GO
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000315, 1000000, 1000011, 1000022, NULL, CAST(N'2026-11-24T11:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Lab results review', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000316, 1000000, 1000011, 1000024, NULL, CAST(N'2026-11-24T14:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Annual physical', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000317, 1000001, 1000014, 1000025, 1000081, CAST(N'2026-11-24T09:30:00.0000000' AS DateTime2), N'Scheduled', CAST(200.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Skin rash', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000318, 1000001, 1000014, 1000026, 1000082, CAST(N'2026-11-24T11:30:00.0000000' AS DateTime2), N'Scheduled', CAST(200.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Acne', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000319, 1000001, 1000014, 1000028, 1000083, CAST(N'2026-11-24T14:30:00.0000000' AS DateTime2), N'Scheduled', CAST(200.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000320, 1000000, 1000015, 1000029, 1000018, CAST(N'2026-11-24T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(275.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000321, 1000000, 1000015, 1000030, 1000084, CAST(N'2026-11-24T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(275.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Knee pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000322, 1000000, 1000015, 1000031, 1000085, CAST(N'2026-11-24T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(275.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Shoulder pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000323, 1000000, 1000000, 1000032, 1000086, CAST(N'2026-11-25T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Cough and sore throat', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000324, 1000000, 1000000, 1000033, 1000087, CAST(N'2026-11-25T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Back pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000325, 1000000, 1000000, 1000034, 1000088, CAST(N'2026-11-25T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Blood pressure check', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000326, 1000000, 1000012, 1000035, NULL, CAST(N'2026-11-25T10:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Flu symptoms', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000327, 1000000, 1000012, 1000039, NULL, CAST(N'2026-11-25T12:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Back pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000328, 1000000, 1000012, 1000043, NULL, CAST(N'2026-11-25T15:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Follow-up visit', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000329, 1000001, 1000013, 1000021, 1000089, CAST(N'2026-11-25T10:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Ear pain', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000330, 1000001, 1000013, 1000022, 1000090, CAST(N'2026-11-25T12:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Rash', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000331, 1000001, 1000013, 1000024, 1000091, CAST(N'2026-11-25T15:30:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'Fever', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000333, 1000000, 1000000, 1000002, NULL, CAST(N'2026-11-13T14:00:00.0000000' AS DateTime2), N'Cancelled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', N'Transportation Problems', N'Patient', 0, NULL, N'headache', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000335, 1000000, 1000000, 1000002, NULL, CAST(N'2026-11-18T13:00:00.0000000' AS DateTime2), N'Cancelled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', N'Transportation Problems', N'Patient', 0, NULL, N'headache', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000338, 1000000, 1000000, 1000010, NULL, CAST(N'2027-01-06T11:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Phone', NULL, NULL, 0, NULL, N'headache', NULL)
INSERT [dbo].[Appointment] ([AppointmentID], [OfficeID], [DoctorID], [PatientID], [ReferralID], [Date_Time], [AppointStatus], [TotalCost], [Channel], [CancelReason], [CancelledBy], [DeletionFlag], [CancellationFee], [VisitReason], [CheckInStatus]) VALUES (1000339, 1000000, 1000012, 1000056, NULL, CAST(N'2027-12-15T16:00:00.0000000' AS DateTime2), N'Scheduled', CAST(150.00 AS Numeric(10, 2)), N'Web Portal', NULL, NULL, 0, NULL, N'Lele Pancha', NULL)
SET IDENTITY_INSERT [dbo].[Appointment] OFF
GO
SET IDENTITY_INSERT [dbo].[MedicalRecord] ON 

INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000000, 1000000, N'Routine examination completed.', 120, 80, 72, CAST(98.6 AS Numeric(4, 1)), CAST(150.0 AS Numeric(5, 1)), CAST(66.0 AS Numeric(4, 1)), N'Continue routine preventive care.', N'Schedule follow-up as needed.', 0, N'No new complaints. Patient resting comfortably.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000001, 1000001, N'Patient attended follow-up examination.', 120, 80, 72, CAST(98.6 AS Numeric(4, 1)), CAST(150.0 AS Numeric(5, 1)), CAST(66.0 AS Numeric(4, 1)), N'Continue routine preventive care.', N'Schedule follow-up as needed.', 0, N'Patient reports mild pain, 3 out of 10.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000002, 1000002, N'Annual wellness examination completed.', 120, 80, 72, CAST(98.6 AS Numeric(4, 1)), CAST(150.0 AS Numeric(5, 1)), CAST(66.0 AS Numeric(4, 1)), N'Continue routine preventive care.', N'Schedule follow-up as needed.', 0, N'Patient says symptoms improved since the last visit.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000003, 1000003, N'Routine examination completed.', 120, 80, 72, CAST(98.6 AS Numeric(4, 1)), CAST(150.0 AS Numeric(5, 1)), CAST(66.0 AS Numeric(4, 1)), N'Continue routine preventive care.', N'Schedule follow-up as needed.', 0, N'Patient asked about refilling a current medication.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000004, 1000004, N'Patient attended follow-up examination.', 120, 80, 72, CAST(98.6 AS Numeric(4, 1)), CAST(150.0 AS Numeric(5, 1)), CAST(66.0 AS Numeric(4, 1)), N'Continue routine preventive care.', N'Schedule follow-up as needed.', 0, N'No new complaints. Patient resting comfortably.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000005, 1000005, N'Annual wellness examination completed.', 120, 80, 72, CAST(98.6 AS Numeric(4, 1)), CAST(150.0 AS Numeric(5, 1)), CAST(66.0 AS Numeric(4, 1)), N'Continue routine preventive care.', N'Schedule follow-up as needed.', 0, N'Patient reports mild pain, 3 out of 10.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000006, 1000006, N'Routine examination completed.', 120, 80, 72, CAST(98.6 AS Numeric(4, 1)), CAST(150.0 AS Numeric(5, 1)), CAST(66.0 AS Numeric(4, 1)), N'Continue routine preventive care.', N'Schedule follow-up as needed.', 0, N'Patient says symptoms improved since the last visit.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000007, 1000007, N'Patient attended follow-up examination.', 120, 80, 72, CAST(98.6 AS Numeric(4, 1)), CAST(150.0 AS Numeric(5, 1)), CAST(66.0 AS Numeric(4, 1)), N'Continue routine preventive care.', N'Schedule follow-up as needed.', 0, N'Patient asked about refilling a current medication.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000008, 1000018, N'Cough and sore throat for 4 days; lungs clear.', 108, 70, 88, CAST(99.6 AS Numeric(4, 1)), CAST(162.0 AS Numeric(5, 1)), CAST(62.0 AS Numeric(4, 1)), N'Rest, fluids and over-the-counter cough medicine.', N'Follow up as needed.', 0, N'No new complaints. Patient resting comfortably.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000009, 1000043, N'Cough and sore throat for 4 days; lungs clear.', 109, 71, 69, CAST(99.8 AS Numeric(4, 1)), CAST(175.0 AS Numeric(5, 1)), CAST(65.0 AS Numeric(4, 1)), N'Rest, fluids and over-the-counter cough medicine.', N'Follow up as needed.', 0, N'Patient reports mild pain, 3 out of 10.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000010, 1000044, N'Blood pressure above goal. Reviewed salt intake and exercise.', 142, 90, 76, CAST(98.6 AS Numeric(4, 1)), CAST(188.0 AS Numeric(5, 1)), CAST(68.0 AS Numeric(4, 1)), N'Continue blood pressure medication; check it at home twice a week.', N'Follow up as needed.', 0, N'Blood pressure high on arrival; rechecked after 5 minutes, still high.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000011, 1000019, N'Blood pressure above goal. Reviewed salt intake and exercise.', 143, 91, 83, CAST(98.8 AS Numeric(4, 1)), CAST(201.0 AS Numeric(5, 1)), CAST(71.0 AS Numeric(4, 1)), N'Continue blood pressure medication; check it at home twice a week.', N'Follow up as needed.', 0, N'Blood pressure high on arrival; rechecked after 5 minutes, still high.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000012, 1000020, N'A1C slightly high. Reviewed diet and home glucose checks.', 112, 74, 64, CAST(99.0 AS Numeric(4, 1)), CAST(122.0 AS Numeric(5, 1)), CAST(61.0 AS Numeric(4, 1)), N'Continue metformin; walk 30 minutes a day.', N'Follow up as needed.', 0, N'No new complaints. Patient resting comfortably.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000013, 1000045, N'A1C slightly high. Reviewed diet and home glucose checks.', 113, 75, 71, CAST(97.8 AS Numeric(4, 1)), CAST(135.0 AS Numeric(5, 1)), CAST(64.0 AS Numeric(4, 1)), N'Continue metformin; walk 30 minutes a day.', N'Follow up as needed.', 0, N'Patient reports mild pain, 3 out of 10.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000014, 1000046, N'Mild wheezing on exam. Inhaler technique reviewed.', 114, 76, 78, CAST(98.0 AS Numeric(4, 1)), CAST(148.0 AS Numeric(5, 1)), CAST(67.0 AS Numeric(4, 1)), N'Use the rescue inhaler as needed; avoid triggers.', N'Follow up as needed.', 0, N'Patient says symptoms improved since the last visit.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000015, 1000021, N'Mild wheezing on exam. Inhaler technique reviewed.', 115, 77, 85, CAST(98.2 AS Numeric(4, 1)), CAST(161.0 AS Numeric(5, 1)), CAST(70.0 AS Numeric(4, 1)), N'Use the rescue inhaler as needed; avoid triggers.', N'Follow up as needed.', 0, N'Patient asked about refilling a current medication.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000016, 1000022, N'Congestion and itchy eyes, worse outdoors.', 116, 78, 66, CAST(98.4 AS Numeric(4, 1)), CAST(174.0 AS Numeric(5, 1)), CAST(73.0 AS Numeric(4, 1)), N'Daily antihistamine during allergy season.', N'Follow up as needed.', 0, N'No new complaints. Patient resting comfortably.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000017, 1000023, N'Cough and sore throat for 4 days; lungs clear.', 117, 79, 73, CAST(99.8 AS Numeric(4, 1)), CAST(187.0 AS Numeric(5, 1)), CAST(63.0 AS Numeric(4, 1)), N'Rest, fluids and over-the-counter cough medicine.', N'Follow up as needed.', 0, N'Patient reports mild pain, 3 out of 10.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000018, 1000024, N'Blood pressure above goal. Reviewed salt intake and exercise.', 150, 90, 80, CAST(98.8 AS Numeric(4, 1)), CAST(200.0 AS Numeric(5, 1)), CAST(66.0 AS Numeric(4, 1)), N'Continue blood pressure medication; check it at home twice a week.', N'Follow up as needed.', 0, N'Blood pressure high on arrival; rechecked after 5 minutes, still high.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000019, 1000025, N'A1C slightly high. Reviewed diet and home glucose checks.', 119, 81, 87, CAST(99.0 AS Numeric(4, 1)), CAST(121.0 AS Numeric(5, 1)), CAST(69.0 AS Numeric(4, 1)), N'Continue metformin; walk 30 minutes a day.', N'Follow up as needed.', 0, N'Patient asked about refilling a current medication.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000020, 1000026, N'Mild wheezing on exam. Inhaler technique reviewed.', 120, 68, 68, CAST(97.8 AS Numeric(4, 1)), CAST(134.0 AS Numeric(5, 1)), CAST(72.0 AS Numeric(4, 1)), N'Use the rescue inhaler as needed; avoid triggers.', N'Follow up as needed.', 0, N'No new complaints. Patient resting comfortably.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000021, 1000028, N'Cough and sore throat for 4 days; lungs clear.', 121, 69, 75, CAST(100.6 AS Numeric(4, 1)), CAST(147.0 AS Numeric(5, 1)), CAST(62.0 AS Numeric(4, 1)), N'Rest, fluids and over-the-counter cough medicine.', N'Follow up as needed.', 0, N'Patient feels feverish and tired. Temperature taken twice.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000022, 1000029, N'Blood pressure above goal. Reviewed salt intake and exercise.', 140, 94, 82, CAST(98.2 AS Numeric(4, 1)), CAST(160.0 AS Numeric(5, 1)), CAST(65.0 AS Numeric(4, 1)), N'Continue blood pressure medication; check it at home twice a week.', N'Follow up as needed.', 0, N'Blood pressure high on arrival; rechecked after 5 minutes, still high.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000023, 1000030, N'A1C slightly high. Reviewed diet and home glucose checks.', 123, 71, 89, CAST(98.4 AS Numeric(4, 1)), CAST(173.0 AS Numeric(5, 1)), CAST(68.0 AS Numeric(4, 1)), N'Continue metformin; walk 30 minutes a day.', N'Follow up as needed.', 0, N'Patient asked about refilling a current medication.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000024, 1000031, N'Mild wheezing on exam. Inhaler technique reviewed.', 124, 72, 70, CAST(98.6 AS Numeric(4, 1)), CAST(186.0 AS Numeric(5, 1)), CAST(71.0 AS Numeric(4, 1)), N'Use the rescue inhaler as needed; avoid triggers.', N'Follow up as needed.', 0, N'No new complaints. Patient resting comfortably.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000025, 1000032, N'Congestion and itchy eyes, worse outdoors.', 125, 73, 77, CAST(98.8 AS Numeric(4, 1)), CAST(199.0 AS Numeric(5, 1)), CAST(61.0 AS Numeric(4, 1)), N'Daily antihistamine during allergy season.', N'Follow up as needed.', 0, N'Patient reports mild pain, 3 out of 10.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000026, 1000033, N'Cough and sore throat for 4 days; lungs clear.', 126, 74, 84, CAST(100.0 AS Numeric(4, 1)), CAST(120.0 AS Numeric(5, 1)), CAST(64.0 AS Numeric(4, 1)), N'Rest, fluids and over-the-counter cough medicine.', N'Follow up as needed.', 0, N'Patient says symptoms improved since the last visit.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000027, 1000034, N'Blood pressure above goal. Reviewed salt intake and exercise.', 145, 91, 65, CAST(97.8 AS Numeric(4, 1)), CAST(133.0 AS Numeric(5, 1)), CAST(67.0 AS Numeric(4, 1)), N'Continue blood pressure medication; check it at home twice a week.', N'Follow up as needed.', 0, N'Blood pressure high on arrival; rechecked after 5 minutes, still high.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000028, 1000035, N'A1C slightly high. Reviewed diet and home glucose checks.', 128, 76, 72, CAST(98.0 AS Numeric(4, 1)), CAST(146.0 AS Numeric(5, 1)), CAST(70.0 AS Numeric(4, 1)), N'Continue metformin; walk 30 minutes a day.', N'Follow up as needed.', 0, N'No new complaints. Patient resting comfortably.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000029, 1000036, N'Mild wheezing on exam. Inhaler technique reviewed.', 129, 77, 79, CAST(98.2 AS Numeric(4, 1)), CAST(159.0 AS Numeric(5, 1)), CAST(73.0 AS Numeric(4, 1)), N'Use the rescue inhaler as needed; avoid triggers.', N'Follow up as needed.', 0, N'Patient reports mild pain, 3 out of 10.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000030, 1000038, N'Cough and sore throat for 4 days; lungs clear.', 130, 78, 86, CAST(100.8 AS Numeric(4, 1)), CAST(172.0 AS Numeric(5, 1)), CAST(63.0 AS Numeric(4, 1)), N'Rest, fluids and over-the-counter cough medicine.', N'Follow up as needed.', 0, N'Patient feels feverish and tired. Temperature taken twice.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000031, 1000039, N'Blood pressure above goal. Reviewed salt intake and exercise.', 149, 95, 67, CAST(98.6 AS Numeric(4, 1)), CAST(185.0 AS Numeric(5, 1)), CAST(66.0 AS Numeric(4, 1)), N'Continue blood pressure medication; check it at home twice a week.', N'Follow up as needed.', 0, N'Blood pressure high on arrival; rechecked after 5 minutes, still high.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000032, 1000040, N'A1C slightly high. Reviewed diet and home glucose checks.', 108, 80, 74, CAST(98.8 AS Numeric(4, 1)), CAST(198.0 AS Numeric(5, 1)), CAST(69.0 AS Numeric(4, 1)), N'Continue metformin; walk 30 minutes a day.', N'Follow up as needed.', 0, N'No new complaints. Patient resting comfortably.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000033, 1000041, N'Mild wheezing on exam. Inhaler technique reviewed.', 109, 81, 81, CAST(99.0 AS Numeric(4, 1)), CAST(119.0 AS Numeric(5, 1)), CAST(72.0 AS Numeric(4, 1)), N'Use the rescue inhaler as needed; avoid triggers.', N'Follow up as needed.', 0, N'Patient reports mild pain, 3 out of 10.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000034, 1000042, N'Congestion and itchy eyes, worse outdoors.', 110, 68, 88, CAST(97.8 AS Numeric(4, 1)), CAST(132.0 AS Numeric(5, 1)), CAST(62.0 AS Numeric(4, 1)), N'Daily antihistamine during allergy season.', N'Follow up as needed.', 0, N'Patient says symptoms improved since the last visit.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000035, 1000017, NULL, 120, 100, 100, CAST(100.0 AS Numeric(4, 1)), CAST(1500.0 AS Numeric(5, 1)), CAST(3.0 AS Numeric(4, 1)), NULL, NULL, 0, NULL)
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000036, 1000101, N'Yadda yadda yda', 120, 100, 50, CAST(95.0 AS Numeric(4, 1)), CAST(140.0 AS Numeric(5, 1)), CAST(66.0 AS Numeric(4, 1)), N'Blah blah blah', N'Whatever bro', 0, N'patient says back hurts')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000037, 1000141, N'Test note: patient well.', 120, 110, 110, CAST(98.0 AS Numeric(4, 1)), CAST(1000.0 AS Numeric(5, 1)), CAST(67.0 AS Numeric(4, 1)), N'Test plan: none.', N'Test follow-up: 1 year.', 0, N'whatever bro')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000038, 1000125, NULL, 120, 100, 50, CAST(89.0 AS Numeric(4, 1)), CAST(500.0 AS Numeric(5, 1)), CAST(67.0 AS Numeric(4, 1)), NULL, NULL, 0, NULL)
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000039, 1000136, NULL, 110, 90, 90, CAST(98.0 AS Numeric(4, 1)), CAST(140.0 AS Numeric(5, 1)), CAST(88.0 AS Numeric(4, 1)), NULL, NULL, 0, NULL)
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000040, 1000178, N'Red throat with white patches; rapid strep test positive.', 118, 76, 96, CAST(101.2 AS Numeric(4, 1)), CAST(128.0 AS Numeric(5, 1)), CAST(64.0 AS Numeric(4, 1)), N'Antibiotic for 5 days, rest and fluids.', N'Return if the fever lasts more than 3 days.', 0, N'Temperature high on arrival; patient says the throat hurts when swallowing.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000041, 1000179, N'Left eardrum red and bulging.', 112, 72, 84, CAST(99.5 AS Numeric(4, 1)), CAST(118.0 AS Numeric(5, 1)), CAST(63.0 AS Numeric(4, 1)), N'Ear drops and pain relief.', N'Follow up in 2 weeks if the pain continues.', 0, N'Patient reports left ear pain for 2 days, 5 out of 10.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000042, 1000182, N'Dry, scaly patches on both forearms.', 116, 74, 70, CAST(98.4 AS Numeric(4, 1)), CAST(132.0 AS Numeric(5, 1)), CAST(65.0 AS Numeric(4, 1)), N'Moisturize twice a day; steroid cream for flare-ups.', N'Follow up in 6 weeks.', 0, N'Patient says the itching is worse at night.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000043, 1000183, N'Mole on the back is even in color with smooth borders.', 134, 86, 76, CAST(98.2 AS Numeric(4, 1)), CAST(186.0 AS Numeric(5, 1)), CAST(70.0 AS Numeric(4, 1)), N'No treatment needed; use sunscreen.', N'Skin check again in 1 year.', 0, N'Patient worried about a mole on his back he noticed last month.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000044, 1000186, N'Right knee swollen; ligaments stable.', 128, 82, 78, CAST(98.6 AS Numeric(4, 1)), CAST(178.0 AS Numeric(5, 1)), CAST(71.0 AS Numeric(4, 1)), N'Rest, ice and compression; knee brace.', N'Follow up in 4 weeks.', 0, N'Patient hurt his right knee playing basketball; pain 6 out of 10.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000045, 1000187, N'Lower back stiff, worse in the morning; X-ray shows mild arthritis.', 142, 88, 74, CAST(98.1 AS Numeric(4, 1)), CAST(201.0 AS Numeric(5, 1)), CAST(69.0 AS Numeric(4, 1)), N'Physical therapy twice a week; stretching at home.', N'Follow up in 6 weeks.', 0, N'Patient says the back pain started 3 months ago, 4 out of 10.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000046, 1000190, N'Chest tightness with exercise; ECG normal at rest.', 148, 92, 88, CAST(98.4 AS Numeric(4, 1)), CAST(196.0 AS Numeric(5, 1)), CAST(70.0 AS Numeric(4, 1)), N'Nitroglycerin as needed; stress test.', N'Follow up after the stress test.', 0, N'Patient reports chest tightness when climbing stairs.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000047, 1000191, N'Irregular heartbeat on ECG.', 138, 84, 112, CAST(98.0 AS Numeric(4, 1)), CAST(189.0 AS Numeric(5, 1)), CAST(68.0 AS Numeric(4, 1)), N'Rate control medicine; wear a heart monitor for 2 weeks.', N'Follow up in 1 month.', 0, N'Patient says his heart has been racing on and off for a week.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000048, 1000198, N'Healthy exam; labs ordered.', 122, 78, 70, CAST(98.2 AS Numeric(4, 1)), CAST(182.0 AS Numeric(5, 1)), CAST(70.0 AS Numeric(4, 1)), N'Keep exercising; recheck labs in a year.', N'Annual physical next year.', 0, N'No complaints today. Patient fasted for labs.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000049, 1000199, N'A1C up to 7.4; feet and eyes checked.', 134, 84, 78, CAST(98.4 AS Numeric(4, 1)), CAST(214.0 AS Numeric(5, 1)), CAST(69.0 AS Numeric(4, 1)), N'Start metformin; walk 30 minutes a day.', N'Follow up in 3 months with labs.', 0, N'Patient reports more thirst lately. Latex allergy: used non-latex gloves.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000050, 1000200, N'Blood pressure still above goal on two readings.', 152, 96, 82, CAST(98.0 AS Numeric(4, 1)), CAST(196.0 AS Numeric(5, 1)), CAST(70.0 AS Numeric(4, 1)), N'Start lisinopril; cut salt.', N'Blood pressure check in 4 weeks.', 0, N'Blood pressure high on arrival; rechecked after 5 minutes, still high.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000051, 1000201, N'Tender right wrist, full motion, X-ray normal.', 118, 74, 72, CAST(98.3 AS Numeric(4, 1)), CAST(141.0 AS Numeric(5, 1)), CAST(65.0 AS Numeric(4, 1)), N'Wrist brace for 2 weeks; ice after use.', N'Keep the Thursday visit to recheck.', 0, N'Patient fell on her right hand on Saturday; pain 5 out of 10.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000052, 1000202, NULL, 120, 110, 110, CAST(95.0 AS Numeric(4, 1)), CAST(1000.0 AS Numeric(5, 1)), CAST(67.0 AS Numeric(4, 1)), NULL, NULL, 0, N'Wore the heart monitor for 2 weeks; says the racing is less often. Aspirin upsets his stomach.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000053, 1000194, N'Lungs with mild wheeze; heart sounds normal; ECG normal.', 124, 80, 86, CAST(99.4 AS Numeric(4, 1)), CAST(168.0 AS Numeric(5, 1)), CAST(69.0 AS Numeric(4, 1)), N'Azithromycin (no penicillin: severe allergy); inhaler as needed.', N'Back to Dr. Patel if the cough lasts 2 more weeks.', 0, N'Cough for 10 days, worse at night. Reminded the doctor of the penicillin allergy.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000054, 1000184, N'Mild acne on the forehead and cheeks.', 112, 70, 74, CAST(98.5 AS Numeric(4, 1)), CAST(128.0 AS Numeric(5, 1)), CAST(64.0 AS Numeric(4, 1)), N'Retinoid cream at night; gentle cleanser.', N'Follow up in 8 weeks.', 0, N'Patient says over-the-counter washes have not helped.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000055, 1000204, N'Chest wall tender to touch; ECG normal.', 132, 84, 80, CAST(98.6 AS Numeric(4, 1)), CAST(186.0 AS Numeric(5, 1)), CAST(70.0 AS Numeric(4, 1)), N'Anti-inflammatory medicine and rest; no heavy lifting.', N'Return right away if the pain spreads or comes with shortness of breath.', 0, N'Sharp chest pain when he breathes in deeply, 4 out of 10. Sulfa allergy noted.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000056, 1000205, N'Flare on both elbows; no infection.', 114, 72, 70, CAST(98.3 AS Numeric(4, 1)), CAST(133.0 AS Numeric(5, 1)), CAST(65.0 AS Numeric(4, 1)), N'Stronger steroid cream for 2 weeks, then back to moisturizer.', N'Follow up in 6 weeks.', 0, N'Patient says the itching came back after the weather turned cold.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000057, 1000206, NULL, 128, 80, 94, CAST(98.4 AS Numeric(4, 1)), CAST(179.0 AS Numeric(5, 1)), CAST(71.0 AS Numeric(4, 1)), NULL, NULL, 0, N'Says his heart skips a beat a few times a day, mostly after coffee.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000058, 1000209, N'Fever, body aches; flu test positive.', 118, 76, 98, CAST(101.6 AS Numeric(4, 1)), CAST(171.0 AS Numeric(5, 1)), CAST(70.0 AS Numeric(4, 1)), N'Rest, fluids, antiviral for 5 days.', N'Return if breathing gets hard.', 0, N'Temperature high on arrival; patient feels achy and tired.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000059, 1000210, N'Facial tenderness and congestion for 12 days.', 126, 80, 76, CAST(99.1 AS Numeric(4, 1)), CAST(192.0 AS Numeric(5, 1)), CAST(72.0 AS Numeric(4, 1)), N'Antibiotic (no penicillin: severe allergy); saline rinse.', N'Follow up if not better in 10 days.', 0, N'Patient says the congestion has lasted almost two weeks. Penicillin allergy noted.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000060, 1000211, N'Blood pressure better since last visit, still a little high.', 144, 90, 74, CAST(98.2 AS Numeric(4, 1)), CAST(205.0 AS Numeric(5, 1)), CAST(70.0 AS Numeric(4, 1)), N'Raise amlodipine dose.', N'Recheck in 6 weeks.', 0, N'Patient takes his blood pressure at home most mornings.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000061, 1000212, N'Itchy eyes and sneezing, worse outdoors.', 112, 72, 68, CAST(98.0 AS Numeric(4, 1)), CAST(134.0 AS Numeric(5, 1)), CAST(66.0 AS Numeric(4, 1)), N'Daily antihistamine; nasal spray.', N'Follow up in the spring if needed.', 0, N'Patient says symptoms started with the ragweed season.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000062, 1000213, N'Wheezing on exam; peak flow lower than usual.', 120, 78, 92, CAST(98.4 AS Numeric(4, 1)), CAST(176.0 AS Numeric(5, 1)), CAST(69.0 AS Numeric(4, 1)), N'Rescue inhaler as needed; start a daily controller inhaler.', N'Follow up in 4 weeks.', 0, N'Patient used the rescue inhaler three times this week.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000063, 1000214, N'Red throat, clear lungs, no fever.', 110, 70, 80, CAST(99.8 AS Numeric(4, 1)), CAST(129.0 AS Numeric(5, 1)), CAST(64.0 AS Numeric(4, 1)), N'Rest, fluids and throat lozenges.', N'Return if the fever starts or it lasts 10 more days.', 0, N'Patient says the sore throat started 4 days ago.')
INSERT [dbo].[MedicalRecord] ([RecordID], [AppointmentID], [ClinicalNotes], [SystolicBP], [DiastolicBP], [HeartRate], [Temperature], [WeightPounds], [HeightInches], [TreatmentPlan], [FollowUp], [DeletionFlag], [NursingNotes]) VALUES (1000064, 1000134, NULL, 100, 70, 110, CAST(98.5 AS Numeric(4, 1)), CAST(70.0 AS Numeric(5, 1)), CAST(81.0 AS Numeric(4, 1)), NULL, NULL, 0, N'LOL')
SET IDENTITY_INSERT [dbo].[MedicalRecord] OFF
GO
SET IDENTITY_INSERT [dbo].[Payment] ON 

INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000000, 1000000, 1, CAST(N'2026-07-06' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000001, 1000001, 1, CAST(N'2026-07-07' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000002, 1000002, 1, CAST(N'2026-08-03' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000003, 1000003, 1, CAST(N'2026-08-04' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000004, 1000004, 1, CAST(N'2026-09-07' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000005, 1000005, 1, CAST(N'2026-09-08' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000006, 1000006, 1, CAST(N'2026-10-05' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000007, 1000007, 1, CAST(N'2026-10-06' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000008, 1000010, 1, CAST(N'2026-12-02' AS Date), N'Pending', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000009, 1000011, 1, CAST(N'2026-12-03' AS Date), N'Pending', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000010, 1000018, 1, CAST(N'2026-09-09' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000011, 1000043, 1, CAST(N'2026-10-16' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000012, 1000044, 1, CAST(N'2026-10-15' AS Date), N'Pending', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000013, 1000019, 1, CAST(N'2026-09-08' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000014, 1000020, 1, CAST(N'2026-09-07' AS Date), N'Pending', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000015, 1000045, 1, CAST(N'2026-10-14' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000016, 1000046, 1, CAST(N'2026-10-15' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000017, 1000021, 1, CAST(N'2026-09-08' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000018, 1000022, 1, CAST(N'2026-09-11' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000019, 1000023, 1, CAST(N'2026-09-15' AS Date), N'Pending', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000020, 1000024, 1, CAST(N'2026-09-16' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000021, 1000025, 1, CAST(N'2026-09-15' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000022, 1000026, 1, CAST(N'2026-09-14' AS Date), N'Pending', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000023, 1000028, 1, CAST(N'2026-09-25' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000024, 1000029, 1, CAST(N'2026-09-22' AS Date), N'Pending', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000025, 1000030, 1, CAST(N'2026-09-23' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000026, 1000031, 1, CAST(N'2026-09-22' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000027, 1000032, 1, CAST(N'2026-09-21' AS Date), N'Pending', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000028, 1000033, 1, CAST(N'2026-09-29' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000029, 1000034, 1, CAST(N'2026-10-02' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000030, 1000035, 1, CAST(N'2026-09-29' AS Date), N'Pending', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000031, 1000036, 1, CAST(N'2026-09-30' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000032, 1000038, 1, CAST(N'2026-10-05' AS Date), N'Pending', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000033, 1000039, 1, CAST(N'2026-10-06' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000034, 1000040, 1, CAST(N'2026-10-09' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000035, 1000041, 1, CAST(N'2026-10-06' AS Date), N'Pending', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000036, 1000042, 1, CAST(N'2026-10-07' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000039, 1000140, 1, CAST(N'2026-11-08' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000042, 1000013, 1, CAST(N'2026-11-08' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000044, 1000010, 2, CAST(N'2026-11-09' AS Date), N'Pending', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000045, 1000044, 2, CAST(N'2026-11-09' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000046, 1000152, 1, CAST(N'2026-11-09' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000047, 1000178, 1, CAST(N'2026-10-14' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000048, 1000179, 1, CAST(N'2026-10-26' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000049, 1000182, 1, CAST(N'2026-10-13' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000050, 1000183, 1, CAST(N'2026-10-29' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000051, 1000186, 1, CAST(N'2026-10-20' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000052, 1000187, 1, CAST(N'2026-10-22' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000053, 1000190, 1, CAST(N'2026-10-16' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000054, 1000191, 1, CAST(N'2026-10-19' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000055, 1000149, 1, CAST(N'2026-11-10' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000056, 1000198, 1, CAST(N'2026-11-10' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000057, 1000200, 1, CAST(N'2026-11-10' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000058, 1000201, 1, CAST(N'2026-11-10' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000059, 1000194, 1, CAST(N'2026-11-10' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000060, 1000184, 1, CAST(N'2026-11-10' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000061, 1000204, 1, CAST(N'2026-11-10' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000062, 1000205, 1, CAST(N'2026-11-10' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000063, 1000209, 1, CAST(N'2026-11-03' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000064, 1000210, 1, CAST(N'2026-11-03' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000065, 1000211, 1, CAST(N'2026-11-03' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000066, 1000212, 1, CAST(N'2026-11-04' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000067, 1000214, 1, CAST(N'2026-11-06' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000073, 1000181, 1, CAST(N'2026-11-10' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000074, 1000046, 2, CAST(N'2026-11-10' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000075, 1000150, 1, CAST(N'2026-11-10' AS Date), N'Completed', 0)
INSERT [dbo].[Payment] ([PaymentID], [AppointmentID], [InstallmentNumber], [PaymentDate], [PayStatus], [DeletionFlag]) VALUES (1000076, 1000202, 1, CAST(N'2026-11-10' AS Date), N'Completed', 0)
SET IDENTITY_INSERT [dbo].[Payment] OFF
GO
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000000, N'Routine health examination', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000001, N'Follow-up health examination', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000002, N'Preventive wellness examination', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000003, N'Routine health examination', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000004, N'Follow-up health examination', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000005, N'Preventive wellness examination', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000006, N'Routine health examination', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000007, N'Follow-up health examination', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000008, N'Upper Respiratory Infection', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000009, N'Upper Respiratory Infection', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000010, N'Hypertension', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000011, N'Hypertension', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000012, N'Type 2 Diabetes', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000013, N'Type 2 Diabetes', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000014, N'Asthma', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000015, N'Asthma', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000016, N'Seasonal Allergies', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000017, N'Upper Respiratory Infection', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000018, N'Hypertension', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000019, N'Type 2 Diabetes', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000020, N'Asthma', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000021, N'Upper Respiratory Infection', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000022, N'Hypertension', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000023, N'Type 2 Diabetes', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000024, N'Asthma', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000025, N'Seasonal Allergies', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000026, N'Upper Respiratory Infection', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000027, N'Hypertension', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000028, N'Type 2 Diabetes', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000029, N'Asthma', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000030, N'Upper Respiratory Infection', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000031, N'Hypertension', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000032, N'Type 2 Diabetes', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000033, N'Asthma', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000034, N'Seasonal Allergies', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000040, N'Strep throat', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000041, N'Ear infection', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000042, N'Atopic dermatitis (eczema)', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000043, N'Benign mole', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000044, N'Knee sprain', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000045, N'Osteoarthritis of the spine', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000046, N'Stable angina', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000047, N'Atrial fibrillation', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000048, N'Preventive wellness examination', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000049, N'Type 2 Diabetes', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000050, N'Hypertension', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000051, N'Wrist sprain', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000053, N'Acute bronchitis', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000054, N'Acne vulgaris', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000055, N'Costochondritis', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000056, N'Atopic dermatitis (eczema)', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000058, N'Influenza', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000059, N'Sinus Infection', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000060, N'Hypertension', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000061, N'Seasonal Allergies', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000062, N'Asthma', N'Primary', 0)
INSERT [dbo].[Diagnosis] ([DiagnosisID], [RecordID], [DiagnosisDescription], [DiagnosisType], [DeletionFlag]) VALUES (1, 1000063, N'Upper Respiratory Infection', N'Primary', 0)
GO
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000000, N'Albuterol', N'90 mcg', N'As needed', N'As directed', N'Sample educational record only', 0, N'Walgreens, Westheimer Road')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000001, N'Lisinopril', N'10 mg', N'Once daily', N'As directed', N'Sample educational record only', 0, N'Walgreens, Westheimer Road')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000003, N'Albuterol', N'90 mcg', N'As needed', N'As directed', N'Sample educational record only', 0, N'Walgreens, Westheimer Road')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000004, N'Lisinopril', N'10 mg', N'Once daily', N'As directed', N'Sample educational record only', 0, N'Walgreens, Westheimer Road')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000006, N'Albuterol', N'90 mcg', N'As needed', N'As directed', N'Sample educational record only', 0, N'Walgreens, Westheimer Road')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000007, N'Lisinopril', N'10 mg', N'Once daily', N'As directed', N'Sample educational record only', 0, N'Walgreens, Westheimer Road')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000049, N'Metformin', N'500 mg', N'Twice a day', N'90 days', NULL, 0, N'CVS Pharmacy, Main Street')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000050, N'Lisinopril', N'10 mg', N'Once a day', N'30 days', NULL, 0, N'Clarity Health Pharmacy, Main Street')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000051, N'Ibuprofen', N'400 mg', N'Three times a day', N'7 days', NULL, 0, N'CVS Pharmacy, Main Street')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000053, N'Azithromycin', N'250 mg', N'Once a day', N'5 days', NULL, 0, N'Walgreens, Westheimer Road')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000054, N'Tretinoin cream 0.025%', N'Pea-sized amount', N'Every night', N'8 weeks', NULL, 0, N'H-E-B Pharmacy, Richmond Avenue')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000055, N'Ibuprofen', N'600 mg', N'Three times a day', N'7 days', NULL, 0, N'Walgreens, Westheimer Road')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000056, N'Triamcinolone cream 0.1%', N'Thin layer', N'Twice a day', N'14 days', NULL, 0, N'H-E-B Pharmacy, Richmond Avenue')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000058, N'Oseltamivir', N'75 mg', N'Twice a day', N'5 days', NULL, 0, N'CVS Pharmacy, Main Street')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000059, N'Doxycycline', N'100 mg', N'Twice a day', N'10 days', NULL, 0, N'Walgreens, Westheimer Road')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000060, N'Amlodipine', N'10 mg', N'Once a day', N'30 days', NULL, 0, N'Clarity Health Pharmacy, Main Street')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000061, N'Cetirizine', N'10 mg', N'Once a day', N'30 days', NULL, 0, N'H-E-B Pharmacy, Richmond Avenue')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (1, 1000062, N'Albuterol inhaler', N'90 mcg', N'As needed', N'30 days', NULL, 0, N'CVS Pharmacy, Main Street')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (2, 1000040, N'Azithromycin', N'250 mg', N'Once a day', N'5 days', N'Take with food', 0, N'Walgreens, Westheimer Road')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (3, 1000041, N'Ciprofloxacin ear drops', N'4 drops', N'Twice a day', N'7 days', N'Left ear only', 0, N'CVS Pharmacy, Main Street')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (4, 1000042, N'Hydrocortisone cream 1%', N'Thin layer', N'Twice a day', N'14 days', N'Apply to the rash only', 0, N'H-E-B Pharmacy, Richmond Avenue')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (5, 1000044, N'Ibuprofen', N'600 mg', N'Three times a day', N'7 days', N'Take with food', 0, N'CVS Pharmacy, Main Street')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (6, 1000045, N'Naproxen', N'500 mg', N'Twice a day', N'14 days', N'Take with food', 0, N'Clarity Health Pharmacy, Main Street')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (7, 1000046, N'Nitroglycerin', N'0.4 mg', N'As needed', N'30 days', N'Under the tongue for chest pain', 0, N'Walgreens, Westheimer Road')
INSERT [dbo].[Prescription] ([PrescriptionID], [RecordID], [MedicationName], [Dosage], [Frequency], [Duration], [Instructions], [DeletionFlag], [Pharmacy]) VALUES (8, 1000047, N'Metoprolol', N'25 mg', N'Twice a day', N'30 days', NULL, 0, N'H-E-B Pharmacy, Richmond Avenue')
GO
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000000, 1000000, N'Fri', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000000, 1000000, N'Mon', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000000, 1000000, N'Wed', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000001, 1000001, N'Thu', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000001, 1000001, N'Tue', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000011, 1000000, N'Thu', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000011, 1000000, N'Tue', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000012, 1000000, N'Fri', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000012, 1000000, N'Mon', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000012, 1000000, N'Wed', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000013, 1000001, N'Mon', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000013, 1000001, N'Wed', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000014, 1000001, N'Thu', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000014, 1000001, N'Tue', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000015, 1000000, N'Thu', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000015, 1000000, N'Tue', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000016, 1000001, N'Fri', 0)
INSERT [dbo].[DoctorSchedule] ([DoctorID], [OfficeID], [DayOfWeek], [DeletionFlag]) VALUES (1000016, 1000001, N'Mon', 0)
GO
INSERT [dbo].[Nurse] ([NurseID], [OfficeID], [LicenseNum], [DeletionFlag]) VALUES (1000005, 1000000, N'TXRN10001', 0)
INSERT [dbo].[Nurse] ([NurseID], [OfficeID], [LicenseNum], [DeletionFlag]) VALUES (1000017, 1000000, N'TXRN20001', 0)
INSERT [dbo].[Nurse] ([NurseID], [OfficeID], [LicenseNum], [DeletionFlag]) VALUES (1000018, 1000001, N'TXRN20002', 0)
INSERT [dbo].[Nurse] ([NurseID], [OfficeID], [LicenseNum], [DeletionFlag]) VALUES (1000048, 1000000, N'1234567', 0)
GO
INSERT [dbo].[Receptionist] ([ReceptionistID], [OfficeID], [DeletionFlag]) VALUES (1000006, 1000001, 0)
INSERT [dbo].[Receptionist] ([ReceptionistID], [OfficeID], [DeletionFlag]) VALUES (1000050, 1000000, 0)
INSERT [dbo].[Receptionist] ([ReceptionistID], [OfficeID], [DeletionFlag]) VALUES (1000053, 1000000, 0)
INSERT [dbo].[Receptionist] ([ReceptionistID], [OfficeID], [DeletionFlag]) VALUES (1000055, 1000000, 0)
GO
SET IDENTITY_INSERT [dbo].[UserAccount] ON 

INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000000, 1000000, N'spatel', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Doctor', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000001, 1000001, N'jwilson', N'$2a$11$9CovlETjB5YcciYjy2Y9lOq6CE/PKrNu0GgEmfonjstG5yZmvHsxu', NULL, N'Doctor', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000002, 1000005, N'jlee', N'$2a$11$Vbodz.USI.mYXu62C8rome4iXk4afUVVxxmowmwCOHmoVMWrHyUcq', NULL, N'Nurse', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000003, 1000006, N'dmartinez', N'$2a$11$dRCQROqEzqOOvG4nT1ClUuerptG6E66xj723s.RMrnExHprlRDB7m', NULL, N'Receptionist', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000004, 1000002, N'egarcia', N'$2a$11$wnjb9Gw7U.RUU8nOYkjhIeneswzval8Z80SONUYmIt77vffn.UmRe', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000005, 1000003, N'mbrown', N'$2a$11$3S3aEWM9kNv8FFgINzxwlOmHI0c6MjhnECi37LSFakJ7G06plC3Jq', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000006, 1000004, N'odavis', N'$2a$11$SeiT78I.KCUCIyA.Tekz3.6iGvRYMB36uEwWHIaUOnpk1LHVEojBC', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000007, 1000007, N'admin', N'$2a$11$bAMpwulL0gHQHs8KjUhXOuQx1H8..srJtpaZvIYgSho1.7h.sJzgO', NULL, N'Admin', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000008, 1000008, N'AppleX', N'$2a$11$brApgqrrxR03HTB8Ien70OY2BlTAGgiKhAsewW2gdfoId6tLpn4Yy', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000009, 1000009, N'BatmanManda777', N'$2a$11$os.5YzxyLfH7fanDc6sTwupSmWgyhwZH8Duw4SI2wJVhKD6Z0SkDO', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000010, 1000010, N'ihaveadisease', N'$2a$11$HR/pEL0wJCrE6/hUDKq.QOWq9qsKx5DQeabRqWLVHuXlFSn5DEqkG', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000011, 1000027, N'aallen', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000012, 1000033, N'abaker', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000013, 1000016, N'anguyen', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Doctor', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000014, 1000038, N'aperez', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000015, 1000021, N'athompson', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000016, 1000036, N'bcarter', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000017, 1000043, N'cparker', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000018, 1000039, N'croberts', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000019, 1000015, N'dbrooks', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Doctor', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000020, 1000011, N'dchen', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Doctor', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000021, 1000019, N'ejohnson', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000022, 1000024, N'elewis', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000023, 1000035, N'enelson', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000024, 1000031, N'escott', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000025, 1000041, N'gphillips', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000026, 1000034, N'hadams', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000027, 1000029, N'hking', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000028, 1000017, N'hwilliams', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Nurse', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000029, 1000025, N'iwalker', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000030, 1000032, N'jgreen', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000031, 1000018, N'kthomas', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Nurse', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000032, 1000020, N'landerson', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000033, 1000026, N'lhall', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000034, 1000030, N'lwright', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000035, 1000023, N'mclark', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000036, 1000028, N'myoung', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000037, 1000022, N'nrobinson', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000038, 1000012, N'pshah', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Doctor', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000039, 1000013, N'rkim', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Doctor', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000040, 1000042, N'scampbell', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000041, 1000014, N'smartinez', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Doctor', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000042, 1000037, N'smitchell', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000043, 1000044, N'tdemopatient', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000044, 1000040, N'wturner', N'$2a$11$CKkfxhkutzfKxTZXy5ibp.argkXTVZlJ3dH7rpYhZdXMEt3Vz5f3i', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000045, 1000047, N'Axe1', N'$2a$11$U3w7PUEdjM2oeZFRhN0PIuJuqmL25fhGF5TUnn2taNrQzSPXWezsS', NULL, N'Patient', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000046, 1000048, N'Johndoe', N'$2a$11$TZyBjVRyMiJoOu0ofcqcIuONR8J0YnlCwX0STswnuCY0VGPMfDBOu', NULL, N'Nurse', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000048, 1000050, N'johndo', N'$2a$11$vQ671P1i.h2LjkEcFvYJwuj1N97FjZAitefR0tfH5ofeIzmcpap0W', NULL, N'Receptionist', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000049, 1000053, N'jdoee', N'$2a$11$JhYAOVmhGBnAG7xy1wI2t.7Waqem1Xys23sf9UjCG5uud4uR.G/u.', NULL, N'Receptionist', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000050, 1000055, N'jdoey', N'$2a$11$OM/hXa0082LXDpXvx/GsCOtzlwb2DTrEIU5CIkZJZmedDeRIBlu3O', NULL, N'Receptionist', 1, 0)
INSERT [dbo].[UserAccount] ([AccountID], [UserID], [Username], [PasswordHash], [LastLogin], [Role], [IsActive], [DeletionFlag]) VALUES (1000051, 1000056, N'Tucupito', N'$2a$11$BOi0wFiG2n.oMuNSegQWweHVxM7c6Lb4VZgEHhRL9ODPVC4KYoRv6', NULL, N'Patient', 1, 0)
SET IDENTITY_INSERT [dbo].[UserAccount] OFF
GO
INSERT [dbo].[PaymentMethod] ([MethodID], [MethodName], [DeletionFlag]) VALUES (1, N'Cash', 0)
INSERT [dbo].[PaymentMethod] ([MethodID], [MethodName], [DeletionFlag]) VALUES (2, N'Credit Card', 0)
INSERT [dbo].[PaymentMethod] ([MethodID], [MethodName], [DeletionFlag]) VALUES (3, N'Debit Card', 0)
INSERT [dbo].[PaymentMethod] ([MethodID], [MethodName], [DeletionFlag]) VALUES (4, N'Insurance', 0)
INSERT [dbo].[PaymentMethod] ([MethodID], [MethodName], [DeletionFlag]) VALUES (5, N'Check', 0)
GO
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000000, 2, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000001, 1, CAST(250.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000002, 1, CAST(125.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000003, 2, CAST(300.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000004, 1, CAST(175.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000005, 2, CAST(250.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000006, 2, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000007, 1, CAST(250.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000010, 2, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000011, 1, CAST(75.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000012, 4, CAST(100.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000013, 1, CAST(75.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000014, 4, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000015, 1, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000016, 2, CAST(75.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000017, 1, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000018, 2, CAST(75.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000019, 4, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000020, 2, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000021, 1, CAST(75.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000022, 4, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000023, 2, CAST(75.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000024, 4, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000025, 2, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000026, 1, CAST(75.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000027, 4, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000028, 1, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000029, 2, CAST(75.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000030, 4, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000031, 2, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000032, 4, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000033, 1, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000034, 2, CAST(75.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000035, 4, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000036, 2, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000039, 1, CAST(25.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000042, 1, CAST(50.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000044, 3, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000045, 2, CAST(50.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000046, 3, CAST(149.92 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000047, 2, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000048, 3, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000049, 2, CAST(200.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000050, 4, CAST(200.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000051, 2, CAST(275.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000052, 2, CAST(137.50 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000053, 4, CAST(300.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000054, 4, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000055, 3, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000056, 2, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000057, 4, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000058, 2, CAST(100.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000059, 4, CAST(300.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000060, 3, CAST(200.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000061, 1, CAST(50.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000062, 2, CAST(200.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000063, 2, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000064, 2, CAST(75.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000065, 4, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000066, 3, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000067, 1, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000073, 2, CAST(150.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000074, 2, CAST(50.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000075, 2, CAST(25.00 AS Numeric(10, 2)), 0)
INSERT [dbo].[PaymentDetail] ([PaymentID], [MethodID], [AmountApplied], [DeletionFlag]) VALUES (1000076, 1, CAST(100.00 AS Numeric(10, 2)), 0)
GO
SET IDENTITY_INSERT [dbo].[ChartRequest] ON 

INSERT [dbo].[ChartRequest] ([RequestID], [PatientID], [DoctorID], [RequestDate], [RequestStatus], [DeletionFlag]) VALUES (1000000, 1000025, 1000013, CAST(N'2026-10-20' AS Date), N'Sent', 0)
INSERT [dbo].[ChartRequest] ([RequestID], [PatientID], [DoctorID], [RequestDate], [RequestStatus], [DeletionFlag]) VALUES (1000001, 1000021, 1000014, CAST(N'2026-10-21' AS Date), N'Sent', 0)
INSERT [dbo].[ChartRequest] ([RequestID], [PatientID], [DoctorID], [RequestDate], [RequestStatus], [DeletionFlag]) VALUES (1000002, 1000034, 1000015, CAST(N'2026-11-03' AS Date), N'Pending', 0)
INSERT [dbo].[ChartRequest] ([RequestID], [PatientID], [DoctorID], [RequestDate], [RequestStatus], [DeletionFlag]) VALUES (1000003, 1000040, 1000016, CAST(N'2026-11-06' AS Date), N'Pending', 0)
INSERT [dbo].[ChartRequest] ([RequestID], [PatientID], [DoctorID], [RequestDate], [RequestStatus], [DeletionFlag]) VALUES (1000004, 1000002, 1000000, CAST(N'2026-11-10' AS Date), N'Pending', 0)
SET IDENTITY_INSERT [dbo].[ChartRequest] OFF
GO
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000002, 1000000, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000002, 1000001, N'Specialist', CAST(N'2026-07-01' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000003, 1000000, N'Primary', CAST(N'2026-02-10' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000003, 1000001, N'Specialist', CAST(N'2026-07-01' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000004, 1000000, N'Primary', CAST(N'2026-03-05' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000004, 1000001, N'Specialist', CAST(N'2026-07-01' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000008, 1000000, N'Primary', CAST(N'2026-10-27' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000009, 1000000, N'Primary', CAST(N'2026-10-27' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000010, 1000000, N'Primary', CAST(N'2026-10-28' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000019, 1000012, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000020, 1000011, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000021, 1000012, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000022, 1000011, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000023, 1000012, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000024, 1000011, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000025, 1000012, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000026, 1000011, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000027, 1000012, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000028, 1000011, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000029, 1000012, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000030, 1000011, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000031, 1000012, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000032, 1000011, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000033, 1000012, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000034, 1000011, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000035, 1000012, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000036, 1000011, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000037, 1000012, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000038, 1000011, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000039, 1000012, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000040, 1000011, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000041, 1000012, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000042, 1000011, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000043, 1000012, N'Primary', CAST(N'2026-01-15' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000044, 1000000, N'Primary', CAST(N'2026-11-08' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000045, 1000012, N'Primary', CAST(N'2026-11-09' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000046, 1000013, N'Primary', CAST(N'2026-11-10' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000047, 1000011, N'Primary', CAST(N'2026-11-10' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000054, 1000000, N'Primary', CAST(N'2026-11-11' AS Date), 0)
INSERT [dbo].[PatientDoctor] ([PatientID], [DoctorID], [RolePlayed], [StartDate], [DeletionFlag]) VALUES (1000056, 1000012, N'Primary', CAST(N'2026-11-12' AS Date), 0)
GO
SET IDENTITY_INSERT [dbo].[PatientCondition] ON 

INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000000, 1000002, N'Asthma', N'Chronic', 0, N'Moderate', CAST(N'2020-04-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000001, 1000003, N'Hypertension', N'Chronic', 1, N'Moderate', CAST(N'2022-06-10' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000002, 1000004, N'Seasonal Influenza', N'Acute', 0, N'Low', CAST(N'2026-02-12' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000003, 1000019, N'Type 2 Diabetes', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000004, 1000020, N'Asthma', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000005, 1000021, N'High Cholesterol', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000006, 1000022, N'Hypertension', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000007, 1000023, N'Type 2 Diabetes', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000008, 1000024, N'Asthma', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000009, 1000025, N'High Cholesterol', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000010, 1000026, N'Hypertension', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000011, 1000027, N'Type 2 Diabetes', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000012, 1000028, N'Asthma', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000013, 1000029, N'High Cholesterol', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000014, 1000030, N'Hypertension', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000015, 1000031, N'Type 2 Diabetes', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000016, 1000032, N'Asthma', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000017, 1000033, N'High Cholesterol', N'Chronic', 0, N'Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000018, 1000028, N'Seasonal Flu', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000019, 1000029, N'Sinus Infection', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000020, 1000030, N'Common Cold', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000021, 1000031, N'Seasonal Flu', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000022, 1000032, N'Sinus Infection', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000023, 1000033, N'Common Cold', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000024, 1000034, N'Seasonal Flu', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000025, 1000035, N'Sinus Infection', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000026, 1000036, N'Common Cold', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000027, 1000037, N'Seasonal Flu', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000028, 1000038, N'Sinus Infection', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000029, 1000039, N'Common Cold', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000030, 1000040, N'Seasonal Flu', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000031, 1000041, N'Sinus Infection', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000032, 1000042, N'Common Cold', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000033, 1000043, N'Seasonal Flu', N'Acute', 0, N'Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000034, 1000025, N'Strep throat', N'Acute', 0, N'Low', CAST(N'2026-10-14' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000035, 1000031, N'Ear infection', N'Acute', 0, N'Low', CAST(N'2026-10-26' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000036, 1000021, N'Eczema', N'Chronic', 0, N'Moderate', CAST(N'2026-10-13' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000037, 1000024, N'Knee sprain', N'Acute', 0, N'Moderate', CAST(N'2026-10-20' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000038, 1000034, N'Osteoarthritis', N'Chronic', 0, N'Moderate', CAST(N'2026-10-22' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000039, 1000026, N'Coronary artery disease', N'Chronic', 0, N'Moderate', CAST(N'2026-10-16' AS Date), 0)
INSERT [dbo].[PatientCondition] ([ConditionID], [PatientID], [ConditionName], [ConditionType], [IsHereditary], [Severity], [DateDiagnosed], [DeletionFlag]) VALUES (1000040, 1000040, N'Atrial fibrillation', N'Chronic', 0, N'Moderate', CAST(N'2026-10-19' AS Date), 0)
SET IDENTITY_INSERT [dbo].[PatientCondition] OFF
GO
SET IDENTITY_INSERT [dbo].[Allergy] ON 

INSERT [dbo].[Allergy] ([AllergyID], [PatientID], [Allergen], [ReactionType], [Severity], [DateIdentified], [DeletionFlag]) VALUES (1000000, 1000002, N'Peanuts', N'Hives', N'Moderate', CAST(N'2018-05-10' AS Date), 0)
INSERT [dbo].[Allergy] ([AllergyID], [PatientID], [Allergen], [ReactionType], [Severity], [DateIdentified], [DeletionFlag]) VALUES (1000001, 1000003, N'Penicillin', N'Skin Rash', N'Mild', CAST(N'2015-03-20' AS Date), 0)
INSERT [dbo].[Allergy] ([AllergyID], [PatientID], [Allergen], [ReactionType], [Severity], [DateIdentified], [DeletionFlag]) VALUES (1000002, 1000004, N'Pollen', N'Sneezing', N'Mild', CAST(N'2021-04-05' AS Date), 0)
INSERT [dbo].[Allergy] ([AllergyID], [PatientID], [Allergen], [ReactionType], [Severity], [DateIdentified], [DeletionFlag]) VALUES (1000003, 1000044, N'Penicillin', N'Hives', N'Severe', CAST(N'2019-06-01' AS Date), 0)
INSERT [dbo].[Allergy] ([AllergyID], [PatientID], [Allergen], [ReactionType], [Severity], [DateIdentified], [DeletionFlag]) VALUES (1000004, 1000022, N'Sulfa', N'Rash', N'Moderate', CAST(N'2017-08-14' AS Date), 0)
INSERT [dbo].[Allergy] ([AllergyID], [PatientID], [Allergen], [ReactionType], [Severity], [DateIdentified], [DeletionFlag]) VALUES (1000005, 1000026, N'Shellfish', N'Swelling', N'Severe', CAST(N'2009-07-04' AS Date), 0)
INSERT [dbo].[Allergy] ([AllergyID], [PatientID], [Allergen], [ReactionType], [Severity], [DateIdentified], [DeletionFlag]) VALUES (1000006, 1000032, N'Latex', N'Skin rash', N'Moderate', CAST(N'2016-05-30' AS Date), 0)
INSERT [dbo].[Allergy] ([AllergyID], [PatientID], [Allergen], [ReactionType], [Severity], [DateIdentified], [DeletionFlag]) VALUES (1000007, 1000034, N'Codeine', N'Nausea and vomiting', N'Severe', CAST(N'2012-02-03' AS Date), 0)
INSERT [dbo].[Allergy] ([AllergyID], [PatientID], [Allergen], [ReactionType], [Severity], [DateIdentified], [DeletionFlag]) VALUES (1000008, 1000036, N'Penicillin', N'Hives', N'Severe', CAST(N'2014-03-11' AS Date), 0)
INSERT [dbo].[Allergy] ([AllergyID], [PatientID], [Allergen], [ReactionType], [Severity], [DateIdentified], [DeletionFlag]) VALUES (1000009, 1000040, N'Aspirin', N'Stomach upset', N'Mild', CAST(N'2020-11-19' AS Date), 0)
SET IDENTITY_INSERT [dbo].[Allergy] OFF
GO
SET IDENTITY_INSERT [dbo].[FamilyCondition] ON 

INSERT [dbo].[FamilyCondition] ([FamilyConditionID], [PatientID], [ConditionName], [FamilyRelationship], [Notes], [DeletionFlag]) VALUES (1000000, 1000002, N'Diabetes', N'Mother', N'Family history of type 2 diabetes.', 0)
INSERT [dbo].[FamilyCondition] ([FamilyConditionID], [PatientID], [ConditionName], [FamilyRelationship], [Notes], [DeletionFlag]) VALUES (1000001, 1000003, N'Hypertension', N'Father', N'Father diagnosed with hypertension.', 0)
SET IDENTITY_INSERT [dbo].[FamilyCondition] OFF
GO
SET IDENTITY_INSERT [dbo].[Insurance] ON 

INSERT [dbo].[Insurance] ([InsuranceID], [PatientID], [ProviderCompany], [PolicyNum], [GroupNum], [PlanType], [EffectiveDate], [ExpirationDate], [IsPrimary], [DeletionFlag]) VALUES (1000000, 1000002, N'Blue Cross', N'1234567890001', N'123456789012345', N'PPO', CAST(N'2026-01-01' AS Date), CAST(N'2026-12-31' AS Date), 1, 0)
INSERT [dbo].[Insurance] ([InsuranceID], [PatientID], [ProviderCompany], [PolicyNum], [GroupNum], [PlanType], [EffectiveDate], [ExpirationDate], [IsPrimary], [DeletionFlag]) VALUES (1000001, 1000003, N'Aetna', N'1234567890002', N'123456789012346', N'HMO', CAST(N'2026-01-01' AS Date), CAST(N'2026-12-31' AS Date), 1, 0)
INSERT [dbo].[Insurance] ([InsuranceID], [PatientID], [ProviderCompany], [PolicyNum], [GroupNum], [PlanType], [EffectiveDate], [ExpirationDate], [IsPrimary], [DeletionFlag]) VALUES (1000002, 1000004, N'Cigna', N'1234567890003', N'123456789012347', N'PPO', CAST(N'2026-01-01' AS Date), CAST(N'2026-12-31' AS Date), 1, 0)
SET IDENTITY_INSERT [dbo].[Insurance] OFF
GO
SET IDENTITY_INSERT [dbo].[EmergencyContact] ON 

INSERT [dbo].[EmergencyContact] ([ContactID], [PatientID], [FirstName], [MiddleName], [LastName], [Phone], [Relationship], [DeletionFlag]) VALUES (1000000, 1000002, N'Robert', NULL, N'Garcia', N'7135552001', N'Father', 0)
INSERT [dbo].[EmergencyContact] ([ContactID], [PatientID], [FirstName], [MiddleName], [LastName], [Phone], [Relationship], [DeletionFlag]) VALUES (1000001, 1000003, N'Linda', NULL, N'Brown', N'7135552002', N'Mother', 0)
INSERT [dbo].[EmergencyContact] ([ContactID], [PatientID], [FirstName], [MiddleName], [LastName], [Phone], [Relationship], [DeletionFlag]) VALUES (1000002, 1000004, N'Sophia', NULL, N'Davis', N'7135552003', N'Sister', 0)
SET IDENTITY_INSERT [dbo].[EmergencyContact] OFF
GO
INSERT [dbo].[AppointmentActivityReport] ([DoctorID], [DoctorFirstName], [DoctorLastName], [OfficeID], [OfficeStreetAddress], [FromDate], [ToDate], [TotalAppointments], [Scheduled], [Completed], [Cancelled], [CancelledByPatient], [CancelledByDoctor], [CancelledByStaff], [CancellationRate], [DeletionFlag]) VALUES (1000000, N'Sarah', N'Patel', 1000000, N'1234 Main Street', CAST(N'2023-10-10' AS Date), CAST(N'2026-10-10' AS Date), 4, 0, 4, 0, 0, 0, 0, CAST(0.00 AS Numeric(5, 2)), 0)
INSERT [dbo].[AppointmentActivityReport] ([DoctorID], [DoctorFirstName], [DoctorLastName], [OfficeID], [OfficeStreetAddress], [FromDate], [ToDate], [TotalAppointments], [Scheduled], [Completed], [Cancelled], [CancelledByPatient], [CancelledByDoctor], [CancelledByStaff], [CancellationRate], [DeletionFlag]) VALUES (1000001, N'James', N'Wilson', 1000001, N'5678 Westheimer Road', CAST(N'2023-10-10' AS Date), CAST(N'2026-10-10' AS Date), 4, 0, 4, 0, 0, 0, 0, CAST(0.00 AS Numeric(5, 2)), 0)
INSERT [dbo].[AppointmentActivityReport] ([DoctorID], [DoctorFirstName], [DoctorLastName], [OfficeID], [OfficeStreetAddress], [FromDate], [ToDate], [TotalAppointments], [Scheduled], [Completed], [Cancelled], [CancelledByPatient], [CancelledByDoctor], [CancelledByStaff], [CancellationRate], [DeletionFlag]) VALUES (1000011, N'David', N'Chen', 1000000, N'1234 Main Street', CAST(N'2023-10-10' AS Date), CAST(N'2026-10-10' AS Date), 12, 0, 10, 2, 2, 0, 0, CAST(16.67 AS Numeric(5, 2)), 0)
INSERT [dbo].[AppointmentActivityReport] ([DoctorID], [DoctorFirstName], [DoctorLastName], [OfficeID], [OfficeStreetAddress], [FromDate], [ToDate], [TotalAppointments], [Scheduled], [Completed], [Cancelled], [CancelledByPatient], [CancelledByDoctor], [CancelledByStaff], [CancellationRate], [DeletionFlag]) VALUES (1000012, N'Priya', N'Shah', 1000000, N'1234 Main Street', CAST(N'2023-10-10' AS Date), CAST(N'2026-10-10' AS Date), 13, 0, 13, 0, 0, 0, 0, CAST(0.00 AS Numeric(5, 2)), 0)
GO
INSERT [dbo].[ReferralTrackingReport] ([SpecialistID], [SpecialistFirstName], [SpecialistLastName], [Specialty], [TotalReferrals], [OpenReferrals], [FinishedReferrals], [CancelledReferrals], [ReferralsWithVisit], [DeletionFlag]) VALUES (1000001, N'James', N'Wilson', N'Cardiology', 4, 2, 2, 0, 3, 0)
INSERT [dbo].[ReferralTrackingReport] ([SpecialistID], [SpecialistFirstName], [SpecialistLastName], [Specialty], [TotalReferrals], [OpenReferrals], [FinishedReferrals], [CancelledReferrals], [ReferralsWithVisit], [DeletionFlag]) VALUES (1000016, N'Angela', N'Nguyen', N'Cardiology', 1, 1, 0, 0, 0, 0)
GO
INSERT [dbo].[VisitDetailsReport] ([AppointmentID], [VisitDateTime], [PatientID], [PatientFirstName], [PatientLastName], [DoctorFirstName], [DoctorLastName], [Specialty], [OfficeStreetAddress], [AppointStatus], [CancelledBy], [TotalCost], [AmountPaid], [CancellationFee], [Diagnoses], [DeletionFlag]) VALUES (1000032, CAST(N'2026-09-21T11:00:00.0000000' AS DateTime2), 1000033, N'Abigail', N'Baker', N'Priya', N'Shah', N'Family Medicine', N'1234 Main Street', N'Completed', NULL, CAST(150.00 AS Numeric(10, 2)), CAST(0.00 AS Numeric(12, 2)), NULL, N'Seasonal Allergies', 0)
INSERT [dbo].[VisitDetailsReport] ([AppointmentID], [VisitDateTime], [PatientID], [PatientFirstName], [PatientLastName], [DoctorFirstName], [DoctorLastName], [Specialty], [OfficeStreetAddress], [AppointStatus], [CancelledBy], [TotalCost], [AmountPaid], [CancellationFee], [Diagnoses], [DeletionFlag]) VALUES (1000184, CAST(N'2026-11-10T10:00:00.0000000' AS DateTime2), 1000033, N'Abigail', N'Baker', N'Sophia', N'Martinez', N'Dermatology', N'5678 Westheimer Road', N'Completed', NULL, CAST(200.00 AS Numeric(10, 2)), CAST(200.00 AS Numeric(12, 2)), NULL, N'Acne vulgaris', 0)
INSERT [dbo].[VisitDetailsReport] ([AppointmentID], [VisitDateTime], [PatientID], [PatientFirstName], [PatientLastName], [DoctorFirstName], [DoctorLastName], [Specialty], [OfficeStreetAddress], [AppointStatus], [CancelledBy], [TotalCost], [AmountPaid], [CancellationFee], [Diagnoses], [DeletionFlag]) VALUES (1000244, CAST(N'2026-11-13T12:30:00.0000000' AS DateTime2), 1000033, N'Abigail', N'Baker', N'Angela', N'Nguyen', N'Cardiology', N'5678 Westheimer Road', N'Scheduled', NULL, CAST(300.00 AS Numeric(10, 2)), CAST(0.00 AS Numeric(12, 2)), NULL, NULL, 0)
INSERT [dbo].[VisitDetailsReport] ([AppointmentID], [VisitDateTime], [PatientID], [PatientFirstName], [PatientLastName], [DoctorFirstName], [DoctorLastName], [Specialty], [OfficeStreetAddress], [AppointStatus], [CancelledBy], [TotalCost], [AmountPaid], [CancellationFee], [Diagnoses], [DeletionFlag]) VALUES (1000254, CAST(N'2026-11-16T15:30:00.0000000' AS DateTime2), 1000033, N'Abigail', N'Baker', N'Robert', N'Kim', N'Pediatrics', N'5678 Westheimer Road', N'Scheduled', NULL, CAST(150.00 AS Numeric(10, 2)), CAST(0.00 AS Numeric(12, 2)), NULL, NULL, 0)
INSERT [dbo].[VisitDetailsReport] ([AppointmentID], [VisitDateTime], [PatientID], [PatientFirstName], [PatientLastName], [DoctorFirstName], [DoctorLastName], [Specialty], [OfficeStreetAddress], [AppointStatus], [CancelledBy], [TotalCost], [AmountPaid], [CancellationFee], [Diagnoses], [DeletionFlag]) VALUES (1000265, CAST(N'2026-11-17T14:30:00.0000000' AS DateTime2), 1000033, N'Abigail', N'Baker', N'Sophia', N'Martinez', N'Dermatology', N'5678 Westheimer Road', N'Scheduled', NULL, CAST(200.00 AS Numeric(10, 2)), CAST(0.00 AS Numeric(12, 2)), NULL, NULL, 0)
INSERT [dbo].[VisitDetailsReport] ([AppointmentID], [VisitDateTime], [PatientID], [PatientFirstName], [PatientLastName], [DoctorFirstName], [DoctorLastName], [Specialty], [OfficeStreetAddress], [AppointStatus], [CancelledBy], [TotalCost], [AmountPaid], [CancellationFee], [Diagnoses], [DeletionFlag]) VALUES (1000294, CAST(N'2026-11-20T12:00:00.0000000' AS DateTime2), 1000033, N'Abigail', N'Baker', N'Priya', N'Shah', N'Family Medicine', N'1234 Main Street', N'Scheduled', NULL, CAST(150.00 AS Numeric(10, 2)), CAST(0.00 AS Numeric(12, 2)), NULL, NULL, 0)
INSERT [dbo].[VisitDetailsReport] ([AppointmentID], [VisitDateTime], [PatientID], [PatientFirstName], [PatientLastName], [DoctorFirstName], [DoctorLastName], [Specialty], [OfficeStreetAddress], [AppointStatus], [CancelledBy], [TotalCost], [AmountPaid], [CancellationFee], [Diagnoses], [DeletionFlag]) VALUES (1000308, CAST(N'2026-11-23T10:30:00.0000000' AS DateTime2), 1000033, N'Abigail', N'Baker', N'Angela', N'Nguyen', N'Cardiology', N'5678 Westheimer Road', N'Scheduled', NULL, CAST(300.00 AS Numeric(10, 2)), CAST(0.00 AS Numeric(12, 2)), NULL, NULL, 0)
INSERT [dbo].[VisitDetailsReport] ([AppointmentID], [VisitDateTime], [PatientID], [PatientFirstName], [PatientLastName], [DoctorFirstName], [DoctorLastName], [Specialty], [OfficeStreetAddress], [AppointStatus], [CancelledBy], [TotalCost], [AmountPaid], [CancellationFee], [Diagnoses], [DeletionFlag]) VALUES (1000324, CAST(N'2026-11-25T12:00:00.0000000' AS DateTime2), 1000033, N'Abigail', N'Baker', N'Sarah', N'Patel', N'Family Medicine', N'1234 Main Street', N'Scheduled', NULL, CAST(150.00 AS Numeric(10, 2)), CAST(0.00 AS Numeric(12, 2)), NULL, NULL, 0)
GO
SET IDENTITY_INSERT [dbo].[PatientHealthSummaryReport] ON 

INSERT [dbo].[PatientHealthSummaryReport] ([ReportRowID], [PatientID], [PatientFirstName], [PatientLastName], [Category], [ItemName], [Detail], [ItemDate], [DeletionFlag]) VALUES (180, 1000033, N'Abigail', N'Baker', N'Condition', N'High Cholesterol', N'Chronic, Moderate', CAST(N'2025-03-15' AS Date), 0)
INSERT [dbo].[PatientHealthSummaryReport] ([ReportRowID], [PatientID], [PatientFirstName], [PatientLastName], [Category], [ItemName], [Detail], [ItemDate], [DeletionFlag]) VALUES (181, 1000033, N'Abigail', N'Baker', N'Condition', N'Common Cold', N'Acute, Low', CAST(N'2026-09-01' AS Date), 0)
INSERT [dbo].[PatientHealthSummaryReport] ([ReportRowID], [PatientID], [PatientFirstName], [PatientLastName], [Category], [ItemName], [Detail], [ItemDate], [DeletionFlag]) VALUES (182, 1000033, N'Abigail', N'Baker', N'Diagnosis', N'Seasonal Allergies', N'Primary', CAST(N'2026-09-21' AS Date), 0)
INSERT [dbo].[PatientHealthSummaryReport] ([ReportRowID], [PatientID], [PatientFirstName], [PatientLastName], [Category], [ItemName], [Detail], [ItemDate], [DeletionFlag]) VALUES (183, 1000033, N'Abigail', N'Baker', N'Diagnosis', N'Acne vulgaris', N'Primary', CAST(N'2026-11-10' AS Date), 0)
INSERT [dbo].[PatientHealthSummaryReport] ([ReportRowID], [PatientID], [PatientFirstName], [PatientLastName], [Category], [ItemName], [Detail], [ItemDate], [DeletionFlag]) VALUES (184, 1000033, N'Abigail', N'Baker', N'Prescription', N'Tretinoin cream 0.025%', N'Pea-sized amount, Every night, 8 weeks', CAST(N'2026-11-10' AS Date), 0)
SET IDENTITY_INSERT [dbo].[PatientHealthSummaryReport] OFF
GO
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000019, N'Emma', N'Johnson', N'7135553001', 1, CAST(N'2026-10-16' AS Date), CAST(300.00 AS Numeric(12, 2)), CAST(225.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000020, N'Liam', N'Anderson', N'7135553002', 2, CAST(N'2026-09-08' AS Date), CAST(300.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), CAST(225.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000021, N'Ava', N'Thompson', N'7135553003', 1, CAST(N'2026-09-07' AS Date), CAST(300.00 AS Numeric(12, 2)), CAST(150.00 AS Numeric(12, 2)), CAST(150.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000022, N'Noah', N'Robinson', N'7135553004', 1, CAST(N'2026-10-15' AS Date), CAST(300.00 AS Numeric(12, 2)), CAST(225.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000023, N'Mia', N'Clark', N'7135553005', 1, CAST(N'2026-09-11' AS Date), CAST(150.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000024, N'Ethan', N'Lewis', N'7135553006', 1, CAST(N'2026-09-15' AS Date), CAST(150.00 AS Numeric(12, 2)), CAST(0.00 AS Numeric(12, 2)), CAST(150.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000026, N'Lucas', N'Hall', N'7135553008', 1, CAST(N'2026-09-15' AS Date), CAST(150.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000027, N'Amelia', N'Allen', N'7135553009', 1, CAST(N'2026-09-14' AS Date), CAST(150.00 AS Numeric(12, 2)), CAST(0.00 AS Numeric(12, 2)), CAST(150.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000029, N'Harper', N'King', N'7135553011', 1, CAST(N'2026-09-25' AS Date), CAST(150.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000030, N'Logan', N'Wright', N'7135553012', 1, CAST(N'2026-09-22' AS Date), CAST(150.00 AS Numeric(12, 2)), CAST(0.00 AS Numeric(12, 2)), CAST(150.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000032, N'Jacob', N'Green', N'7135553014', 1, CAST(N'2026-09-22' AS Date), CAST(150.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000033, N'Abigail', N'Baker', N'7135553015', 1, CAST(N'2026-09-21' AS Date), CAST(150.00 AS Numeric(12, 2)), CAST(0.00 AS Numeric(12, 2)), CAST(150.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000035, N'Ella', N'Nelson', N'7135553017', 1, CAST(N'2026-10-02' AS Date), CAST(150.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000036, N'Benjamin', N'Carter', N'7135553018', 1, CAST(N'2026-09-29' AS Date), CAST(150.00 AS Numeric(12, 2)), CAST(0.00 AS Numeric(12, 2)), CAST(150.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000039, N'Charlotte', N'Roberts', N'7135553021', 1, CAST(N'2026-10-05' AS Date), CAST(150.00 AS Numeric(12, 2)), CAST(0.00 AS Numeric(12, 2)), CAST(150.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000041, N'Grace', N'Phillips', N'7135553023', 1, CAST(N'2026-10-09' AS Date), CAST(150.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), CAST(75.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OutstandingBalanceReport] ([PatientID], [PatientFirstName], [PatientLastName], [Phone], [UnpaidVisits], [OldestUnpaidVisit], [Billed], [Paid], [Balance], [DeletionFlag]) VALUES (1000042, N'Samuel', N'Campbell', N'7135553024', 1, CAST(N'2026-10-06' AS Date), CAST(150.00 AS Numeric(12, 2)), CAST(0.00 AS Numeric(12, 2)), CAST(150.00 AS Numeric(12, 2)), 0)
GO
INSERT [dbo].[OfficeRevenueReport] ([OfficeID], [OfficeStreetAddress], [FromDate], [ToDate], [CompletedVisits], [Billed], [Collected], [Refunded], [Outstanding], [CashCollected], [CreditCardCollected], [DebitCardCollected], [InsuranceCollected], [CheckCollected], [DeletionFlag]) VALUES (1000000, N'1234 Main Street', CAST(N'2026-10-01' AS Date), CAST(N'2026-11-10' AS Date), 23, CAST(3825.00 AS Numeric(12, 2)), CAST(2687.50 AS Numeric(12, 2)), CAST(0.00 AS Numeric(12, 2)), CAST(1137.50 AS Numeric(12, 2)), CAST(700.00 AS Numeric(12, 2)), CAST(1537.50 AS Numeric(12, 2)), CAST(150.00 AS Numeric(12, 2)), CAST(300.00 AS Numeric(12, 2)), CAST(0.00 AS Numeric(12, 2)), 0)
INSERT [dbo].[OfficeRevenueReport] ([OfficeID], [OfficeStreetAddress], [FromDate], [ToDate], [CompletedVisits], [Billed], [Collected], [Refunded], [Outstanding], [CashCollected], [CreditCardCollected], [DebitCardCollected], [InsuranceCollected], [CheckCollected], [DeletionFlag]) VALUES (1000001, N'5678 Westheimer Road', CAST(N'2026-10-01' AS Date), CAST(N'2026-11-10' AS Date), 11, CAST(2550.00 AS Numeric(12, 2)), CAST(2150.00 AS Numeric(12, 2)), CAST(0.00 AS Numeric(12, 2)), CAST(400.00 AS Numeric(12, 2)), CAST(300.00 AS Numeric(12, 2)), CAST(550.00 AS Numeric(12, 2)), CAST(350.00 AS Numeric(12, 2)), CAST(950.00 AS Numeric(12, 2)), CAST(0.00 AS Numeric(12, 2)), 0)
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- R2 base: one row per appointment
CREATE   VIEW vw_AppointmentActivity
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- REPORT 2: MOST COMMON PATIENT CONDITIONS


CREATE   VIEW dbo.vw_CommonHealthConditions
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW vw_DoctorWeeklySchedule
AS
SELECT ds.DoctorID,
    m.FirstName + ' ' + m.LastName AS DoctorName,
    ds.OfficeID,
    o.StreetAddress AS Office,
    ds.DayOfWeek AS DayName,
    (CHARINDEX(ds.DayOfWeek, 'MonTueWedThuFriSatSun') + 2) / 3 AS DayNumber
FROM DoctorSchedule AS ds
JOIN Member AS m ON m.MemberID = ds.DoctorID
JOIN Office AS o ON o.OfficeID = ds.OfficeID
WHERE ds.DeletionFlag = 0
  AND m.DeletionFlag = 0
  AND o.DeletionFlag = 0;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- REPORT 1: CHRONIC VS ACUTE CONDITIONS


CREATE   VIEW dbo.vw_HealthConditionSummary
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- REPORT 3: MONTHLY DIAGNOSIS TRENDS


CREATE   VIEW dbo.vw_MonthlyDiagnosisTrends
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW vw_OfficeBilling
AS
SELECT a.OfficeID, o.StreetAddress AS OfficeStreetAddress, a.Date_Time, a.TotalCost
FROM Appointment AS a
JOIN Office AS o ON o.OfficeID = a.OfficeID
WHERE a.AppointStatus = 'Completed'
AND a.DeletionFlag = 0
AND o.DeletionFlag = 0;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW vw_OfficePayments
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW vw_PatientHealthItems
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- REPORT 4: PATIENT HEALTH HISTORY


CREATE   VIEW dbo.vw_PatientHealthTrends
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW  vw_PatientVisitPayments
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW vw_ReferralVisits
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- R3: Visit details behind every report
-- One row per visit with all its data: who, where, status, money, diagnoses
CREATE   VIEW vw_VisitDetails
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Query 1: a doctor's appointments for a given week
CREATE   PROCEDURE usp_DoctorWeekAppointments
    @DoctorID INT,
    @WeekStart DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT a.Date_Time, m.FirstName + ' ' + m.LastName AS PatientName, o.StreetAddress AS Office, a.AppointStatus
    FROM Appointment AS a
    JOIN Member AS m
    ON m.MemberID = a.PatientID
    JOIN Office AS o ON o.OfficeID = a.OfficeID
    WHERE a.DoctorID = @DoctorID
    AND a.Date_Time >= @WeekStart
    AND a.Date_Time < DATEADD(DAY,7,@WeekStart)
    AND a.DeletionFlag = 0
    AND m.DeletionFlag = 0
    AND o.DeletionFlag = 0
    ORDER BY a.Date_Time;

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- PROCEDURE 2: MOST COMMON CONDITIONS


CREATE   PROCEDURE dbo.usp_GetCommonHealthConditions
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- PROCEDURE 1: CONDITION SUMMARY


CREATE   PROCEDURE dbo.usp_GetHealthConditionSummary
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- PROCEDURE 5: HEALTH TRENDS DASHBOARD
--
-- Returns three result sets:
-- 1. Chronic vs acute conditions
-- 2. Most common conditions
-- 3. Monthly diagnoses


CREATE   PROCEDURE dbo.usp_GetHealthTrendsDashboard
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- PROCEDURE 3: MONTHLY DIAGNOSIS TRENDS


CREATE   PROCEDURE dbo.usp_GetMonthlyDiagnosisTrends
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- PROCEDURE 4: INDIVIDUAL PATIENT HEALTH TRENDS

CREATE   PROCEDURE dbo.usp_GetPatientHealthTrends
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Query 2: patient's balance

CREATE   PROCEDURE usp_PatientBalance
    @PatientID INT

AS BEGIN
    SET NOCOUNT ON;

    DECLARE @Billed NUMERIC(10,2), @Paid NUMERIC(10,2),
            @Visits NUMERIC(10,2), @Fees NUMERIC(10,2);

    --Billed completed visits only
    SELECT @Visits = ISNULL(SUM(a.TotalCost), 0)
    FROM Appointment AS a
    WHERE a.PatientID = @PatientID
    AND a.AppointStatus = 'Completed'
    AND a.DeletionFlag = 0;

    --Late-cancellation fees
    SELECT @Fees = ISNULL(SUM(a.CancellationFee), 0)
    FROM Appointment AS a
    WHERE a.PatientID = @PatientID
    AND a.AppointStatus = 'Cancelled'
    AND a.DeletionFlag = 0;

    SET @Billed = @Visits + @Fees;

-- Paid: payment lines on completed visits and cancelled visits with fees
SELECT @Paid = ISNULL(SUM(pd.AmountApplied), 0)
FROM PaymentDetail AS pd
JOIN Payment AS p ON p.PaymentID = pd.PaymentID
JOIN Appointment AS a ON a.AppointmentID = p.AppointmentID
WHERE a.PatientID = @PatientID
AND (
    a.AppointStatus = 'Completed'
    OR (a.AppointStatus = 'Cancelled'
        AND ISNULL(a.CancellationFee, 0) > 0)
)
AND p.PayStatus = 'Completed'
AND a.DeletionFlag = 0
AND p.DeletionFlag = 0
AND pd.DeletionFlag = 0;

SELECT @Billed AS Billed, @Paid AS Paid,
       @Billed - @Paid AS Balance,
       @Visits AS Visits, @Fees AS Fees;
END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE usp_RefreshAppointmentActivityReport
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE usp_RefreshOfficeRevenueReport
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE usp_RefreshOutstandingBalanceReport
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE usp_RefreshPatientHealthSummaryReport
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE usp_RefreshReferralTrackingReport
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Fills VisitDetailsReport for a date range and/or one patient (NULL = no filter)
CREATE   PROCEDURE usp_RefreshVisitDetailsReport
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Query 3: search patients by name and/or date of birth
CREATE   PROCEDURE usp_SearchPatients
    @Name VARCHAR(50),
    @DateOfBirth DATE

AS BEGIN
    SET NOCOUNT ON;

    SELECT p.PatientID, m.FirstName + ' ' + m.LastName AS PatientName,
    m.DateOfBirth AS DateOfBirth,
    m.Phone AS Phone
    FROM Patient AS p
    JOIN Member AS m ON m.MemberID = p.PatientID
    WHERE (@Name IS NULL OR m.FirstName + ' ' + m.LastName LIKE '%' + @Name + '%' )
    AND (@DateOfBirth IS NULL OR m.DateOfBirth = @DateOfBirth)
    AND p.DeletionFlag = 0
    AND m.DeletionFlag = 0
    ORDER BY m.LastName, m.FirstName

END;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   TRIGGER TR_Appointment_DoctorSchedule 
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
ALTER TABLE [dbo].[Appointment] ENABLE TRIGGER [TR_Appointment_DoctorSchedule]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- R5: $25 late-cancellation/no show fee
CREATE   TRIGGER [dbo].[TR_Appointment_LateCancelFee]
ON [dbo].[Appointment]
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
ALTER TABLE [dbo].[Appointment] ENABLE TRIGGER [TR_Appointment_LateCancelFee]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- A doctor cannot have two scheduled visits less than 30 minutes apart (booking slots are 30 minutes)
CREATE   TRIGGER [dbo].[TR_Appointment_NoDoubleBook]
ON [dbo].[Appointment]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;

    IF NOT (
        UPDATE(DoctorID)
        OR UPDATE(Date_Time)
        OR UPDATE(AppointStatus)
        OR UPDATE(DeletionFlag)
    ) RETURN;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.Appointment AS a WITH (UPDLOCK, HOLDLOCK)
            ON a.DoctorID = i.DoctorID
           AND a.AppointmentID <> i.AppointmentID
           AND a.Date_Time > DATEADD(MINUTE, -30, i.Date_Time)
           AND a.Date_Time < DATEADD(MINUTE, 30, i.Date_Time)
        WHERE i.DeletionFlag = 0
          AND i.AppointStatus = 'Scheduled'
          AND a.DeletionFlag = 0
          AND a.AppointStatus = 'Scheduled'
    )
    BEGIN
        ROLLBACK TRANSACTION;

        THROW 50010,
            'This doctor already has an appointment at that time. Choose another time.',
            1;
    END;
END;
GO
ALTER TABLE [dbo].[Appointment] ENABLE TRIGGER [TR_Appointment_NoDoubleBook]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Cannot delete a completed or paid appointment
CREATE   TRIGGER [dbo].[TR_Appointment_PreventDeleteCompletedOrPaid]
ON [dbo].[Appointment]
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
ALTER TABLE [dbo].[Appointment] ENABLE TRIGGER [TR_Appointment_PreventDeleteCompletedOrPaid]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Cannot mark completion before date of appt
CREATE   TRIGGER [dbo].[TR_Appointment_PreventEarlyCompletion]
ON [dbo].[Appointment]
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
ALTER TABLE [dbo].[Appointment] ENABLE TRIGGER [TR_Appointment_PreventEarlyCompletion]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Check changes in appointment
CREATE   TRIGGER [dbo].[TR_Appointment_PreventOverpayment]
ON [dbo].[Appointment]
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
ALTER TABLE [dbo].[Appointment] ENABLE TRIGGER [TR_Appointment_PreventOverpayment]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   TRIGGER TR_Appointment_SpecialistReferral
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
ALTER TABLE [dbo].[Appointment] ENABLE TRIGGER [TR_Appointment_SpecialistReferral]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   TRIGGER TR_Appointment_StatusTransition
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
ALTER TABLE [dbo].[Appointment] ENABLE TRIGGER [TR_Appointment_StatusTransition]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   TRIGGER TR_Payment_CancelledAppointment
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
ALTER TABLE [dbo].[Payment] ENABLE TRIGGER [TR_Payment_CancelledAppointment]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Payment status and appointments reassignment
CREATE   TRIGGER [dbo].[TR_Payment_PreventOverpayment]
ON [dbo].[Payment]
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
ALTER TABLE [dbo].[Payment] ENABLE TRIGGER [TR_Payment_PreventOverpayment]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Trigger 2

-- New/edited payment 
CREATE   TRIGGER [dbo].[TR_PaymentDetail_PreventOverpayment]
ON [dbo].[PaymentDetail]
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
ALTER TABLE [dbo].[PaymentDetail] ENABLE TRIGGER [TR_PaymentDetail_PreventOverpayment]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- 50011: A doctor cannot prescribe a medicine the patient has a severe allergy to.
-- The app warns the doctor about every allergy (mild ones can still be prescribed after
-- "Prescribe anyway"); a Severe, Life Threatening or Fatal allergy is refused here, by name
-- (Penicillin -> "Penicillin VK") or by drug family (Penicillin -> Amoxicillin).
CREATE   TRIGGER [dbo].[TR_Prescription_PreventSevereAllergy]
ON [dbo].[Prescription]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;

    DECLARE @Message NVARCHAR(400);

    SELECT TOP 1 @Message = CONCAT(
        'Not prescribed: this patient has a ', LOWER(al.Severity), ' allergy to ', al.Allergen,
        ' (', al.ReactionType, '), and ', i.MedicationName, ' is not safe for them.')
    FROM inserted AS i
    JOIN dbo.MedicalRecord AS mr ON mr.RecordID = i.RecordID
    JOIN dbo.Appointment AS a ON a.AppointmentID = mr.AppointmentID
    JOIN dbo.Allergy AS al ON al.PatientID = a.PatientID
    LEFT JOIN (VALUES
        ('penicillin', 'amoxicillin'), ('penicillin', 'ampicillin'), ('penicillin', 'augmentin'),
        ('penicillin', 'dicloxacillin'),
        ('sulfa', 'sulfamethoxazole'), ('sulfa', 'bactrim'), ('sulfa', 'sulfasalazine'),
        ('aspirin', 'ibuprofen'), ('aspirin', 'naproxen'), ('aspirin', 'advil'), ('aspirin', 'aleve'),
        ('codeine', 'hydrocodone'), ('codeine', 'oxycodone'), ('codeine', 'morphine')
    ) AS fam (Allergen, Drug)
        ON fam.Allergen = LOWER(LTRIM(RTRIM(al.Allergen)))
       AND LOWER(i.MedicationName) LIKE '%' + fam.Drug + '%'
    WHERE i.DeletionFlag = 0
      AND al.DeletionFlag = 0
      AND al.Severity IN ('Severe', 'Life Threatening', 'Fatal')
      AND (LOWER(i.MedicationName) LIKE '%' + LOWER(LTRIM(RTRIM(al.Allergen))) + '%'
           OR fam.Drug IS NOT NULL);

    IF @Message IS NOT NULL
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50011, @Message, 1;
    END;
END;
GO
ALTER TABLE [dbo].[Prescription] ENABLE TRIGGER [TR_Prescription_PreventSevereAllergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   TRIGGER TR_Referral_IssuedByPrimary
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
ALTER TABLE [dbo].[Referral] ENABLE TRIGGER [TR_Referral_IssuedByPrimary]
GO
