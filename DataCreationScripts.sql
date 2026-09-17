/* CUSTOMER Table Data */
INSERT INTO Customer_T 
    (FirstName, LastName, Phone, Email, DriverLicenceNo, DateOfBirth)
SELECT
    INITCAP(DBMS_RANDOM.STRING('A', 6)),
    INITCAP(DBMS_RANDOM.STRING('A', 8)),
    '(' || TRUNC(DBMS_RANDOM.VALUE(200, 999)) || ') ' ||
    TRUNC(DBMS_RANDOM.VALUE(200, 999)) || '-' ||
    TRUNC(DBMS_RANDOM.VALUE(1000, 9999)),
    LOWER(DBMS_RANDOM.STRING('A', 6)) || '@gmail.com',
    'DL' || TRUNC(DBMS_RANDOM.VALUE(100000, 999999)),
    DATE '1980-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 15000))
FROM dual
CONNECT BY LEVEL <= 100;

/* VEHICLE Table Data */
INSERT INTO Vehicle_T 
    (Make, Model, Year, VinNo, DailyRate, VehicleStatus, VehicleCategory)
SELECT
    UBSTR(DBMS_RANDOM.STRING('U', 3), 1, 3) || '-' || LPAD(TRUNC(DBMS_RANDOM.VALUE(1000, 9999)), 4, '0'),
    CASE MOD(LEVEL, 5)
        WHEN 0 THEN 'Toyota'
        WHEN 1 THEN 'Honda'
        WHEN 2 THEN 'Ford'
        WHEN 3 THEN 'BMW'
        ELSE 'Tesla'
    END,
    'Model' || MOD(LEVEL, 20),
    TRUNC(DBMS_RANDOM.VALUE(2010, 2024)),
    'VIN' || DBMS_RANDOM.STRING('A', 10),
    ROUND(DBMS_RANDOM.VALUE(30, 150), 2),
    CASE MOD(LEVEL, 3)
        WHEN 0 THEN 'Available'
        WHEN 1 THEN 'Rented'
        ELSE 'Maintenance'
    END,
    CASE MOD(LEVEL, 4)
        WHEN 0 THEN 'Economy'
        WHEN 1 THEN 'SUV'
        WHEN 2 THEN 'Luxury'
        ELSE 'Van'
    END
FROM dual
CONNECT BY LEVEL <= 100;


/* RESERVATION Table Data */
INSERT INTO Reservation_T 
    (CustomerID, VehicleID, PickupDate, ReturnDate)
SELECT
    (SELECT CustomerID FROM Customer_T ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROW ONLY),
    (SELECT VehicleID FROM Vehicle_T ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROW ONLY),
    SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1, 200)),
    SYSDATE - TRUNC(DBMS_RANDOM.VALUE(0, 199))
FROM dual
CONNECT BY LEVEL <= 100;

/* RENTAL Table Data */
INSERT INTO Rental_T 
    (ReservationID, VehicleID, StartDate, EndDate, RentalStatus)
SELECT
    (SELECT ReservationID FROM Reservation_T ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROW ONLY),
    (SELECT VehicleID FROM Vehicle_T ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROW ONLY),
    SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1, 200)),
    SYSDATE - TRUNC(DBMS_RANDOM.VALUE(0, 199)),
    CASE MOD(LEVEL, 3)
        WHEN 0 THEN 'Completed'
        WHEN 1 THEN 'Ongoing'
        ELSE 'Cancelled'
    END
FROM dual
CONNECT BY LEVEL <= 100;

/* PAYMENT Table Data */
INSERT INTO Payment_T 
    (RentalID, PaymentDate, PaymentMethod, Amount, TransactionReference, TokenReference, PaymentStatus)
SELECT
    (SELECT RentalID FROM Rental_T ORDER BY DBMS_RANDOM.VALUE FETCH FIRST 1 ROW ONLY),
    SYSDATE - TRUNC(DBMS_RANDOM.VALUE(0, 200)),
    CASE MOD(LEVEL, 3)
        WHEN 0 THEN 'Credit Card'
        WHEN 1 THEN 'Debit Card'
        ELSE 'Cash'
    END,
    ROUND(DBMS_RANDOM.VALUE(50, 500), 2),
    'TXN-' || DBMS_RANDOM.STRING('X', 10),
    'TKN-' || DBMS_RANDOM.STRING('X', 15),
    CASE MOD(LEVEL, 3)
        WHEN 0 THEN 'Completed'
        WHEN 1 THEN 'Pending'
        ELSE 'Failed'
    END
FROM dual
CONNECT BY LEVEL <= 100;

COMMIT;
