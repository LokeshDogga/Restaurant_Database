use World;

SELECT * FROM country;
SELECT * FROM countrylanguage
WHERE CountryCode = 'IND';

INSERT into countrylanguage
values ('IND','AccLanguage','F','0.1'); 

UPDATE countrylanguage
set Percentage = 0.2
where Language = 'AccLanguage'  /*strings are in quotes, but not numbers*/
and CountryCode = 'IND';

DELETE from COUNTRYlanguage   /* table names are case -insensitive*/
where Language = 'AccLanguage'
and CountryCode = 'IND';

/*create Table*/
Drop table if exists `TestDemo`;
CREATE TABLE `TestDemo` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CountryCode` char(3) NOT NULL DEFAULT '',
  `CityId` int NOT NULL,
  `col2` varchar(30) NOT NULL DEFAULT '',
  `col3` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),    
	#CONSTRAINT `Foreignkey1` FOREIGN KEY (`CountryCode`) REFERENCES `country` (`Code`),
    CONSTRAINT `Foreignkey2` FOREIGN KEY (`CityId`) REFERENCES `city` (`ID`)				/*Foreign Keys*/
);
#DEFAULT CHARSET=latin1;  		#know why this is required?


select * from TestDemo;

INSERT INTO testdemo
(`CountryCode`,`CityId`,`col2`)
VALUES ('IND',1,'somevalue');

INSERT INTO testdemo
(`CountryCode`,`CityId`,`col2`)
VALUES ('PAK',22,'someOthervalue');

INSERT INTO testdemo
(`CountryCode`,`CityId`,`col3`)
VALUES ('AUS',222,333);

INSERT INTO testdemo			
(`CountryCode`,`CityId`,`col3`)		
VALUES ('IND',22222222,444);		/*Foreign key contraint fails*/

select * from TestDemo;


/*different selects*/
SELECT CountryCode, Language 
FROM countrylanguage
WHERE CountryCode = 'IND';
#Order By Language desc;

SELECT DISTINCT CountryCode
FROM countrylanguage;
#Limit 10;

SELECT COUNT(DISTINCT CountryCode) 
FROM countrylanguage;

/*sub query*/
Select * from countrylanguage
where CountryCode in 
(
	select Code from country
    where Name = 'India'
);

/*where cause*/
SELECT * FROM countrylanguage
WHERE CountryCode = 'IND'
AND Percentage >= 8.2;		/*no quotes for numeric values*/

SELECT * FROM countrylanguage
WHERE CountryCode = 'IND'
OR CountryCode = 'USA';

SELECT * FROM countrylanguage
WHERE NOT CountryCode = 'IND';
#same as
SELECT * FROM countrylanguage
WHERE CountryCode <> 'IND';

SELECT * from Country
Where IndepYear = '1947';

SELECT * from Country
Where IndepYear is null;


/*GROUPBY EX: https://youtu.be/bziXLSplVFc?t=3m20s*/

/*group by*/
SELECT language
FROM CountryLanguage
WHERE Percentage > 10   /*percentage is > 10% in each country*/
GROUP by language
HAVING count(language) > 5; /* same language spoken by more than 5 countries*/


/*check if true:*/
SELECT *
FROM CountryLanguage
WHERE Percentage > 10 
AND language = 'EnglisH';

/*Alias, more when we learn joins */
SELECT CountryCode as 'CCode', CL.Language
FROM countrylanguage as CL
WHERE CL.CountryCode = 'IND';

/*views*/
CREATE VIEW IndiaCountryLanguage AS
SELECT *
FROM countrylanguage
WHERE CountryCode = 'IND';

SELECT * 
FROM IndiaCountryLanguage
where percentage > 10;

/*is same as*/
SELECT *
FROM countrylanguage
WHERE CountryCode = 'IND'
AND percentage > 10;


/*DDLs*/
Drop view IndiaCountryLanguage;
Drop table testdemo;

/*joins*/
Select CL.Name as CityName,C.Name as 'IsCapitalOf'  /*look at alias used*/
from city AS CL
inner join country AS C									/*look at alias used*/
ON C.Capital = CL.ID;
#where can be used here.

Select CL.Name as CityName,C.Name as 'IsCapitalOf'  /*look at alias used*/
from city AS CL
left outer join country AS C							/*look at alias used*/
ON C.Capital = CL.ID;


Select CL.Name as CityName,C.Name as 'IsCapitalOf'  /*look at alias used*/
from city AS CL
right outer join country AS C							/*look at alias used*/
ON C.Capital = CL.ID;


/*Procedures*/
/*NOTE: Delimiters other than the default  ; are typically used when defining functions, stored procedures, and triggers 
wherein you must define multiple statements. You define a different delimiter like $$ which is used to define the end 
of the entire procedure, but inside it, individual statements are each terminated by ;. 
That way, when the code is run in the mysql client, the client can tell where the entire procedure ends 
and execute it as a unit rather than executing the individual statements inside.*/
DELIMITER $$
CREATE PROCEDURE `DemoProcedure` (IN cityid int)
BEGIN
	select * from city where id = cityid;
END$$
DELIMITER ;

/*calling sp*/
call DemoProcedure(5);

DROP procedure IF EXISTS `DemoProcedure`;
/*SP Params IN , OUT*/
DELIMITER $$
CREATE procedure DemoProcedure (IN cityid int,out populationcount int)
BEGIN
	DECLARE tempvar int;
	select population into tempvar from city where id = cityid;    
    set populationcount = tempvar;
END$$
DELIMITER ;


SET @cityid = 5,@popcount=0; /*query params, different from SP Params*/
call DemoProcedure(@cityid,@popcount);
SELECT @popcount as 'populationcount';


/*SP Params INTOUT*/
DROP procedure IF EXISTS `DemoProcedure`;
DELIMITER $$
CREATE procedure DemoProcedure (INOUT param1 int)
BEGIN
	DECLARE tempvar int;
	select population into tempvar from city where id = param1;    
    set param1 = tempvar;
END$$
DELIMITER ;

/*calling procedure*/
SET @tempvar = 5;
call DemoProcedure(@tempvar);
SELECT @tempvar;

/*functions*/
SELECT NOW();

SELECT Continent, SUM(SurfaceArea)
FROM country
GROUP by Continent;

/*create functions*/
DROP function IF EXISTS `GNPDiff`;
DELIMITER $$
CREATE FUNCTION GNPDiff(GNP FLOAT, GNPOLD FLOAT) 
RETURNS DECIMAL(9,2)
BEGIN
  DECLARE diff DECIMAL(9,2);
  SET diff = ifnull(GNP,0)-ifnull(GNPOLD,0);	/*function ifnull used. system func.*/
  RETURN diff;
END$$
DELIMITER ;

#calling functions
SELECT GNPDiff(25,20);
SELECT GNP,GNPOld,GNPDiff(GNP,GNPOld) from country;
SELECT * from country
where GNPDiff(GNP,GNPOld) > 50;

/*transactions*/
SHOW VARIABLES LIKE 'AUTOCOMMIT'; #look at LIKE here
SHOW VARIABLES LIKE 'transaction_isolation';

/*start transaction, commit, rollback*/
DROP PROCEDURE IF EXISTS `CreateAndInsertTestData`;
Drop table IF exists TestDemo;
DELIMITER $$ 
CREATE PROCEDURE CreateAndInsertTestData()
BEGIN  
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	 BEGIN
		  select 'exception occured';
          ROLLBACK;
          SET autocommit=1;	#set this only after rollback	  
	 END;
     
	#creating tables within procedures
    CREATE TABLE if not exists `TestDemo`  (
		  `ID` int(11) NOT NULL,
		  `Col1` varchar(35) NOT NULL DEFAULT '',
		  PRIMARY KEY (`ID`)
		);	
        
    SET autocommit=0;
	START TRANSACTION;		 	 
		INSERT INTO TestDemo(ID,Col1)  VALUES(1,"apple");
		INSERT INTO TestDemo(ID,Col1)   VALUES(2,"mango");		   
		INSERT INTO TestDemo(ID,Col1)   VALUES(1,"orange");	 
	COMMIT;  
    SET autocommit=1;
END$$
DELIMITER ;


call CreateAndInsertTestData();
SELECT * from TestDemo;
Drop table TestDemo;
