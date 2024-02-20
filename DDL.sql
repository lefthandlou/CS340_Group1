SET FOREIGN_KEY_CHECKS=0;
SET AUTOCOMMIT = 0;

---- TABLE CREATION ----
DROP TABLE IF EXISTS;
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    address VARCHAR(255),
);

DROP TABLE IF EXISTS;
CREATE TABLE room_types (
    room_type_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    description TEXT,
	price FLOAT
);

DROP TABLE IF EXISTS;
CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_type_id INT NOT NULL,
	room_number INT NOT NULL UNIQUE,
	FOREIGN KEY (room_type_id) REFERENCES room_types(room_type_id)
);

DROP TABLE IF EXISTS;
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
	total_paid FLOAT DEFAULT '0.00',
    date_created DATE NOT NULL,
    status ENUM('arriving', 'checkedin unpaid', 'checkedin paid', 'checked out') DEFAULT 'arriving',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

DROP TABLE IF EXISTS;
CREATE TABLE room_bookings (
    room_booking_id INT AUTO_INCREMENT PRIMARY KEY,
    room_type_id INT NOT NULL,
	booking_id INT,
    room_id INT NULL,-- <-- NULL because this will be updated to a specific room ID on arrival
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    nights INT NOT NULL,
    booked_price FLOAT NOT NULL,
    FOREIGN KEY (room_id) REFERENCES rooms(room_id),
	FOREIGN KEY (room_type_id) REFERENCES room_types(room_type_id),
	FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE
);--booking_id gets DELETE CASCADE because when a booking is deleted we want each of the room_bookings associated with it also deleted

-------- INSERT HOTEL DATA ---------
INSERT INTO customers (first_name, last_name, email, address) 
VALUES
	('John', 'Smith', 'john.smith@example.com', '123 Some Street'),
	('Jane', 'Doe', 'jane.doe@example.com', '456 Another Street'),
	('Sumyun', 'Gai', 'sumyun.gai@example.com', '789 That Way');

INSERT INTO room_types (name, description, price) 
VALUES
	('Standard', 'A standard room with basic stuff.', 55.00),
	('Deluxe', 'A deluxe room with more stuff.', 65.00);

-- Insert 25 rooms in total
-- 13 standard rooms
INSERT INTO rooms (room_type_id, room_number) 
VALUES
	(1, 101), (1, 102), (1, 103), (1, 104), (1, 105), 
	(1, 106), (1, 107), (1, 108), (1, 109), (1, 110), 
	(1, 111), (1, 112), (1, 113);

-- 12 deluxe rooms
INSERT INTO rooms (room_type_id, room_number) 
VALUES
	(2, 201), (2, 202), (2, 203), (2, 204), (2, 205), 
	(2, 206), (2, 207), (2, 208), (2, 209), (2, 210), 
	(2, 211), (2, 212);

---- BOOKING NUMBER 1 ----
-- John Smith (customer id = 1) creates a new booking...
INSERT INTO bookings (customer_id, date_created) 
VALUES
	(1, '2024-02-07'); -- <- John Smith (customer id = 1)
-- Wait for returned bookings.booking_id, then complete all room_booking...
INSERT INTO room_bookings (room_type_id, booking_id, start_date, end_date, nights, booked_price) 
VALUES
	(
		1, 1, '2024-02-07', '2024-02-09', 2, (-- <- room type = 1 because John is a cheap schmuck and got a standard room
			SELECT price FROM room_types 
			WHERE room_type_id = 1 -- <- get the booked price from room_type = 1
		)
	);

---- BOOKING NUMBER 2 ----
-- Now Jane Doe creates a new booking...
INSERT INTO bookings (customer_id, date_created, status) 
VALUES
	(2, '2024-02-07'); -- <- Jane Doe (customer id = 2)
-- Wait for returned bookings.booking_id, then complete all room_bookings...
INSERT INTO room_bookings (room_type_id, booking_id, start_date, end_date, nights, booked_price) 
VALUES
	(
		2, 2, '2024-02-07', '2024-02-09', 2, (-- <- room type = 2 for Deluxe and 2 for the booking id
			SELECT price FROM room_types -- <- get the booked price from room_type = 2
			WHERE room_type_id = 2
		)
	);

---- BOOKING NUMBER 3 ----
-- Now Sumyung Guy creates a new booking...
INSERT INTO bookings (customer_id, date_created, status) 
VALUES
	(3, '2024-02-07'); -- <- Jane Doe (customer id = 2)
-- Wait for returned bookings.booking_id, then complete all room_bookings...
INSERT INTO room_bookings (room_type_id, booking_id, start_date, end_date, nights, booked_price) 
VALUES
	(
		1, 3, '2024-02-07', '2024-02-09', 2, (-- <- room type = 2 for Deluxe and 2 for the booking id
			SELECT price FROM room_types -- <- get the booked price from room_type = 2
			WHERE room_type_id = 1
		)
	);

SET FOREIGN_KEY_CHECKS=1;
COMMIT;