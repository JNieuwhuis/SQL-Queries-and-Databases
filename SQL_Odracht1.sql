USE Bank;

/******1.3.1******/
/* Alle cliënten binnen de postcode range van 3000-4000 met een actieve leningen van meer dan 2500 euro. */

SELECT * 
FROM Client

WHERE AddressID IN (
	SELECT ID
	FROM Address
	WHERE CAST((SUBSTRING (ZipCode, 1, 4)) AS INT) 
		BETWEEN 3000 AND 4000)
		/*ZipCode like 3%*/
AND ID IN (
	SELECT ClientID
	FROM Loan
	WHERE Amount > 2500
	AND DateClosed IS NULL
	);

	
/******1.3.2******/
/* Lijst van transacties behorende bij een betaling voor een actieve lening gegroepeerd per cliënt. */

--(FIRST VERSION)
SELECT Loan.ID, Loan.ClientID, Pay.Amount, Pay.Description, Pay.Date
	FROM Loan AS Loan FULL JOIN Payment as Pay
	ON Loan.ID = Pay.LoanID

WHERE DateClosed IS NULL
	AND Pay.Amount IS NOT NULL
ORDER BY ClientID;

--(SECOND VERSION)
SELECT Loan.ClientID, Clie.FirstName, Clie.MiddleName, Clie.FamilyName,
			Loan.ID AS LoanID, Pay.Amount, Pay.Description, Pay.Date
	FROM Client AS Clie
INNER JOIN(
	SELECT ID, ClientID
	FROM Loan
	WHERE DateClosed IS NULL)
		AS Loan 
		ON Clie.ID = Loan.ClientID
INNER JOIN(
	SELECT LoanID, Amount, Date, Description
	FROM Payment
	WHERE Amount IS NOT NULL)
	AS Pay
	ON Loan.ID = Pay.LoanID
ORDER BY ClientID;

--(THIRD VERSION)
SELECT Loan.ClientID, Clie.FirstName, Clie.MiddleName, Clie.FamilyName,
		 Loan.ID AS LoanID, AccT.Amount, AccT.Description, AccT.Date
FROM Client AS Clie
/*LOAN*/
INNER JOIN( 
	SELECT ID, ClientID
	FROM Loan
	WHERE DateClosed IS NULL)
		AS Loan 
		ON Clie.ID = Loan.ClientID
/*ACCOUNT*/
INNER JOIN(
	SELECT ID, ClientID
	FROM Account
	)
	AS Acc
	ON Acc.ClientID = Clie.ID
/*ACCOUNTTRANSACTION*/
INNER JOIN(
	SELECT AccountID, Amount, Date, Description
	FROM AccountTransaction
	WHERE Amount IS NOT NULL
	AND Code = 'LP')
	AS AccT
	ON Acc.ID = AccT.AccountID
WHERE Loan.ID IN(
	SELECT LoanID
	FROM Payment
	WHERE AccT.Date = Date
	)
ORDER BY Loan.ClientID;

--(VERSION ROBBERT)

SELECT L.ClientID, SUM(P.Amount)
FROM Client AS C, Loan AS L, Payment AS P
	WHERE C.ID = L.ClientID
	AND L.ID = P.LoanID
GROUP BY L.ClientID

/******1.3.3******/
/* Check voor cliënt Tieneke Van Brabandt of het totaal van de transacties van haar rekening courant klopt met het saldo van haar rekening courant. */
	
SELECT Clie.ID, Clie.FirstName, Clie.MiddleName, Clie.FamilyName, 
			Acc.Balance, Trans.SumAmount
FROM Client AS Clie 
INNER JOIN(
	SELECT Balance, ClientID, ID, Type
	FROM Account
	WHERE Type = 'C')  
	AS Acc 
	ON Clie.ID = Acc.ClientID
INNER JOIN(
	SELECT AccountID, 
	SUM(CASE WHEN Type = 'C' THEN Amount ELSE -Amount END) 
	AS SumAmount
	FROM AccountTransaction
	GROUP BY AccountID)
	AS Trans 
	ON Acc.ID = AccountID
WHERE Clie.Firstname LIKE '%eneke%'
	AND Clie.Familyname LIKE '%Braban%';
	
	
/******1.3.4******/
/*De som van alle betalingen voor een actieve lening gegroepeerd per cliënt. Deze query kan op twee manieren uitgevoerd worden, maak ze alle twee. */

--(OPTION 1)
SELECT Loan.ClientID, Clie.FirstName, Clie.MiddleName, Clie.FamilyName,
			 Loan.TotalLoanAmount, Pay.SumAmountPayments
	FROM Client AS Clie
INNER JOIN(
	SELECT ID, ClientID, Amount AS TotalLoanAmount
	FROM Loan
	WHERE DateClosed IS NULL)
		AS Loan 
		ON Clie.ID = Loan.ClientID
INNER JOIN(
	SELECT LoanID, SUM(Amount) AS SumAmountPayments
	FROM Payment
	WHERE Amount IS NOT NULL
	GROUP BY LoanID)
	AS Pay
	ON Loan.ID = Pay.LoanID
ORDER BY ClientID;

--(OPTION 2)
SELECT Loan.ClientID, Clie.FirstName, Clie.MiddleName, Clie.FamilyName,
			 Loan.TotalLoanAmount, AccT.SumAmountPayments
FROM Client AS Clie
/*LOAN*/
INNER JOIN( 
	SELECT ID, ClientID, Amount AS TotalLoanAmount
	FROM Loan
	WHERE DateClosed IS NULL)
		AS Loan 
		ON Clie.ID = Loan.ClientID
/*ACCOUNT*/
INNER JOIN(
	SELECT ID, ClientID
	FROM Account
	)
	AS Acc
	ON Acc.ClientID = Clie.ID
/*ACCOUNTTRANSACTION*/
INNER JOIN(
	SELECT AccountID, SUM(Amount) AS SumAmountPayments
	FROM AccountTransaction
	WHERE Amount IS NOT NULL
	AND Code = 'LP'
	AND AccountID IN(
		SELECT AccountID
		FROM Loan
		WHERE ID IN (
			SELECT LoanID
			FROM Payment
			WHERE Payment.Date = AccountTransaction.Date
			))
	GROUP BY AccountID)
	AS AccT
	ON Acc.ID = AccT.AccountID
ORDER BY Loan.ClientID;

