---- Below are examples of the essential functionality for 
---- the BellHop Hotel Manager App written as they will be 
---- used inside our fullstack application:
----   CREATE BOOKING
----   UPDATE BOOKING
----   SHOW ALL BOOKINGS
----   SHOW A SINGLE BOOKING
----   CANCEL A BOOKING
----   SHOW AVAILABLE ROOMS (rooms not booked) 
----   UPDATE ROOM_TYPE PRICES

-- NOTE: Data, in the queries below, is not hard coded into
--       the queries because these are the actual queries we'll 
--       embed into our code base. Variables are indicated with
--       a colon in front, so a search for a booking will will 
--       use a variable like this, :booking.id


---- CREATE BOOKING ----
-- Inserting a new booking for John Smith
INSERT INTO bookings (customer_id, date_created) 
VALUES
    (:booking.customer.id, :booking.dateCreated);
INSERT INTO room_bookings 
	(room_type_id, booking_id, start_date, end_date, nights, booked_price) 
VALUES
    (:booking.roomType.id, :booking.id,  :booking.startDate, :booking.endDate, DATEDIFF(:booking.endDate, :booking.startDate), 
    (
		SELECT price FROM room_types
		WHERE room_type_id = :booking.roomType.id
	));

----- UPDATE BOOKING -----
UPDATE bookings
SET status = :booking.status
WHERE booking_id = :booking.id;

---- SHOW ALL BOOKINGS ----
SELECT bookings.*, customers.*, room_bookings.*
FROM bookings
JOIN customers ON bookings.customer_id = customers.customer_id
LEFT JOIN room_bookings ON bookings.booking_id = room_bookings.booking_id;

---- SHOW A SINGLE BOOKING ----
SELECT bookings.*, room_bookings.*
FROM bookings
JOIN customers ON bookings.customer_id = customers.customer_id
LEFT JOIN room_bookings ON bookings.booking_id = room_bookings.booking_id
WHERE customers.email = :booking.customer.email;

---- CANCEL A BOOKING ----
DELETE FROM bookings 
WHERE booking_id = :booking.id;

---- SHOW AVAILABLE ROOMS ----
SELECT rooms.*
FROM rooms
WHERE rooms.room_id NOT IN (
    SELECT room_bookings.room_id
    FROM room_bookings
    WHERE room_bookings.start_date <= :booking.endDate AND room_bookings.end_date >= :booking.startDate
    AND room_bookings.room_id IS NOT NULL
);

---- UPDATE ROOM PRICES ----
UPDATE room_types
SET price = roomType.price
WHERE room_type_id = :roomType.id;


---- BOOKING NUMBER 1 FOR JOHN DOE CHECKED IN ----
---- At this point the receptionist has selected the correct booking.
---- Using the client app, she updatess the booking status
-- UPDATE bookings
-- SET status = booking.status
-- WHERE booking_id = 1;
---- Now each of the room_bookings are fetched
-- UPDATE room_bookings
-- SET room_id = booking.room.id
-- WHERE booking_id = booking.id;