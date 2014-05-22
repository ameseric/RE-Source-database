
/*  Database drop/add is not supported at the SQL level for phpmyadmin, so for our use,
    first go into phpmyadmin localhost, then select the desired database, and run these
    SQL commands. Everything is nominal, except that the queries reference no specific
    database, so you need to select it manually via the GUI interface.
    
    NOTE: After running, phpmyadmin might not throw an error OR a success window.
     Instead, it just points out that the DROP TABLE queries failed- BUT the rest
     of the query still worked, so all tables have been created as needed.
 */

Come on, make the changes...

/* Again, can't wipe the database, so wipe every associated table.  */
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS file;
DROP TABLE IF EXISTS class;
DROP TABLE IF EXISTS users;



/* ======== Recreate tables using queries. ================*/

CREATE TABLE `users` (
 `UID` int(8) NOT NULL,
 `Username` varchar(30) NOT NULL,
 `HashPassword` varchar(32) NOT NULL,
 `Name` varchar(30) NOT NULL,
 `Blocked` int(1) NOT NULL,
 `Permissions` int(1) NOT NULL,
 `Department` varchar(30) DEFAULT NULL,
 `Year` int(4),
 `Major` varchar(3),
 PRIMARY KEY (`UID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;




CREATE TABLE `class` (
 `Course_number` varchar(30) NOT NULL,
 `Department` varchar(30) DEFAULT NULL,
 `CName` varchar(50) DEFAULT NULL,
 PRIMARY KEY (`Course_number`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `alter` (
`Timestamp` datetime NOT NULL,
`UID` int(9) NOT NULL,
`Table` varchar(6) NOT NULL,
`Body` varchar(25) NOT NULL,
PRIMARY KEY (`Timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `file` (
 `FID` int(8) NOT NULL AUTO_INCREMENT,
 `Content` mediumblob NOT NULL,
 `Timestamp` int(11) NOT NULL,
 `Type` varchar(8) NOT NULL,
 `Year` varchar(8) NOT NULL,
 `Course_number` varchar(20) NOT NULL,
 `UID` int(11) DEFAULT NULL,
 `Name` varchar(30) NOT NULL,
 `Instructor` varchar(50) NULL,
 PRIMARY KEY (`FID`),
 KEY `UID` (`UID`),
 CONSTRAINT `file_ibfk_1` FOREIGN KEY (`UID`) REFERENCES `users` (`UID`)
) ENGINE=InnoDB AUTO_INCREMENT=60000000 DEFAULT CHARSET=latin1;



CREATE TABLE `comment` (
 `CID` int(8) NOT NULL AUTO_INCREMENT,
 `Body` varchar(255) NOT NULL,
 `Timestamp` datetime DEFAULT NULL,
 `FID` int(8) NOT NULL,
 `UID` int(8) NOT NULL,
 `Reply_to` int(8) DEFAULT NULL,
 PRIMARY KEY (`CID`),
 KEY `FID` (`FID`),
 KEY `UID` (`UID`),
 KEY `Reply_to` (`Reply_to`),
 CONSTRAINT `comment_ibfk_1` FOREIGN KEY (`FID`) REFERENCES `file` (`FID`),
 CONSTRAINT `comment_ibfk_2` FOREIGN KEY (`UID`) REFERENCES `users` (`UID`),
 CONSTRAINT `comment_ibfk_3` FOREIGN KEY (`Reply_to`) REFERENCES `comment` (`CID`)
) ENGINE=InnoDB AUTO_INCREMENT=70000000 DEFAULT CHARSET=latin1;


/*====================== Stored Procedures here. ========================= */


DROP PROCEDURE IF EXISTS CreateUser;
DROP PROCEDURE IF EXISTS UpdateBlocked;
DROP PROCEDURE IF EXISTS UpdatePermissions;
DROP PROCEDURE IF EXISTS CreateComment;
DROP PROCEDURE IF EXISTS UploadFile;
DROP PROCEDURE IF EXISTS DeleteFile;
DROP PROCEDURE IF EXISTS DeleteComment;
DROP PROCEDURE IF EXISTS DeleteUser;


CREATE PROCEDURE CreateUser
    (IN uid_0 int,
    IN username_1 varchar(30),
    IN password_2 varchar(30),
    IN name_3 varchar(30),
    IN department_4 varchar(30),
    IN year_5 int(4),
    IN major_6 varchar(4),
    OUT result smallint
    )
    
MAIN:BEGIN
    IF department_4 = '' THEN
        SET department_4 = NULL;
    END IF;
    
    IF year_5 = '' THEN
        SET year_5 = NULL;
    END IF;
    
    IF major_6 = '' THEN
        SET major_6 = NULL;
    END IF;
    
    IF year_5 > 2020 OR year_5 < 1980 THEN
        SELECT 'Improper Year.';
        LEAVE MAIN;
    END IF;


    IF EXISTS (Select Username FROM users WHERE Username = username_1) THEN
            Set result = 1;
            SELECT 'That username is already taken';
            LEAVE MAIN;
    END IF;

    IF (EXISTS (Select UID from users Where UID = uid_0)) THEN
        Set result = 1;
        SELECT 'An account already exists for this ID number';
        LEAVE MAIN;
    END IF;

    INSERT INTO users (UID, Username, HashPassword, Name, Blocked, Permissions, Department, Year, Major)
    VALUES(uid_0, username_1, MD5(password_2), name_3, 0, 0, department_4, year_5, major_6);

END $$

    
    
    
CREATE PROCEDURE UpdateBlocked
    (IN self_uid int,
    IN target_uid int,
    IN _blocked int,
    OUT result smallint)
MAIN:BEGIN

    IF(Exists (Select UID from users Where UID = target_uid)) AND
                    ( (SELECT Permissions from users Where UID=self_uid) >= 2) THEN
        Update users SET Blocked = _blocked WHERE UID=target_uid;
        LEAVE MAIN;
    END IF;

    Set result = 1;
    SELECT 'UID not found or Permissions inadequate! Please try again.';

END $$



CREATE PROCEDURE UpdatePermissions
    (IN self_uid int,
    IN target_uid int,
    IN new_perm int,
    OUT result smallint)
MAIN:BEGIN

    IF(Exists (Select UID from users Where UID = target_uid)) AND
                    ( (SELECT Permissions from users Where UID=self_uid) >= 2) THEN
            UPDATE users SET Permissions = new_perm WHERE UID = target_uid;
            LEAVE MAIN;
    END IF;

    Set result = 1;
    SELECT 'UID not found or Permissions inadequate! Please try again.';

END $$


//=======================No longer applicable======================

CREATE PROCEDURE UploadFile
    (IN _uid int(9),
     IN _Type varchar(9),
     IN _Year int(4),
     IN _Course_num varchar(20),
     IN _content mediumblob,
     IN _name varchar(32),
     IN _instr varchar(50)
     )
MAIN:BEGIN
    IF (_Type <> 'Exam' AND _Type <> 'Quiz' AND _Type <> 'Homework' AND _Type <> 'Other') THEN
        SELECT 'Improper file type, please try again.';
        LEAVE MAIN;
    END IF;
    
    IF ( (SELECT Blocked FROM users WHERE UID=_uid) = 1) THEN
        SELECT 'User is BLOCKED, not allowed to upload files.';
        LEAVE MAIN;
    END IF;

    IF EXISTS (SELECT UID from users WHERE UID=_uid) /*Check for user existance*/
        THEN
            INSERT INTO file (Timestamp, Type, Year, Course_number, UID, Content, Name, Instructor)
            VALUES(CURRENT_TIMESTAMP, _Type, _Year, _Course_num, _uid, _content, _name, _instr);
            LEAVE MAIN;
    END IF;
    Select 'User does not exist.';
    
END $$


//==========================================================
     

CREATE PROCEDURE CreateComment
    (IN _text varchar(255),
    IN _fid int(9),
    IN _uid int(9),
    IN _comment int(9)
    )
MAIN:BEGIN
    IF _comment = '' THEN
        SET _comment = NULL;
    END IF;
    
    IF ((SELECT Blocked FROM users WHERE UID=_uid) = 1) THEN
        SELECT 'User is blocked- action not allowed.';
        LEAVE MAIN;
    END IF;

    INSERT INTO comment (Body, Timestamp, FID, UID, Reply_to)
    VALUES(_text, CURRENT_TIMESTAMP, _fid, _uid, _comment);

END $$



CREATE PROCEDURE DeleteComment
    (IN _uid int(8),
    IN _cid int(8)
    )
MAIN:BEGIN
    IF ( (SELECT UID FROM comment WHERE CID=_cid) <> _uid) OR ((SELECT Permissions FROM users WHERE UID=_uid) < 2)
        THEN
            SELECT 'You are neither the user who posted this comment, or an admin. Action not allowed.';
            LEAVE MAIN;
    END IF;
    
    IF EXISTS (SELECT CID from comment WHERE CID=_cid) THEN
        DELETE FROM comment WHERE CID=_cid;
        SELECT 'Comment deleted.';
        LEAVE MAIN;
    END IF;
    
    SELECT 'Comment does not exist.';
    
END $$




CREATE PROCEDURE DeleteFile
    (IN _uid int(8),
    IN _fid int(8)
    )
MAIN:BEGIN
    IF ( (SELECT UID FROM file WHERE FID=_fid) <> _uid) OR ((SELECT Permissions FROM users WHERE UID=_uid) < 2)
        THEN
            SELECT 'You are neither the user who posted this file, or an admin. Action not allowed.';
            LEAVE MAIN;
    END IF;
    
    IF EXISTS (SELECT FID from file WHERE FID=_fid) THEN
        DELETE FROM comment WHERE FID=_fid; /* To satisfy any attached comments */
        DELETE FROM file WHERE FID=_fid;
        SELECT 'File deleted';
        LEAVE MAIN;
    END IF;
    
    SELECT 'File does not exist.';
    
END $$


CREATE PROCEDURE DeleteUser
    (IN _uid int(8),
    IN del_uid int(8)
    )
MAIN:BEGIN
    IF ( (_uid <> del_uid) OR (SELECT Permissions FROM users WHERE UID=_uid) < 2)
        THEN
            SELECT 'You are neither the user who posted this file, or an admin. Action not allowed.';
            LEAVE MAIN;
    END IF;
    
    UPDATE comment SET UID=00000000 WHERE UID=del_uid;
    UPDATE file SET UID=00000000 WHERE UID=del_uid;
    DELETE FROM users WHERE UID=del_uid;
    
END $$




/* Sample data is entered here....  */

CALL CreateUser(00000000, 'Nihil', 'Void', 'Nihil', '', '', '', @result);
CALL CreateUser(12345678, 'Admin01', 'god', 'Carl', NULL, NULL, '', @result);
CALL CreateUser(80000010, 'Blocky', 'idiot', 'Joe', '', '', '', @result);
CALL UpdatePermissions(12345678, 2, @result);
CALL UpdateBlocked(80000010, 1, @result);

CALL CreateComment('I AM GOD.', 60000000, 12345678, '');



/*  Done!  */















