#### Schemas

CREATE TABLE artists
(
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks
(
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales
(
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists
    (artist_id, name, country, birth_year)
VALUES
    (1, 'Vincent van Gogh', 'Netherlands', 1853),
    (2, 'Pablo Picasso', 'Spain', 1881),
    (3, 'Leonardo da Vinci', 'Italy', 1452),
    (4, 'Claude Monet', 'France', 1840),
    (5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks
    (artwork_id, title, artist_id, genre, price)
VALUES
    (1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
    (2, 'Guernica', 2, 'Cubism', 2000000.00),
    (3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
    (4, 'Water Lilies', 4, 'Impressionism', 500000.00),
    (5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales
    (sale_id, artwork_id, sale_date, quantity, total_amount)
VALUES
    (1, 1, '2024-01-15', 1, 1000000.00),
    (2, 2, '2024-02-10', 1, 2000000.00),
    (3, 3, '2024-03-05', 1, 3000000.00),
    (4, 4, '2024-04-20', 2, 1000000.00);


--- Section 1: 1 mark each

--1. Write a query to display the artist names in uppercase.
select toUpperCase(name)
from artists

--2. Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.

select top(2)
    artworks.artwork_id, title, genre, total_amount
from artworks
    join sales
    on artworks.artwork_id=sales.artwork_id
order by price desc;

--3. Write a query to find the total amount of sales for the artwork 'Mona Lisa'.
select total_amount
from artworks
    join sales
    on artworks.artwork_id=sales.artwork_id
where title='Mona Lisa'


--4. Write a query to extract the year from the sale date of 'Guernica'.
select year(sale_date)
from artworks
    join sales
    on artworks.artwork_id=sales.artwork_id
where title='Guernica'

--### Section 2: 2 marks each

--5. Write a query to find the artworks that have the highest sale total for each genre.

With
    SaleTotal_CTE
    AS
    (
        select title, genre, total_amount,
            rank() over (partition by genre order by total_amount desc) AS Ranking
        from artworks
            join sales
            on artworks.artwork_id=sales.artwork_id
        Group by genre,title,total_amount
    )


select *
from SaleTotal_CTE
where ranking=1;

--6. Write a query to rank artists by their total sales amount and display the top 3 artists.

select top(3)
    name , total_amount
from artists
    join artworks
    on artists.artist_id=artworks.artwork_id
    join sales
    on artworks.artwork_id=sales.artwork_id
order by total_amount desc

--7. Write a query to display artists who have artworks in multiple genres.

select name
from artists
where  Exists (select artist_id, genre
from artworks
group by artist_id,genre
having  count(distinct genre)>1)

--8. Write a query to find the average price of artworks for each artist.

select a.artist_id, name , avg(price)
from artists a
    join artworks
    on a.artist_id=artworks.artwork_id
group by a.artist_id,name

--9. Write a query to create a non-clustered index on the `sales` table to improve query performance for queries filtering by `artwork_id`.
Create Nonclustered idx_sales_artworkid on sales
(artwork_id);

--10. Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.

select name
from artists
where artist_id in (select artist_id
from artworks
where artwork_id in (select artwork_id
from sales
group by artwork_id
having sum(quantity)>(select avg(quantity)
from sales )))

--11. Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.
    select "name"
    from artists
    where artist_id in (select artist_id
    from artworks
    where genre='Cubism')
Intersect
    select "name"
    from artists
    where artist_id in (select artist_id
    from artworks
    where genre='Surrealism')

--12. Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.
select *
from artists a
where birth_year<(select avg(birth_year)
from artists b
where  a.country=b.country
group by country)

--13. Write a query to find the artworks that have been sold in both January and February 2024.
    select *
    from artworks
    where artwork_id in (select artwork_id
    from sales
    where month(sale_date)=01 and year(sale_date)=2024)
Intersect
    select *
    from artworks
    where artwork_id in (select artwork_id
    from sales
    where month(sale_date)=02 and year(sale_date)=2024)

--14. Write a query to calculate the price of 'Starry Night' plus 10% tax.

select price, price/10 As tax, price + (price/10) As total
from artworks
where title='Starry Night'

--15. Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.
select *
from artists
where artist_id in(select artist_id
from artworks
group by artist_id
having avg(price)> ALL (select price
from artworks ))

--### Section 3: 3 Marks Questions

--16. Write a query to find artworks that have a higher price than the average price of artworks by the same artist.

select *
from artworks a
where price>(select avg(price)
from artworks b
where a.artist_id=b.artist_id)

--17. Write a query to find the average price of artworks for each artist and only include artists whose average artwork price is higher than the overall average artwork price.
select *
from(
select artist_id, avg(price) as Average
    from artworks
    group by  artist_id) AS b
where Average>(select avg(price)
from artworks)

--18. Write a query to create a view that shows artists who have created artworks in multiple genres.

create view vwArtistsInMultipleGenre
As
    select *
    from artists
    where  Exists (select artist_id, genre
    from artworks
    group by artist_id,genre
    having  count(distinct genre)>1)
select *
from vwArtistsInMultipleGenre

--### Section 4: 4 Marks Questions

--19. Write a query to convert the artists and their artworks into JSON format.

select ar.artist_id, name, title, genre
from artists ar
    join artworks a
    on ar.artist_id=a.artist_id
--auto
FOR JSON auto,root('artists')
    --path
    select ar.artist_id, name, title, genre
    from artists ar
        join artworks a
        on ar.artist_id=a.artist_id
    FOR JSON path,root('artists')

        --20. Write a query to export the artists and their artworks into XML format.

        select ar.artist_id, name, title, genre
        from artists ar
            join artworks a
            on ar.artist_id=a.artist_id
        FOR XML raw('artist')
            --path
            select ar.artist_id, name, title, genre
            from artists ar
                join artworks a
                on ar.artist_id=a.artist_id
            FOR XML path('artist'),root('artists')


                --### Section 5: 5 Marks Questions

                --21. Create a trigger to log changes to the `artworks` table into an `artworks_log` table, capturing the `artwork_id`, `title`, and a change description.

                create table artworks_log
                (
                    artwork_id int,
                    title varchar,
                    description varchar(30)
                );

                Create trigger logchanges
on artworks
after insert
AS
Begin
                    Insert Into artworks()




                    --22. Create a scalar function to calculate the average sales amount for artworks in a given genre and write a query to use this function for 'Impressionism'.

                    Alter Function dbo.AvgSalesAmount(@genre varchar(30))
Returns Int
AS
Begin
                        return(select avg(total_amount)
                        from sales
                        where artwork_id in (select artwork_id
                        from artworks
                        where genre= @genre))
                    End

                    select dbo.AvgSalesAmount ('Impressionism')


                    --23. Create a stored procedure to add a new sale and update the total sales for the artwork. Ensure the quantity is positive, and use transactions to maintain data integrity.

                    select *
                    from sales

                    Create Procedure AddNewSale(
                        @sale_id Int,
                        @artwork_id int,
                        @sale_date varchar(20),
                        @quantity int,
                        @total_amount decimal(10,2)
                    )
                    AS
                    Begin
                        if @quantity <0
throw 60000,'value of quantity should be positive',1

                        Begin transaction
                        Insert Into sales
                        Values(@sale_id, @artwork_id, @sale_date, @quantity, @total_amount)

                        update sales
set total_amount=total_amount+@total_amount
where artwork_id=@artwork_id

                        commit
                    End

                    Exec AddNewSale @sale_id =5,@artwork_id =2,@sale_date = '2024-07-01',@quantity =3,@total_amount=1000000



                    --24. Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each genre and use it in a query to display the results.

                    Create Function TotalQuantitySold()
returns Table (@Genre varchar
                    (30)) 
AS

                    Begin
                        Return(
select genre, sum(total_amount) as total
                        from artworks
                            join sales
                            on artworks.artwork_id=sales.artwork_id
                        group by genre
)

                        --25. Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.
                        select artists.artist_id, name, total_amount,
                            Ntile(3) Over(order by total_amount desc) AS Groups
                        from artists
                            join artworks
                            on artists.artist_id=artworks.artist_id
                            join sales
                            on artworks.artwork_id=sales.artwork_id


                        --### Normalization (5 Marks)

                        --26. **Question:**
                        --    Given the denormalized table `ecommerce_data` with sample data:

                        --| id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
                        --| --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
                        --| 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
                        --| 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
                        --| 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
                        --| 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

                        --Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.

                        Create table customers
                        (
                            cust_id Int primary key,
                            customer_name varchar(20) Not Null,
                            customer_email nvarchar(20)Not Null unique
                        );
                        Create table products(product_name varchar(20)Not Null,product_category nvarchar(20)Not Null,product_price decimal(10,2)Not Null check >= 0);
                        Create table orders
                        (
                            order_id Int primary key,
                            order_date date Not Null,
                            order_quantity int Not Null,
                            order_total_amount decimal(10,2)Not Null
                        );
                        Create table mapping
                        (
                            id int,
                            cust_id Int foreign key references customers,
                            product_id int,
                            order_id int
                        );



--### ER Diagram (5 Marks)

--27. Using the normalized tables from Question 26, create an ER diagram. Include the entities, relationships, primary keys, foreign keys, unique constraints, not null constraints, and check constraints. Indicate the associations using proper ER diagram notation.