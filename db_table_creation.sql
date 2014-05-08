
/*  Database drop/add is not supported at the SQL level for phpmyadmin, so for our use,
    first go into phpmyadmin localhost, then select the desired database, and run these
    SQL commands. Everything is nominal, except that the queries reference no specific
    database, so you need to select it manually via the GUI interface.
    
    NOTE: After running, phpmyadmin might not throw an error OR a success window.
     Instead, it just points out that the DROP TABLE queries failed- BUT the rest
     of the query still worked, so all tables have been created as needed.
 */


/* Again, can't wipe the database, so wipe every associated table.  */
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS file;
DROP TABLE IF EXISTS class;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS admin;



/* Recreate tables using queries.  */

CREATE TABLE `admin` (
 `UID` int(8) NOT NULL AUTO_INCREMENT,
 `Username` varchar(30) NOT NULL,
 `Password` varchar(30) NOT NULL,
 `Name` varchar(30) NOT NULL,
 `Blocked` int(1) NOT NULL,
 `Permissions` int(1) NOT NULL,
 `Department` varchar(30) DEFAULT NULL,
 PRIMARY KEY (`UID`)
) ENGINE=InnoDB AUTO_INCREMENT=90000000 DEFAULT CHARSET=latin1;



CREATE TABLE `student` (
 `UID` int(8) NOT NULL AUTO_INCREMENT,
 `Username` varchar(30) NOT NULL,
 `Password` varchar(30) NOT NULL,
 `Name` varchar(30) NOT NULL,
 `Blocked` int(1) NOT NULL DEFAULT '0',
 `Year` varchar(4) DEFAULT NULL,
 `Major` varchar(4) DEFAULT NULL,
 PRIMARY KEY (`UID`)
) ENGINE=InnoDB AUTO_INCREMENT=80000000 DEFAULT CHARSET=latin1;



CREATE TABLE `class` (
 `Course_number` varchar(30) NOT NULL,
 `Department` varchar(30) DEFAULT NULL,
 `CName` varchar(50) DEFAULT NULL,
 `Instructor` int(8) NOT NULL,
 PRIMARY KEY (`Course_number`),
 KEY `Instructor` (`Instructor`),
 CONSTRAINT `class_ibfk_1` FOREIGN KEY (`Instructor`) REFERENCES `admin` (`UID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;




CREATE TABLE `file` (
 `FID` int(8) NOT NULL AUTO_INCREMENT,
 `Timestamp` datetime DEFAULT NULL,
 `Type` varchar(8) NOT NULL,
 `Year` varchar(8) NOT NULL,
 `Course_number` varchar(20) NOT NULL,
 `UID` int(11) DEFAULT NULL,
 PRIMARY KEY (`FID`),
 KEY `UID` (`UID`),
 CONSTRAINT `file_ibfk_1` FOREIGN KEY (`UID`) REFERENCES `student` (`UID`)
) ENGINE=InnoDB AUTO_INCREMENT=60000000 DEFAULT CHARSET=latin1;



CREATE TABLE `comment` (
 `CID` int(8) NOT NULL AUTO_INCREMENT,
 `Body` varchar(255) NOT NULL,
 `Timestamp` datetime DEFAULT NULL,
 `FID` int(8) NOT NULL,
 `UID` int(8) NOT NULL,
 `Reply_to` int(8) NOT NULL,
 PRIMARY KEY (`CID`),
 KEY `FID` (`FID`),
 KEY `UID` (`UID`),
 KEY `Reply_to` (`Reply_to`),
 CONSTRAINT `comment_ibfk_1` FOREIGN KEY (`FID`) REFERENCES `file` (`FID`),
 CONSTRAINT `comment_ibfk_2` FOREIGN KEY (`UID`) REFERENCES `student` (`UID`),
 CONSTRAINT `comment_ibfk_3` FOREIGN KEY (`Reply_to`) REFERENCES `student` (`UID`)
) ENGINE=InnoDB AUTO_INCREMENT=70000000 DEFAULT CHARSET=latin1;


/* Stored Procedures will be added here later.  */

CREATE PROCEDURE CreateStudent
	(IN uid int,
	IN username varchar(30),
	IN password varchar(30),
	IN name varchar(30),
	IN year int,
	IN major varchar(4),
	OUT result smallint)
AS
IF(Exists (Select Username from student Where Username = username)
	OR Exists (Select Username from admin Where Username = username))
	Begin
		Set result = 1;
		RaisError('That username is already taken', 14, 1);
		Return
	End
ELSE IF (Exists (Select UID from student Where UID = uid))
	Begin
		Set result = 1;
		RaisError('An account already exists for this ID number', 14, 1);
		Return
	End
ELSE
	Begin
		INSERT INTO student
			(UID, Username, Password, Name, Blocked, Year, Major)
		VALUES (uid, username, password, name, 0, year, major);
	End
	
CREATE PROCEDURE CreateAdmin
	(IN uid int,
	IN username varchar(30),
	IN password varchar(30),
	IN name varchar(30),
	IN department varchar(30),
	OUT result smallint)
AS
IF(Exists (Select Username from student Where Username = username)
	OR Exists (Select Username from admin Where Username = username))
	Begin
		Set result = 1;
		RaisError('That username is already taken', 14, 1);
		Return
	End
ELSE IF (Exists (Select UID from admin Where UID = uid))
	Begin
		Set result = 1;
		RaisError('An account already exists for this ID number', 14, 1);
		Return
	End
ELSE
	Begin
		INSERT INTO student
			(UID, Username, Password, Name, Blocked, Permissions, Department)
		VALUES (uid, username, password, name, 0, 1, department);
	End
	
CREATE PROCEDURE UpdateBlocked
	(IN uid int,
	IN blocked int,
	OUT result smallint)
AS
IF(Exists (Select UID from student Where UID = uid))
	Begin
		Update student
		Set Blocked = blocked
		Where UID = uid;
	End
ELSE IF (Exists (Select UID from admin Where UID = uid))
	Begin
		Update admin
		Set Blocked = blocked
		Where UID = uid;
	End
ELSE
	Begin
		Set result = 1;
		RaisError('UID not found', 14, 1);
		Return
	End




/* Sample data is entered here....  */







/*  Done!  */






