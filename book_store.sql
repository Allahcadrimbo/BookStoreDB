--Authors: Grant Mitchell and Dan Anderson

--------Customer of the Bookstore--------------------
CREATE TABLE customerbook (
    email     VARCHAR(32),
    name      VARCHAR(32) NOT NULL,
    address   VARCHAR(32),
    cphone    NUMERIC(10,0),
    PRIMARY KEY ( email )
);

INSERT INTO customerbook VALUES (
    'j@gmail.com',
    'j',
    'west coast ave',
    6513332323
);

INSERT INTO customerbook VALUES (
    'a@gmail.com',
    'a',
    'west coast ave',
    6513332323
);

INSERT INTO customerbook VALUES (
    'b@gmail.com',
    'b',
    'west coast ave',
    6513332323
);

INSERT INTO customerbook VALUES (
    'c@gmail.com',
    'c',
    'west coast ave',
    6513332323
);

INSERT INTO customerbook VALUES (
    'd@gmail.com',
    'd',
    'west coast ave',
    6513332323
);

INSERT INTO customerbook VALUES (
    'e@gmail.com',
    'e',
    'west coast ave',
    6513332323
);

-----------------Publisher------------------------------------

CREATE TABLE publisher (
    pname     VARCHAR(32),
    address   VARCHAR(32),
    PRIMARY KEY ( name )
);

INSERT INTO publisher VALUES (
    'publisher',
    'duluth'
);

-----------------Publisher Phones------------------------------------

CREATE TABLE pphones (
    name      VARCHAR(32),
    pnumber   NUMERIC(10,0),
    PRIMARY KEY ( name,
                  pnumber ),
    FOREIGN KEY ( name )
        REFERENCES publisher
);

INSERT INTO pphones VALUES (
    'publisher',
    6512222222
);

-----------------Book------------------------------------

CREATE TABLE book (
    bookisbn           NUMERIC(13,0),
    title              VARCHAR(32) NOT NULL UNIQUE,
    publication_year   INT,
    price              NUMERIC(5,2) NOT NULL,
    publisher_name     VARCHAR(32),
    PRIMARY KEY ( bookisbn ),
    FOREIGN KEY ( publisher_name )
        REFERENCES publisher,
    CHECK ( publication_year >= 0 )
);

INSERT INTO book VALUES (
    0000000000000,
    'book1',
    1997,
    2.52,
    'publisher'
);

INSERT INTO book VALUES (
    0000000000011,
    'book2',
    1993,
    12.52,
    'publisher'
);

INSERT INTO book VALUES (
    0000000000001,
    'book3',
    1987,
    21.52,
    'publisher'
);

INSERT INTO book VALUES (
    0000000000111,
    'book4',
    1987,
    21.52,
    'publisher'
);

INSERT INTO book VALUES (
    0000000001111,
    'book5',
    1987,
    21.52,
    'publisher'
);

-----------------Customer's Shopping Cart------------------------------------

CREATE TABLE shopping_cart (
    email           VARCHAR(32),
    bookisbn        NUMERIC(13,0),
    number_copies   INT,
    PRIMARY KEY ( email,
                  bookisbn ),
    FOREIGN KEY ( email )
        REFERENCES customerbook,
    FOREIGN KEY ( bookisbn )
        REFERENCES book,
    CHECK ( number_copies > 0 )
);

INSERT INTO shopping_cart VALUES (
    'j@gmail.com',
    0000000000000,
    1
);

INSERT INTO shopping_cart VALUES (
    'j@gmail.com',
    0000000000011,
    1
);

INSERT INTO shopping_cart VALUES (
    'a@gmail.com',
    0000000000000,
    1
);

INSERT INTO shopping_cart VALUES (
    'b@gmail.com',
    0000000000000,
    1
);

INSERT INTO shopping_cart VALUES (
    'c@gmail.com',
    0000000000001,
    1
);

INSERT INTO shopping_cart VALUES (
    'd@gmail.com',
    0000000000001,
    1
);

INSERT INTO shopping_cart VALUES (
    'e@gmail.com',
    0000000000011,
    1
);

INSERT INTO shopping_cart VALUES (
    'e@gmail.com',
    0000000000111,
    1
);

-----------------Book Authors------------------------------------

CREATE TABLE book_author (
    name      VARCHAR(32),
    address   VARCHAR(32),
    PRIMARY KEY ( name )
);

INSERT INTO book_author VALUES (
    'john',
    'east coast ave'
);

INSERT INTO book_author VALUES (
    'jim',
    'east coast st'
);

INSERT INTO book_author VALUES (
    'jake',
    'east coast lake'
);

-----------------Authors------------------------------------

CREATE TABLE authors (
    bookisbn   NUMERIC(13,0),
    name       VARCHAR(32),
    PRIMARY KEY ( bookisbn,
                  name ),
    FOREIGN KEY ( bookisbn )
        REFERENCES book,
    FOREIGN KEY ( name )
        REFERENCES book_author
);

INSERT INTO authors VALUES (
    0000000000000,
    'john'
);

INSERT INTO authors VALUES (
    0000000000011,
    'jim'
);

INSERT INTO authors VALUES (
    0000000000001,
    'jake'
);

-----------------Warehouse------------------------------------

CREATE TABLE warehouse (
    code      NUMERIC(5,0),
    address   VARCHAR(32),
    PRIMARY KEY ( code )
);

INSERT INTO warehouse VALUES (
    11111,
    'the hills'
);

INSERT INTO warehouse VALUES (
    11110,
    'the hills 2'
);

INSERT INTO warehouse VALUES (
    11100,
    'the hills 3'
);

-----------------Warehouse Phones------------------------------------

CREATE TABLE wphones (
    code      NUMERIC(5,0),
    wnumber   NUMERIC(10,0),
    PRIMARY KEY ( code,
                  wnumber ),
    FOREIGN KEY ( code )
        REFERENCES warehouse
);

INSERT INTO wphones VALUES (
    11111,
    6511111111
);

INSERT INTO wphones VALUES (
    11110,
    6511111111
);

INSERT INTO wphones VALUES (
    11100,
    6511111111
);

-----------------Books in a warehouse------------------------------------

CREATE TABLE warehouse_books (
    code            NUMERIC(5,0),
    bookisbn        NUMERIC(13,0),
    number_copies   INT,
    PRIMARY KEY ( code,
                  bookisbn ),
    FOREIGN KEY ( code )
        REFERENCES warehouse,
    FOREIGN KEY ( bookisbn )
        REFERENCES book,
    CHECK ( number_copies >= 0 )
);

INSERT INTO warehouse_books VALUES (
    11111,
    0000000000000,
    5
);

INSERT INTO warehouse_books VALUES (
    11110,
    0000000000000,
    2
);

INSERT INTO warehouse_books VALUES (
    11100,
    0000000000001,
    2
);

INSERT INTO warehouse_books VALUES (
    11111,
    0000000000011,
    0
);

INSERT INTO warehouse_books VALUES (
    11110,
    0000000000011,
    0
);

INSERT INTO warehouse_books VALUES (
    11111,
    0000000001111,
    0
);

INSERT INTO warehouse_books VALUES (
    11110,
    0000000001111,
    0
);

INSERT INTO warehouse_books VALUES (
    11100,
    0000000000011,
    1
);


--------------Query 1 Function---------------------
--Returns a Cursor with a column of names and emails. These contents are the customers who have 
-- some book specified by bookTitle in their shopping cart.

CREATE OR REPLACE FUNCTION findemailname (
    booktitle VARCHAR
) RETURN SYS_REFCURSOR AS
    myc   SYS_REFCURSOR;
BEGIN
    OPEN myc FOR SELECT
                     s.email,
                     c.name --Returns the email and name of a customer if the ISBN from the subquery is in their shopping cart
                 FROM
                     shopping_cart s,
                     customerbook c
                 WHERE
                     s.email = c.email
                     AND s.bookisbn IN (
                         SELECT
                             bookisbn --Returns the ISBN of the book specified by the user
                         FROM
                             book b
                         WHERE
                             b.title = booktitle
                     );

    return(myc);
    CLOSE myc;
END findemailname;
        
-------------Query 2 Function---------------
--Returns a cursor with a column of book titles. These books are books that are out of stock in all warehouses.

CREATE OR REPLACE FUNCTION findoutofstock RETURN SYS_REFCURSOR AS
    myc   SYS_REFCURSOR;
BEGIN
    OPEN myc FOR SELECT
                     k.title --Gets the title of the book if that books ISBN is returned in the subquery
                 FROM
                     book k
                 WHERE
                     k.bookisbn IN (
                         SELECT
                             b.bookisbn  --Gets all of the ISBN where the sum of its copies from all warehouses is 0
                         FROM
                             warehouse_books b
                         GROUP BY
                             b.bookisbn
                         HAVING
                             SUM(b.number_copies) < 1
                     );

    return(myc);
    CLOSE myc;
END findoutofstock;   
                                                 
-------------------------INDEXES------------------------------------------------------------------------

--Created a standard b-tree index on the bookISBN and number_copies columns from the warehouse_books table.
--The reasoning behind this decicsion was because these two columns are queried often.

CREATE INDEX warehousebooks ON
    warehouse_books (
        bookisbn,
        number_copies
    )
        COMPUTE STATISTICS;
