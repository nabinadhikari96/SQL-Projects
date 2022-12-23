-- select data from dataset !
select * from dbo.Dataset1;

select * from dbo.Dataset2;

-- converting decimal to Numerical !

select Floor(Population) from dbo.Dataset2;
select Floor(Area_km2) from dbo.Dataset2;

-- select the number of rows
select count(*) from .Dataset1;
select count(*) from .Dataset2;

-- select rows from Jhakhand and Bihar
select * from .Dataset1 where state in ('Jharkhand' ,'Bihar')


-- population of India

select sum(Floor(population)) as Population from .Dataset2


-- avg growth 

-- avg growth 
-- ERROR : Operand data type nvarchar is invalid for avg operator.
select State,avg(Growth) from .Dataset1 group by state;

-- avg sex ratio

select state,round(avg(sex_ratio),0) avg_sex_ratio from .Dataset1 group by state order by avg_sex_ratio desc;

-- avg literacy rate
select state,floor(avg(literacy)) as avg_literacy from dbo.Dataset1 group by state order by avg_literacy desc;

-- top 3 state showing highest growth ratio

select top 3 state,avg(cast(growth As decimal)) as avg_growth from .Dataset1 group by state order by avg_growth desc;

update Dataset1 set growth = left(growth, len(growth)-1)   


-- bottom 3 state showing lowest sex ratio

select top 3 state,avg(sex_ratio) as avg_sex_ratio from .Dataset1 group by state order by avg_sex_ratio asc;


-- top and bottom 3 states in Literacy rate.

-- creating top state table
drop table if exists #topstate
create table #topstate(
state nvarchar(50),
topstate float
)

insert into #topstate
select top 3 state,avg(Literacy) as Lit from .Dataset1 group by state order by Lit desc;

select top 3 * from #topstate order by #topstate.topstate;


-- creating bottom state table
drop table if exists #bottomstate
create table #bottomstate(
state nvarchar(255),
bottomstate float
)

insert into #bottomstate
select top 3 state, avg(Literacy) as Lit from .Dataset1 group by state order by Lit asc;

select * from #bottomstate order by #bottomstate.bottomstate;


-- union operators
select * from (
select top 3 * from #topstate order by #topstate.topstate desc) a

union

select * from (
select top 3 * from #bottomstate order by #bottomstate.bottomstate asc) b;

-- ABOVE and this queries are same
select * from #topstate union select * from #bottomstate ;



-- states starting with letter a

select distinct state from Dataset1 where lower(state) like 'a%' or lower(state) like 'b%'

select distinct state from Dataset2 where lower(state) like 'a%' and lower(state) like '%m'



-- joining both table
--Select a.district,a.State,Sex_Ratio,round(population,2) from dbo.Dataset1 as a inner join dbo.Dataset2 as b on a.District=b.District;




--TOTAL NUMBER OF MALES AND FEMALES

-- CALculating male and female
--female/male  = Sex_ratio-----1
--female+male  = Population-----2
--from 2,
--male = population - Female------3
--from 1,
--femlae = sex_ratio * male----------4
--from 3 and 4
--male = population - (sex_ration*male)
--population = male(1+sex_ratio)
--male = population/(sex_ratio + 1)

-- female = sex_ratio * population/(sex_ratio + 1)

select sum(d.male) as Total_Male,sum(d.female) as Total_Female from 
(select c.district , c.state,floor((c.p/(c.sex_ratio + 1))) as male,
Floor(sex_ratio * p/(sex_ratio + 1))
 as female from (Select a.district,a.State,Sex_Ratio,floor(population) as p
 from dbo.Dataset1 as a inner join dbo.Dataset2 as b on a.District=b.District) as c) as d;

 
 
 -- total literacy rate

 --illiteracy = 1-literacy

 select d.state,d.Literacy,d.Iliteracy from (select c.state,c.Literacy,(Literacy-1) as Iliteracy from
 (Select a.district,a.State,a.Literacy,floor(population) as p
 from dbo.Dataset1 as a inner join dbo.Dataset2 as b on a.District=b.District) as c) as d;
 

