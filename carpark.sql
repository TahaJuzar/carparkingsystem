-- Create Users table
CREATE TABLE Users (
    User_ID SERIAL PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(100) NOT NULL,
    Role VARCHAR(10) NOT NULL CHECK (Role IN ('admin', 'attendant'))
);

-- Create Parking_Lots table
CREATE TABLE Parking_Lots (
    Lot_ID SERIAL PRIMARY KEY,
    Location VARCHAR(100) NOT NULL,
    Capacity INT NOT NULL,
    Current_Availability INT NOT NULL
);

-- Create Car_Information table
CREATE TABLE Car_Information (
    Car_Number VARCHAR(20) PRIMARY KEY,
    Owner_Name VARCHAR(100) NOT NULL,
    Car_Model VARCHAR(50) NOT NULL,
    Phone_Number VARCHAR(15)
);

-- Create Parking_Records table
CREATE TABLE Parking_Records (
    Record_ID SERIAL PRIMARY KEY,
    Car_Number VARCHAR(20) NOT NULL,
    Entry_Time TIMESTAMP NOT NULL,
    Exit_Time TIMESTAMP,
    Parking_Lot_ID INT,
    Parking_Fee DECIMAL(10,2),
    FOREIGN KEY (Car_Number) REFERENCES Car_Information(Car_Number),
    FOREIGN KEY (Parking_Lot_ID) REFERENCES Parking_Lots(Lot_ID)
);

-- Sample data for Parking_Lots
INSERT INTO Parking_Lots (Location, Capacity, Current_Availability) VALUES
('Lot A', 50, 50),
('Lot B', 100, 100),
('Lot C', 75, 75);

-- Sample data for Car_Information
INSERT INTO Car_Information (Car_Number, Owner_Name, Car_Model, Phone_Number) VALUES
('ABC123', 'John Doe', 'Toyota Camry', '123-456-7890'),
('XYZ789', 'Jane Smith', 'Honda Civic', '987-654-3210'),
('DEF456', 'Alice Johnson', 'Ford Mustang', '555-555-5555');

-- Sample data for Parking_Records
INSERT INTO Parking_Records (Car_Number, Entry_Time, Parking_Lot_ID) VALUES
('ABC123', NOW() - INTERVAL '1 HOUR', 1),
('XYZ789', NOW() - INTERVAL '2 HOUR', 2),
('DEF456', NOW() - INTERVAL '3 HOUR', 3);

-- Sample query: List available parking lots
SELECT Lot_ID, Location, Capacity, Current_Availability
FROM Parking_Lots
WHERE Current_Availability > 0;

-- Sample query: Find total revenue earned in a given period
SELECT SUM(Parking_Fee) AS Total_Revenue
FROM Parking_Records
WHERE Exit_Time BETWEEN NOW() - INTERVAL '1 DAY' AND NOW();

-- Sample query: List cars parked for more than a specified duration
SELECT Car_Number, Entry_Time
FROM Parking_Records
WHERE Exit_Time IS NULL
  AND Entry_Time < NOW() - INTERVAL '1 HOUR';

-- Sample query: List top-paying customers
SELECT ci.Owner_Name, ci.Phone_Number, SUM(pr.Parking_Fee) AS Total_Payment
FROM Parking_Records pr
JOIN Car_Information ci ON pr.Car_Number = ci.Car_Number
GROUP BY ci.Owner_Name, ci.Phone_Number
ORDER BY Total_Payment DESC
LIMIT 10;

-- Sample query: Count the number of cars parked per day
SELECT DATE(Entry_Time) AS Parking_Date, COUNT(*) AS Cars_Parked
FROM Parking_Records
GROUP BY DATE(Entry_Time);