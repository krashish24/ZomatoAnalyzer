CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'22-09-2017'),
(3,'21-04-2017');


CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'02-09-2014'),
(2,'15-01-2015'),
(3,'11-04-2014');


CREATE TABLE sales(userid integer,created_date date,product_id integer); 


INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'19-04-2017',2),
(3,'18-12-2019',1),
(2,'20-07-2020',3),
(1,'23-10-2019',2),
(1,'19-03-2018',3),
(3,'20-12-2016',2),
(1,'09-11-2016',1),
(1,'20-05-2016',3),
(2,'24-09-2017',1),
(1,'11-03-2017',2),
(1,'11-03-2016',1),
(3,'10-11-2016',1),
(3,'07-12-2017',2),
(3,'15-12-2016',2),
(2,'08-11-2017',2),
(2,'10-09-2018',3);


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

---created_date means purchased_date

1.What is the total amount each customer spent on zomato?

select a.userid,sum(b.price) as total_amount_spent
from sales a inner join product b 
on a.product_id=b.product_id
group by a.userid;

2.How many days has  each customer visited zomato?

select userid,count(distinct created_date) distinct_days
from sales group by userid;

3.what was the first product purchased by each customer?

select * from
(select *,rank() over(partition by userid order by created_date) as rank 
from sales) a where rank =1


4.what is the most purchased items and how many times was it purchased by all customers?

select userid,count(product_id) purchased
from sales where product_id =(select product_id
from sales group by product_id
order by count(product_id) desc
limit 1)
group by userid;



5.which items was the most popular for each customer?

select * from

(select *,rank() over(partition by userid order by count desc) as rankwise     
from (select userid,product_id,count(product_id) count from sales
group by userid,product_id) a)b
where rankwise=1;



6.which item was purchased first after they became a gold member?


select * from
(select z.*,rank() over(partition by userid order by created_date) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date
from sales a inner join goldusers_signup  b
on a.userid=b.userid and  created_date >=gold_signup_date) z)y
 where rnk =1;


7.which item was purchased just before the customer became a gold member?

select * from
(select z.*,rank() over(partition by userid order by created_date) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date
from sales a inner join goldusers_signup  b
on a.userid=b.userid and  created_date <=gold_signup_date) z)y
 where rnk =1;


8.what is the total orders and amount spent for each member before they became a member?



select userid,count(created_date) total_orders,sum(price) amount_spent from
(select c.*,d.price from 
(select a.userid,a.created_date,a.product_id,b.gold_signup_date
from sales a inner join goldusers_signup  b
on a.userid=b.userid and  created_date <=gold_signup_date) c inner join product d
on c.product_id=d.product_id)e
 group by userid;


9.if buying each product generates points for eg 5 rs=2 zomato point and each product has
different purchasing points for eg for P1 5 rs= 1 zomato point,for P2 10 rs= 5 zomato point 
and P3 5 rs= 1 zomato point .
Calculate points collected by each customer and for which product most points have been given till now.


select userid,sum(total_points) total_points_earned from
(select e.*,amt/points as total_points from
(select d.*,case when product_id=1 then 5 
when product_id=2 then 2
when product_id=3 then 5
else 0 end as points from
(select c.userid,c.product_id, sum(price) amt from
(select a.*,b.price from sales a inner join product b on a.product_id=b.product_id) c
group by userid,product_id)d)e)f
group by userid ;


--10.In the first one year after a customer joins the gold program (including their join date)
irrespective of what the customer has purchased they earn 5 zomato points for every 10 rs spent who 
earned more 1 or 3 (as 1 &3 are gold member) and what was their profit earnings in their first year?
1 zp = 2 rs
0.5 zp =1 rs

select distinct c.*,d.price*0.5 total_points from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date
from sales a inner join goldusers_signup  b
on a.userid=b.userid and  created_date >=gold_signup_date and 
created_date <=gold_signup_date +365)c
inner join product d on c.product_id=d.product_id;


11.Rank all the transaction of the customers


select *,rank() over (partition by userid order by created_date desc) rank from sales


12.Rank all the transactions for each member whenever they are a zomato gold member
 for every non gold member transaction mark as NA.
 

select e.*, case when rank01='0' then 'na' else rank01 end as rank012 from
(select c.*,cast(( case when gold_signup_date is null then 0 else 
rank() over (partition by userid order by created_date desc) end) as varchar) as rank01 from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date
from sales a left join goldusers_signup  b
on a.userid=b.userid and  created_date >=gold_signup_date )c)e;  


























































