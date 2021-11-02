#intro to mysql 
#- there is a fixed sql clause structure you need to follow

select account_id, frequency from account
where district_id=5;

# we want to select all the columns from client table 
select * from client;
# we want to select A1,A2,A3 from district where 
#A1 = 50
select d.A1,d.A2,d.A3 from district d where A1= 50;

#SELECT FIELDS / * 
#from table 
#where condition ... 

# AliASES - aliasing 
select tr.trans_id as transaction,k_symbol,
tr.account_id as acc, 
tr.type as creditdebit, 
tr.operation as mode,
tr.amount
from trans tr
where k_symbol =' ';


#LIMIT 
select * from trans t 
order by t.trans_id
limit 30;

# top 10 districts , ordered by the number of inhabitants 
select d.A2, d.A3,d.A4 as popln
from district d
ORDER BY popln DESC
LIMIT 10;

Select 11 * 4;

select distinct d.A1 from district d; # select unique 

# select unique account_id in transaction table 
select count(distinct account_id) from trans;
# and count them - using count()

# loan balance, loan balance in EUR
# order of big to small 
select loan_id, status, amount-payments as loanbal, 
(amount-payments)* 0.039 as balinEUR
from loan
where (amount-payments)*0.39 > 15000
AND status ='B'
ORDER by loanbal DESC
limit 100;
# where balance in EUR > 15000
# AND status is B


select * from loan
where status in ('B','D') and not duration <> 12 ; 

# average loan amount ?? 
select ceiling(avg(amount)) as avgloan from loan;


#STRING functions 
#district name lower case, 
#and region name upper case 

select lower(d.A2) as district, 
upper(d.A3) as region 
from district d;

#divides and returns the remainder 
select 20 % 3;

# dates - dates are stored as numbers 
# convert number into date 
#  date format options - appear in a certain way 
# date functions - DATEDIFF ADDDATE 

SELECT *, convert(a.date,datetime) as dateopened
 from account a;
 
 # example:
SELECT DATE_FORMAT("2017-06-15", "%D %M %Y");

select*, 
date_format(convert(substring_index(issued,' ',1), date), "%D %M %Y")
 as date, 
 date_format(convert(substring_index(issued,' ',1), date), "%w")
 as weekdayno
from card;

# earliest date in the card table ? 
select max(issued) from card;

# between dates >and< all cards issued between or in the years 95,96,97
select * from card
where issued between 950101 and 971231;

# datediff 
# adddate 
select floor((datediff(curdate(), 19830505))/365);
select adddate("19830505", INTERVAL 6 MONTH);

# select all rows from the order table where k_symbol is empty
SELECT count(*)FROM bank.order where k_symbol = ' ';
# with order, as this is a key word, you need to specify the db

# how many transactions where amount is null ? (trans table)
select count(*) from trans where amount is null;

# case statement - replace columns in loan table with business defn

select * ,case 
when status = 'A' then 'good-repaid'
when status = 'B' then 'default'
when status = 'C' then 'on track'
else 'in debt'
end 
as statusdesc
from loan
order by statusdesc, amount DESC ;

# searching for stuff in strings - LIKE/REGEXP %_ $^| (wildcards)

select * from district where A3 LIKE 'pra%'; #wildcard, can also use _

select * from district where A3 regexp 'pra|south'; # OR

select * from district where A3 LIKE 'pra%' or A3 LIKE 'sout%'; #long form alternative

select * from district where A3 regexp '^c'; #starts with

select * from district where A3 regexp 'bohemia$'; #ends with