/* 
Script Name: CAR_RENTAL_SCHEMA.SQL
Purpose: Builds Oracle tables for Car Rental System
Author: Luan
Date: May 2026
Comment: Creates CUSTOMER, VEHICLE, RESERVATION, RENTAL, and PAYMENT tables with PK/FK relationships.
*/

/* Step 1: Drop tables */

DROP TABLE Payment_T CASCADE CONSTRAINTS;
DROP TABLE Rental_T CASCADE CONSTRAINTS;
DROP TABLE Reservation_T CASCADE CONSTRAINTS;
DROP TABLE Vehicle_T CASCADE CONSTRAINTS;
DROP TABLE Customer_T CASCADE CONSTRAINTS;

/* Step 1B: Drop sequences */

DROP SEQUENCE customer_seq;
DROP SEQUENCE vehicle_seq;
DROP SEQUENCE reservation_seq;
DROP SEQUENCE rental_seq;
DROP SEQUENCE payment_seq;

/* Step 2: Tables creation */

/* CUSTOMER Table */
CREATE TABLE Customer_T (
    CustomerID        VARCHAR2(20),
    FirstName         VARCHAR2(50),
    LastName          VARCHAR2(50),
    Phone             VARCHAR2(20),
    Email             VARCHAR2(100),
    DriverLicenceNo   VARCHAR2(50),
    DateOfBirth       DATE,
    CONSTRAINT pk_customer PRIMARY KEY (CustomerID)
);

CREATE SEQUENCE customer_seq
    START WITH 1000
    INCREMENT BY 1
    MAXVALUE 9999
    CYCLE;

CREATE OR REPLACE TRIGGER trg_customer_id
BEFORE INSERT ON Customer_T
FOR EACH ROW
BEGIN
    :NEW.CustomerID :=
        UPPER(SUBSTR(:NEW.LastName, 1, 3)) ||
        TO_CHAR(customer_seq.NEXTVAL);
END;
/
 
/* VEHICLE Table */
CREATE TABLE Vehicle_T (
    VehicleID        VARCHAR2(20),
    LicencePlate     VARCHAR2(20),
    Make             VARCHAR2(50),
    Model            VARCHAR2(50),
    Year             NUMBER(4),
    VinNo            VARCHAR2(50),
    DailyRate        NUMBER(10,2),
    VehicleStatus    VARCHAR2(20),
    VehicleCategory  VARCHAR2(50),
    CONSTRAINT pk_vehicle PRIMARY KEY (VehicleID)
);

CREATE SEQUENCE vehicle_seq
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 9999
    CYCLE;

CREATE OR REPLACE TRIGGER trg_vehicle_id
BEFORE INSERT ON Vehicle_T
FOR EACH ROW
BEGIN
    :NEW.VehicleID :=
        'CAR-' ||
        TO_CHAR(EXTRACT(YEAR FROM SYSDATE)) || '-' ||
        LPAD(vehicle_seq.NEXTVAL, 4, '0');
END;
/

/* RESERVATION Table */
CREATE TABLE Reservation_T (
    ReservationID   VARCHAR2(20),
    CustomerID      VARCHAR2(20),
    VehicleID       VARCHAR2(20),
    PickupDate      DATE,
    ReturnDate      DATE,
    CONSTRAINT pk_reservation PRIMARY KEY (ReservationID),
    CONSTRAINT fk_res_customer FOREIGN KEY (CustomerID)
        REFERENCES Customer_T(CustomerID),
    CONSTRAINT fk_res_vehicle FOREIGN KEY (VehicleID)
        REFERENCES Vehicle_T(VehicleID)
);

CREATE SEQUENCE reservation_seq
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 999999
    CYCLE;

CREATE OR REPLACE TRIGGER trg_reservation_id
BEFORE INSERT ON Reservation_T
FOR EACH ROW
BEGIN
    :NEW.ReservationID :=
        'RES-' ||
        LPAD(reservation_seq.NEXTVAL, 6, '0');
END;
/

/* RENTAL Table */
CREATE TABLE Rental_T (
    RentalID        VARCHAR2(20),
    ReservationID   VARCHAR2(20),
    VehicleID       VARCHAR2(20),
    StartDate       DATE,
    EndDate         DATE,
    RentalStatus    VARCHAR2(20),
    CONSTRAINT pk_rental PRIMARY KEY (RentalID),
    CONSTRAINT fk_rental_res FOREIGN KEY (ReservationID)
        REFERENCES Reservation_T(ReservationID),
    CONSTRAINT fk_rental_vehicle FOREIGN KEY (VehicleID)
        REFERENCES Vehicle_T(VehicleID)
);

CREATE SEQUENCE rental_seq
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 999999
    CYCLE;

CREATE OR REPLACE TRIGGER trg_rental_id
BEFORE INSERT ON Rental_T
FOR EACH ROW
BEGIN
    :NEW.RentalID :=
        'RNT-' ||
        SUBSTR(DBMS_RANDOM.STRING('X', 6), 1, 6);
END;
/

/* PAYMENT Table */
CREATE TABLE Payment_T (
    PaymentID            VARCHAR2(20),
    RentalID             VARCHAR2(20),
    PaymentDate          DATE,
    PaymentMethod        VARCHAR2(30),
    Amount               NUMBER(10,2),
    TransactionReference VARCHAR2(100),
    TokenReference       VARCHAR2(200),
    PaymentStatus        VARCHAR2(20),
    CONSTRAINT pk_payment PRIMARY KEY (PaymentID),
    CONSTRAINT fk_payment_rental FOREIGN KEY (RentalID)
        REFERENCES Rental_T(RentalID)
);

CREATE SEQUENCE payment_seq
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 999999
    CYCLE;

CREATE OR REPLACE TRIGGER trg_payment_id
BEFORE INSERT ON Payment_T
FOR EACH ROW
BEGIN
    :NEW.PaymentID :=
        'PAY-' ||
        TO_CHAR(EXTRACT(YEAR FROM SYSDATE)) || '-' ||
        SUBSTR(DBMS_RANDOM.STRING('U', 3), 1, 3);
END;
/

COMMIT;
