CREATE SCHEMA Emergency_Room;

use Emergency_Room;


/* *****************
*
*
*
	CREATING SCHEMA
*
*
*
*******************/

CREATE TABLE person (
    personID INT AUTO_INCREMENT PRIMARY KEY,
    fname VARCHAR(100) NOT NULL,
    lname VARCHAR(100) NOT NULL,
    mname VARCHAR(100),
    DoB DATE NOT NULL
);

CREATE TABLE address (
    addressID INT AUTO_INCREMENT PRIMARY KEY,
    personID INT NOT NULL,
    country VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    Street VARCHAR(150) NOT NULL,
    hnumber VARCHAR(20) NOT NULL,
    
    FOREIGN KEY (personID) REFERENCES person(personID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE email (
    personID INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    
    PRIMARY KEY (personID, email),
    FOREIGN KEY (personID) REFERENCES person(personID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE phoneNumber (
    personID INT NOT NULL,
    phoneNum VARCHAR(20) NOT NULL,
    
    PRIMARY KEY (personID, phoneNum),
    FOREIGN KEY (personID) REFERENCES person(personID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE worker (
    workerID INT PRIMARY KEY AUTO_INCREMENT,
    personID INT NOT NULL,
    
    FOREIGN KEY (personID) REFERENCES person(personID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE doctor (
    workerID INT PRIMARY KEY,
    specialization VARCHAR(255),
    
    FOREIGN KEY (workerID) REFERENCES worker(workerID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE nurse (
    workerID INT PRIMARY KEY,
    
    FOREIGN KEY (workerID) REFERENCES worker(workerID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE receptionist (
    workerID INT PRIMARY KEY,
    
    FOREIGN KEY (workerID) REFERENCES worker(workerID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE shift (
    shiftID INT PRIMARY KEY AUTO_INCREMENT,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    triageID INT NOT NULL,
    
    FOREIGN KEY (triageID) REFERENCES worker(workerID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE shift_assignment (
    workerID INT NOT NULL,
    shiftID INT NOT NULL,
	role ENUM('nurse', 'receptionist', 'case doctor', 'triage doctor') NOT NULL,
    
    PRIMARY KEY (workerID, shiftID),
    FOREIGN KEY (workerID) REFERENCES worker(workerID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (shiftID) REFERENCES shift(shiftID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE patient (
    patientID INT PRIMARY KEY AUTO_INCREMENT,
    personID INT NOT NULL,
    
    FOREIGN KEY (personID) REFERENCES person(personID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE visit (
    visitID INT PRIMARY KEY AUTO_INCREMENT,
    shiftID INT NOT NULL,
    patientID INT NOT NULL,
    receptionistID INT NOT NULL,
    outcome ENUM('ER_STAY', 'TAKE_HOME_PRESCRIPTION', 'SEND_HOME_INTERACTION') NOT NULL,
    
    FOREIGN KEY (shiftID) REFERENCES shift(shiftID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (patientID) REFERENCES patient(patientID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (receptionistID) REFERENCES worker(workerID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE visit
ADD COLUMN admission_datetime DATETIME,
ADD COLUMN discharge_datetime DATETIME;

CREATE TABLE send_home_interaction (
    interactionID INT PRIMARY KEY AUTO_INCREMENT,
    visitID INT NOT NULL,
    docID INT NOT NULL,
    notes TEXT,
    
    FOREIGN KEY (visitID) REFERENCES visit(visitID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (docID) REFERENCES worker(workerID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE send_home_interaction
ADD COLUMN timeOfConsultation DATETIME;


CREATE TABLE take_home_prescription (
    take_home_prescriptionID INT PRIMARY KEY AUTO_INCREMENT,
    visitID INT NOT NULL,
    docID INT NOT NULL,
    medName VARCHAR(255) NOT NULL,
    dosage VARCHAR(255) NOT NULL,
    times_per_day INT NOT NULL,
    duration VARCHAR(255) NOT NULL,
    notes TEXT,
    
    FOREIGN KEY (visitID) REFERENCES visit(visitID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (docID) REFERENCES worker(workerID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

alter table take_home_prescription
ADD COLUMN timeOfConsultation DATETIME;
select * from take_home_prescription; 


CREATE TABLE bed (
    bedID INT PRIMARY KEY AUTO_INCREMENT
);

ALTER TABLE bed
ADD COLUMN currently_occupied BOOLEAN NOT NULL DEFAULT FALSE;


CREATE TABLE ER_Stay (
    ER_StayID INT PRIMARY KEY AUTO_INCREMENT,
    visitID INT NOT NULL,
    patientID INT NOT NULL,
    bedID INT NOT NULL,
    
    FOREIGN KEY (visitID) REFERENCES visit(visitID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (patientID) REFERENCES patient(patientID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (bedID) REFERENCES bed(bedID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE ER_Stay
ADD COLUMN timeOfConsultation DATETIME;


CREATE TABLE ER_prescription (
    ER_prescripID INT PRIMARY KEY AUTO_INCREMENT,
    ER_StayID INT NOT NULL,
    medName VARCHAR(255) NOT NULL,
    dosage VARCHAR(255) NOT NULL,
    times_per_day INT NOT NULL,
    duration VARCHAR(255) NOT NULL,
    notes TEXT,
    
    FOREIGN KEY (ER_StayID) REFERENCES ER_Stay(ER_StayID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE ER_prescription
ADD COLUMN docID INT;
ALTER TABLE ER_prescription
ADD CONSTRAINT fk_docID_ER_prescription
FOREIGN KEY (docID) REFERENCES worker(workerID)
ON DELETE CASCADE
ON UPDATE CASCADE;

CREATE TABLE nurse_bed_assignment(
    ER_StayID INT NOT NULL,
    bedID INT NOT NULL,
    nurseID INT NOT NULL,
    shiftID INT NOT NULL,
    
    PRIMARY KEY (shiftID, nurseID, bedID),
    FOREIGN KEY (ER_StayID) REFERENCES ER_Stay(ER_StayID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (bedID) REFERENCES bed(bedID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (nurseID) REFERENCES worker(workerID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (shiftID) REFERENCES shift(shiftID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE doc_bed_assignment(
    ER_StayID INT NOT NULL,
    bedID INT NOT NULL,
    docID INT NOT NULL,
    shiftID INT NOT NULL,
    
    PRIMARY KEY (shiftID, docID, bedID),
    FOREIGN KEY (ER_StayID) REFERENCES ER_Stay(ER_StayID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (bedID) REFERENCES bed(bedID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (docID) REFERENCES worker(workerID)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (shiftID) REFERENCES shift(shiftID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

/* ********************
*
*
*
	INSERTION
*
*
*
************************/


INSERT INTO person (fname, lname, mname, DoB) VALUES
('John', 'Doe', 'William', '1980-05-15'),
('Jane', 'Smith', 'Marie', '1992-02-22'),
('Alice', 'Johnson', 'Eve', '1985-03-10'),
('Bob', 'Brown', 'Thomas', '1978-07-09'),
('Charlie', 'Davis', 'Ray', '1990-09-18'),
('David', 'Martinez', 'Luis', '1982-11-25'),
('Eva', 'Lopez', 'Maria', '1994-01-13'),
('Frank', 'Miller', 'George', '1988-04-17'),
('Grace', 'Wilson', 'Anne', '1991-12-02'),
('Hannah', 'Moore', 'Beth', '1984-06-30'),
('Ian', 'Taylor', 'Scott', '1989-08-21'),
('Jack', 'Anderson', 'James', '1995-03-12'),
('Kelly', 'Thomas', 'Marie', '1993-10-25'),
('Liam', 'Jackson', 'David', '1996-05-16'),
('Monica', 'White', 'Diane', '1987-02-28'),
('Nina', 'Harris', 'Lynn', '1990-07-30'),
('Oliver', 'Martin', 'William', '1986-09-12'),
('Pamela', 'Garcia', 'Rita', '1984-11-20'),
('Quincy', 'Martinez', 'Javier', '1992-03-15'),
('Rachel', 'Roberts', 'Anna', '1981-05-19'),
('Sam', 'Clark', 'David', '1995-06-17'),
('Tina', 'Rodriguez', 'Paula', '1983-09-05'),
('Ursula', 'Lopez', 'Carmen', '1980-10-22'),
('Victor', 'Walker', 'Ryan', '1994-11-01'),
('Wendy', 'Young', 'Nora', '1982-12-09'),
('Xander', 'Scott', 'Lee', '1991-08-13'),
('Yvonne', 'Adams', 'Rachel', '1990-01-30'),
('Zachary', 'Nelson', 'Paul', '1987-04-20'),
('Amanda', 'Hill', 'Cynthia', '1996-09-12'),
('Benjamin', 'Green', 'Lucas', '1983-03-17'),
('Clara', 'King', 'Helen', '1990-06-07'),
('Daniel', 'Gonzalez', 'Carlos', '1992-02-10'),
('Ella', 'Baker', 'Sophie', '1995-11-15'),
('Felix', 'Adams', 'Benjamin', '1988-03-25'),
('Gina', 'Perez', 'Maria', '1991-08-30'),
('Harry', 'Carter', 'Frank', '1993-04-22'),
('Ivy', 'Evans', 'Grace', '1984-10-14'),
('James', 'Parker', 'Mark', '1985-06-03'),
('Katherine', 'Mitchell', 'Sue', '1994-04-12'),
('Louis', 'Robinson', 'Patrick', '1992-05-05'),
('Monique', 'Collins', 'Cheryl', '1996-01-18');

select * from person;

INSERT INTO address (personID, country, province, city, Street, hnumber) VALUES
(1, 'USA', 'California', 'Los Angeles', 'Sunset Blvd', '115'),
(2, 'USA', 'California', 'San Francisco', 'Market St', '116'),
(3, 'USA', 'Texas', 'Dallas', 'Main St', '117'),
(4, 'USA', 'Texas', 'Austin', '6th St', '118'),
(5, 'USA', 'Florida', 'Tampa', 'Bayshore Blvd', '119'),
(6, 'USA', 'Florida', 'Orlando', 'International Dr', '120'),
(7, 'USA', 'New York', 'New York', 'Broadway', '121'),
(8, 'USA', 'New York', 'Brooklyn', 'Fulton St', '122'),
(9, 'USA', 'Illinois', 'Chicago', 'Wacker Dr', '123'),
(10, 'USA', 'Illinois', 'Chicago', 'Clark St', '124'),
(11, 'Canada', 'Ontario', 'Ottawa', 'Rideau St', '125'),
(12, 'Canada', 'Quebec', 'Montreal', 'Saint Denis', '126'),
(13, 'Canada', 'British Columbia', 'Vancouver', 'West 4th Ave', '127'),
(14, 'Canada', 'Alberta', 'Calgary', '8th Ave SW', '128'),
(15, 'Australia', 'New South Wales', 'Sydney', 'George St', '129'),
(16, 'Australia', 'Victoria', 'Melbourne', 'Collins St', '130'),
(17, 'UK', 'England', 'London', 'Oxford St', '131'),
(18, 'UK', 'England', 'Manchester', 'Deansgate', '132'),
(19, 'Germany', 'Bavaria', 'Munich', 'Marienplatz', '133'),
(20, 'Germany', 'Berlin', 'Berlin', 'Unter den Linden', '134'),
(21, 'USA', 'California', 'Los Angeles', 'Hollywood Blvd', '135'),
(22, 'USA', 'California', 'San Francisco', 'Golden Gate Ave', '136'),
(23, 'USA', 'Texas', 'Dallas', 'Elm St', '137'),
(24, 'USA', 'Texas', 'Austin', 'Congress Ave', '138'),
(25, 'USA', 'Florida', 'Miami', 'Ocean Dr', '139'),
(26, 'USA', 'Florida', 'Tampa', 'Harbour Blvd', '140'),
(27, 'USA', 'New York', 'Brooklyn', 'Smith St', '141'),
(28, 'USA', 'New York', 'Manhattan', 'Wall St', '142'),
(29, 'Canada', 'Ontario', 'Toronto', 'Yonge St', '143'),
(30, 'Canada', 'Quebec', 'Montreal', 'Rue St-Denis', '144'),
(31, 'Canada', 'British Columbia', 'Vancouver', 'Main St', '145'),
(32, 'Canada', 'Alberta', 'Calgary', 'Macleod Trail', '146'),
(33, 'Australia', 'New South Wales', 'Sydney', 'Pitt St', '147'),
(34, 'Australia', 'Victoria', 'Melbourne', 'Swanston St', '148'),
(35, 'UK', 'England', 'London', 'Regent St', '149'),
(36, 'UK', 'England', 'Liverpool', 'Bold St', '150'),
(37, 'Germany', 'Bavaria', 'Munich', 'Maximilianstrasse', '151'),
(38, 'Germany', 'Berlin', 'Berlin', 'Alexanderplatz', '152'),
(39, 'USA', 'California', 'Los Angeles', 'Wilshire Blvd', '153'),
(40, 'USA', 'Texas', 'Austin', 'Riverside Dr', '154'),
(41, 'USA', 'Florida', 'Orlando', 'Kissimmee Ave', '155'),
(1, 'Canada', 'Ontario', 'Ottawa', 'Bank St', '156'),
(2, 'Australia', 'Victoria', 'Melbourne', 'Little Collins St', '157'),
(3, 'UK', 'England', 'Manchester', 'Piccadilly Gardens', '158'),
(4, 'Germany', 'Bavaria', 'Munich', 'Sendlinger Str.', '159');

select * from address;

INSERT INTO phoneNumber (personID, phoneNum) VALUES
(1, '555-0101'),
(2, '555-0102'),
(3, '555-0103'),
(4, '555-0104'),
(5, '555-0105'),
(6, '555-0106'),
(7, '555-0107'),
(8, '555-0108'),
(9, '555-0109'),
(10, '555-0110'),
(11, '555-0111'),
(12, '555-0112'),
(13, '555-0113'),
(14, '555-0114'),
(15, '555-0115'),
(16, '555-0116'),
(17, '555-0117'),
(18, '555-0118'),
(19, '555-0119'),
(20, '555-0120'),
(21, '555-0121'),
(22, '555-0122'),
(23, '555-0123'),
(24, '555-0124'),
(25, '555-0125'),
(26, '555-0126'),
(27, '555-0127'),
(28, '555-0128'),
(29, '555-0129'),
(30, '555-0130'),
(31, '555-0131'),
(32, '555-0132'),
(33, '555-0133'),
(34, '555-0134'),
(35, '555-0135'),
(36, '555-0136'),
(37, '555-0137'),
(38, '555-0138'),
(39, '555-0139'),
(40, '555-0140'),
(41, '555-0141');

select * from phoneNumber;

INSERT INTO email (personID, email) VALUES
(1, 'john.doe1@example.com'),
(2, 'jane.smith2@example.com'),
(3, 'alice.jones3@example.com'),
(4, 'bob.white4@example.com'),
(5, 'carol.brown5@example.com'),
(6, 'david.miller6@example.com'),
(7, 'ellen.davis7@example.com'),
(8, 'frank.wilson8@example.com'),
(9, 'grace.moore9@example.com'),
(10, 'henry.taylor10@example.com'),
(11, 'irene.anderson11@example.com'),
(12, 'jackson.lee12@example.com'),
(13, 'karen.harris13@example.com'),
(14, 'louis.clark14@example.com'),
(15, 'mary.walker15@example.com'),
(16, 'nathan.young16@example.com'),
(17, 'olivia.king17@example.com'),
(18, 'paul.wright18@example.com'),
(19, 'quincy.evans19@example.com'),
(20, 'rachel.adams20@example.com'),
(21, 'samuel.johnson21@example.com'),
(22, 'tina.martinez22@example.com'),
(23, 'ursula.hernandez23@example.com'),
(24, 'victor.garcia24@example.com'),
(25, 'wanda.rodriguez25@example.com'),
(26, 'xander.martin26@example.com'),
(27, 'yara.lopez27@example.com'),
(28, 'zachary.gonzalez28@example.com'),
(29, 'amelia.perez29@example.com'),
(30, 'brian.sanchez30@example.com'),
(31, 'cynthia.martinez31@example.com'),
(32, 'daniel.davis32@example.com'),
(33, 'emily.russell33@example.com'),
(34, 'fred.garcia34@example.com'),
(35, 'grace.mitchell35@example.com'),
(36, 'hannah.johnson36@example.com'),
(37, 'isaac.kimberly37@example.com'),
(38, 'julia.foster38@example.com'),
(39, 'kelvin.stewart39@example.com'),
(40, 'lily.morris40@example.com'),
(41, 'mary.carter41@example.com'),
(1, 'test@gmail.com');

select * from email;

INSERT INTO worker (personID) 
VALUES 
(20), 
(6), 
(12), 
(3), 
(19), 
(26), 
(25), 
(34), 
(30), 
(4), 
(18), 
(29), 
(14), 
(9), 
(11);

select * from worker;

INSERT INTO receptionist (workerID) 
VALUES 
(1), 
(2), 
(3);

-- Get receptionists with their personID
SELECT r.workerID, p.personID, p.fname, p.lname
FROM receptionist r
JOIN worker w ON r.workerID = w.workerID
JOIN person p ON w.personID = p.personID;

select * from receptionist;

-- Inserting 7 nurses into the nurse table
INSERT INTO nurse (workerID) 
VALUES 
(4), 
(5), 
(6), 
(7), 
(8), 
(9), 
(10);

-- Get nurses with their personID
SELECT n.workerID, p.personID, p.fname, p.lname
FROM nurse n
JOIN worker w ON n.workerID = w.workerID
JOIN person p ON w.personID = p.personID;

INSERT INTO doctor (workerID, specialization) 
VALUES 
(11, 'Cardiology'), 
(12, 'Neurology'), 
(13, 'Orthopedics'), 
(14, 'Pediatrics'), 
(15, 'General Surgery');

-- Get doctors with their personID and specialization
SELECT d.workerID, p.personID, p.fname, p.lname, d.specialization
FROM doctor d
JOIN worker w ON d.workerID = w.workerID
JOIN person p ON w.personID = p.personID;

INSERT INTO shift (start_time, end_time, start_date, end_date, triageID) VALUES
-- March 1
('08:00:00', '16:00:00', '2025-03-01', '2025-03-01', 11),
('16:00:00', '00:00:00', '2025-03-01', '2025-03-02', 12),
('00:00:00', '08:00:00', '2025-03-02', '2025-03-02', 13),
-- March 2
('08:00:00', '16:00:00', '2025-03-02', '2025-03-02', 14),
('16:00:00', '00:00:00', '2025-03-02', '2025-03-03', 15),
('00:00:00', '08:00:00', '2025-03-03', '2025-03-03', 11),
-- March 3
('08:00:00', '16:00:00', '2025-03-03', '2025-03-03', 12),
('16:00:00', '00:00:00', '2025-03-03', '2025-03-04', 13),
('00:00:00', '08:00:00', '2025-03-04', '2025-03-04', 14),
-- March 4
('08:00:00', '16:00:00', '2025-03-04', '2025-03-04', 15),
('16:00:00', '00:00:00', '2025-03-04', '2025-03-05', 11),
('00:00:00', '08:00:00', '2025-03-05', '2025-03-05', 12),
-- March 5
('08:00:00', '16:00:00', '2025-03-05', '2025-03-05', 13),
('16:00:00', '00:00:00', '2025-03-05', '2025-03-06', 14),
('00:00:00', '08:00:00', '2025-03-06', '2025-03-06', 15),
-- March 6
('08:00:00', '16:00:00', '2025-03-06', '2025-03-06', 11),
('16:00:00', '00:00:00', '2025-03-06', '2025-03-07', 12),
('00:00:00', '08:00:00', '2025-03-07', '2025-03-07', 13),
('08:00:00', '16:00:00', '2025-03-07', '2025-03-07', 14);

select * from shift;

-- Assigning 2 receptionists to each shift
INSERT INTO shift_assignment (workerID, shiftID, role) VALUES
(1, 39, 'receptionist'), (2, 39, 'receptionist'),
(2, 40, 'receptionist'), (3, 40, 'receptionist'),
(1, 41, 'receptionist'), (3, 41, 'receptionist'),
(1, 42, 'receptionist'), (2, 42, 'receptionist'),
(2, 43, 'receptionist'), (3, 43, 'receptionist'),
(1, 44, 'receptionist'), (3, 44, 'receptionist'),
(1, 45, 'receptionist'), (2, 45, 'receptionist'),
(2, 46, 'receptionist'), (3, 46, 'receptionist'),
(1, 47, 'receptionist'), (3, 47, 'receptionist'),
(1, 48, 'receptionist'), (2, 48, 'receptionist'),
(2, 49, 'receptionist'), (3, 49, 'receptionist'),
(1, 50, 'receptionist'), (3, 50, 'receptionist'),
(1, 51, 'receptionist'), (2, 51, 'receptionist'),
(2, 52, 'receptionist'), (3, 52, 'receptionist'),
(1, 53, 'receptionist'), (3, 53, 'receptionist'),
(1, 54, 'receptionist'), (2, 54, 'receptionist'),
(2, 55, 'receptionist'), (3, 55, 'receptionist'),
(1, 56, 'receptionist'), (3, 56, 'receptionist'),
(1, 57, 'receptionist'), (2, 57, 'receptionist');


-- Assigning at least 2 nurses to each shift
INSERT INTO shift_assignment (workerID, shiftID, role) VALUES
(4, 39, 'nurse'), (5, 39, 'nurse'),
(6, 40, 'nurse'), (7, 40, 'nurse'),
(8, 41, 'nurse'), (9, 41, 'nurse'),
(10, 42, 'nurse'), (4, 42, 'nurse'),
(5, 43, 'nurse'), (6, 43, 'nurse'),
(7, 44, 'nurse'), (8, 44, 'nurse'),
(9, 45, 'nurse'), (10, 45, 'nurse'),
(4, 46, 'nurse'), (5, 46, 'nurse'),
(6, 47, 'nurse'), (7, 47, 'nurse'),
(8, 48, 'nurse'), (9, 48, 'nurse'),
(10, 49, 'nurse'), (4, 49, 'nurse'),
(5, 50, 'nurse'), (6, 50, 'nurse'),
(7, 51, 'nurse'), (8, 51, 'nurse'),
(9, 52, 'nurse'), (10, 52, 'nurse'),
(4, 53, 'nurse'), (5, 53, 'nurse'),
(6, 54, 'nurse'), (7, 54, 'nurse'),
(8, 55, 'nurse'), (9, 55, 'nurse'),
(10, 56, 'nurse'), (4, 56, 'nurse'),
(5, 57, 'nurse'), (6, 57, 'nurse');

-- Assigning 2 doctors per shift (1 triage doctor + 1 case doctor)
INSERT INTO shift_assignment (workerID, shiftID, role) VALUES
(11, 39, 'triage doctor'), (12, 39, 'case doctor'), (13, 39, 'case doctor'),
(12, 40, 'triage doctor'), (14, 40, 'case doctor'),
(13, 41, 'triage doctor'), (11, 41, 'case doctor'),
(14, 42, 'triage doctor'), (13, 42, 'case doctor'),
(15, 43, 'triage doctor'), (14, 43, 'case doctor'),
(11, 44, 'triage doctor'), (12, 44, 'case doctor'),
(12, 45, 'triage doctor'), (14, 45, 'case doctor'),
(13, 46, 'triage doctor'), (11, 46, 'case doctor'),
(14, 47, 'triage doctor'), (13, 47, 'case doctor'),
(15, 48, 'triage doctor'), (12, 48, 'case doctor'),
(11, 49, 'triage doctor'), (12, 49, 'case doctor'),
(12, 50, 'triage doctor'), (14, 50, 'case doctor'),
(13, 51, 'triage doctor'), (11, 51, 'case doctor'),
(14, 52, 'triage doctor'), (13, 52, 'case doctor'),
(15, 53, 'triage doctor'), (11, 53, 'case doctor'),
(11, 54, 'triage doctor'), (12, 54, 'case doctor'),
(12, 55, 'triage doctor'), (14, 55, 'case doctor'),
(13, 56, 'triage doctor'), (11, 56, 'case doctor'),
(14, 57, 'triage doctor'), (13, 57, 'case doctor');

select * from shift_assignment;

INSERT INTO patient (personID) VALUES
(1), (2), (5), (7), (8), (9), (13), (16), (17), (21),
(22), (23), (24), (27), (28), (31), (32), (33), (35),
(36), (37), (38), (39), (40), (41);

-- inserting some overlapping workers and patients
INSERT INTO patient (personID) VALUES 
(3), (4);

select * from patient;

INSERT INTO visit (shiftID, patientID, receptionistID, outcome) VALUES
(43, 1, 2, 'TAKE_HOME_PRESCRIPTION'),
(50, 2, 3, 'ER_STAY'),
(40, 3, 3, 'ER_STAY'),
(42, 4, 1, 'ER_STAY'),
(39, 5, 1, 'SEND_HOME_INTERACTION'),
(44, 6, 3, 'ER_STAY'),
(44, 7, 3, 'ER_STAY'),
(56, 8, 2, 'SEND_HOME_INTERACTION'),
(47, 9, 1, 'TAKE_HOME_PRESCRIPTION'),
(44, 10, 3, 'TAKE_HOME_PRESCRIPTION'),
(53, 13, 2, 'ER_STAY'),
(55, 16, 1, 'ER_STAY'),
(45, 17, 2, 'TAKE_HOME_PRESCRIPTION'),
(40, 21, 3, 'ER_STAY'),
(54, 22, 1, 'SEND_HOME_INTERACTION'),
(49, 23, 2, 'TAKE_HOME_PRESCRIPTION'),
(46, 24, 3, 'ER_STAY'),
(51, 27, 1, 'SEND_HOME_INTERACTION'),
(57, 11, 2, 'ER_STAY'),
(42, 12, 3, 'TAKE_HOME_PRESCRIPTION'),
(52, 14, 1, 'ER_STAY'),
(48, 15, 2, 'SEND_HOME_INTERACTION'),
(39, 18, 3, 'ER_STAY'),
(55, 19, 1, 'TAKE_HOME_PRESCRIPTION'),
(44, 20, 2, 'SEND_HOME_INTERACTION'),
(50, 25, 3, 'ER_STAY'),
(41, 26, 1, 'TAKE_HOME_PRESCRIPTION');

UPDATE visit
SET admission_datetime = CASE visitID
    WHEN 54 THEN '2025-03-01 08:15:00'
    WHEN 55 THEN '2025-03-01 09:45:00'
    WHEN 56 THEN '2025-03-02 10:10:00'
    WHEN 57 THEN '2025-03-02 11:20:00'
    WHEN 58 THEN '2025-03-02 12:05:00'
    WHEN 59 THEN '2025-03-02 13:30:00'
    WHEN 60 THEN '2025-03-03 07:45:00'
    WHEN 61 THEN '2025-03-03 08:55:00'
    WHEN 62 THEN '2025-03-03 10:30:00'
    WHEN 63 THEN '2025-03-03 14:15:00'
    WHEN 64 THEN '2025-03-03 18:05:00'
    WHEN 65 THEN '2025-03-04 06:50:00'
    WHEN 66 THEN '2025-03-04 09:25:00'
    WHEN 67 THEN '2025-03-04 13:15:00'
    WHEN 68 THEN '2025-03-04 17:40:00'
    WHEN 69 THEN '2025-03-04 20:05:00'
    WHEN 70 THEN '2025-03-05 07:10:00'
    WHEN 71 THEN '2025-03-05 09:20:00'
    WHEN 72 THEN '2025-03-05 11:45:00'
    WHEN 73 THEN '2025-03-05 14:30:00'
    WHEN 74 THEN '2025-03-05 16:50:00'
    WHEN 75 THEN '2025-03-05 18:20:00'
    WHEN 76 THEN '2025-03-05 19:45:00'
    WHEN 77 THEN '2025-03-05 20:30:00'
    WHEN 78 THEN '2025-03-05 21:15:00'
    WHEN 79 THEN '2025-03-05 22:45:00'
    WHEN 80 THEN '2025-03-05 23:30:00'
    ELSE admission_datetime
END,
discharge_datetime = CASE visitID
    WHEN 54 THEN '2025-03-01 16:45:00'
    WHEN 55 THEN '2025-03-01 17:50:00'
    WHEN 56 THEN '2025-03-02 18:20:00'
    WHEN 57 THEN '2025-03-02 19:45:00'
    WHEN 58 THEN '2025-03-02 20:30:00'
    WHEN 59 THEN '2025-03-02 21:55:00'
    WHEN 60 THEN '2025-03-03 14:10:00'
    WHEN 61 THEN '2025-03-03 15:45:00'
    WHEN 62 THEN '2025-03-03 17:20:00'
    WHEN 63 THEN '2025-03-03 20:10:00'
    WHEN 64 THEN '2025-03-03 23:40:00'
    WHEN 65 THEN '2025-03-04 10:30:00'
    WHEN 66 THEN '2025-03-04 12:55:00'
    WHEN 67 THEN '2025-03-04 16:05:00'
    WHEN 68 THEN '2025-03-04 19:50:00'
    WHEN 69 THEN '2025-03-04 23:15:00'
    WHEN 70 THEN '2025-03-05 11:10:00'
    WHEN 71 THEN '2025-03-05 13:25:00'
    WHEN 72 THEN '2025-03-05 15:50:00'
    WHEN 73 THEN '2025-03-05 17:45:00'
    WHEN 74 THEN '2025-03-05 19:30:00'
    WHEN 75 THEN '2025-03-05 21:00:00'
    WHEN 76 THEN '2025-03-05 22:10:00'
    WHEN 77 THEN '2025-03-05 23:00:00'
    WHEN 78 THEN '2025-03-05 23:30:00'
    WHEN 79 THEN '2025-03-05 23:55:00'
    WHEN 80 THEN '2025-03-05 23:59:00'
    ELSE discharge_datetime
END;


select * from visit;

SELECT visitID
FROM visit
WHERE outcome = 'SEND_HOME_INTERACTION';

INSERT INTO send_home_interaction (visitID, docID, notes)
VALUES 
(78, 11, 'Interaction notes for visit 78'),
(75, 12, 'Interaction notes for visit 75'),
(71, 13, 'Interaction notes for visit 71'),
(68, 14, 'Interaction notes for visit 68'),
(61, 14, 'Interaction notes for visit 61'),
(58, 14, 'Interaction notes for visit 58');

UPDATE send_home_interaction
SET notes = 'Fever. Just needs sleep'
WHERE visitID = 78;

UPDATE send_home_interaction
SET notes = 'referred to specialist at later date'
WHERE visitID = 75;

UPDATE send_home_interaction
SET notes = 'nothing wrong'
WHERE visitID = 71;

UPDATE send_home_interaction
SET notes = 'tonsilitus. no treatmnent necessary'
WHERE visitID = 68;

UPDATE send_home_interaction
SET notes = 'NOTES EXAMPLE'
WHERE visitID = 61;

UPDATE send_home_interaction
SET notes = 'NOTES EXAMPLE'
WHERE visitID = 58;

UPDATE send_home_interaction shi
JOIN visit v ON shi.visitID = v.visitID
SET shi.timeOfConsultation = 
    GREATEST(
        '2025-03-01 00:00:00',
        LEAST(
            ADDTIME(v.admission_datetime, 
                SEC_TO_TIME(FLOOR(TIMESTAMPDIFF(SECOND, v.admission_datetime, v.discharge_datetime) * RAND()))
            ),
            '2025-03-05 23:59:59'
        )
    )
WHERE shi.visitID BETWEEN 54 AND 80;

select * from send_home_interaction;
select * from visit;

SELECT visitID
FROM visit
WHERE outcome = 'TAKE_HOME_PRESCRIPTION';

INSERT INTO take_home_prescription (visitID, docID, medName, dosage, times_per_day, duration, notes)
VALUES
    (54, 11, 'Amoxicillin', '500mg', 3, '7 days', 'Take with food to avoid stomach upset'),
    (62, 12, 'Ibuprofen', '200mg', 2, '5 days', 'For pain relief, take every 4-6 hours as needed'),
    (63, 14, 'Lisinopril', '10mg', 1, '30 days', 'Take in the morning with or without food'),
    (66, 13, 'Metformin', '500mg', 2, '30 days', 'Take with meals to reduce gastrointestinal side effects'),
    (69, 15, 'Paracetamol', '500mg', 3, '5 days', 'Use for fever and pain relief, maximum 4 times a day'),
    (73, 15, 'Cetirizine', '10mg', 1, '7 days', 'Take once daily in the evening, may cause drowsiness'),
    (77, 14, 'Prednisone', '20mg', 1, '7 days', 'Take in the morning with food to reduce stomach irritation'),
    (80, 12, 'Hydrochlorothiazide', '25mg', 1, '30 days', 'Take in the morning with a full glass of water');

UPDATE take_home_prescription thp
JOIN visit v ON thp.visitID = v.visitID
SET thp.timeOfConsultation = 
    GREATEST(
        '2025-03-01 00:00:00',
        LEAST(
            DATE_ADD(v.admission_datetime, INTERVAL (RAND() * TIMESTAMPDIFF(SECOND, v.admission_datetime, v.discharge_datetime)) SECOND),
            '2025-03-05 23:59:59'
        )
    )
WHERE thp.visitID BETWEEN 54 AND 80;

select * from take_home_prescription;

INSERT INTO bed ()
VALUES
(), (), (), (), (), (), (), (), (), (), (), (), (), (), ();


UPDATE bed
SET currently_occupied = IF(RAND() > 0.5, TRUE, FALSE);

select * from bed;

SELECT visitID, patientID
FROM visit
WHERE outcome = 'ER_STAY';

INSERT INTO ER_Stay (visitID, patientID, bedID)
VALUES
    (55, 2, 1),
    (56, 3, 2),
    (57, 4, 3),
    (59, 6, 4),
    (60, 7, 5),
    (64, 13, 6),
    (65, 16, 7),
    (67, 21, 8),
    (70, 24, 9),
    (72, 11, 10),
    (74, 14, 11),
    (76, 18, 12),
    (79, 25, 13);

UPDATE ER_Stay es
JOIN visit v ON es.visitID = v.visitID
SET es.timeOfConsultation = 
    GREATEST(
        '2025-03-01 00:00:00',
        LEAST(
            DATE_ADD(v.admission_datetime, INTERVAL (RAND() * TIMESTAMPDIFF(SECOND, v.admission_datetime, v.discharge_datetime)) SECOND),
            '2025-03-05 23:59:59'
        )
    )
WHERE es.ER_StayID BETWEEN 1 AND 13;



select * from ER_Stay;
select * from visit;
select * from take_home_prescription;

INSERT INTO ER_prescription (ER_StayID, medName, dosage, times_per_day, duration, notes, docID)
VALUES
    (2, 'Aspirin', '500mg', 2, '5 days', 'For pain relief', 11),
    (4, 'Ibuprofen', '400mg', 3, '7 days', 'For inflammation', 12),
    (6, 'Amoxicillin', '250mg', 2, '10 days', 'Antibiotic treatment', 13),
    (7, 'Paracetamol', '500mg', 4, '3 days', 'For fever reduction', 14),
    (9, 'Cetirizine', '10mg', 1, '5 days', 'For allergic reactions', 14),
    (11, 'Loperamide', '2mg', 2, '4 days', 'For diarrhea treatment', 15),
    (12, 'Omeprazole', '20mg', 1, '7 days', 'For stomach ulcers', 15);



INSERT INTO nurse_bed_assignment (ER_StayID, bedID, nurseID, shiftID)
VALUES
(1, 1, 4, 39),
(2, 2, 5, 40),
(3, 3, 6, 41),
(4, 4, 7, 42),
(5, 5, 8, 43),
(6, 6, 9, 44),
(7, 7, 10, 45),
(8, 8, 4, 46),
(9, 9, 5, 47),
(10, 10, 6, 48),
(11, 11, 7, 49),
(12, 12, 8, 50),
(13, 13, 9, 51);

INSERT INTO doc_bed_assignment (ER_StayID, bedID, docID, shiftID)
VALUES
(1, 1, 11, 39),
(2, 2, 12, 40),
(3, 3, 13, 41),
(4, 4, 14, 42),
(5, 5, 15, 43),
(6, 6, 11, 44),
(7, 7, 12, 45),
(8, 8, 13, 46),
(9, 9, 14, 47),
(10, 10, 15, 48),
(11, 11, 11, 49),
(12, 12, 12, 50),
(13, 13, 13, 51);

select * from doc_bed_assignment;
select Er_StayID from ER_STAY;
select * from worker;
select * from person;
select * from doctor;
select * from nurse;
select * from visit;
select * from shift;


/* *****************
*
*
*
	REPORTS
*
*
*
*******************/

-- 1. Staff Management: SHIFT SCHEDULE REPORT
		SELECT 
			s.shiftID,
			s.start_date,
			s.end_date,
			s.start_time,
			s.end_time,
			p_triage.fname AS triage_doc_firstname,
			p_triage.lname AS triage_doc_lastname,
			sa.role,
			p_worker.fname AS worker_firstname,
			p_worker.lname AS worker_lastname
		FROM shift s
		LEFT JOIN worker triage ON s.triageID = triage.workerID
		LEFT JOIN person p_triage ON triage.personID = p_triage.personID
		LEFT JOIN shift_assignment sa ON s.shiftID = sa.shiftID
		LEFT JOIN worker w ON sa.workerID = w.workerID
		LEFT JOIN person p_worker ON w.personID = p_worker.personID
		ORDER BY s.start_date, s.start_time, sa.role;
        
	-- 1. Staff Management: Worker availablity report
		SELECT 
			s.shiftID,
			s.start_date,
			s.end_date,
			s.start_time,
			s.end_time,
			p_triage.fname AS triage_doc_firstname,
			p_triage.lname AS triage_doc_lastname,
			sa.role AS worker_role,
			p_worker.fname AS worker_firstname,
			p_worker.lname AS worker_lastname
		FROM shift s
		LEFT JOIN worker triage ON s.triageID = triage.workerID
		LEFT JOIN person p_triage ON triage.personID = p_triage.personID
		LEFT JOIN shift_assignment sa ON s.shiftID = sa.shiftID
		LEFT JOIN worker w ON sa.workerID = w.workerID
		LEFT JOIN person p_worker ON w.personID = p_worker.personID
		ORDER BY s.start_date, s.start_time, sa.role;

		-- Find workers without a shift
		SELECT w.workerID, p.fname, p.lname
		FROM worker w
		JOIN person p ON w.personID = p.personID
		WHERE w.workerID NOT IN (
			SELECT DISTINCT sa.workerID
			FROM shift_assignment sa
			JOIN shift s ON sa.shiftID = s.shiftID
			WHERE s.start_date BETWEEN '2025-03-01' AND '2025-03-01'
		);
			
	-- 1. Staff Management: Staff workload report
		-- total shifts per worker
			SELECT 
				w.workerID, 
				p.fname, 
				p.lname, 
				CASE 
					WHEN sa.role IN ('case doctor', 'triage doctor') THEN 'doctor' 
					ELSE sa.role 
				END AS role, 
				COUNT(sa.shiftID) AS total_shifts
			FROM worker w
			JOIN person p ON w.personID = p.personID
			LEFT JOIN shift_assignment sa ON w.workerID = sa.workerID
			LEFT JOIN shift s ON sa.shiftID = s.shiftID
			WHERE s.start_date BETWEEN '2025-03-01' AND '2025-03-05'
			GROUP BY w.workerID, p.fname, p.lname, role
			ORDER BY total_shifts DESC;
                
		-- shifts within a more specific time frame
			SELECT 
				w.workerID, 
				p.fname, 
				p.lname, 
				CASE 
					WHEN sa.role IN ('case doctor', 'triage doctor') THEN 'doctor' 
					ELSE sa.role 
				END AS role, 
				COUNT(sa.shiftID) AS total_shifts
			FROM worker w
			JOIN person p ON w.personID = p.personID
			LEFT JOIN shift_assignment sa ON w.workerID = sa.workerID
			LEFT JOIN shift s ON sa.shiftID = s.shiftID
			WHERE s.start_date BETWEEN '2025-03-01' AND '2025-03-02'
			GROUP BY w.workerID, p.fname, p.lname, role
			ORDER BY total_shifts DESC;

		-- identify underworked and overworked employees
        SELECT w.workerID, p.fname, p.lname, sa.role, COUNT(sa.shiftID) AS total_shifts,
			CASE 
				WHEN COUNT(sa.shiftID) > 5 THEN 'Overworked'
				WHEN COUNT(sa.shiftID) < 4 THEN 'Underutilized'
				ELSE 'Normal'
			END AS workload_status
		FROM worker w
		JOIN person p ON w.personID = p.personID
		LEFT JOIN shift_assignment sa ON w.workerID = sa.workerID
		LEFT JOIN shift s ON sa.shiftID = s.shiftID
		WHERE s.start_date BETWEEN '2025-03-01' AND '2025-03-05'
		GROUP BY w.workerID, p.fname, p.lname, sa.role
		ORDER BY total_shifts DESC;

-- 2. Patient Management Report
-- 2. Patient Management Report: Patient Admissions
SELECT 
    v.visitID,
    p.fname AS patient_fname,
    p.lname AS patient_lname,
    r.fname AS receptionist_fname,
    r.lname AS receptionist_lname,
    v.admission_datetime,
    v.discharge_datetime,
    v.outcome
FROM visit v
JOIN patient pt ON v.patientID = pt.patientID
JOIN person p ON pt.personID = p.personID
JOIN worker w ON v.receptionistID = w.workerID
JOIN person r ON w.personID = r.personID
WHERE v.admission_datetime BETWEEN '2025-03-01' AND '2025-03-05'
ORDER BY v.admission_datetime;

-- 2. Patient Management Report: Bed Occupancy
select * from bed;

-- 2. Patient Management Report: Nurse assignment
SELECT 
    b.bedID, 
    p.patientID, 
    per.fname AS patient_fname, 
    per.lname AS patient_lname, 
    w.workerID AS nurseID, 
    nurse_per.fname AS nurse_fname, 
    nurse_per.lname AS nurse_lname
FROM bed b
JOIN ER_Stay er ON b.bedID = er.bedID
JOIN patient p ON er.patientID = p.patientID
JOIN person per ON p.personID = per.personID
JOIN nurse_bed_assignment nba ON er.ER_StayID = nba.ER_StayID
JOIN worker w ON nba.nurseID = w.workerID
JOIN person nurse_per ON w.personID = nurse_per.personID
WHERE b.currently_occupied = TRUE;

-- 2. Patient Mangagement: Doctor assignemnt
SELECT 
    b.bedID, 
    p.patientID, 
    per.fname AS patient_fname, 
    per.lname AS patient_lname, 
    w.workerID AS doctorID, 
    doc_per.fname AS doctor_fname, 
    doc_per.lname AS doctor_lname
FROM bed b
JOIN ER_Stay er ON b.bedID = er.bedID
JOIN patient p ON er.patientID = p.patientID
JOIN person per ON p.personID = per.personID
JOIN doc_bed_assignment dba ON er.ER_StayID = dba.ER_StayID
JOIN worker w ON dba.docID = w.workerID
JOIN person doc_per ON w.personID = doc_per.personID
WHERE b.currently_occupied = TRUE;

-- 2. Patient Management: Prescription Report
-- view all prescriptions both ER and take home --
SELECT 
    visitID, 
    docID, 
    medName, 
    dosage, 
    times_per_day, 
    duration, 
    notes, 
    'take_home_prescription' AS prescription_type
FROM take_home_prescription
UNION ALL
SELECT 
    ER_Stay.visitID,  -- Join ER_Stay to get the visitID
    ER_prescription.docID,  
    ER_prescription.medName, 
    ER_prescription.dosage, 
    ER_prescription.times_per_day, 
    ER_prescription.duration, 
    ER_prescription.notes, 
    'ER_prescription' AS prescription_type
FROM ER_prescription
JOIN ER_Stay ON ER_prescription.ER_StayID = ER_Stay.ER_StayID;
-- -- -- 

-- administering nurse
SELECT 
    erp.medName, 
    erp.dosage, 
    erp.times_per_day, 
    erp.duration, 
    erp.notes,
    nurse.workerID AS administering_nurse_ID,
    nurse_per.fname AS nurse_fname, 
    nurse_per.lname AS nurse_lname
FROM ER_prescription erp
JOIN ER_Stay ers ON erp.ER_StayID = ers.ER_StayID
JOIN nurse_bed_assignment nba ON ers.ER_StayID = nba.ER_StayID
JOIN shift s ON nba.shiftID = s.shiftID  -- Ensures nurse was working during the ER stay
JOIN worker nurse ON nba.nurseID = nurse.workerID
JOIN person nurse_per ON nurse.personID = nurse_per.personID;

-- 3. Performance & Quality Control Reports
-- 3. Perofmarnce & Quality Control Reports: Patient Treatment Time Report
-- time between admission and consultation
SELECT 
    v.visitID,
    p.fname AS patient_fname, 
    p.lname AS patient_lname,
    v.admission_datetime,
    COALESCE(shi.timeOfConsultation, thp.timeOfConsultation, er.timeOfConsultation) AS triage_consultation_time,
    TIMEDIFF(
        COALESCE(shi.timeOfConsultation, thp.timeOfConsultation, er.timeOfConsultation), 
        v.admission_datetime
    ) AS time_to_consultation
FROM visit v
JOIN patient pt ON v.patientID = pt.patientID
JOIN person p ON pt.personID = p.personID
LEFT JOIN send_home_interaction shi ON v.visitID = shi.visitID
LEFT JOIN take_home_prescription thp ON v.visitID = thp.visitID
LEFT JOIN ER_stay er ON v.visitID = er.visitID
WHERE v.admission_datetime BETWEEN '2025-03-01' AND '2025-03-05';

-- 3. Perofmarnce & Quality Control Reports: Patient Treatment Time Report
-- time between admission and consultation
SELECT 
    AVG(TIMESTAMPDIFF(MINUTE, v.admission_datetime, v.discharge_datetime)) AS avg_time_in_ER_minutes
FROM visit v
WHERE v.admission_datetime BETWEEN '2025-03-01' AND '2025-03-05';

-- 3. Perfomarnce & Quality Control Reports: Doctor & Nurse Efficiency
-- Number of patients seen by each doctor and nurse per shift.
SELECT 
    sa.shiftID,
    w.workerID,
    p.fname AS worker_fname,
    p.lname AS worker_lname,
    sa.role,
    COUNT(DISTINCT v.visitID) AS patients_seen
FROM shift_assignment sa
JOIN worker w ON sa.workerID = w.workerID
JOIN person p ON w.personID = p.personID
JOIN shift s ON sa.shiftID = s.shiftID
JOIN visit v 
    ON v.admission_datetime BETWEEN 
       STR_TO_DATE(CONCAT(s.start_date, ' ', s.start_time), '%Y-%m-%d %H:%i:%s') 
       AND 
       STR_TO_DATE(CONCAT(s.end_date, ' ', s.end_time), '%Y-%m-%d %H:%i:%s')
WHERE sa.role IN ('Nurse', 'Case Doctor', 'Triage Doctor')
GROUP BY sa.shiftID, w.workerID, p.fname, p.lname, sa.role
ORDER BY sa.shiftID, patients_seen DESC;


 -- Identify workload distribution among staff members.
SELECT 
    w.workerID, 
    p.fname AS first_name, 
    p.lname AS last_name, 
    sa.role, 
    COUNT(sa.shiftID) AS total_shifts
FROM worker w
JOIN person p ON w.personID = p.personID
LEFT JOIN shift_assignment sa ON w.workerID = sa.workerID
LEFT JOIN shift s ON sa.shiftID = s.shiftID
GROUP BY w.workerID, p.fname, p.lname, sa.role
ORDER BY total_shifts DESC;

-- 3. Perfomarnce & Quality Control Reports: ER Utilization
-- Number of patients treated in the ER over a given period.
SELECT COUNT(*) AS total_patients_treated
FROM visit
WHERE admission_datetime BETWEEN '2025-03-01' AND '2025-03-05';

-- Breakdown of cases by severity (sent home vs. admitted).
SELECT 
    'Sent Home' AS case_outcome, COUNT(sh.visitID) AS total_cases
FROM send_home_interaction sh
WHERE sh.timeOfConsultation BETWEEN '2025-03-01' AND '2025-03-07'

UNION ALL

SELECT 
    'Admitted' AS case_outcome, COUNT(er.visitID) AS total_cases
FROM er_stay er
WHERE er.timeOfConsultation BETWEEN '2025-03-01' AND '2025-03-07'

UNION ALL

SELECT 
    'Prescribed Medication' AS case_outcome, COUNT(tp.visitID) AS total_cases
FROM take_home_prescription tp
WHERE tp.timeOfConsultation BETWEEN '2025-03-01' AND '2025-03-07';

-- Peak hours for patient visits.
SELECT 
    HOUR(admission_datetime) AS hour_of_day, 
    COUNT(*) AS patient_count
FROM visit
WHERE admission_datetime BETWEEN '2025-03-01' AND '2025-03-07'
GROUP BY hour_of_day
ORDER BY patient_count DESC;

-- Peak days for patient visits.
SELECT 
    DATE(admission_datetime) AS visit_date, 
    COUNT(*) AS patient_count
FROM visit
WHERE admission_datetime BETWEEN '2025-03-01' AND '2025-03-07'
GROUP BY visit_date
ORDER BY patient_count DESC;

-- 4. Contact & Administrative Reports
-- 4. Contact & Administrative Reports: Worker Contact Report
SELECT 
    w.workerID, 
    p.fname, 
    p.lname, 
    pn.phoneNum AS phone, 
    e.email AS email, 
    CONCAT(a.hnumber, ' ', a.Street, ', ', a.city, ', ', a.province, ', ', a.country) AS address
FROM worker w
JOIN person p ON w.personID = p.personID
LEFT JOIN phoneNumber pn ON p.personID = pn.personID
LEFT JOIN email e ON p.personID = e.personID
LEFT JOIN address a ON p.personID = a.personID
ORDER BY p.lname, p.fname;

-- 4. Contact & Administrative Reports: Emergency Contact List
SELECT 
    p.personID, 
    p.fname, 
    p.lname, 
    pn.phoneNum AS phone, 
    e.email AS email, 
    CONCAT(a.hnumber, ' ', a.Street, ', ', a.city, ', ', a.province, ', ', a.country) AS address
FROM person p
JOIN patient pt ON p.personID = pt.personID  -- ensure only patients are included
LEFT JOIN phoneNumber pn ON p.personID = pn.personID
LEFT JOIN email e ON p.personID = e.personID
LEFT JOIN address a ON p.personID = a.personID
ORDER BY p.lname, p.fname;


-- -- -- -- - -- -- - - - - - -- - - - - --- -- -- - - - - -
select * from address;
select * from bed;
select * from doc_bed_assignment;
select * from doctor;
select * from email;
select * from ER_prescription;
select * from ER_Stay;
select * from nurse;
select * from nurse_bed_assignment;
select * from patient;
select * from person;
select * from phoneNumber;
select * from receptionist;
select * from send_home_interaction;
select * from shift;
select * from shift_assignment;

select * from take_home_prescription;
select * from visit;

