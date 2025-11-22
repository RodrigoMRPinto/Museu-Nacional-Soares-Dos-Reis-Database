--In the refined conceptual model, there is a total specialization constraint between 
--Person and its subclasses Artist, Staff, and Visitor. 
--This means that every instance of Person must belong to at least one of the three 
--subtypes, ensuring that no person exists without a defined role within the system.
-- However, this constraint cannot be directly enforced in SQLite.

PRAGMA foreign_keys = ON;

-- DROP TABLES (first those who have FKs)
DROP TABLE IF EXISTS Experience;
DROP TABLE IF EXISTS Favourite;
DROP TABLE IF EXISTS StaffRoomNumber;
DROP TABLE IF EXISTS Task;
DROP TABLE IF EXISTS ArtWork;
DROP TABLE IF EXISTS ArtRoom;
DROP TABLE IF EXISTS Office;
DROP TABLE IF EXISTS Visit;
DROP TABLE IF EXISTS Visitor;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Artist;
DROP TABLE IF EXISTS Section;
DROP TABLE IF EXISTS Feedback;
DROP TABLE IF EXISTS VisitPack;
DROP TABLE IF EXISTS Event;
DROP TABLE IF EXISTS Warehouse;
DROP TABLE IF EXISTS Room;
DROP TABLE IF EXISTS Person;

-- Alteração da Ordem de criação das  tabelas

------------------------------------------------------------
-- Tabelas base (sem foreign keys)
------------------------------------------------------------

CREATE TABLE Person (
    personID INTEGER PRIMARY KEY,
    name      TEXT NOT NULL,
    birthDate DATE,
    nationality TEXT,
    gender    TEXT
);

CREATE TABLE Event (
    eventID   INTEGER PRIMARY KEY,
    theme     TEXT NOT NULL UNIQUE,
    startDate DATE,
    endDate   DATE,
    CHECK (startDate < endDate)
);

CREATE TABLE Warehouse (
    warehouseID INTEGER PRIMARY KEY,
    location    TEXT,
    storage     INT
);

CREATE TABLE Room (
    roomID     INTEGER PRIMARY KEY,
    roomNumber TEXT NOT NULL,
    floor      INTEGER NOT NULL
);

CREATE TABLE VisitPack (
    packID       INTEGER PRIMARY KEY,
    name         TEXT NOT NULL,
    purchaseDate DATE,
    price        REAL,
    description  TEXT
);

CREATE TABLE Feedback (
    feedbackID INTEGER PRIMARY KEY,
    packRating INTEGER,
    opinion    TEXT,
    suggestions TEXT
);

------------------------------------------------------------
-- Especializações de Person
------------------------------------------------------------

CREATE TABLE Artist (
    artistID INTEGER PRIMARY KEY,
    personID INTEGER NOT NULL UNIQUE,
    style    TEXT,
    description TEXT,
    FOREIGN KEY (personID) REFERENCES Person(personID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE Staff (
    staffID  INTEGER PRIMARY KEY,
    personID INTEGER NOT NULL UNIQUE,
    salary   REAL NOT NULL CHECK (salary > 0),
    contractStart DATE,
    contractEnd   DATE,
    curriculumVitae TEXT,
    FOREIGN KEY (personID) REFERENCES Person(personID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CHECK (contractEnd IS NULL OR contractStart < contractEnd)
);

CREATE TABLE Visitor (
    visitorID  INTEGER PRIMARY KEY,
    personID   INTEGER NOT NULL UNIQUE,
    email      TEXT NOT NULL UNIQUE,
    phoneNumber INTEGER NOT NULL UNIQUE,
    FOREIGN KEY (personID) REFERENCES Person(personID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

------------------------------------------------------------
-- Dependentes de Event / Room
------------------------------------------------------------

CREATE TABLE Section (
    sectionID INTEGER PRIMARY KEY,
    eventID   INTEGER NOT NULL,
    FOREIGN KEY (eventID) REFERENCES Event(eventID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE ArtRoom (
    roomID    INTEGER PRIMARY KEY,
    capacity  INTEGER NOT NULL CHECK (capacity > 0),
    sectionID INTEGER NOT NULL,
    FOREIGN KEY (roomID) REFERENCES Room(roomID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (sectionID) REFERENCES Section(sectionID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE Office (
    roomID       INTEGER PRIMARY KEY,
    n_Computers  INTEGER,
    FOREIGN KEY (roomID) REFERENCES Room(roomID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

------------------------------------------------------------
-- ArtWork e relações com Staff/Room
------------------------------------------------------------

CREATE TABLE ArtWork (
    pieceID    TEXT PRIMARY KEY,
    title      TEXT NOT NULL,
    description TEXT,
    type       TEXT,
    state      TEXT NOT NULL CHECK (state IN ('InUse','Maintenance','Stored')),
    artistID   INTEGER NOT NULL,
    warehouseID INTEGER,
    roomID     INTEGER,
    FOREIGN KEY (artistID) REFERENCES Artist(artistID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (roomID) REFERENCES Room(roomID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CHECK (
      (state = 'InUse' AND roomID IS NOT NULL AND warehouseID IS NULL) OR
      (state <> 'InUse' AND roomID IS NULL AND warehouseID IS NOT NULL)
    )
);

CREATE TABLE StaffRoomNumber (
    staffID INTEGER NOT NULL,
    roomID  INTEGER NOT NULL,
    PRIMARY KEY (staffID, roomID),
    FOREIGN KEY (staffID) REFERENCES Staff(staffID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (roomID) REFERENCES Room(roomID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE Task (
    staffID INTEGER NOT NULL,
    roomID  INTEGER NOT NULL,
    name    TEXT NOT NULL,
    date    TEXT NOT NULL,
    description TEXT,
    PRIMARY KEY (staffID, roomID),
    FOREIGN KEY (staffID) REFERENCES Staff(staffID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (roomID) REFERENCES Room(roomID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

------------------------------------------------------------
-- Visit, Experience, Favourite
------------------------------------------------------------

CREATE TABLE Visit (
    visitID   INTEGER PRIMARY KEY,
    visitDate DATE,
    partySize INTEGER,
    discount  REAL,
    visitorID INTEGER NOT NULL, --(Remoção de Unique)
    FOREIGN KEY (visitorID) REFERENCES Visitor(visitorID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE Experience (
    visitID    INTEGER NOT NULL,
    packID     INTEGER NOT NULL,
    feedbackID INTEGER NOT NULL,
    eventID    INTEGER NOT NULL,
    PRIMARY KEY (visitID, packID),
    FOREIGN KEY (visitID) REFERENCES Visit(visitID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (packID) REFERENCES VisitPack(packID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (feedbackID) REFERENCES Feedback(feedbackID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (eventID) REFERENCES Event(eventID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE Favourite (
    feedbackID INTEGER NOT NULL,
    pieceID    TEXT    NOT NULL,
    PRIMARY KEY (feedbackID, pieceID),
    FOREIGN KEY (feedbackID) REFERENCES Feedback(feedbackID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (pieceID) REFERENCES ArtWork(pieceID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);