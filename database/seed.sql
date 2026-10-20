--sample data for medical clinic database

--2 sample offices
INSERT INTO Office
    (StreetAddress, SuiteNum, City, State, ZipCode,
     Country, Phone, OpeningTime, ClosingTime)
VALUES
    ('1234 Main Street', '100', 'Houston', 'Texas',
     '77002', 'USA', '7135550100', '08:00', '17:00'),

    ('5678 Westheimer Road', '200', 'Houston', 'Texas',
     '77056', 'USA', '7135550200', '09:00', '18:00');

     
-- Sample members: 2 doctors and 3 patients

INSERT INTO dbo.Member
(SSN, FirstName, MiddleName, LastName,
 StreetAddress, ApartmentNum, City, State,
 ZipCode, Country, Phone, Sex, DateOfBirth, Email)
VALUES
('900-10-0001', 'Sarah', NULL, 'Patel',
 '100 Oak Street', NULL, 'Houston', 'Texas',
 '77002', 'USA', '7135551001', 'F', '1980-05-12',
 'sarah.patel@example.com'),

('900-10-0002', 'James', NULL, 'Wilson',
 '200 Pine Street', NULL, 'Houston', 'Texas',
 '77056', 'USA', '7135551002', 'M', '1975-09-21',
 'james.wilson@example.com'),

('900-10-0003', 'Emily', NULL, 'Garcia',
 '300 Elm Street', '12', 'Houston', 'Texas',
 '77003', 'USA', '7135551003', 'F', '1998-03-15',
 'emily.garcia@example.com'),

('900-10-0004', 'Michael', NULL, 'Brown',
 '400 Maple Street', NULL, 'Houston', 'Texas',
 '77004', 'USA', '7135551004', 'M', '1990-07-08',
 'michael.brown@example.com'),

('900-10-0005', 'Olivia', NULL, 'Davis',
 '500 Cedar Street', '4B', 'Houston', 'Texas',
 '77005', 'USA', '7135551005', 'F', '2001-11-25',
 'olivia.davis@example.com');
