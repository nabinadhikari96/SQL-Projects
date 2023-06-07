drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

--1. What is the total amount each custumer spend on zomato ?
SELECT a.userid,SUM(b.price) total_amount FROM sales a INNER JOIN product b ON a.product_id=b.product_id
GROUP BY a.userid

--2. How many days each customer visited zomato ?
SELECT userid,COUNT(DISTINCT(created_date)) as frequent_visit FROM sales 
GROUP BY userid

-- 3. What was the first product purchased by customers ?
SELECT * FROM
(SELECT *,rank() over (partition by userid  order by created_date) rnk from sales) a where rnk=1;

--4. what is the most purchased item on the menu and how many times its purchased by all customers ?
SELECT userid,COUNT(product_id) cnt FROM sales WHERE product_id=
(SELECT TOP 1 product_id from sales GROUP BY product_id ORDER BY COUNT(product_id) DESC)
GROUP BY userid

--5. Which item is the most popular for each customers ?
SELECT * FROM 
(SELECT * ,rank() over(partition by userid order by cnt desc) rnk
FROM (SELECT userid,product_id,count(product_id) cnt from sales
group by userid,product_id)a)b WHERE rnk=1

--6. which item was first purchased by the customer after they became a member ?
select * from
(select c.*,rank() over(partition by userid order by created_date) rnk from
(SELECT a.userid,a.product_id,a.created_date,b.gold_signup_date 
from sales a inner join
goldusers_signup b on a.userid=b.userid
and created_date>=gold_signup_date)c)d where rnk=1;

--7. which item was purchased just before the customer became a member ? 
select * from
(select c.*,rank() over(partition by userid order by created_date desc) rnk from
(SELECT a.userid,a.product_id,a.created_date,b.gold_signup_date 
from sales a inner join
goldusers_signup b on a.userid=b.userid
and created_date<=gold_signup_date)c)d where rnk=1;

--8. what is the total order and total amount spent for each member before they became a member ?
SELECT userid, COUNT(created_date) total_purchased,sum(price) total_amount FROM
(SELECT c.*,d.price FROM
(SELECT a.userid,a.product_id,a.created_date,b.gold_signup_date 
from sales a inner join
goldusers_signup b on a.userid=b.userid
and created_date<=gold_signup_date)c inner join product d on c.product_id=d.product_id)e
GROUP BY userid;

-- 9 . If buying each product generates points for eg. 5rs = 2 zomato point and each product has different purchasing points for eg. for p1 5rs=1 zomato point ,
--for p2 10rs=5 zomato point and for p3 5rs 1 zomato point.  Calculate points collected by each customers and for which product most points have been given till now ?
SELECT userid,SUM(total_point) total_points_earned FROM
(SELECT e.*,amount/point  total_point FROM
(SELECT d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as point FROM
(SELECT c.userid,c.Product_id,SUM(price) amount FROM
(SELECT a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
GROUP BY userid,product_id)d)e)f
GROUP BY userid;

SELECT * FROM
(SELECT *,RANK() OVER(ORDER BY total_points_earned DESC) rnk FROM
(SELECT product_id,SUM(total_point) total_points_earned FROM
(SELECT e.*,amount/point  total_point FROM
(SELECT d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as point FROM
(SELECT c.userid,c.Product_id,SUM(price) amount FROM
(SELECT a.*,b.price from sales a inner join product b on a.product_id=b.product_id)c
GROUP BY userid,product_id)d)e)f
GROUP BY product_id)f)g where rnk=1;


--10. In the first 1 year after a customers join gold programme (including their join date) irrespective of what the customer has purchased they earned 5 zomato points
--for every 10rs spent who earned more 1 or 3 and what was their points earnings in their first year ?
--1 zomato points = 2rs
--0.5 points = 1rs

SELECT c.*,d.price*.5 total_points_earned FROM
(SELECT a.userid,a.product_id,a.created_date,b.gold_signup_date 
from sales a inner join
goldusers_signup b on a.userid=b.userid
and created_date>=gold_signup_date and created_date <=DATEADD(year,1,gold_signup_date))c
INNER JOIN product d on c.product_id=d.product_id;


--11. rank all the transaction of the customes
SELECT *,RANK() OVER(PARTITION BY userid ORDER BY created_date) rnk from sales;


--12. rank all the transaction for each member whenever they are a zomato gold member for every non gold member transaction mark as na
SELECT e.*,case when rnk=0 then 'na' else rnk end as rnk from
(SELECT c.*, cast((case when gold_signup_date is null then 0 else RANK() OVER(PARTITION BY userid ORDER BY created_date DESC)end)as varchar) as rnk FROM
(SELECT a.userid,a.product_id,a.created_date,b.gold_signup_date 
from sales a LEFT JOIN
goldusers_signup b on a.userid=b.userid
and created_date>=gold_signup_date)c)e;