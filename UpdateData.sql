UPDATE Vehicle_T
SET 
    Model = CASE Make
        WHEN 'Toyota' THEN CASE MOD(ROWNUM, 4)
            WHEN 0 THEN 'RAV4'        -- SUV
            WHEN 1 THEN 'Camry'       -- Sedan
            WHEN 2 THEN 'Corolla'     -- Hatchback
            ELSE 'Tacoma'             -- MiniTruck
        END
        WHEN 'Ford' THEN CASE MOD(ROWNUM, 4)
            WHEN 0 THEN 'Escape'      -- SUV
            WHEN 1 THEN 'Fusion'      -- Sedan
            WHEN 2 THEN 'Focus'       -- Hatchback
            ELSE 'F-150'              -- MiniTruck
        END
        WHEN 'Tesla' THEN CASE MOD(ROWNUM, 3)
            WHEN 0 THEN 'Model 3'     -- Sedan
            WHEN 1 THEN 'Model Y'     -- SUV
            ELSE 'Cybertruck'         -- MiniTruck
        END
        WHEN 'Honda' THEN CASE MOD(ROWNUM, 4)
            WHEN 0 THEN 'CR-V'        -- SUV
            WHEN 1 THEN 'Accord'      -- Sedan
            WHEN 2 THEN 'Civic'       -- Hatchback
            ELSE 'Ridgeline'          -- MiniTruck
        END
        WHEN 'BMW' THEN CASE MOD(ROWNUM, 4)
            WHEN 0 THEN 'X5'          -- SUV
            WHEN 1 THEN '3 Series'    -- Sedan
            WHEN 2 THEN '1 Series'    -- Hatchback
            ELSE 'X3'                 -- SUV
        END
        ELSE 'Generic'
    END,
    VehicleCategory = CASE Make
        WHEN 'Toyota' THEN CASE MOD(ROWNUM, 4)
            WHEN 0 THEN 'SUV'
            WHEN 1 THEN 'Sedan'
            WHEN 2 THEN 'Hatchback'
            ELSE 'MiniTruck'
        END
        WHEN 'Ford' THEN CASE MOD(ROWNUM, 4)
            WHEN 0 THEN 'SUV'
            WHEN 1 THEN 'Sedan'
            WHEN 2 THEN 'Hatchback'
            ELSE 'MiniTruck'
        END
        WHEN 'Tesla' THEN CASE MOD(ROWNUM, 3)
            WHEN 0 THEN 'Sedan'
            WHEN 1 THEN 'SUV'
            ELSE 'MiniTruck'
        END
        WHEN 'Honda' THEN CASE MOD(ROWNUM, 4)
            WHEN 0 THEN 'SUV'
            WHEN 1 THEN 'Sedan'
            WHEN 2 THEN 'Hatchback'
            ELSE 'MiniTruck'
        END
        WHEN 'BMW' THEN CASE MOD(ROWNUM, 4)
            WHEN 0 THEN 'SUV'
            WHEN 1 THEN 'Sedan'
            WHEN 2 THEN 'Hatchback'
            ELSE 'SUV'
        END
        ELSE 'SUV'
    END;

--update the rental startdate based off the reservation pickupdate. 
UPDATE Rental_T rt
SET rt.StartDate =
(
    SELECT 
        CASE 
            WHEN DBMS_RANDOM.VALUE(0,1) < 0.8 
                THEN r.PickupDate + TRUNC(DBMS_RANDOM.VALUE(0, 3))   -- 0–2 days after pickup
            ELSE 
                r.PickupDate - TRUNC(DBMS_RANDOM.VALUE(1, 3))       -- 1–2 days before pickup
        END
    FROM Reservation_T r
    WHERE r.ReservationID = rt.ReservationID
);

--update the rental enddate based off the rental startdate
UPDATE Rental_T
SET EndDate = StartDate + TRUNC(DBMS_RANDOM.VALUE(1, 21));  -- 1–21 day rental

--update the payment table after fine-tuning on rental_t
INSERT INTO Payment_T (PaymentID, RentalID, Amount, PaymentStatus, PaymentDate)
SELECT 
    'PAY-' || LPAD(ROWNUM, 6, '0') AS PaymentID,
    r.RentalID,
    ROUND(DBMS_RANDOM.VALUE(50, 500), 2) AS Amount,
    'PAID' AS PaymentStatus,
    r.EndDate + TRUNC(DBMS_RANDOM.VALUE(0, 3)) AS PaymentDate
FROM Rental_T r;

-- Update the daily rate based on the vehicel category
UPDATE Vehicle_T
SET DailyRate =
    ROUND(
        (
            CASE VehicleCategory
                WHEN 'Sedan'      THEN DBMS_RANDOM.VALUE(40, 70)
                WHEN 'Hatchback'  THEN DBMS_RANDOM.VALUE(30, 55)
                WHEN 'SUV'        THEN DBMS_RANDOM.VALUE(70, 120)
                WHEN 'MiniTruck'  THEN DBMS_RANDOM.VALUE(80, 140)
                ELSE DBMS_RANDOM.VALUE(40, 80)
            END
        )
        *
        CASE Make
            WHEN 'Tesla' THEN 1.8
            WHEN 'BMW'   THEN 1.6
            WHEN 'Toyota' THEN 1.1
            WHEN 'Honda' THEN 1.0
            WHEN 'Ford'  THEN 1.0
            ELSE 1.0
        END
    , 2);

--regenerate real paymentamount from the payment_T
INSERT INTO Payment_T (PaymentID, RentalID, Amount, PaymentStatus, PaymentDate)
SELECT
    'PAY-2026-' || SUBSTR(DBMS_RANDOM.STRING('U', 3), 1, 3) AS PaymentID,
    r.RentalID,

    ROUND(
        v.DailyRate * (r.EndDate - r.StartDate)
    , 2) AS Amount,

    'Completed' AS PaymentStatus,
    r.EndDate + TRUNC(DBMS_RANDOM.VALUE(0, 3)) AS PaymentDate

FROM Rental_T r
JOIN Vehicle_T v
    ON r.VehicleID = v.VehicleID;



