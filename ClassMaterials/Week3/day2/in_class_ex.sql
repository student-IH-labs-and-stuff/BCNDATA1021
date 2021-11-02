2.04.5

#The select statement is used as a print command in SQL. Use the select statement to print "Hello World".

select 'hello world'; 


#Use the select statement to perform a 
#simple mathematical calculation to add two numbers.

select 2+5;


#Use an appropriate select statement to 
#retrieve a list of unique card types 
#from the bank database. (Hint: You can use DISTINCT function here.)

select distinct c.type from card c  ;


#Get a list of all the district names in the bank database.
# Suggestion is to use the files_for_activities/case_study_extended 
#here to work out which column is required here because we are 
#looking for the names of places, not just the IDs. 
#It would be great to see the results under the heading district_name.
# (Hint: Use an alias.). You should have 77 rows.

select distinct d.A2 as district_name from district d
order by A2 
limit 30 ;

#Bonus: Revise your query to also show the Region, 
#and limit the results to just 30 rows. 
#Sort the results alphabetically by district name A>Z 
#before selecting the 30.
2.05.1
#Select districts and salaries (from the district table)
# where salary is greater than 10000. 
#Return columns as district_name and average_salary.

select d.A2 as districtname, d.A11 as average_salary 
from district d
where d.A11 > 10000;

#Calculate the urban population for all districts. 
#Hint: You are looking for the number of inhabitants 
#and the % of urban inhabitants in each district. 
#Return columns as district_name and urban_population.
select A2 as district_name, A4 as noofinhabitants, 
A10 as ratioofurban,
ceiling(A4 * (A10/100)) as urban_population
from district; 

#On the previous query result - rerun it but 
#filtering out districts where the rural population
# is greater than 50%.

select A2 as district_name, A4 as noofinhabitants, 
A10 as ratioofurban,
ceiling(A4 * (A10/100)) as urban_population
from district
where A10 < 50; 




select c.client_id as client, d.A2, 
c.district_id as district, 
a.account_id
from client c
join district d on c.district_id = d.A1
join disp ds on c.client_id = ds.client_id 
join account a on ds.account_id = a.account_id;




#On the previous query result - rerun it but 
#filtering out districts where the rural population
# is greater than 50%.




