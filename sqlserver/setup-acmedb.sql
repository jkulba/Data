-- Create a new database
CREATE DATABASE AcmeDB;
GO

-- Switch to the newly created database
USE AcmeDB;
GO

-- Create a schema
CREATE SCHEMA Recruits;
GO

-- Create the Users table with UUID as the primary key
CREATE TABLE Recruits.Users (
    UserID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    RegistrationDate DATETIME2 DEFAULT GETDATE()
);
GO

-- Insert 25 sample records with Star Wars inspired names and UUIDs
INSERT INTO Recruits.Users (FirstName, LastName, Email) VALUES
('Luke', 'Skywalker', 'luke.skywalker@rebellion.org'),
('Leia', 'Organa', 'leia.organa@resistance.gov'),
('Han', 'Solo', 'han.solo@millenniumfalcon.com'),
('Obi-Wan', 'Kenobi', 'obiwan.kenobi@jediorder.net'),
('Darth', 'Vader', 'darth.vader@empire.mil'),
('Yoda', '', 'master.yoda@dagobah.net'),
('Padmé', 'Amidala', 'padme.amidala@naboo.gov'),
('Anakin', 'Skywalker', 'anakin.skywalker@jediorder.net'),
('Chewbacca', '', 'chewbacca@wookiee.net'),
('Lando', 'Calrissian', 'lando.calrissian@cloudcity.com'),
('Palpatine', '', 'emperor@empire.gov'),
('Mace', 'Windu', 'mace.windu@jediorder.net'),
('Qui-Gon', 'Jinn', 'quigon.jinn@jediorder.net'),
('Ahsoka', 'Tano', 'ahsoka.tano@republic.mil'),
('Captain', 'Rex', 'captain.rex@clonetrooper.net'),
('Boba', 'Fett', 'boba.fett@mandalorian.com'),
('Jabba', 'the Hutt', 'jabba@tatooine.net'),
('R2', 'D2', 'r2d2@rebellion.org'),
('C', '3PO', 'c3po@rebellion.org'),
('Finn', '', 'finn@resistance.mil'),
('Rey', '', 'rey@jakku.net'),
('Poe', 'Dameron', 'poe.dameron@resistance.mil'),
('Kylo', 'Ren', 'kylo.ren@firstorder.mil'),
('General', 'Hux', 'general.hux@firstorder.mil'),
('Maz', 'Kanata', 'maz.kanata@takodana.net');
GO