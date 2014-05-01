

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




CREATE TABLE `class` (
 `Course_number` varchar(30) NOT NULL,
 `Department` varchar(30) DEFAULT NULL,
 `CName` varchar(50) DEFAULT NULL,
 `Instructor` int(8) NOT NULL,
 PRIMARY KEY (`Course_number`),
 KEY `Instructor` (`Instructor`),
 CONSTRAINT `class_ibfk_1` FOREIGN KEY (`Instructor`) REFERENCES `admin` (`UID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;




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