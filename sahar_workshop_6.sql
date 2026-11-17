--Workshop Tasks
--Part 1: Basic SQL Operations and JOIN Queries



- 1. Create Branches Table
CREATE TABLE Branches (
    branch_id INTEGER PRIMARY KEY AUTOINCREMENT,
    branch_name TEXT NOT NULL,
    address TEXT,
    city TEXT,
    phone TEXT
);

-- 2. Create Genres Table
CREATE TABLE Genres (
    genre_id INTEGER PRIMARY KEY AUTOINCREMENT,
    genre_name TEXT NOT NULL,
    description TEXT
);

-- 3. Create Authors Table
CREATE TABLE Authors (
    author_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    birth_year INTEGER,
    country TEXT
);

-- 4. Create Patrons Table
CREATE TABLE Patrons (
    patron_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    address TEXT,
    city TEXT,
    registration_date TEXT NOT NULL,
    branch_id INTEGER,
    FOREIGN KEY (branch_id) REFERENCES Branches(branch_id) ON DELETE SET NULL
);

-- 5. Create Books Table
CREATE TABLE Books (
    book_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    author_id INTEGER,
    genre_id INTEGER,
    isbn TEXT,
    publication_year INTEGER,
    copies_owned INTEGER DEFAULT 1,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE SET NULL,
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id) ON DELETE SET NULL
);

-- 6. Create Loans Table
PRAGMA foreign_keys = 0;

CREATE TABLE sqlitestudio_temp_table AS SELECT *
                                          FROM Loans;

DROP TABLE Loans;

CREATE TABLE Loans (
    loan_id       INTEGER PRIMARY KEY,
    book_id       INTEGER NOT NULL,
    patron_id     INTEGER NOT NULL,
    branch_id     INTEGER NOT NULL,
    checkout_date TEXT    NOT NULL,
    due_date      TEXT    NOT NULL,
    return_date   TEXT,
    FOREIGN KEY (
        book_id
    )
    REFERENCES Books (book_id) ON DELETE CASCADE,
    FOREIGN KEY (
        patron_id
    )
    REFERENCES Patrons (patron_id) ON DELETE CASCADE,
    FOREIGN KEY (
        branch_id
    )
    REFERENCES Branches (branch_id) ON DELETE CASCADE
);

INSERT INTO Loans (
                      loan_id,
                      book_id,
                      patron_id,
                      branch_id,
                      checkout_date,
                      due_date,
                      return_date
                  )
                  SELECT loan_id,
                         book_id,
                         patron_id,
                         branch_id,
                         checkout_date,
                         due_date,
                         return_date
                    FROM sqlitestudio_temp_table;

DROP TABLE sqlitestudio_temp_table;

PRAGMA foreign_keys = 1;

);
-- for the loan table, i removed the autoincrement from the table in order to upload the loan table.

--WORK SHOP TASKS:
--Part 1: Basic SQL Operations and JOIN Queries

--1.Basic Selection: Retrieve the titles and publication years of all books published after 2000, ordered by publication year (newest first).
-- Answer:

SELECT title, publication_year
FROM Books
WHERE publication_year > 2000
ORDER BY publication_year DESC;

--2. Filtering: Find all books with more than 5 copies owned in the fiction genre (genre_id = 1).
-- ANSWE:
SELECT title,genre_id,copies_owned FROM Books 
WHERE genre_id =1 AND copies_owned >5;

--3.Pattern Matching: List all books whose titles contain the word "History".
--Answer:
SELECT title FROM Books WHERE title LIKE '%HISTORY%';

--4.JOIN Operations: Display loan information (loan_id, checkout_date, due_date) along with patron details (first_name, last_name, email) for all loans made in January 2023.
SELECT
L.loan_id,
L.checkout_date,
L.due_date,
P.first_name,
p.last_name,
p.email
FROM Loans AS L
INNER JOIN Patrons AS P
ON L.patron_id = P.patron_id
WHERE L.checkout_date >= '01-01-20203'
AND L.checkout_date >='02-02-2023';



--5.Multi-table JOIN: Show book details (title, author's full name, genre_name) for each loan, along with the checkout_date and due_date.
--Soultion 1 using INNER JOIN
SELECT 
L.loan_id,
L.checkout_date,
L.due_date,
G.genre_name,
A.first_name AS Author_Name,
A.last_name AS Author_lastname,
B.title
FROM Loans AS L
INNER JOIN Books AS B
ON L.book_id= B.book_id
INNER JOIN Authors AS A
ON B.author_id= A.author_id
INNER JOIN Genres AS G 
ON B.genre_id= G.genre_id

-- solution 2 using left JOIN 
SELECT
    L.loan_id,
    L.checkout_date,
    L.due_date,
    G.genre_name,
    A.first_name AS Author_Name,
    A.last_name AS Author_Lastname,
    B.title
FROM Loans AS L
LEFT JOIN Books AS B
    ON L.book_id = B.book_id
LEFT JOIN Authors AS A
    ON B.author_id = A.author_id
LEFT JOIN Genres AS G
    ON B.genre_id = G.genre_id;

--6.Self JOIN: Find pairs of patrons who live in the same city. Show both patrons' names and their city.
    P1.first_name AS Patron_first_name_1,
    P1.last_name AS Patron_last_name_1,
    P2.first_name AS Patron_first_name_2,
    P2.last_name AS Patron_last_name_2,
    P1.city
FROM Patrons AS P1
INNER JOIN Patrons AS P2
    ON P1.city = P2.city
	
	-- 7. Find all fiction books (genre_id = 1) that have been borrowed, along with the patron name and the branch where they were borrowed from.
	--Solution 1Using INNER JOIN
	SELECT
    B.title,
    P.first_name AS patron_name,
    P.last_name AS patron_last_name,
    BR.branch_name
FROM Loans AS L
INNER JOIN Books AS B
    ON L.book_id = B.book_id
INNER JOIN Patrons AS P
    ON L.patron_id = P.patron_id
INNER JOIN Branches AS BR
    ON L.branch_id = BR.branch_id
WHERE B.genre_id = 1;

-- Solution 2 Using Left join 
SELECT
    B.title,
    P.first_name AS patron_name,
    P.last_name AS patron_last_name,
    BR.branch_name
FROM Books AS B
LEFT JOIN Loans AS L
    ON B.book_id = L.book_id
LEFT JOIN Patrons AS P
    ON L.patron_id = P.patron_id
LEFT JOIN Branches AS BR
    ON L.branch_id = BR.branch_id
WHERE B.genre_id = 1;


--Part 2: Aggregation and GROUP BY Operations
--8. COUNT aggregation: Count the number of books in each genre category.
-- There are 8 genere id:

SELECT
COUNT(genre_id) AS Total_Number_of_Genres
FROM Genres;

SELECT
    G.genre_id,
    G.genre_name,
    COUNT(B.book_id) AS total_number_of_books
FROM Genres AS G
INNER JOIN Books AS B
    ON B.genre_id = G.genre_id
GROUP BY G.genre_id, G.genre_name;
-- Using LEFT JOIN

SELECT
    G.genre_id,
    G.genre_name,
    COUNT(B.book_id) AS total_number_of_books
FROM Genres AS G
LEFT JOIN Books AS B
    ON B.genre_id = G.genre_id
GROUP BY G.genre_id, G.genre_name;

--9.Calculate the average, minimum, and maximum loan duration (days between checkout and return) for each library branch. Include only returned books.


SELECT
    BR.branch_name,
    AVG(return_date - checkout_date) AS average_loan_duration,
    MIN(return_date - checkout_date) AS minimum_loan_duration,
    MAX(return_date - checkout_date) AS maximum_loan_duration
FROM Loans AS L
INNER JOIN Branches AS BR
    ON L.branch_id = BR.branch_id
WHERE L.return_date IS NOT NULL
GROUP BY BR.branch_name;

-- left JOIN


SELECT
    BR.branch_name,
    AVG(return_date - checkout_date) AS average_loan_duration,
    MIN(return_date - checkout_date) AS minimum_loan_duration,
    MAX(return_date - checkout_date) AS maximum_loan_duration
FROM Loans AS L
LEFT JOIN Branches AS BR
    ON L.branch_id = BR.branch_id
WHERE L.return_date IS NOT NULL
GROUP BY BR.branch_name;

--10.Find patrons with overdue books (due_date < CURRENT_DATE and return_date = ' '), along with the count of overdue books they have.
SELECT
    P.patron_id,
    P.first_name,
    P.last_name,
    COUNT(L.loan_id) AS overdue_book_count
FROM Loans AS L
INNER JOIN Patrons AS P
    ON L.patron_id = P.patron_id
WHERE L.due_date < CURRENT_DATE
    AND (L.return_date IS NULL)
GROUP BY
    P.patron_id,
    P.first_name,
    P.last_name
ORDER BY overdue_book_count DESC;

--11. Analyze monthly borrowing trends. Show the year, month, number of loans, and number of unique patrons for each month.
-- i got help from google for this part. i did not know strftime

SELECT
    strftime('%Y', checkout_date) AS loan_year,
    strftime('%m', checkout_date) AS loan_month,
    COUNT(loan_id) AS number_of_loans,
    COUNT(DISTINCT patron_id) AS unique_patrons
FROM Loans
GROUP BY
    strftime('%Y', checkout_date),
    strftime('%m', checkout_date)
ORDER BY
    loan_year,
    loan_month;
	
	--BONUS: Write a query to create a simple data dictionary for the library database schema, listing table names, column names, data types, and whether they are primary keys.
	-- i couldnt run the queries as a unique query. I do not know how to join them
    
SELECT 'Loans' AS table_name,
       'loan_id' AS column_name,
       'INTEGER' AS data_type,
       'Yes' AS primary_key;
	   
	   SELECT 'Loans' AS table_name,
       'book_id' AS column_name,
       'INTEGER' AS data_type,
       'No' AS primary_key;
	   
	   SELECT 'Loans' AS table_name,
       'patron_id' AS column_name,
       'INTEGER' AS data_type,
       'No' AS primary_key;
	   
	   SELECT 'Loans' AS table_name,
       'branch_id' AS column_name,
       'INTEGER' AS data_type,
       'No' AS primary_key;
	   
	   SELECT 'Loans' AS table_name,
       'checkout_date' AS column_name,
       'TEXT' AS data_type,
       'No' AS primary_key;
	   
	   SELECT 'Loans' AS table_name,
       'due_date' AS column_name,
       'TEXT' AS data_type,
       'No' AS primary_key;
	   
	   SELECT 'Loans' AS table_name,
       'return_date' AS column_name,
       'TEXT' AS data_type,
       'No' AS primary_key;
	   

--Discussion Questions
--In our library database, we track which branch a book was borrowed from, but books can exist at multiple branches. How would you modify the schema to track the actual inventory at each branch?
-- I modify the schema by adding a new inventory table like this that contains copies owned at each branch. 
--
CREATE TABLE Inventory (
    inventory_id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id      INTEGER NOT NULL
                         REFERENCES Books (book_id),
    branch_id    INTEGER NOT NULL
                         REFERENCES Branches (branch_id),
    copies_owned INTEGER NOT NULL
                         REFERENCES Books (copies_owned) 
);

--Based on the provided data model, what business questions could library administrators answer using SQL queries that we haven't covered in our exercise?
--•	Which books are borrowed most frequently?


SELECT
    B.book_id,
    B.title,
    COUNT(L.loan_id) AS times_borrowed
FROM Books AS B
INNER JOIN Loans AS L
    ON B.book_id = L.book_id
GROUP BY
    B.book_id,
    B.title
ORDER BY
    times_borrowed DESC;
	-- Which author is most popular among Patrons
	
	
SELECT
    A.author_id,
    A.first_name,
    A.last_name,
    COUNT(L.loan_id) AS total_borrows
FROM Authors AS A
INNER JOIN Books AS B
    ON A.author_id = B.author_id
INNER JOIN Loans AS L
    ON B.book_id = L.book_id
GROUP BY
    A.author_id,
    A.first_name,
    A.last_name
ORDER BY
    total_borrows DESC;
	-- How would you extend this schema to track additional patron interactions, such as reserved books, late fees, or participation in library programs?
	-- add new tables for reservation, late fees, and participations 


CREATE TABLE Reservations (
    reservation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    patron_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    reservation_date TEXT NOT NULL,
    status TEXT NOT NULL,
    FOREIGN KEY (patron_id) REFERENCES Patrons(patron_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);



CREATE TABLE LateFees (
    fee_charge_id INTEGER PRIMARY KEY AUTOINCREMENT,
    loan_id INTEGER NOT NULL,
    patron_id INTEGER NOT NULL,
    amount DECIMAL(5,2) NOT NULL,
    fee_date TEXT NOT NULL,
    paid_status TEXT NOT NULL,
    FOREIGN KEY (loan_id) REFERENCES Loans(loan_id),
    FOREIGN KEY (patron_id) REFERENCES Patrons(patron_id)
);
/*
A. ON DELETE SET NULL
What it does: When a record in the parent table is deleted, the foreign key column in the child table is automatically set to NULL.
Real-world meaning: If you delete an author (e.g., Ernest Hemingway) from the Authors table, the books he wrote remain in the Books table, but their author_id field becomes NULL ("Author Unknown").
Why use it? You do not want to delete physical library books from your inventory just because an author record was removed from the database.

B. ON DELETE CASCADE
What it does: When a record in the parent table is deleted, all matching child records in the child table are automatically deleted too (the deletion "cascades" down).
Real-world meaning: If a library branch is permanently closed and deleted from the Branches table, or a loan record is deleted, all associated loan activity attached specifically to that entry is automatically cleaned up and removed.
Why use it? It prevents orphaned records (e.g., a loan entry referring to a patron ID that no longer exists in your database).
*/