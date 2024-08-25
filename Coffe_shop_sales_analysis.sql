CREATE DATABASE coffe_shop_db;

use coffe_shop_db;

select * from coffee_shop_data;

desc coffee_shop_data;

## Cleaning dataset :- 

# update transaction_date data into date format
update coffee_shop_data
set transaction_date = str_to_date(transaction_date, '%d-%m-%Y');

# change datatype of transaction_date column into Date datatype
alter table coffee_shop_data
modify column transaction_date date;

# Update transaction_time data into time format
update coffee_shop_data
set transaction_time = str_to_date(transaction_time,  '%H:%i:%s ' );

# Change datatype of transaction_time column into Time datatype
alter table coffee_shop_data
modify column transaction_time time;

#Rename column name
alter table coffee_shop_data
change ï»¿transaction_id transaction_id int;

# Do now business requirement queries (Data analysis):-

# 1. Total Sales Analysis:

-- Calculate the total sales for each respective month.alter
select concat((round(sum(transaction_qty * unit_price)))/1000, 'K') as Total_Sales
from coffee_shop_data
where 
month(transaction_date) = 5; -- May Month

-- Ditermine the month-on-month increase or decrease in sales
select
		month(transaction_date) as Month, 
        round(sum(transaction_qty * unit_price)) as Total_sales,
        round((sum(transaction_qty * unit_price) - lag(sum(transaction_qty * unit_price), 1)
        over(order by month(transaction_date)))) as mom_sales_difference
from 
	coffee_shop_data
where 
	month(transaction_date) in (4,5)
group by 
	month(transaction_date)
order by 
	month(transaction_date);

-- calculate the difference in sales between the selected month and the previous month
select
		month(transaction_date) as Month, -- Number of month
        round(sum(transaction_qty * unit_price)) as Total_sales, -- Total sales column
        (sum(transaction_qty * unit_price) - lag(sum(transaction_qty * unit_price), 1) -- month sales Difference
        over(order by month(transaction_date))) / lag(sum(transaction_qty * unit_price), 1) -- Divition by PM Sales
        over(order by month(transaction_date)) * 100 as mom_sales_difference_percentage -- Percentage
from 
	coffee_shop_data
where 
	month(transaction_date) in (4,5) -- for months of April and May
group by 
	month(transaction_date)
order by 
	month(transaction_date);
    
# 2. Total Orders Analysis:-

-- Calculate total no of orders for each respective month.
select count(*) as Total_Orders 
from coffee_shop_data
where
month(transaction_date) = 5; -- May Month 

-- Ditermine the month-on-month increase or decrease in the numbers of orders
select
		month(transaction_date) as Month, 
        round(count(*)) as Total_Orders,
        round((count(*) - lag(count(*), 1)
        over(order by month(transaction_date)))) as mom_orders_difference
from 
	coffee_shop_data
where 
	month(transaction_date) in (4,5)
group by 
	month(transaction_date)
order by 
	month(transaction_date);

-- calculate the difference in the numbers of orders between the selected month and the previous month
select
		month(transaction_date) as Month, -- Number of month
        round(count(*)) as Total_Orders, -- Total sales column
        (count(*) - lag(count(*), 1) -- month sales Difference
        over(order by month(transaction_date))) / lag(count(*), 1) -- Divition by PM Sales
        over(order by month(transaction_date)) * 100 as mom_Orders_difference_percentage -- Percentage
from 
	coffee_shop_data
where 
	month(transaction_date) in (4,5) -- for months of April and May
group by 
	month(transaction_date)
order by 
	month(transaction_date);

# 3. Total Quanty Sold Analysis:-

-- Calculate total Quantity Sold for each respective month.
select sum(transaction_qty) as Total_Quantity_Sold
from coffee_shop_data
where
month(transaction_date) = 5; -- May Month

-- Ditermine the month-on-month increase or decrease in the total quantity sold.
select
		month(transaction_date) as Month, 
        round(sum(transaction_qty)) as Total_Quantity_Sold,
        round((sum(transaction_qty) - lag(sum(transaction_qty), 1)
        over(order by month(transaction_date)))) as mom_quantity_difference
from 
	coffee_shop_data
where 
	month(transaction_date) in (4,5)
group by 
	month(transaction_date)
order by 
	month(transaction_date);

-- calculate the difference in the total quantity sold between the selected month and the previous month
select
		month(transaction_date) as Month, -- Number of month
        round(sum(transaction_qty)) as Total_Quantity_Sold, -- Total quantity column
        (sum(transaction_qty) - lag(sum(transaction_qty), 1) -- month quantity Difference
        over(order by month(transaction_date))) / lag(sum(transaction_qty), 1) -- Divition by PM quantity
        over(order by month(transaction_date)) * 100 as mom_quantity_difference_percentage -- Percentage
from 
	coffee_shop_data
where 
	month(transaction_date) in (4,5) -- for months of April and May
group by 
	month(transaction_date)
order by 
	month(transaction_date);

# 4. Calender Heat Map:-

-- Show the table that display Total Sales,Orders and Quantity
select
	concat(round(sum(transaction_qty * unit_price)/1000,1), 'K') as Total_Sales,
    concat(round(count(transaction_id)/1000,1), 'K') as Total_Orders,
    concat(round(sum(transaction_qty)/1000,1), 'K') as Total_Quantity
from coffee_shop_data
where
	transaction_date = '2023-05-27';
    
# 5. Sales Analysis by Weekdays and Weekends
-- Sun = 1
-- Mon = 2
-- .
-- .
-- Sat = 7
select 
	case when dayofweek(transaction_date) in(1,7) then 'Weekends'
    else 'Weekdays'
    end as day_type,
    concat(round(sum(transaction_qty * unit_price)/1000,1), 'K') as Total_Sales
from
	coffee_shop_data
where 
	month(transaction_date) = 5
group by
	day_type;
    
# 6. Sales Analysis by best store location
select 
	store_location,
    concat(round(sum(transaction_qty * unit_price)/1000,1), 'K') as Total_Sales
from 
	coffee_shop_data
where 
	month(transaction_date) = 5 -- May Month
group by
	store_location
order by
	Total_Sales desc;
    
# 7. Daily Sales analysis with Average 

-- Display Daily Sales for the selected month
select 
	concat(round(avg(Total_Sales)/1000,1), 'K') as Total_Average_Sales
    from (
			select sum(transaction_qty * unit_price) as Total_Sales
            from coffee_shop_data
            where month(transaction_date) = 5
            group by transaction_date
    ) as inner_query;

-- Display Daily Sales for that perticular month selected
select 
	day(transaction_date) as Day_of_month,
    sum(transaction_qty * unit_price) as Day_of_Total_Sales
from coffee_shop_data
where month(transaction_date) = 5
group by Day_of_month
order by Day_of_month;

-- Display the table that daily sales data for perticular month is Above average sales or Below average sales
select 
	day_of_month,
    case
		when Day_of_Total_Sales > avg_sales then 'Above average'
        when Day_of_Total_Sales < avg_sales then 'Below average'
        else 'Average'
	end as Sales_Status,
    Day_of_Total_Sales
from (
	select
		day(transaction_date) as day_of_month,
        sum(transaction_qty * unit_price) as Day_of_Total_Sales,
        avg(sum(transaction_qty * unit_price)) over () as avg_sales
	from
		coffee_shop_data
	where
		month(transaction_date) = 5
	group by
		day(transaction_date)
	) as Sales_data
order by day_of_month;

# 8. Sales analysis by product category 
select 
	product_category, 
    sum(transaction_qty * unit_price) as Total_Sales
from coffee_shop_data
where month(transaction_date) = 5
group by product_category
order by Total_Sales desc;

# 9. Top 10 Products by sales
select 
	product_type, 
    sum(transaction_qty * unit_price) as Total_Sales
from coffee_shop_data
where month(transaction_date) = 5
group by product_type
order by Total_Sales desc 
limit 10;

# 10. Sales analysis by Days and Hour
select 
    round(sum(transaction_qty * unit_price),1) as Total_Sales,
    sum(transaction_qty) as Total_quantity,
    count(*) as Total_orders
from coffee_shop_data
where month(transaction_date) = 5 -- May Month
and dayofweek(transaction_date) = 2 -- Monday
and hour(transaction_time) = 10;
