select * from elections_vw
-------------------------------------
1)
(select pc_name as "Constituency", total_electors as "Total Electors",sum(total_votes) as "Total Votes" ,round((sum(total_votes) / total_electors)*100,2) as "Voter Turnout"  
from elections_vw
where year = '2014'
group by 1,2
order by 4 desc
limit 5)
union all
(select pc_name as "Constituency", total_electors as "Total Electors",sum(total_votes) as "Total Votes" ,round((sum(total_votes) / total_electors)*100,2) as "Voter Turnout"  
from elections_vw
where year = '2014'
group by 1,2
order by 4 asc
limit 5)
----------------------------------
2)with cte as 
(
	select state,pc_name,candidate,sum(total_electors) as total_electors,
row_number() over(partition by state,pc_name order by sum(total_electors)) as rn
from elections_vw
where year = '2014'
group by 1,2,3
),cte2 as(
select state,sum(total_electors) as "Total Electors"
from cte
where rn = 1
group by 1),
cte3 as
(select state,sum(total_votes) as "Total Votes"  
from elections_vw
where year = '2014'
group by 1)
select cte2.state as "State" , "Total Votes", "Total Electors",
round(("Total Votes"/"Total Electors")*100,2) as "Voter Turnout %" from cte2
left join
cte3 on cte2.state = cte3.state
order by 4 asc
limit 10
------------------------------------------------------------------------------------

3)
with cte as(
select year,state,pc_name,party,total_electors,round((sum(total_votes) / total_electors)*100,2) as "Vote Share"
,row_number() over(partition by year,state,pc_name order by sum(total_votes) desc) as "rn"
from elections_vw
group by 1,2,3,4,5
	),
cte2 as (
select year,state,pc_name,party,"Vote Share",lead(party,1) over (partition by state,pc_name order by pc_name desc) as prev_party from cte 
where rn = 1
order by 3,1 desc
)
select state as "State", pc_name as "Constituency",party as "Political Party","Vote Share"
from cte2 where party = prev_party
order by 4 desc
limit 10

--------------------------------
4)
with cte as(
select year,state,pc_name,party,total_electors,round((sum(total_votes) / total_electors)*100,2) as "Vote Share"
,row_number() over(partition by year,state,pc_name order by sum(total_votes) desc) as "rn"
from elections_vw
group by 1,2,3,4,5
	)
	,cte2 as (
select year,state,pc_name,party,"Vote Share",lead(party,1) over (partition by state,pc_name order by pc_name desc) as prev_party 
,lead("Vote Share",1) over (partition by state,pc_name order by pc_name desc) as prev_voteshare from cte 
	where rn = 1
order by 3,1 desc
)
select state as "State", pc_name as "Constituency",party as "Political Party","Vote Share"
,"Vote Share" - prev_voteshare as "Difference"
from cte2 where party != prev_party
order by 5 desc
limit 10
----------------------------------

5)
with cte1 as(
select pc_name,candidate,sum(total_votes) as "Total Votes",
row_number() over(partition by pc_name order by sum(total_votes) desc) as rn
from elections_vw
where year = '2019'
group by 1,2,total_electors
	)
	,cte2 as
	(select pc_name,candidate,"Total Votes",lead("Total Votes",1) over(partition by pc_name) as "2nd"
	from cte1 where rn<3)
	select pc_name as "Constituency",candidate as "Candidate","Total Votes" - "2nd" as "Margin"
	from cte2
	where "Total Votes" - "2nd" is not null
	order by 3 desc 
	limit 10
---------------------------------------

6)
with cte as (
select party,sum(total_votes) as "Total Votes Won"
from elections_vw
where year = '2019'
group by 1
),
cte2 as (
select sum(total_votes) as "Total Votes"
from elections_vw
where year = '2019')
,cte3 as
(
select * from cte
cross join
cte2
	)
	select party as "Party",round(("Total Votes Won" / "Total Votes")*100,2) as "Vote Share"
	from cte3
	order by 2 desc
	limit 10
-----------------------------
7)
with cte as (
select party,state,sum(total_votes) as "Total Votes Won"
from elections_vw
where year = '2019'
group by 1,2
),
cte2 as (
select state,sum(total_votes) as "Total Votes"
from elections_vw
where year = '2019'
group by 1),
cte3 as(
select party,cte.state,"Total Votes Won","Total Votes" from cte
left join
cte2 on cte.state = cte2.state 
	
	)
	select state as "State" , party as "Party",round(("Total Votes Won" / "Total Votes")*100,2) as "Vote Share"
	from cte3
	order by 3 desc
----------------------------------------------------
8)
with cte1 as(
select year,state,pc_name,party,round((sum(total_votes)/total_electors)*100,2) as "Vote Share %"
from elections_vw
where party = 'INC'
group by 1,2,3,4,total_electors)
select state as "State",pc_name as "Constituency",coalesce("Vote Share %" - lead("Vote Share %",1) over(partition by state,pc_name order by year desc ),0) as "Increase in Vote Share %"
from cte1
order by 3 desc
limit 10
---------------------------
10)
with cte as((select state,pc_name,round((sum(total_votes)/total_electors)*100,2) as "Vote Share %",
'Constituency where vote share is most' as "Desc",'2014' as "Year"
from elections_vw
where year = '2014' and candidate = 'NOTA'
group by 1,2,total_electors
order by 3 desc
limit 1)
union all
(select state,pc_name,round((sum(total_votes)/total_electors)*100,2) as "Vote Share %",
'Constituency where vote share is most' as "Desc",'2019' as "Year"
from elections_vw
where year = '2019' and candidate = 'NOTA'
group by 1,2,total_electors
order by 3 desc
limit 1)
union all
(select state,pc_name,sum(total_votes) as "Vote Share %",
'Constituency where votes are most' as "Desc",'2014' as "Year"
from elections_vw
where year = '2014' and candidate = 'NOTA'
group by 1,2,total_electors
order by 3 desc
limit 1)
union all
(select state,pc_name,sum(total_votes) as "Vote Share %",
'Constituency where votes are most' as "Desc",'2019' as "Year"
from elections_vw
where year = '2019' and candidate = 'NOTA'
group by 1,2,total_electors
order by 3 desc
limit 1))
select "Year",state as "State", pc_name as "Constituency", "Desc"
from cte
----------------------------------------
11)
with cte1 as(
with cte
as (select state,pc_name,party,candidate,sum(total_votes) as "Total Won",row_number() over(partition by state,pc_name order by sum(total_votes) desc) as rn
from elections_vw
where year = '2014'
group by 1,2,3,4)
select state,pc_name,party,candidate,"Total Won"
from cte
where rn = 1),
cte2 as(
with 
cte1 as 
(select state,party,sum(total_votes) as "Total Won" from elections_vw
where year = '2014'
group by 1,2),cte2 as
(select state,sum(total_votes) as "Total Votes" from elections_vw e2
group by 1)
select cte1.state,cte1.party,("Total Won"/"Total Votes")*100 as "Party Share" from cte1
left join 
cte2 on cte1.state=cte2.state)
select cte1.state as "State",cte1.pc_name as "Constituency",cte1.party as "Party",cte1.candidate as "Candidate"
from cte1 
left join
cte2 on cte1.state=cte2.state and cte1.party=cte2.party
where "Party Share" < 10
order by 2






    
	
	








    
	
	





    
	
	

    
	
	

	
	

