use webtraffic;

-- Website Traffic Analysis - Sources and Device Types Queries--

-- 1.Session Duration And Page views By Device Type--
select d.Device_Type,
 sum(w.Session_Duration)/3600 as total_session_duration,
 avg(w.Session_Duration)/3600 as avg_session_duration,
 sum(w.Page_Views_Per_Session) as total_page_views
from device_lookup d
inner join website_traffic_data w
on d.Device_Key=w.Device_Key
group by Device_type;

-- 2.Session Duration And Page views By Traffic Source--
select s.Source_Type,
 sum(w.Session_Duration)/3600 as total_session_duration,
 avg(w.Session_Duration)/3600 as avg_session_duration,
 sum(w.Page_Views_Per_Session) as total_page_views
from source_lookup s
inner join website_traffic_data w
on s.Source_Key = w.Source_Key
group by Source_Type;

-- Query 3 - Bounce Rate by Device Type--
with total_session as
(select d.Device_Type,
count(w.Session_Id) as total_sessions
from device_lookup d
inner join website_traffic_data w
on d.Device_Key = w.Device_Key
group  by d.Device_Type)

select d.Device_Type,
count(w.Session_Id)/max(t.total_sessions)*100 as bounce_rate
from device_lookup d
inner join website_traffic_data w
on d.Device_Key=w.Device_Key
inner join total_session t
on d.Device_Type = t.Device_Type
where w.Page_Views_Per_Session < 2
group by d.Device_Type

-- Query 4 - Bounce Rate by Traffic Sources--
 with total_session as (
 select s.Source_Type,
 count(w.Session_Id) as total_sessions
 from source_lookup s
 inner join website_traffic_data w
 on s.Source_Key = w.Source_Key
 group by s.Source_Type)
 
 select s.Source_Type,
 count(w.Session_Id)/max(t.total_sessions)*100 as bounce_rate
 from source_lookup s 
 inner join website_traffic_data w
 on s.Source_Key = w.Source_Key
 inner join total_session t 
 on s.Source_Type = t.Source_Type
 where w.Page_Views_Per_Session < 2
 group by s.Source_Type;
 
 -- Query 5 - Bounce Rate by Device Browser--
with total_session as (
select d.Device_Browser,
count(w.Session_Id) as total_sessions
from device_lookup d
inner join website_traffic_data w
on d.Device_Key = w.Device_Key
group by d.Device_Browser)

select d.Device_Browser,
count(w.Session_Id)/max(t.total_sessions)*100 as bounce_rate
from device_lookup d
inner join website_traffic_data w
on d.Device_Key = w.Device_Key
inner join total_session t
on d.Device_Browser = t.Device_browser
where w.Page_Views_Per_Session < 2
group by d.Device_Browser;

 -- Query 6 - Bounce Rate by Content Segment--
with total_session as (
select d.Content_Segment,
count(w.Session_Id) as total_sessions
from device_lookup d
inner join website_traffic_data w
on d.Device_Key = w.Device_Key
group by d.Content_Segment)

select d.Content_Segment,
count(w.Session_Id)/max(t.total_sessions)*100 as bounce_rate
from device_lookup d
inner join website_traffic_data w
on d.Device_Key = w.Device_Key
inner join total_session t
on d.Content_Segment = t.Content_Segment
where w.Page_Views_Per_Session < 2
group by d.Content_Segment;

-- Website Traffic Analysis - Trend Based--

-- Query 7 - Total Session Durartion - Trend based on Device Type--
Select Year(STR_TO_DATE(w.Date_key, '%m/%d/%Y')) as Year,
quarter(STR_TO_DATE(w.Date_key, '%m/%d/%Y')) as Quarter,
d.Device_Type,
sum(w.Session_Duration)/3600 as Total_session_duration_hrs
from device_lookup d 
inner join website_traffic_data w
on d.Device_Key = w.Device_Key
group by Year,quarter,d.Device_Type
order by Year,quarter,d.Device_Type;

-- Query 8 - Total Session Durartion - Trend based on Website Sources--
Select Year(STR_TO_DATE(w.Date_key, '%m/%d/%Y')) as Year,
quarter(STR_TO_DATE(w.Date_key, '%m/%d/%Y')) as Quarter,
s.Source_Type,
sum(w.Session_Duration)/3600 as Total_session_duration_hrs
from source_lookup s 
inner join website_traffic_data w
on s.Source_Key = w.Source_Key
group by Year,quarter,s.Source_Type
order by s.Source_Type,Year,quarter;

-- Query 9 - Total Session Durartion - Overall Trend --
select Year(str_to_date(w.Date_Key, '%m/%d/%Y')) as year,
quarter(str_to_date(w.Date_Key, '%m/%d/%Y')) as quarter,
avg(w.Session_Duration)/3600 as Total_session_duration_Hrs
from website_traffic_data w
group by year,quarter
order by year,quarter;

-- Query 10 - Bounce Rate - Monthly Trend
with total_sessions as
(Select monthname(STR_TO_DATE(w.Date_key, '%m/%d/%Y')) as Month_name,
count(w.Session_Id) as total_session
FROM website_traffic_data w
group by Month_Name)
    
Select monthname(STR_TO_DATE(w.Date_key, '%m/%d/%Y')) as Month_Name1,
count(w.Session_Id) / MAX(t.total_session) * 100 as Bounce_Rate
FROM website_traffic_data w 
inner join total_sessions t 
on t.Month_name = monthname(STR_TO_DATE(w.Date_key, '%m/%d/%Y'))
WHERE w.Page_Views_Per_Session < 2
group by Month_name1 , Month(STR_TO_DATE(w.Date_key, '%m/%d/%Y'))
order by Month(STR_TO_DATE(w.Date_key, '%m/%d/%Y'));

-- Query 11 - Bounce Rate - Daily Trend--
with total_session as
(Select dayname(STR_TO_DATE(w.Date_key, '%m/%d/%Y')) as WeekDay,
count(w.Session_Id) as total_sessions
FROM website_traffic_data w
group by WeekDay)
    
Select 
dayname(STR_TO_DATE(w.Date_key, '%m/%d/%Y')) as WeekDay1,
count(w.Session_Id) / MAX(t.total_sessions) * 100 as Bounce_Rate
FROM website_traffic_data w 
inner join total_session t
on t.WeekDay = dayname(STR_TO_DATE(w.Date_key, '%m/%d/%Y'))
WHERE w.Page_Views_Per_Session < 2
group by WeekDay1 , WeekDay(STR_TO_DATE(w.Date_key, '%m/%d/%Y'))
order by WeekDay(STR_TO_DATE(w.Date_key, '%m/%d/%Y'));

-- Website Traffic Analysis - Geographical Analysis--

-- Query 12 -- Total Page Views - Regionwise
select g.Location_Region as region,
sum(w.Page_Views_Per_Session)/(select sum(w.Page_Views_Per_Session)
from website_traffic_data w)*100 as total_page_views_Percentage
from geo_lookup as g
inner join website_traffic_data w
on g.Location_Key = w.Location_Key
group by g.Location_Region

-- Query 13 -- Total Session Duration - Regionwise--
select g.Location_Region as region,
sum(w.Session_Duration)/(select sum(w.Session_Duration)
from website_traffic_data w)*100 as total_SessionDuration_Percentage
from geo_lookup as g
inner join website_traffic_data w
on g.Location_Key = w.Location_Key
group by g.Location_Region

-- Query 14 -- Bounce Rate - Regionwise--
with total_sessions as (
select g.Location_Region,
count(w.Session_Id) as total_session
from geo_lookup g
inner join website_traffic_data w 
on g.Location_Key = w.Location_Key 
group by g.Location_Region)

select t.Location_Region as region,
count(w.Session_Id)/max(t.total_session)* 100 as Bounce_Rate
from website_traffic_data w
inner join geo_lookup g
on g.Location_Key = w.Location_Key
inner join total_sessions t
on g.Location_Region = t.Location_Region
where w.Page_Views_Per_Session < 2
group by t.Location_Region

-- Query 15--Total Session Duration - Top 5 cities
select * from (
select *,dense_rank()over(order by total_session_duration desc) as ranks from 
(select g.location_city AS City,
sum(w.Session_Duration) /3600 as total_session_duration
from website_traffic_data w
inner join geo_lookup g 
on g.location_key = w.location_key
group by g.location_city) as total_sessions
) as result 
Where result.ranks <6;

-- Query 16--Total Page Views - Top 5 cities
select * from (
select *,dense_rank()over(order by total_pageviews desc) as ranks from 
(select g.location_city AS City,
sum(w.Page_Views_Per_Session) as total_pageviews
from website_traffic_data w
inner join geo_lookup g 
on g.location_key = w.location_key
group by g.location_city) as total_views
) as result 
Where result.ranks <6;

-- Query 17-Total Number of Sessions - Top 5 cities
select * from (
select *,dense_rank()over(order by total_sessions desc) as ranks from 
(select g.location_city AS City,
count(w.Session_Id) as total_sessions
from website_traffic_data w
inner join geo_lookup g 
on g.location_key = w.location_key
group by g.location_city) as total_sessions
) as result 
Where result.ranks <6;


-- Query 18--Bounce Rate - Top 5 cities
with total_sessions as (
select g.Location_City,
count(w.Session_Id) as total_session
from geo_lookup g
inner join website_traffic_data w 
on g.Location_Key = w.Location_Key 
group by g.Location_City)

select * from (
select *,dense_rank()over(order by Bounce_rate desc) as ranks from 
(select g.Location_City AS City,
count(w.Session_Id)/max(t.total_session)*100 as Bounce_rate
from website_traffic_data w
inner join geo_lookup g 
on g.location_key = w.location_key
inner join total_sessions t
on t.Location_City = g.Location_City
where w.Page_Views_Per_Session < 2
group by g.Location_City) as b
) as result 
Where result.ranks <6;

-- Website Traffic Analysis - Dashboard--

-- Query 19 -- Average Session Duration--
select avg(w.Session_Duration)/3600 as avg_ses_duration_hrs
from website_traffic_data w;

-- Query 20 -- Total Page Views--
select sum(w.Page_Views_Per_Session) as total_page_views
from website_traffic_data w;

-- Query 21 -- Total Session Duration--
select sum(w.Session_Duration)/3600 as total_ses_duration
from website_traffic_data w;

-- Query 22 -- Bounce Rate--
select count(w.Session_Id)/(select 
count(w.Session_Id) as total_sessions from website_traffic_data w)*100 as Bounce_rate
from website_traffic_data w
where Page_Views_Per_Session <2;

-- Query 23 -- Total Session Duration Trend--
select year(str_to_date(w.Date_key, '%m/%d/%Y')) as Year,
quarter(str_to_date(w.Date_key, '%m/%d/%Y')) as Quarter,
sum(w.Session_Duration) / 3600 as total_ses_duration_hrs
from website_traffic_data w
group by Year,Quarter 
order by  Year,Quarter;

-- Query 24 -- Total Page Views Trend--
select year(str_to_date(w.Date_key, '%m/%d/%Y')) as Year,
quarter(str_to_date(w.Date_key, '%m/%d/%Y')) as Quarter,
sum(w.Page_Views_Per_Session) as total_page_views_per_session
from website_traffic_data w
group by Year,Quarter 
order by  Year,Quarter;

-- Query 25 -- Bounce Rate Trend--
with total_sessions as
(select year(str_to_date(w.Date_key, '%m/%d/%Y')) as Year,
quarter(str_to_date(w.Date_key, '%m/%d/%Y')) as Quarter,
count(Session_Id) as total_session
from website_traffic_data w 
group by Year,Quarter)
    
select 
year(str_to_date(w.Date_key, '%m/%d/%Y')) as Year,
quarter(str_to_date(w.Date_key, '%m/%d/%Y')) as Quarter,
count(Session_Id) / max(t.total_session) * 100 as Bounce_Rate
from website_traffic_data w 
inner join total_sessions t
on t.Year = Year(str_to_date(w.Date_key, '%m/%d/%Y')) and
t.Quarter = quarter(str_to_date(w.Date_key, '%m/%d/%Y')) 
where w.Page_Views_Per_Session < 2
group by Year(str_to_date(w.Date_key, '%m/%d/%Y')),quarter(str_to_date(w.Date_key, '%m/%d/%Y')) 
order by  Year,Quarter;
        
        
