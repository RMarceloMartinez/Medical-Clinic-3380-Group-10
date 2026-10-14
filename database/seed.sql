USE MedicalClinic;
GO
SET QUOTED_IDENTIFIER ON;
GO
INSERT INTO Office(BuildingNum,SuiteNum,Street,City,State,ZipCode,Country,Phone,OpeningTime,ClosingTime)
VALUES('4500', '210', 'Main St', 'Houston', 'Texas', '77002', 'USA', '7135550100', '08:00', '17:00'),
    ('1200', NULL,  'Westheimer Rd', 'Houston', 'Texas', '77006', 'USA', '7135550200', '09:00', '18:00');

INSERT INTO Member (SSN, FirstName, MiddleName, LastName, ApartmentNum, HouseNum, Street, City, State, ZipCode, Country, Phone, Sex, DateOfBirth, Email)
VALUES
    ('900-10-0001', 'Elena',  'Maria',  'Ramirez', NULL,  '1820', 'Bissonnet St',   'Houston', 'Texas', '77005', 'USA', '7135550101', 'F', '1978-04-12', 'elena.ramirez@example.com'),
    ('900-10-0002', 'Marcus', NULL,     'Chen',    '12B', '2600', 'Kirby Dr',       'Houston', 'Texas', '77098', 'USA', '7135550102', 'M', '1982-09-03', 'marcus.chen@example.com'),
    ('900-10-0003', 'Priya',  'Anand',  'Patel',   NULL,  '5410', 'Braeswood Blvd', 'Houston', 'Texas', '77096', 'USA', '7135550103', 'F', '1985-01-27', 'priya.patel@example.com'),
    ('900-10-0004', 'Daniel', 'James',  'Brooks',  '304', '900',  'Montrose Blvd',  'Houston', 'Texas', '77006', 'USA', '7135550104', 'M', '1990-06-18', 'daniel.brooks@example.com'),
    ('900-10-0005', 'Sofia',  NULL,     'Nguyen',  NULL,  '7731', 'Bellaire Blvd',  'Houston', 'Texas', '77036', 'USA', '7135550105', 'F', '1996-11-02', 'sofia.nguyen@example.com'),
    ('900-10-0006', 'James',  'Robert', 'Carter',  NULL,  '3315', 'Westheimer Rd',  'Houston', 'Texas', '77027', 'USA', '7135550106', 'M', '1975-02-20', 'james.carter@example.com'),
    ('900-10-0007', 'Olivia', 'Grace',  'Bennett', NULL,  '418',  'Heights Blvd',   'Houston', 'Texas', '77007', 'USA', '7135550107', 'F', '1992-07-30', 'olivia.bennett@example.com'),
    ('900-10-0008', 'Ethan',  NULL,     'Walker',  '2A',  '1500', 'Louisiana St',   'Houston', 'Texas', '77002', 'USA', '7135550108', 'M', '1988-12-05', 'ethan.walker@example.com');

INSERT INTO Employee(EmployeeID, HiringDate)
VALUES
    (1000000, '2015-08-01'),
    (1000001, '2018-01-15'),
    (1000002, '2019-06-10'),
    (1000003, '2021-03-01'),
    (1000004, '2023-09-05' ),
    (1000005, '2012-05-20');

INSERT INTO Doctor(DoctorID, LicenseNum, Specialty)
VALUES
    (1000000, 'TX-D-10001', 'Family Medicine'),
    (1000001, 'TX-D-10002', 'Cardiology'),
    (1000002, 'TX-D-10003', 'Dermatology');

INSERT INTO Nurse(NurseID, OfficeID, LicenseNum)
VALUES
    (1000003, 1000000, 'TX-N-2001');

INSERT INTO Receptionist(ReceptionistID, OfficeID)
VALUES
    (1000004, 1000001);

INSERT INTO Patient(PatientID)
VALUES
    (1000006),
    (1000007);