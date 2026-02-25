/*========================================================
    TOUR & TRAVEL MANAGEMENT SYSTEM
   
  ========================================================*/

----------------------------------------------------------
-- 1. CREATE DATABASE
----------------------------------------------------------
CREATE DATABASE TourandTravelManagementDB;
GO

USE TourandTravelManagementDB;
GO

----------------------------------------------------------
-- 2. USERS TABLE
----------------------------------------------------------
CREATE TABLE Users
(
    UserID INT IDENTITY PRIMARY KEY,               -- Auto-increment primary key
    FullName VARCHAR(100) NOT NULL,                -- Full name of the user
    Username VARCHAR(50) UNIQUE NOT NULL,          -- Unique login username
    Password VARCHAR(50) NOT NULL,                 -- User password
    Role VARCHAR(20) CHECK (Role IN ('Admin','Staff')), -- User role constraint
    CreatedAt DATETIME DEFAULT GETDATE()           -- Record creation date
);

----------------------------------------------------------
-- 3. CUSTOMERS TABLE
----------------------------------------------------------
CREATE TABLE Customers
(
    CustomerID INT IDENTITY PRIMARY KEY,           -- Primary key
    FullName VARCHAR(100) NOT NULL,                -- Customer name
    Phone VARCHAR(20) NOT NULL,                    -- Contact number
    Email VARCHAR(100) UNIQUE,                     -- Unique email
    CNIC VARCHAR(15) UNIQUE,                       -- Unique ID number
    Address VARCHAR(255),                           -- Address of customer
    CreatedAt DATETIME DEFAULT GETDATE()           -- Record creation date
);

----------------------------------------------------------
-- 4. HOTELS TABLE
----------------------------------------------------------
CREATE TABLE Hotels
(
    HotelID INT IDENTITY PRIMARY KEY,             -- Primary key
    HotelName VARCHAR(100) NOT NULL,             -- Hotel name
    Location VARCHAR(100),                        -- City/location of hotel
    StarRating INT CHECK (StarRating BETWEEN 1 AND 5), -- Star rating between 1-5
    ContactNumber VARCHAR(20),                    -- Contact number of hotel
    CostPerNight DECIMAL(10,2)                   -- Cost per night
);

----------------------------------------------------------
-- 5. FACILITIES TABLE
----------------------------------------------------------
CREATE TABLE Facilities
(
    FacilityID INT IDENTITY PRIMARY KEY,          -- Primary key
    FacilityName VARCHAR(50) NOT NULL             -- Facility name (e.g., Breakfast, Lunch)
);

----------------------------------------------------------
-- 6. TRANSPORT TABLE
----------------------------------------------------------
CREATE TABLE Transport
(
    TransportID INT IDENTITY PRIMARY KEY,         -- Primary key
    TransportType VARCHAR(50) NOT NULL,           -- Bus, Flight, Car
    Provider VARCHAR(100),                        -- Transport provider name
    Cost DECIMAL(10,2)                            -- Cost of transport
);

----------------------------------------------------------
-- 7. TOUR GUIDES TABLE
----------------------------------------------------------
CREATE TABLE TourGuides
(
    GuideID INT IDENTITY PRIMARY KEY,             -- Primary key
    FullName VARCHAR(100) NOT NULL,               -- Guide name
    Phone VARCHAR(20),                             -- Contact number
    Language VARCHAR(50)                           -- Language spoken
);

----------------------------------------------------------
-- 8. TOUR PACKAGES TABLE
----------------------------------------------------------
CREATE TABLE TourPackages
(
    PackageID INT IDENTITY PRIMARY KEY,           -- Primary key
    PackageName VARCHAR(100) NOT NULL,            -- Package name
    Destination VARCHAR(100),                      -- Package destination
    DurationDays INT CHECK (DurationDays > 0),    -- Duration in days...tour must be atleast one day
    Price DECIMAL(10,2),                           -- Base package price
    AvailableSeats INT CHECK (AvailableSeats >= 0), -- Seats available
    Description TEXT                               -- Package description
);

----------------------------------------------------------
-- 9. PACKAGE FACILITIES TABLE (Many-to-Many)
----------------------------------------------------------
CREATE TABLE PackageFacilities
(
    PackageID INT,                                -- Foreign key to TourPackages..TourPackeges.PackegeID
    FacilityID INT,                               -- Foreign key to Facilities...TourPackeges.FacilityID
    PRIMARY KEY (PackageID, FacilityID),          -- Composite primary key...one package can have many facilioties and one facility can belong to many packages
    FOREIGN KEY (PackageID) REFERENCES TourPackages(PackageID),---Ensures package Id exist.maintains referntial integrity
    FOREIGN KEY (FacilityID) REFERENCES Facilities(FacilityID)
);

----------------------------------------------------------
-- 10. PACKAGE HOTELS TABLE
----------------------------------------------------------
CREATE TABLE PackageHotels  --- itc onnects Tour packages Hotel and no.of nights
(
    PackageHotelID INT IDENTITY PRIMARY KEY,      -- Primary key
    PackageID INT,                                -- Foreign key to TourPackages..which tour package
    HotelID INT,                                  -- Foreign key to Hotels
    Nights INT CHECK (Nights > 0),                -- Number of nights...prevent data like 0 or -2
    FOREIGN KEY (PackageID) REFERENCES TourPackages(PackageID),
    FOREIGN KEY (HotelID) REFERENCES Hotels(HotelID)
);

----------------------------------------------------------
-- 11. PACKAGE TRANSPORT TABLE (Many-to-Many)
----------------------------------------------------------
CREATE TABLE PackageTransport   -- one transport is used in many packages
(
    PackageID INT,                                -- Foreign key to TourPackages
    TransportID INT,                              -- Foreign key to Transport
    PRIMARY KEY (PackageID, TransportID), --- prevents duplicate transport...enforces uniqueness
    FOREIGN KEY (PackageID) REFERENCES TourPackages(PackageID),
    FOREIGN KEY (TransportID) REFERENCES Transport(TransportID)
);

----------------------------------------------------------
-- 12. PACKAGE GUIDES TABLE (Many-to-Many)
----------------------------------------------------------
CREATE TABLE PackageGuides   -- packages may need multiple guides
(
    PackageID INT,                                -- Foreign key to TourPackages
    GuideID INT,                                  -- Foreign key to TourGuides
    PRIMARY KEY (PackageID, GuideID),
    FOREIGN KEY (PackageID) REFERENCES TourPackages(PackageID),
    FOREIGN KEY (GuideID) REFERENCES TourGuides(GuideID)
);--- if a guide is unavailable  delte one row and insert another..no need to touch main tables

----------------------------------------------------------
-- 13. DISCOUNTS / PROMOTIONS TABLE
----------------------------------------------------------
CREATE TABLE Discounts
(
    DiscountID INT IDENTITY PRIMARY KEY,          -- Primary key
    PackageID INT,                                -- Foreign key to TourPackages
    DiscountPercent DECIMAL(5,2) CHECK (DiscountPercent >= 0 AND DiscountPercent <= 100), -- Discount percent..allows precision
    StartDate DATE,                               -- Start date of discount..seasonal offers..limited time deals
    EndDate DATE,                                 -- End date of discount
    FOREIGN KEY (PackageID) REFERENCES TourPackages(PackageID)
);

----------------------------------------------------------
-- 14. BOOKINGS TABLE  (Transaction Table)
----------------------------------------------------------
CREATE TABLE Bookings--- connects customer, package, staff, paymnet, status
(
    BookingID INT IDENTITY PRIMARY KEY,           -- Primary key
    CustomerID INT,                               -- Foreign key to Customers
    PackageID INT,                                -- Foreign key to TourPackages
    UserID INT,                                   -- Foreign key to Users
    BookingDate DATETIME DEFAULT GETDATE(),       -- Date of booking
    TravelDate DATE,                              -- Travel start date
    SeatsBooked INT CHECK (SeatsBooked > 0),     -- Seats booked...logical constraint
    TotalPrice DECIMAL(10,2),                     -- Total price after discount,,,calculate using price * seats - discount
    Status VARCHAR(20) CHECK (Status IN ('Confirmed','Cancelled','Pending')), -- Booking status
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (PackageID) REFERENCES TourPackages(PackageID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

----------------------------------------------------------
-- 15. BOOKING STATUS HISTORY TABLE
----------------------------------------------------------
CREATE TABLE BookingStatusHistory -- keep record of when status changed...maintains audit trail of booking system changes
(
    HistoryID INT IDENTITY PRIMARY KEY,           -- Primary key
    BookingID INT,                                -- Foreign key to Bookings
    Status VARCHAR(20) CHECK (Status IN ('Confirmed','Cancelled','Pending')), -- Booking status
    ChangeDate DATETIME DEFAULT GETDATE(),        -- Date of status change
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

----------------------------------------------------------
-- 16. REVIEWS TABLE
----------------------------------------------------------
CREATE TABLE Reviews   ---customer wanna rate packages and share experience...review is linked to who reviwed and what was reviewed
(
    ReviewID INT IDENTITY PRIMARY KEY,           -- Primary key
    PackageID INT,                               -- Foreign key to TourPackages
    CustomerID INT,                              -- Foreign key to Customers
    Rating INT CHECK (Rating BETWEEN 1 AND 5),   -- Rating 1-5
    Comment VARCHAR(500),                         -- Review comment
    ReviewDate DATETIME DEFAULT GETDATE(),       -- Date of review
    FOREIGN KEY (PackageID) REFERENCES TourPackages(PackageID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

----------------------------------------------------------
-- 17. ITINERARY TABLE(day wise plan)
----------------------------------------------------------
CREATE TABLE Itinerary
(
    ItineraryID INT IDENTITY PRIMARY KEY,        -- Primary key
    PackageID INT,                               -- Foreign key to TourPackages
    DayNumber INT CHECK (DayNumber > 0),         -- Day number
    Description TEXT,                             -- Day-wise plan..full explanation of day
    FOREIGN KEY (PackageID) REFERENCES TourPackages(PackageID)
);

----------------------------------------------------------
-- 18. PAYMENTS TABLE
----------------------------------------------------------
CREATE TABLE Payments
(
    PaymentID INT IDENTITY PRIMARY KEY,          -- Primary key
    BookingID INT UNIQUE,                         -- Foreign key to Bookings..one booking one payment
    AmountPaid DECIMAL(10,2),                     -- Amount paid
    PaymentMethod VARCHAR(20) CHECK (PaymentMethod IN ('Cash','Card','Online')), -- Payment method
    PaymentDate DATETIME DEFAULT GETDATE(),       -- Payment date
    PaymentStatus VARCHAR(20) CHECK (PaymentStatus IN ('Paid','Unpaid')), -- Paid or Unpaid
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

----------------------------------------------------------
-- 19. Insertion in  All tables
----------------------------------------------------------

-- Users
INSERT INTO Users (FullName, Username, Password, Role) VALUES
('Admin User','admin','admin123','Admin'),
('Staff User','staff','staff123','Staff');

-- Customers
INSERT INTO Customers (FullName, Phone, Email, CNIC, Address) VALUES
('Ali Khan','03001234567','ali@gmail.com','35201-1234567-1','Lahore'),
('Sara Ahmed','03007654321','sara@gmail.com','35201-7654321-2','Karachi'),
('Usman Malik','03003334455','usman@gmail.com','35201-3334445-3','Islamabad'),
('Ayesha Khan','03004445566','ayesha@gmail.com','35201-4445556-4','Lahore');

-- Hotels
INSERT INTO Hotels (HotelName, Location, StarRating, ContactNumber, CostPerNight) VALUES
('Hunza Serena Hotel','Hunza',5,'0581-123456',15000),
('Skardu View Resort','Skardu',4,'0582-654321',12000),
('Gilgit Grand Hotel','Gilgit',4,'0583-111222',10000),
('Murree Hills Hotel','Murree',3,'0584-333444',8000);

-- Facilities
INSERT INTO Facilities (FacilityName) VALUES
('Breakfast'),('Lunch'),('Dinner'),('Transport'),('Tour Guide'),('Bonfire'),('Adventure Sports'),('Spa');

-- Transport
INSERT INTO Transport (TransportType, Provider, Cost) VALUES
('Bus','PakTravel',5000),
('Flight','AirPak',25000),
('Van','TravelExpress',7000),
('Jeep','MountainTours',12000);

-- Tour Guides
INSERT INTO TourGuides (FullName, Phone, Language) VALUES
('John Smith','03001112233','English'),
('Ali Raza','03004445566','Urdu'),
('Sara Khan','03005556677','English'),
('Ahmed Ali','03006667788','Urdu');

-- Tour Packages
INSERT INTO TourPackages (PackageName, Destination, DurationDays, Price, AvailableSeats, Description) VALUES
('Northern Pakistan Tour','Hunza & Skardu',7,85000,30,'Includes hotel, food, transport, guides'),
('Gilgit Adventure','Gilgit',5,65000,25,'Adventure package with sightseeing and trekking'),
('Murree Weekend','Murree',3,30000,40,'Short weekend trip with hotel stay and sightseeing');

-- Package Facilities
INSERT INTO PackageFacilities (PackageID, FacilityID) VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),
(2,1),(2,2),(2,3),(2,4),(2,5),(2,7),
(3,1),(3,2),(3,3),(3,4),(3,5);

-- Package Hotels
INSERT INTO PackageHotels (PackageID, HotelID, Nights) VALUES
(1,1,3),(1,2,3),
(2,3,5),
(3,4,3);

-- Package Transport
INSERT INTO PackageTransport (PackageID, TransportID) VALUES
(1,1),(1,2),
(2,2),(2,4),
(3,1),(3,3);

-- Package Guides
INSERT INTO PackageGuides (PackageID, GuideID) VALUES
(1,1),(1,2),
(2,3),(2,4),
(3,2),(3,3);

-- Discounts
INSERT INTO Discounts (PackageID, DiscountPercent, StartDate, EndDate) VALUES
(1,10,'2025-12-01','2025-12-31'),
(2,15,'2025-11-15','2025-12-15'),
(3,5,'2025-12-10','2025-12-20');

-- Bookings
INSERT INTO Bookings (CustomerID, PackageID, UserID, BookingDate, TravelDate, SeatsBooked, TotalPrice, Status) VALUES
(1,1,1,GETDATE(),'2026-01-05',2,170000,'Confirmed'),
(2,1,2,GETDATE(),'2026-02-10',3,255000,'Confirmed'),
(3,2,1,GETDATE(),'2026-03-01',1,65000,'Pending'),
(4,3,2,GETDATE(),'2026-01-15',4,120000,'Confirmed');

-- Booking Status History
INSERT INTO BookingStatusHistory (BookingID, Status, ChangeDate) VALUES
(1,'Confirmed',GETDATE()),
(2,'Confirmed',GETDATE()),
(3,'Pending',GETDATE()),
(4,'Confirmed',GETDATE());

-- Reviews
INSERT INTO Reviews (PackageID, CustomerID, Rating, Comment, ReviewDate) VALUES
(1,1,5,'Amazing experience!',GETDATE()),
(1,2,4,'Very good tour.',GETDATE()),
(2,3,4,'Excellent trekking',GETDATE()),
(3,4,3,'Nice weekend getaway',GETDATE());

-- Itinerary
INSERT INTO Itinerary (PackageID, DayNumber, Description) VALUES
(1,1,'Arrival at hotel and welcome dinner'),
(1,2,'Sightseeing in Hunza Valley'),
(1,3,'Travel to Skardu, sightseeing'),
(1,4,'Adventure activities in Skardu'),
(1,5,'Relaxation and spa'),
(1,6,'Bonfire and cultural night'),
(1,7,'Departure back home'),
(2,1,'Arrival and trekking briefing'),
(2,2,'Trekking in Gilgit mountains'),
(2,3,'Visit local markets'),
(2,4,'River rafting'),
(2,5,'Return to hotel'),
(3,1,'Arrival and check-in'),
(3,2,'Sightseeing in Murree'),
(3,3,'Return home');

-- Payments
INSERT INTO Payments (BookingID, AmountPaid, PaymentMethod, PaymentStatus) VALUES
(1,170000,'Card','Paid'),
(2,255000,'Cash','Paid'),
(3,65000,'Online','Unpaid'),
(4,120000,'Card','Paid');

-------------------------------------------------------------------
-- Fetching data from tabled using Joins
-------------------------------------------------------------------

----------------------------------------------------------
-- 1. SHOW ALL PACKAGES WITH THEIR FACILITIES
----------------------------------------------------------

SELECT  
    TP.PackageID,                 -- Fetch unique ID of tour package
    TP.PackageName,               -- Fetch name of tour package
    F.FacilityName                -- Fetch facility name (Breakfast, Transport etc.)
FROM TourPackages TP              -- Main table: TourPackages
JOIN PackageFacilities PF         -- Junction table connecting packages & facilities
    ON TP.PackageID = PF.PackageID -- Match package ID in tourpackages with package ID in packageFacilities
JOIN Facilities F                 -- Facilities table
    ON PF.FacilityID = F.FacilityID -- Match facility IDs
ORDER BY TP.PackageID;            -- Arrange output by package ID


----------------------------------------------------------
-- 2. SHOW PACKAGES WITH HOTELS AND NUMBER OF NIGHTS
----------------------------------------------------------

SELECT
    TP.PackageName,               -- Name of tour package
    H.HotelName,                  -- Name of hotel
    PH.Nights                     -- Number of nights in that hotel
FROM TourPackages TP              -- Tour packages table
JOIN PackageHotels PH             -- Table linking packages & hotels
    ON TP.PackageID = PH.PackageID -- Join using PackageID
JOIN Hotels H                     -- Hotels table
    ON PH.HotelID = H.HotelID;    -- Join using HotelID


----------------------------------------------------------
-- 3. SHOW PACKAGES WITH TRANSPORT DETAILS
----------------------------------------------------------

SELECT
    TP.PackageName,               -- Tour package name
    T.TransportType,              -- Transport type (Bus, Flight, Jeep)
    T.Provider,                   -- Transport provider name
    T.Cost                        -- Transport cost
FROM TourPackages TP              -- Tour packages
JOIN PackageTransport PT          -- Junction table
    ON TP.PackageID = PT.PackageID -- Match PackageID
JOIN Transport T                  -- Transport table
    ON PT.TransportID = T.TransportID; -- Match TransportID


----------------------------------------------------------
-- 4. SHOW PACKAGES WITH TOUR GUIDES
----------------------------------------------------------

SELECT
    TP.PackageName,               -- Tour package name
    G.FullName AS GuideName,      -- Guide full name
    G.Language                    -- Language spoken by guide
FROM TourPackages TP              -- Tour packages
JOIN PackageGuides PG             -- Junction table linking packages & guides
    ON TP.PackageID = PG.PackageID -- Match PackageID
JOIN TourGuides G                 -- Tour guides table
    ON PG.GuideID = G.GuideID;    -- Match GuideID


----------------------------------------------------------
-- 5. SHOW ACTIVE DISCOUNTS ON PACKAGES
----------------------------------------------------------

SELECT
    TP.PackageName,               -- Tour package name
    D.DiscountPercent,            -- Discount percentage
    D.StartDate,                  -- Discount start date
    D.EndDate                     -- Discount end date
FROM Discounts D                  -- Discounts table
JOIN TourPackages TP              -- Tour packages table
    ON D.PackageID = TP.PackageID -- Match PackageID
WHERE GETDATE() BETWEEN           -- Check current date
      D.StartDate AND D.EndDate;  -- Discount validity period


----------------------------------------------------------
-- 6. FULL BOOKING DETAILS (CUSTOMER + PACKAGE + STAFF)
----------------------------------------------------------

SELECT
    B.BookingID,                  -- Unique booking ID
    C.FullName AS CustomerName,   -- Customer name
    TP.PackageName,               -- Tour package name
    U.FullName AS StaffName,      -- Staff/Admin who handled booking
    B.SeatsBooked,                -- Number of seats booked
    B.TotalPrice,                 -- Total price of booking
    B.Status,                     -- Booking status
    B.TravelDate                  -- Travel start date
FROM Bookings B                   -- Bookings table (main)
JOIN Customers C                  -- Customers table
    ON B.CustomerID = C.CustomerID -- Match CustomerID
JOIN TourPackages TP              -- Tour packages table
    ON B.PackageID = TP.PackageID -- Match PackageID
JOIN Users U                      -- Users (Admin/Staff) table
    ON B.UserID = U.UserID;       -- Match UserID


----------------------------------------------------------
-- 7. BOOKINGS WITH PAYMENT DETAILS (INCLUDING UNPAID)
----------------------------------------------------------

SELECT
    B.BookingID,                  -- Booking ID
    C.FullName AS CustomerName,   -- Customer name
    TP.PackageName,               -- Package name
    P.AmountPaid,                 -- Amount paid
    P.PaymentMethod,              -- Payment method
    P.PaymentStatus               -- Paid or Unpaid
FROM Bookings B                   -- Bookings table
JOIN Customers C                  -- Customers table
    ON B.CustomerID = C.CustomerID -- Match CustomerID
JOIN TourPackages TP              -- Tour packages table
    ON B.PackageID = TP.PackageID -- Match PackageID
LEFT JOIN Payments P              -- LEFT JOIN to include unpaid bookings
    ON B.BookingID = P.BookingID; -- Match BookingID...all bookings are shown even if payment is missing  and payment info appears if it exists otherwise null


----------------------------------------------------------
-- 8. PACKAGE REVIEWS WITH CUSTOMER DETAILS
----------------------------------------------------------

SELECT
    TP.PackageName,               -- Tour package name
    C.FullName AS CustomerName,   -- Customer name
    R.Rating,                     -- Rating given by customer
    R.Comment,                    -- Review comment
    R.ReviewDate                  -- Date of review
FROM Reviews R                    -- Reviews table
JOIN TourPackages TP              -- Tour packages
    ON R.PackageID = TP.PackageID -- Match PackageID
JOIN Customers C                  -- Customers table
    ON R.CustomerID = C.CustomerID; -- Match CustomerID


----------------------------------------------------------
-- 9. DAY-WISE ITINERARY FOR EACH PACKAGE
----------------------------------------------------------

SELECT
    TP.PackageName,               -- Tour package name
    I.DayNumber,                  -- Day number (Day 1, Day 2...)
    I.Description                 -- Day-wise plan description
FROM Itinerary I                  -- Itinerary table
JOIN TourPackages TP              -- Tour packages
    ON I.PackageID = TP.PackageID -- Match PackageID
ORDER BY TP.PackageName,          -- Sort by package
         I.DayNumber;             -- Sort by day number


----------------------------------------------------------
-- 10. COMPLETE PACKAGE SUMMARY (ADVANCED REPORT)
----------------------------------------------------------

SELECT
    TP.PackageName,               -- Package name
    TP.Destination,               -- Destination
    TP.DurationDays,              -- Total days
    TP.Price,                     -- Package price
    COUNT(DISTINCT PF.FacilityID) AS TotalFacilities, -- Count facilities
    COUNT(DISTINCT PH.HotelID) AS TotalHotels         -- Count hotels
FROM TourPackages TP              -- Tour packages
LEFT JOIN PackageFacilities PF    -- Join facilities table
    ON TP.PackageID = PF.PackageID -- Match PackageID
LEFT JOIN PackageHotels PH        -- Join hotels table
    ON TP.PackageID = PH.PackageID -- Match PackageID
GROUP BY                          -- Group data for aggregation...one row per package
    TP.PackageName,
    TP.Destination,
    TP.DurationDays,
    TP.Price;

-----------------------------------------------
  Joins + Aggregate Functions
-----------------------------------------------
SELECT 
    TP.PackageName,                       -- Package name
    COUNT(DISTINCT B.BookingID) AS TotalBookings,  -- Total bookings per package
    SUM(COALESCE(P.AmountPaid,0)) AS TotalCollected, -- Total payment collected (NULL replaced by 0)
    AVG(R.Rating) AS AverageRating,       -- Average customer rating for the package
    COUNT(DISTINCT F.FacilityID) AS TotalFacilities, -- Total facilities in package
    COUNT(DISTINCT H.HotelID) AS TotalHotels,       -- Total hotels included in package
    COUNT(DISTINCT G.GuideID) AS TotalGuides        -- Total guides assigned to package
FROM TourPackages TP                       -- Base table: TourPackages
LEFT JOIN Bookings B                       -- Join bookings to include all packages
    ON TP.PackageID = B.PackageID
LEFT JOIN Payments P                       -- Join payments to calculate total collected
    ON B.BookingID = P.BookingID
LEFT JOIN Reviews R                        -- Join reviews to calculate average rating
    ON TP.PackageID = R.PackageID
LEFT JOIN PackageFacilities PF             -- Join to count facilities
    ON TP.PackageID = PF.PackageID
LEFT JOIN Facilities F                      -- Get actual facility names
    ON PF.FacilityID = F.FacilityID
LEFT JOIN PackageHotels PH                  -- Join to count hotels
    ON TP.PackageID = PH.PackageID
LEFT JOIN Hotels H                          -- Get actual hotel names
    ON PH.HotelID = H.HotelID
LEFT JOIN PackageGuides PG                  -- Join to count guides
    ON TP.PackageID = PG.PackageID
LEFT JOIN TourGuides G                      -- Get actual guide names
    ON PG.GuideID = G.GuideID
GROUP BY TP.PackageName                     -- Group by package for aggregation
ORDER BY TotalCollected DESC;               -- Sort by total collected amount descending      

----------------------------------------------------------
--  UNION : combine two queries
----------------------------------------------------------
-- Get all customer names from both Customers and TourGuides tables
SELECT FullName AS Name FROM Customers
UNION                                   -- UNION removes duplicates automatically
SELECT FullName FROM TourGuides;

----------------------------------------------------------
--  Using aggregates with COALESCE
----------------------------------------------------------
-- Total payments collected for all packages
SELECT 
    SUM(COALESCE(AmountPaid,0)) AS GrandTotalCollected, -- Sum payments, replace NULL with 0
    COUNT(DISTINCT BookingID) AS TotalBookings          -- Count total bookings
FROM Payments;

----------------------------------------------------------
--  SELECT INTO with filtering
----------------------------------------------------------
-- Create a table for bookings that are still Pending
SELECT *
INTO PendingBookings                   -- New table to store pending bookings
FROM Bookings
WHERE Status = 'Pending';             -- Only select bookings with Pending status










-------------------------------------------------------------
-- END
-------------------------------------------------------------