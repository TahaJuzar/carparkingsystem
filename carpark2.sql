-- View for available parking lots
CREATE VIEW Available_Parking_Lots AS
SELECT Lot_ID, Location, Capacity, Current_Availability
FROM Parking_Lots
WHERE Current_Availability > 0;

-- View for total revenue earned in a given period
CREATE VIEW Total_Revenue_Period AS
SELECT SUM(Parking_Fee) AS Total_Revenue
FROM Parking_Records
WHERE Exit_Time BETWEEN NOW() - INTERVAL '1 DAY' AND NOW();

-- View for top-paying customers
CREATE VIEW Top_Paying_Customers AS
SELECT ci.Owner_Name, ci.Phone_Number, SUM(pr.Parking_Fee) AS Total_Payment
FROM Parking_Records pr
JOIN Car_Information ci ON pr.Car_Number = ci.Car_Number
GROUP BY ci.Owner_Name, ci.Phone_Number
ORDER BY Total_Payment DESC
LIMIT 10;

-- View for counting the number of cars parked per day
CREATE VIEW Cars_Parked_Per_Day AS
SELECT DATE(Entry_Time) AS Parking_Date, COUNT(*) AS Cars_Parked
FROM Parking_Records
GROUP BY DATE(Entry_Time);


-- Trigger to update Current_Availability in Parking_Lots
CREATE OR REPLACE FUNCTION update_availability()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        UPDATE Parking_Lots
        SET Current_Availability = Capacity - (
            SELECT COUNT(*)
            FROM Parking_Records
            WHERE Parking_Lot_ID = NEW.Parking_Lot_ID
              AND Exit_Time IS NULL
        )
        WHERE Lot_ID = NEW.Parking_Lot_ID;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE Parking_Lots
        SET Current_Availability = Capacity - (
            SELECT COUNT(*)
            FROM Parking_Records
            WHERE Parking_Lot_ID = OLD.Parking_Lot_ID
              AND Exit_Time IS NULL
        )
        WHERE Lot_ID = OLD.Parking_Lot_ID;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_availability_trigger
AFTER INSERT OR UPDATE OR DELETE ON Parking_Records
FOR EACH ROW EXECUTE FUNCTION update_availability();


-- Function to calculate parking fee
CREATE OR REPLACE FUNCTION calculate_parking_fee(entry_time TIMESTAMP, exit_time TIMESTAMP)
RETURNS DECIMAL AS $$
DECLARE
    duration INTERVAL;
BEGIN
    duration := exit_time - entry_time;
    -- Example fee calculation: $1 per hour
    RETURN EXTRACT(EPOCH FROM duration) / 3600 * 1;
END;
$$ LANGUAGE plpgsql;
