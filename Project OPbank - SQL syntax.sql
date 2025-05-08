
USE master
GO

IF EXISTS(SELECT * FROM sys.databases WHERE name = 'OPbank')
BEGIN
    ALTER DATABASE OPbank SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE OPbank
END;

CREATE DATABASE OPbank
GO

USE OPbank
GO

-- Create tables

CREATE TABLE Country (
    CountryID INT IDENTITY(1,1) PRIMARY KEY,
    CountryName NVARCHAR(30)
)


CREATE TABLE City (
    CityID INT IDENTITY(1,1) PRIMARY KEY,
    CountryID INT,
    CityName NVARCHAR(30),
    FOREIGN KEY (CountryID) REFERENCES Country(CountryID)
)


CREATE TABLE PostalCode (
    PostalCodeID INT IDENTITY(1,1) PRIMARY KEY,
    CityID INT,
    PostalCode NVARCHAR(20),
    FOREIGN KEY (CityID) REFERENCES City(CityID)
)


CREATE TABLE Address (
    AddressID INT IDENTITY(1,1) PRIMARY KEY,
    PostalCodeID INT,
    Address NVARCHAR(50),
    FOREIGN KEY (PostalCodeID) REFERENCES PostalCode(PostalCodeID)
)


CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    AddressID INT,
    FirstName NVARCHAR(25),
    LastName NVARCHAR(25),
    BirthDate DATE,
    SocialSecurityNumberSalt NVARCHAR(100),
    SocialSecurityNumberHash NVARCHAR(100),
    EmailAddress NVARCHAR(50),
    PhoneNumber NVARCHAR(25),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (AddressID) REFERENCES Address(AddressID)
)


CREATE TABLE CreditLevel (
    CreditLevelID INT IDENTITY(1,1) PRIMARY KEY,
    CreditLevel NVARCHAR(15),
    Score INT
)


CREATE TABLE CreditScore (
    CreditScoreID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    CreditLevelID INT NOT NULL,
    CreditChecked DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (CreditLevelID) REFERENCES CreditLevel(CreditLevelID)
)


CREATE TABLE AuthMethod (
    AuthMethodID INT IDENTITY(1,1) PRIMARY KEY,
    AuthMethod NVARCHAR(30)
)


CREATE TABLE LoginStatus (
    LoginStatusID INT IDENTITY(1,1) PRIMARY KEY,
    StatusCode NVARCHAR(10),
    StatusMessage NVARCHAR(50)
)


CREATE TABLE LoginAttempts (
    AttemptID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    AuthMethodID INT NOT NULL,
    LoginStatusID INT NOT NULL,
    IPAddress NVARCHAR(50),
    RequestTime DATETIME,
    AttemptTime DATETIME,
    BankIDVerified BIT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (AuthMethodID) REFERENCES AuthMethod(AuthMethodID),
    FOREIGN KEY (LoginStatusID) REFERENCES LoginStatus(LoginStatusID)
)

CREATE TABLE CardStatus (
    CardStatusID INT IDENTITY(1,1) PRIMARY KEY,
    CardStatus NVARCHAR(20)
)


CREATE TABLE CardType (
    CardTypeID INT IDENTITY(1,1) PRIMARY KEY,
    CardType NVARCHAR(20)
)

CREATE TABLE AccountStatus (
    AccountStatusID INT IDENTITY(1,1) PRIMARY KEY,
    AccountStatus NVARCHAR(20)
)


CREATE TABLE AccountType (
    AccountTypeID INT IDENTITY(1,1) PRIMARY KEY,
    AccountType NVARCHAR(20)
)

CREATE TABLE Account (
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    AccountStatusID INT NOT NULL,
    AccountTypeID INT NOT NULL,
    AccountNumber NVARCHAR(50) NOT NULL UNIQUE,
    Balance DECIMAL(18,2),
    CreatedAt DATETIME,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (AccountStatusID) REFERENCES AccountStatus(AccountStatusID),
    FOREIGN KEY (AccountTypeID) REFERENCES AccountType(AccountTypeID)
)


CREATE TABLE Card (
    CardID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT NOT NULL,
    CardStatusID INT NOT NULL,
    CardTypeID INT NOT NULL,
    CardNumber NVARCHAR(25) NOT NULL UNIQUE,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ExpiryDate DATE,
    CVV2Salt NVARCHAR(100),
    CVV2Hash NVARCHAR(100),
    PincodeSalt NVARCHAR(100),
    PincodeHash NVARCHAR(100),
	FOREIGN KEY (AccountID) REFERENCES Account(AccountID),
    FOREIGN KEY (CardStatusID) REFERENCES CardStatus(CardStatusID),
    FOREIGN KEY (CardTypeID) REFERENCES CardType(CardTypeID)
)

CREATE TABLE Disposition (
    DispositionID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    AccountID INT NOT NULL,
    CardID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID),
    FOREIGN KEY (CardID) REFERENCES Card(CardID)
)

CREATE TABLE LoanStatus (
    LoanStatusID INT IDENTITY(1,1) PRIMARY KEY,
    LoanStatus NVARCHAR(20)
)


CREATE TABLE LoanType (
    LoanTypeID INT IDENTITY(1,1) PRIMARY KEY,
    LoanType NVARCHAR(20)
)

CREATE TABLE Loan (
    LoanID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    AccountID INT NOT NULL,
    LoanStatusID INT NOT NULL,
    LoanTypeID INT NOT NULL,
    LoanAmount DECIMAL(18,2),
    InterestRate DECIMAL(5,2),
    LoanPeriod INT,
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID),
    FOREIGN KEY (LoanStatusID) REFERENCES LoanStatus(LoanStatusID),
    FOREIGN KEY (LoanTypeID) REFERENCES LoanType(LoanTypeID)
)


CREATE TABLE LoanPaymentStatus (
    LoanPaymentStatusID INT IDENTITY(1,1) PRIMARY KEY,
    LoanPaymentStatus NVARCHAR(20)
)


CREATE TABLE LoanPaymentMethod (
    LoanPaymentMethodID INT IDENTITY(1,1) PRIMARY KEY,
    LoanPaymentMethod NVARCHAR(20)
)


CREATE TABLE LoanPayment (
    LoanPaymentID INT IDENTITY(1,1) PRIMARY KEY,
    LoanID INT NOT NULL,
    LoanPaymentStatusID INT NOT NULL,
    LoanPaymentMethodID INT NOT NULL,
    InterestAmount DECIMAL(10,2),
    PrincipalAmount DECIMAL(10,2),
    FeeAmount DECIMAL(10,2),
    TotalAmount DECIMAL(10,2),
	DueDate DATETIME,
	PaymentDate DATETIME NULL,
    FOREIGN KEY (LoanID) REFERENCES Loan(LoanID),
    FOREIGN KEY (LoanPaymentStatusID) REFERENCES LoanPaymentStatus(LoanPaymentStatusID),
    FOREIGN KEY (LoanPaymentMethodID) REFERENCES LoanPaymentMethod(LoanPaymentMethodID)
)


CREATE TABLE TransactionStatus (
    TransactionStatusID INT IDENTITY(1,1) PRIMARY KEY,
    TransactionStatus NVARCHAR(50)
)


CREATE TABLE TransactionType (
    TransactionTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TransactionType NVARCHAR(50)
)


CREATE TABLE [Transaction] (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT NOT NULL,
    TransactionStatusID INT NOT NULL,
    TransactionTypeID INT NOT NULL,
    ReceiverAccount NVARCHAR(50),
    Amount DECIMAL(18,2),
    Date DATETIME,
    Description NVARCHAR(50),
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID),
    FOREIGN KEY (TransactionStatusID) REFERENCES TransactionStatus(TransactionStatusID),
    FOREIGN KEY (TransactionTypeID) REFERENCES TransactionType(TransactionTypeID)
)


-- Insert data

INSERT INTO Country (CountryName)
VALUES ('Sverige')
GO

INSERT INTO City (CountryID, CityName)
VALUES (1, 'Stockholm'), (1, 'Göteborg'), (1, 'Malmö'), (1, 'Lund'), (1, 'Visby')
GO

INSERT INTO PostalCode (CityID, PostalCode)
VALUES (1, '11122'), (1, '11322'), (2, '11455'), (3, '12355'),(4, '12333'),(5, '15498')
GO

INSERT INTO Address (PostalCodeID, Address)
VALUES (1, 'Storgatan 12'), 
		(2, 'Sveavägen 45'),
		(3, 'Kungsgatan 89'), 
		(4, 'Skånegatan 88'),
		(5, 'Villavägen 3'),
		(6, 'Tulegatan 22'),
		(1, 'Lillgatan 5'),         
		(2, 'Västra Vägen 10'),     
		(3, 'Östra Gatan 15'),      
		(4, 'Norra Allén 20');
GO

-- Create customers in the database

CREATE OR ALTER PROCEDURE CreateCustomer
    @FirstName NVARCHAR(25),
    @LastName NVARCHAR(25),
    @BirthDate DATE,
    @SSN NVARCHAR(50),
    @EmailAddress NVARCHAR(50),
    @PhoneNumber NVARCHAR(25),
    @AddressID INT

AS
BEGIN
    DECLARE 
	@Salt NVARCHAR(100),
	@SSNHash NVARCHAR(100)

BEGIN TRY
        SET @Salt = CONVERT(NVARCHAR(100), NEWID());
        SET @SSNHash = CONVERT(NVARCHAR(100), HASHBYTES('SHA2_256', @SSN + @Salt), 1)

        INSERT INTO Customer (
            AddressID, FirstName, LastName, BirthDate,
            SocialSecurityNumberSalt, SocialSecurityNumberHash,
            EmailAddress, PhoneNumber, CreatedAt
			)

        VALUES (
            @AddressID, @FirstName, @LastName, @BirthDate,
            @Salt, @SSNHash,
            @EmailAddress, @PhoneNumber, GETDATE()
			)

        PRINT 'Customer created successfully.'
    END TRY

 BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH

END
GO

    EXEC CreateCustomer
        @FirstName = 'Emma',
        @LastName = 'Svensson',
        @BirthDate = '1964-05-14',
        @SSN = '640514-1234',
        @EmailAddress = 'emma.svensson@gmail.com',
        @PhoneNumber = '0701234567',
        @AddressID = 1


    EXEC CreateCustomer
        @FirstName = 'Johan',
        @LastName = 'Svensson',
        @BirthDate = '1999-09-23',
        @SSN = '990923-5678',
        @EmailAddress = 'johan.svensson@gmail.com',
        @PhoneNumber = '0729876543',
        @AddressID = 1


    EXEC CreateCustomer
        @FirstName = 'Sara',
        @LastName = 'Nilsson',
        @BirthDate = '1995-12-01',
        @SSN = '951201-3456',
        @EmailAddress = 'sara.nilsson@gmail.com',
        @PhoneNumber = '0761122334',
        @AddressID = 3


    EXEC CreateCustomer
        @FirstName = 'David',
        @LastName = 'Johansson',
        @BirthDate = '1982-06-15',
        @SSN = '820615-4321',
        @EmailAddress = 'david.johansson@Hotmail.com',
        @PhoneNumber = '0733456789',
        @AddressID = 4


    EXEC CreateCustomer
        @FirstName = 'Anna',
        @LastName = 'Lindström',
        @BirthDate = '1992-03-22',
        @SSN = '920322-6789',
        @EmailAddress = 'anna.lindstrom@Outlook.com',
        @PhoneNumber = '0708765432',
        @AddressID = 5


    EXEC CreateCustomer
        @FirstName = 'Petra',
        @LastName = 'Karlsson',
        @BirthDate = '1998-11-03',
        @SSN = '981103-2345',
        @EmailAddress = 'petra.karlsson@live.com',
        @PhoneNumber = '0731234567',
        @AddressID = 6

	EXEC CreateCustomer
		@FirstName = 'Lars',
		@LastName = 'Eriksson',
		@BirthDate = '1975-08-10',
		@SSN = '750810-9876',
		@EmailAddress = 'lars.eriksson@gmail.com',
		@PhoneNumber = '0709876543',
		@AddressID = 7

	EXEC CreateCustomer
		@FirstName = 'Maria',
		@LastName = 'Andersson',
		@BirthDate = '1988-04-17',
		@SSN = '880417-5432',
		@EmailAddress = 'maria.andersson@outlook.com',
		@PhoneNumber = '0734567890',
		@AddressID = 8

	EXEC CreateCustomer
		@FirstName = 'Erik',
		@LastName = 'Persson',
		@BirthDate = '1990-01-30',
		@SSN = '900130-1122',
		@EmailAddress = 'erik.persson@live.com',
		@PhoneNumber = '0765432109',
		@AddressID = 9

	EXEC CreateCustomer
		@FirstName = 'Klara',
		@LastName = 'Gustafsson',
		@BirthDate = '2000-07-25',
		@SSN = '000725-3344',
		@EmailAddress = 'klara.gustafsson@gmail.com',
		@PhoneNumber = '0701122334',
		@AddressID = 10
GO

-- Insert data

INSERT INTO CreditLevel (CreditLevel, Score)
VALUES 
    ('Excellent', 800),
    ('Good', 700),
    ('Fair', 600),
    ('Poor', 500)


INSERT INTO CreditScore (CustomerID, CreditLevelID, CreditChecked)
VALUES 
    (1, 1, '2024-12-01'), 
    (2, 2, '2024-11-02'), 
    (3, 2, '2024-09-22'),  
    (4, 3, '2024-12-28'),  
    (5, 1, '2024-04-05'),  
    (6, 4, '2024-12-06'),
	(7, 2, '2024-12-10'), 
    (8, 3, '2024-11-15'),  
    (9, 1, '2024-10-20'), 
    (10, 4, '2024-09-25')


INSERT INTO AuthMethod (AuthMethod)
VALUES 
    ('Mobile BankID'),          
    ('BankID on File'),           
    ('BankID on Card'),           
    ('BankID on Other Device')


INSERT INTO LoginStatus (StatusCode, StatusMessage)
VALUES 
    ('200', 'Login successful'),
    ('401', 'Unauthorized - Wrong credentials'),
    ('403', 'Account locked - Too many failed attempts'),
    ('408', 'Request timeout - No response from user'),
    ('500', 'Internal server error - Try again later'),
    ('423', 'Account temporarily suspended')


INSERT INTO LoginAttempts (CustomerID, AuthMethodID, LoginStatusID, IPAddress, RequestTime, AttemptTime, BankIDVerified)
VALUES
	(1, 1, 1, '85.230.199.82', '2025-04-06 07:45:00', '2025-04-06 07:45:07', 1),
	(1, 1, 2, '85.230.199.90', '2025-04-07 08:00:00', NULL, 0),

	(2, 2, 1, '192.168.1.101', '2025-04-06 09:10:00', '2025-04-06 09:10:12', 1),
	(2, 3, 3, '192.168.1.105', '2025-04-07 09:30:00', NULL, 0),
	(2, 1, 1, '192.168.1.110', '2025-04-08 07:20:00', '2025-04-08 07:20:05', 1),

	(3, 4, 4, '10.0.0.45', '2025-04-06 10:00:00', NULL, 0),
	(3, 2, 1, '10.0.0.46', '2025-04-07 10:10:00', '2025-04-07 10:10:09', 1),

	(4, 1, 5, '213.112.56.1', '2025-04-07 11:00:00', NULL, 0),
	(4, 3, 1, '213.112.56.15', '2025-04-08 12:15:00', '2025-04-08 12:15:10', 1),

	(5, 4, 1, '172.16.0.12', '2025-04-06 13:00:00', '2025-04-06 13:00:08', 1),
	(5, 2, 6, '172.16.0.13', '2025-04-07 13:30:00', NULL, 0),

	(6, 1, 2, '100.72.14.22', '2025-04-06 14:10:00', NULL, 0),
	(6, 1, 1, '100.72.14.24', '2025-04-08 14:20:00', '2025-04-08 14:20:05', 1),

	(7, 1, 1, '192.168.1.120', '2025-04-10 08:00:00', '2025-04-10 08:00:05', 1), 
    (7, 2, 2, '192.168.1.121', '2025-04-11 09:15:00', NULL, 0),

    (8, 3, 1, '10.0.0.50', '2025-04-09 10:30:00', '2025-04-09 10:30:08', 1), 
    (8, 4, 4, '10.0.0.51', '2025-04-10 11:00:00', NULL, 0), 

    (9, 1, 1, '172.16.0.20', '2025-04-08 12:45:00', '2025-04-08 12:45:07', 1),
    (9, 1, 3, '172.16.0.21', '2025-04-09 13:00:00', NULL, 0), 

    (10, 2, 1, '100.72.14.30', '2025-04-07 14:20:00', '2025-04-07 14:20:06', 1),
    (10, 3, 5, '100.72.14.31', '2025-04-08 15:30:00', NULL, 0)


INSERT INTO AccountStatus (AccountStatus)
VALUES 
    ('Active'),
    ('Closed'),
    ('Frozen')

INSERT INTO AccountType (AccountType)
VALUES 
    ('Savings'),
    ('Allkonto account'),
	('Credit account')


INSERT INTO Account (CustomerID, AccountStatusID, AccountTypeID, AccountNumber, Balance, CreatedAt)
VALUES  
    (1, 1, 1, '1001001001', 24500.50, '2022-01-15'),
    (1, 1, 2, '2001001001', 15000.00, '2019-03-01'),
    (2, 1, 2, '3002001002', 8950.75, '2025-01-20'),  
    (3, 1, 2, '1003001003', 12500.00, '2021-11-10'), 
    (3, 2, 2, '2003001003', 0.00, '2021-11-10'),   
    (4, 1, 1, '2004001004', 520000.00, '2024-02-14'),
    (5, 3, 1, '3005001005', 780000.00, '2022-07-01'),
    (6, 1, 2, '1006001006', 4200.90, '2024-10-05'), 
    (7, 1, 1, '1007001007', 32000.00, '2023-06-01'),
    (7, 1, 2, '2007001007', 4500.50, '2023-06-01'),  
    (7, 1, 3, '3007001007', 4500.50, '2024-05-01'), 
    (8, 1, 2, '1008001008', 18000.75, '2024-01-15'), 
    (8, 1, 3, '2008001008', 4500.50, '2023-06-01'),  
    (9, 1, 1, '1009001009', 65000.00, '2022-09-10'), 
    (10, 1, 2, '1010001010', 9200.30, '2024-11-20') 



INSERT INTO CardStatus (CardStatus)
VALUES 
    ('Active'),
    ('Blocked'),
    ('Expired')

INSERT INTO CardType (CardType)
VALUES 
    ('Debit Card'),
    ('Credit Card')


-- Create cards for customers

GO
CREATE OR ALTER PROCEDURE CreateCard
    @AccountID INT,
    @CardStatusID INT,
    @CardTypeID INT,
    @CardNumber NVARCHAR(25),
    @ExpiryDate DATE,
    @CVV2 NVARCHAR(3),
    @Pincode NVARCHAR(4)
AS
BEGIN
    DECLARE 
        @SaltCVV2 NVARCHAR(100),
        @SaltPincode NVARCHAR(100),
        @CVV2Hash NVARCHAR(100),
        @PincodeHash NVARCHAR(100)

 BEGIN TRY
        SET @SaltCVV2 = CONVERT(NVARCHAR(100), NEWID());
        SET @SaltPincode = CONVERT(NVARCHAR(100), NEWID());

        SET @CVV2Hash = CONVERT(NVARCHAR(100), HASHBYTES('SHA2_256', @CVV2 + @SaltCVV2), 1);
        SET @PincodeHash = CONVERT(NVARCHAR(100), HASHBYTES('SHA2_256', @Pincode + @SaltPincode), 1);

INSERT INTO Card (
            AccountID, 
            CardStatusID, 
            CardTypeID, 
            CardNumber, 
            CreatedDate, 
            ExpiryDate, 
            CVV2Salt, 
            CVV2Hash, 
            PincodeSalt, 
            PincodeHash
 )

VALUES (	
			@AccountID, 
            @CardStatusID, 
            @CardTypeID, 
            @CardNumber, 
            GETDATE(), 
            @ExpiryDate, 
            @SaltCVV2, 
            @CVV2Hash, 
            @SaltPincode, 
            @PincodeHash
)
        PRINT 'Card created successfully.'
END TRY
BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
END
GO

EXEC CreateCard
    @AccountID = 2, 
    @CardStatusID = 1, 
    @CardTypeID = 1,
    @CardNumber = '4002005006007000',
    @ExpiryDate = '2026-12-01',
    @CVV2 = '122',
    @Pincode = '1296'

	EXEC CreateCard
    @AccountID = 2, 
    @CardStatusID = 2, 
    @CardTypeID = 1, 
    @CardNumber = '4002005006007999',
    @ExpiryDate = '2027-12-01',
    @CVV2 = '123',
    @Pincode = '4321'

	EXEC CreateCard
    @AccountID = 3, 
    @CardStatusID = 1, 
    @CardTypeID = 1, 
    @CardNumber = '4332005006347999',
    @ExpiryDate = '2030-12-01',
    @CVV2 = '893',
    @Pincode = '1239'

	EXEC CreateCard
	@AccountID = 3, 
    @CardStatusID = 3, 
    @CardTypeID = 1, 
    @CardNumber = '4002005006008000',
    @ExpiryDate = '2023-12-01', 
    @CVV2 = '456',
    @Pincode = '7890';

	EXEC CreateCard
    @AccountID = 4,
    @CardStatusID = 1, 
    @CardTypeID = 1, 
    @CardNumber = '2002005006009234',
    @ExpiryDate = '2028-02-01',
    @CVV2 = '989',
    @Pincode = '5734'

	EXEC CreateCard
    @AccountID = 8, 
    @CardStatusID = 1, 
    @CardTypeID = 1, 
    @CardNumber = '5002005006003000',
    @ExpiryDate = '2028-09-01',
    @CVV2 = '225',
    @Pincode = '1754'

	EXEC CreateCard
    @AccountID = 11, 
    @CardStatusID = 1, 
    @CardTypeID = 2, 
    @CardNumber = '4002005006007001',
    @ExpiryDate = '2029-01-01',
    @CVV2 = '456',
    @Pincode = '5678'

EXEC CreateCard
    @AccountID = 13, 
    @CardStatusID = 1, 
    @CardTypeID = 2, 
    @CardNumber = '4002005006007002',
    @ExpiryDate = '2028-11-01',
    @CVV2 = '789',
    @Pincode = '9012'

EXEC CreateCard
    @AccountID = 15, 
    @CardStatusID = 1, 
    @CardTypeID = 1, 
    @CardNumber = '4002005006007003',
    @ExpiryDate = '2029-02-01',
    @CVV2 = '234',
    @Pincode = '3456'


-- Insert data


INSERT INTO Disposition (CustomerID, AccountID, CardID)
VALUES
    (1, 2, 1),
    (2, 3, 3), 
    (3, 4, 5), 
    (6, 8, 6), 
    (7, 11, 7), 
    (8, 13, 8), 
    (10, 15, 9) 


INSERT INTO LoanStatus (LoanStatus)
VALUES 
    ('Approved'),
    ('Rejected'),
    ('Active'),
    ('Completed')

INSERT INTO LoanType (LoanType)
VALUES 
    ('Personal Loan'), 
    ('Vehicle Loan'),   
    ('Mortgage Loan')


INSERT INTO Loan (CustomerID, AccountID, LoanStatusID, LoanTypeID, LoanAmount, InterestRate, LoanPeriod, StartDate, EndDate)
VALUES
    (1, 2, 3, 1, 300000.00, 5.00, 36, '2025-01-01', '2028-01-01'), 
    (1, 2, 4, 1, 200000.00, 3.50, 60, '2019-05-01', '2024-05-01'), 

    (2, 3, 1, 2, 350000.00, 3.80, 60, '2025-06-01', '2029-06-01'), 

    (3, 4, 3, 3, 8000000.00, 5.00, 60, '2024-05-01', '2029-05-01'), 
    (3, 4, 2, 3, 12000000.00, 4.50, 48, NULL, NULL), 

	(7, 10, 3, 1, 250000.00, 4.75, 48, '2024-03-01', '2028-03-01')


INSERT INTO LoanPaymentStatus (LoanPaymentStatus) 
VALUES
	('Unpaid'),       
	('Paid'),             
	('Failed')

INSERT INTO LoanPaymentMethod (LoanPaymentMethod) 
VALUES
	('Autogiro'),
	('E-invoice'),
	('Manual Payment')

INSERT INTO LoanPayment (LoanID, LoanPaymentStatusID, LoanPaymentMethodID, InterestAmount, PrincipalAmount, FeeAmount, TotalAmount, DueDate, PaymentDate)
VALUES 
    (1, 2, 3, 1250.00, 7796.00, 50.00, 9096.00, '2025-02-01', '2025-02-01'), 
    (1, 1, 3, 1217.50, 7828.50, 50.00, 9096.00, '2025-03-01', NULL), 

    (3, 2, 2, 1108.00, 5434.00, 0.00, 6542.00, '2025-07-01', '2025-07-01'),
    (3, 1, 2, 1085.00, 5457.00, 0.00, 6542.00, '2025-08-01', NULL),

    (4, 3, 1, 33336.00, 117653.00, 0.00, 150989.00, '2024-07-01', NULL), 
    (4, 2, 3, 33336.00, 117653.00, 50.00, 151039.00, '2024-07-01', '2024-07-05'),
    (4, 2, 1, 32846.00, 118143.00, 0.00, 150989.00, '2024-08-01', '2024-08-01'), 

    (6, 2, 1, 990.00, 4939.00, 0.00, 5929.00, '2024-04-01', '2024-04-01'), 
    (6, 1, 1, 969.00, 4960.00, 0.00, 5929.00, '2024-05-01', NULL)

INSERT INTO TransactionStatus (TransactionStatus)
VALUES 
    ('Pending'),
    ('Completed'),
    ('Failed')

INSERT INTO TransactionType (TransactionType)
VALUES 
    ('Deposit'),
    ('Withdrawal'),
    ('Transfer'),
    ('Payment'),
    ('Fee')

INSERT INTO [Transaction] (AccountID, TransactionStatusID, TransactionTypeID, ReceiverAccount, Amount, Date, Description)
VALUES
    (2, 2, 1, NULL, 35000.00, '2025-03-25', 'Salary March 2025'), 
    (2, 2, 3, '1001001001', 5000.00, '2025-04-01', 'Internal transfer to saving account'), 
    (2, 2, 2, NULL, 2000.00, '2025-04-05', 'Cash withdrawal'),
    (2, 2, 4, NULL, 1500.00, '2025-04-10', 'Payment electricity'),

    (3, 2, 1, NULL, 40000.00, '2025-03-25', 'Salary March 2025'),
    (3, 1, 3, '1008001008', 3000.00, '2025-04-15', 'Transfer to another customer in the bank'),
    (3, 2, 4, NULL, 2500.00, '2025-04-02', 'Card payment Ica'),
    (3, 2, 5, NULL, 50.00, '2025-04-01', 'Monthly account fee'), 

    (4, 2, 1, NULL, 45000.00, '2025-03-25', 'Salary March 2025'),
    (4, 3, 3, '9999999999', 10000.00, '2025-04-03', 'Transfer to external account'),
    (4, 2, 2, NULL, 3000.00, '2025-04-07', 'Card payment IKEA'),
    (4, 2, 4, NULL, 4000.00, '2025-04-12', 'Payment rent'),

    (8, 2, 1, NULL, 55000.00, '2025-03-25', 'Salary March 2025'),
    (8, 2, 3, '2001001001', 2000.00, '2025-04-04', 'Transfer to another customer in the bank'), 
    (8, 2, 4, NULL, 1200.00, '2025-04-06', 'Payment phone'),
    (8, 2, 4, NULL, 500.00, '2025-04-08', 'Card payment Åhlens'),

    (10, 2, 1, NULL, 38000.00, '2025-03-25', 'Salary March 2025'), 
    (10, 2, 3, '1010001010', 4000.00, '2025-04-02', 'Transfer to another customer in the bank'),
    (10, 2, 2, NULL, 1500.00, '2025-04-09', 'Cash withdrawal'), 
    (10, 2, 5, NULL, 75.00, '2025-04-01', 'Card fee'),

    (12, 2, 1, NULL, 32000.00, '2025-03-25', 'Salary March 2025'),
    (12, 1, 3, '9999999998', 2000.00, '2025-04-05', 'Transfer to external account'), 
    (12, 2, 4, NULL, 1800.00, '2025-04-10', 'Payment phone'),
    (12, 2, 2, NULL, 1000.00, '2025-04-12', 'Card payment Coop'), 

    (15, 2, 1, NULL, 28000.00, '2025-03-25', 'Salary March 2025'), 
    (15, 2, 3, '2007001007', 2500.00, '2025-04-03', 'Transfer to external account'),
    (15, 2, 4, NULL, 300.00, '2025-04-11', 'Payment streaming service Viaplay'),
    (15, 3, 2, NULL, 800.00, '2025-04-13', 'Cash withdrawal, failed')


-- Index

CREATE NONCLUSTERED INDEX IX_Account_CustomerID
ON Account (CustomerID)

CREATE NONCLUSTERED INDEX IX_Card_AccountID
ON Card (AccountID)

CREATE NONCLUSTERED INDEX IX_Transaction_AccountID
ON [Transaction] (AccountID)

CREATE NONCLUSTERED INDEX IX_Transaction_Date
ON [Transaction] (Date)

CREATE NONCLUSTERED INDEX IX_Loan_CustomerID
ON Loan (CustomerID)

CREATE NONCLUSTERED INDEX IX_LoanPayment_LoanID
ON LoanPayment (LoanID)

CREATE NONCLUSTERED INDEX IX_LoginAttempts_CustomerID
ON LoginAttempts (CustomerID)

-- Overview of customer information

SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.BirthDate,
    c.SocialSecurityNumberSalt,
    c.SocialSecurityNumberHash,
    c.EmailAddress,
    c.PhoneNumber,
    c.CreatedAt,
    a.Address,
    pc.PostalCode,
    ci.CityName,
    co.CountryName
FROM Customer c
JOIN Address a ON c.AddressID = a.AddressID
JOIN PostalCode pc ON a.PostalCodeID = pc.PostalCodeID
JOIN City ci ON pc.CityID = ci.CityID
JOIN Country co ON ci.CountryID = co.CountryID
ORDER BY c.CustomerID


