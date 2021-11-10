use bank ; 
select a.account_id, a.frequency, c.client_id, c.district_id
from account a 
join disp d
using (account_id)
join client c 
using (client_id)
where type = 'OWNER';



-- scenario 1 from slides 
# trans, loan, disp - tables needed 
select l.status, #gives us good/ bad
date_format(convert(t.date,date),'%m%y'), # gives us month and year
count(distinct t.account_id) as noofaccounts,
count(distinct t.trans_id) as nooftrans,
ceiling(sum(t.amount)) as movedamount,
count(distinct d.client_id) as noofclients
from trans t #for transactions
join disp d using (account_id) # allows us to get clients
join loan l using (account_id) # allows us to get status
where d.type = 'OWNER'
group by l.status, date_format(convert(t.date,date),'%m%y');

-- export to tableau for visualisation

-- scenario 2 on the slides - we will create a series of views to build up the query

# this is monthly unique accounts which made transactions
create or replace view user_activity as 
select account_id, 
if(l.status in ('A','C'), 'goodloans', 'badloans') as statusnew,
#(CASE WHEN l.status in ('A','C') THEN 'goodloans' else 'badloans'end) as statusalt,
date_format(convert(t.date,date), '%m-%Y') as activitymonthyear,
date_format(convert(t.date,date), '%Y') as activityyear,
date_format(convert(t.date,date), '%m') as activitymonth
from trans t
join loan l using (account_id)
order by activityyear,activitymonth, statusnew ;

# year month unique account id count 
create or replace view monthly_active_users as 
select activitymonthyear, activityyear, activitymonth,
count(distinct account_id) as activeusers,
statusnew
from user_activity
group by activitymonthyear, activityyear, activitymonth, statusnew
order by activityyear,activitymonth, statusnew;

# includes LAG - allows to compare MoM 
create or replace view monthonmonth_users as 
select *, 
lag(activeusers,1) over(partition by statusnew) as prevmonth
from monthly_active_users; 

# do a query on the last view to work out the % change MoM
select *, 
round((activeusers-prevmonth)/activeusers*100/2) as perchange
from monthonmonth_users 
where prevmonth is not null;

-- export to tableau for visualisation
 
 
 # approach 3 - month on month sticky accounts
 
 create or replace view retained_customers_view as
with distinct_users as (
  select distinct account_id , activitymonthyear, activityyear 
  from user_activity
)
select d1.activitymonthyear, d1.activityyear,
count(distinct d1.account_id) as Retained_customers
from distinct_users d1
left join distinct_users d2 on d1.account_id = d2.account_id
and d1.activitymonthyear = d2.activitymonthyear + 1
group by d1.activitymonthyear, d1.activityyear
order by d1.activityyear, d1.activitymonthyear;

# building upon the above view, to find the
# month on month comparison, using LAG:
select*, 
lag(Retained_customers, 1) over(order by activityyear,activitymonthyear) as Last_month_retained_customers,
(Retained_customers-lag(Retained_customers, 1)
 over(order by activityyear,activitymonthyear))
 as Diff
from bank.retained_customers_view;

-- export to tableau for visualisation




 







