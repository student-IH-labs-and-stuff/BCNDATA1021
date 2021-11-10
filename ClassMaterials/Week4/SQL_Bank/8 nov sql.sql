# self joins 
# accounts inside the same district - bank  
account - alias twice 
join on account id (same field) <>
and district id

use bank; 
select * from account t1
join account t2
on t1.account_id <> t2.account_id # not the same account
and t1.district_id=t2.district_id # is the same district
where t1.district_id = 7
order by t1.district_id, t1.account_id
;
#(like a cross join) - we have everything joined to everything 

# disp - slightly strange information ?
# for each account the owner and disponent (legal authority) 

Create view owner_info as
select d1.account_id as account, d1.type as primaryrole, 
d1.client_id as disponent_client_id, 
d2.client_id as owner_client_id, cl.birth_number as ownerbirthnumber
from disp d1 
join disp d2 
on d1.account_id=d2.account_id 
and d1.type <> d2.type
join client cl 
on d2.client_id= cl.client_id #join on owner client id
where d1.type = 'DISPONENT' ;

select * from client c
join district d
on c.district_id = d.A1
join disp dp
using (client_id)
join account a
using(account_id)
where dp.type = 'OWNER';

#  write the inner query first - and check it ! 
# pseudo code to sketch out the whole query 
# space your query out over a few rows ((())))

-- loans which are bigger than average of all loans 
# inner query 1st 
-- get the loan id 
-- where loanamount is bigger than 
-- avg loans all 
# a subquery:
SELECT 
    loan_id, amount, duration, status
FROM
    loan
WHERE
    amount > (SELECT 
            AVG(amount)
        FROM
            loan)
order by amount DESC
limit 10
;


# Find out the average number of transactions by account. 
# Get those accounts that have more transactions than the average.

# find out the no of trans per account 
# find the average of those 
# get those accounts with more than avg trans -- info 

select t.account_id, count(t.trans_id) as num_trans, 
a.district_id, a.frequency from trans t
join account a using (account_id)
group by t.account_id, a.district_id, a.frequency
having count(t.trans_id) >
(select floor(avg(num_trans)) from
(select account_id, 
count(trans_id) as num_trans from trans 
group by account_id) 
s1)
order by num_trans;


# get a list of accounts from Central Bohemia - using a subsquery 
select * from account 
where district_id in
 (select A1 from district 
 where A3 = 'central Bohemia') ;
 
 # create view of ... 
 # list of bad loans - based on status B and D 
 # summary of each region, district, with the no of accounts
 # empl rate 
 
 #inner - account_id where status is B or D 
 create view badloansdistrict as 
 select count(a.account_id) as noofaccounts, d.A2 as districtname, 
 d.A3 as regionname, round(avg(d.A13),1) as unemplrate
 from district d 
 join account a 
 on d.A1 = a.district_id 
 inner join 
 (select distinct account_id from loan where status in ('B','D')) s1
 using (account_id) 
 group by districtname, regionname
 ;
 
 # Error Code: 1248. Every derived table must have its own alias

 
-- a subquery is a select statement which includes another query
-- enclose in () 
-- subquery can return a single value in () or a list or a table 
-- if a table - use an alias 
-- subquery always ignores the inner order by clause 
-- can have multiple levels ( nested subqueries) 




