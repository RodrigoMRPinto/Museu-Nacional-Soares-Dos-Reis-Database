-- populate2.sql
PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

------------------------------------------------------------
-- Person
------------------------------------------------------------
INSERT INTO Person (personID, name, birthDate, nationality, gender) VALUES
 (1, 'Pablo Picasso', '1881-10-25', 'Spanish', 'M'),
 (2, 'Frida Kahlo', '1907-07-06', 'Mexican', 'F'),
 (3, 'Vincent van Gogh', '1853-03-30', 'Dutch', 'M'),
 (4, 'Alice Curator', '1985-04-12', 'Portuguese', 'F'),
 (5, 'Bob Guide', '1990-09-01', 'Portuguese', 'M'),
 (6, 'Carla Manager', '1978-01-20', 'Portuguese', 'F'),
 (7, 'Daniel Visitor', '2000-02-02', 'Portuguese', 'M'),
 (8, 'Eva Tourist', '1995-11-11', 'German', 'F'),
 (9, 'Hugo Student', '2003-05-05', 'Portuguese', 'M');

------------------------------------------------------------
-- Event
------------------------------------------------------------
INSERT INTO Event (eventID, theme, startDate, endDate) VALUES
 (1, 'Modern Art Week', '2025-03-01', '2025-03-10'),
 (2, 'Impressionist Nights', '2025-04-15', '2025-04-20');

------------------------------------------------------------
-- Warehouse
------------------------------------------------------------
INSERT INTO Warehouse (warehouseID, location, storage) VALUES
 (1, 'Main Warehouse', 100),
 (2, 'Secondary Warehouse', 50);

------------------------------------------------------------
-- Room
------------------------------------------------------------
INSERT INTO Room (roomID, roomNumber, floor) VALUES
 (1, 'A101', 1),
 (2, 'A102', 1),
 (3, 'B201', 2),
 (4, 'Office-1', 0);

------------------------------------------------------------
-- VisitPack
------------------------------------------------------------
INSERT INTO VisitPack (packID, name, purchaseDate, price, description) VALUES
 (1, 'Standard Pack', '2025-01-01', 15.0,
  'Guided visit of the main exhibition (1 hour)'),
 (2, 'Family Pack', '2025-01-05', 40.0,
  'Pack for 2 adults and 2 children'),
 (3, 'Student Pack', '2025-02-01', 8.0,
  'Discounted ticket for students');

------------------------------------------------------------
-- Feedback
------------------------------------------------------------
INSERT INTO Feedback (feedbackID, packRating, opinion, suggestions) VALUES
 (1, 5, 'Amazing visit!', 'Keep the same quality of guides.'),
 (2, 4, 'Great artworks and organisation.', 'Add more benches in the rooms.'),
 (3, 3, 'Good but a bit crowded.', 'Improve the signalling between sections.');

------------------------------------------------------------
-- Especializações de Person: Artist / Staff / Visitor
------------------------------------------------------------
INSERT INTO Artist (artistID, personID, style, description) VALUES
 (1, 1, 'Cubism', 'Famous Spanish painter and sculptor.'),
 (2, 2, 'Surrealism', 'Mexican painter known for self-portraits.'),
 (3, 3, 'Post-Impressionism', 'Dutch painter with expressive brushwork.');

INSERT INTO Staff (staffID, personID, salary, contractStart, contractEnd, curriculumVitae) VALUES
 (1, 4, 1800.00, '2020-01-01', NULL,
  'Senior curator with 10 years of experience.'),
 (2, 5, 1200.00, '2022-06-15', NULL,
  'Museum guide fluent in three languages.'),
 (3, 6, 2000.00, '2019-09-01', '2026-09-01',
  'Operations manager responsible for events.');

INSERT INTO Visitor (visitorID, personID, email, phoneNumber) VALUES
 (1, 7, 'daniel.visitor@example.com', 111111111),
 (2, 8, 'eva.tourist@example.com',   222222222),
 (3, 9, 'hugo.student@example.com',  333333333);

------------------------------------------------------------
-- Section (dependente de Event)
------------------------------------------------------------
INSERT INTO Section (sectionID, eventID) VALUES
 (1, 1),
 (2, 1),
 (3, 2);

------------------------------------------------------------
-- ArtRoom e Office (dependem de Room e Section)
------------------------------------------------------------
INSERT INTO ArtRoom (roomID, capacity, sectionID) VALUES
 (1, 30, 1),
 (2, 50, 2),
 (3, 40, 3);

INSERT INTO Office (roomID, n_Computers) VALUES
 (4, 4);

------------------------------------------------------------
-- ArtWork (dependente de Artist / Warehouse / Room)
------------------------------------------------------------
-- Atenção ao CHECK:
--  state = 'InUse'  -> roomID NOT NULL AND warehouseID IS NULL
--  state <> 'InUse' -> roomID IS NULL AND warehouseID NOT NULL
INSERT INTO ArtWork (pieceID, title, description, type, state,
                     artistID, warehouseID, roomID) VALUES
 ('P001', 'Guernica',
  'Large oil painting on canvas.', 'Painting',
  'InUse', 1, NULL, 1),
 ('P002', 'The Two Fridas',
  'Double self-portrait.', 'Painting',
  'InUse', 2, NULL, 2),
 ('P003', 'Starry Night',
  'Depiction of a night sky.', 'Painting',
  'Stored', 3, 1, NULL),
 ('P004', 'Self Portrait',
  'Self portrait of the artist.', 'Painting',
  'Maintenance', 3, 2, NULL);

------------------------------------------------------------
-- StaffRoomNumber (Relação Staff–Room)
------------------------------------------------------------
INSERT INTO StaffRoomNumber (staffID, roomID) VALUES
 (1, 4),
 (1, 1),
 (2, 1),
 (3, 2);

------------------------------------------------------------
-- Task (dependente de Staff e Room)
------------------------------------------------------------
INSERT INTO Task (staffID, roomID, name, date, description) VALUES
 (1, 1, 'Check lighting', '2025-03-02',
  'Verify and adjust the lighting for the main exhibition.'),
 (2, 1, 'Guided tour',    '2025-03-03',
  'Lead an evening guided tour for visitors.'),
 (3, 2, 'Prepare room',   '2025-04-14',
  'Prepare the room for the "Impressionist Nights" event.');

------------------------------------------------------------
-- Visit (dependente de Visitor)
------------------------------------------------------------
INSERT INTO Visit (visitID, visitDate, partySize, discount, visitorID) VALUES
 (1, '2025-03-02', 2, 0.0, 1),
 (2, '2025-03-03', 4, 5.0, 2),
 (3, '2025-04-16', 1, 0.0, 3);

------------------------------------------------------------
-- Experience (dependente de Visit, VisitPack, Feedback, Event)
------------------------------------------------------------
INSERT INTO Experience (visitID, packID, feedbackID, eventID) VALUES
 (1, 1, 1, 1),
 (2, 2, 2, 1),
 (3, 3, 3, 2);

------------------------------------------------------------
-- Favourite (dependente de Feedback e ArtWork)
------------------------------------------------------------
INSERT INTO Favourite (feedbackID, pieceID) VALUES
 (1, 'P001'),
 (1, 'P002'),
 (2, 'P003'),
 (3, 'P001'),
 (3, 'P004');

COMMIT;
