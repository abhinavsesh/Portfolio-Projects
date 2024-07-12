-- 1.Remove Duplicates
-- 2.Standardize the Data
-- 3.Null values or blank values
-- 4.Remove any columns
with duplicate_cte as(
select *,
row_number()over(
partition by company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions ) as row_num
from layoffs_staging)
select* from duplicate_cte where row_num>1;
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_staging2
select *,
row_number()over(
partition by company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions ) as row_num
from layoffs_staging;

select * from layoffs_staging2 ;
-- Standardizing data

select company,trim( company)
from layoffs_staging2;
 update layoffs_staging2
 set company=trim(company);
 
select * from
layoffs_staging2
where industry like 'Crypto%'; 

update layoffs_staging2
set industry= 'Crypto'
where industry LIKE 'Crypto%';

select distinct location from layoffs_staging2 order by 1;
select distinct country from layoffs_staging2 order by 1; 
update layoffs_staging2 
set country=TRIM(TRAILING '.' from country);
select date from layoffs_staging2;
select date,
str_to_date(date, '%m/%d/%Y')
from layoffs_staging2;
 update layoffs_staging2
 set date=str_to_date(date, '%m/%d/%Y');
 
 alter table layoffs_staging2 
 modify column date date;
 
 select *
 from layoffs_staging2
 where total_laid_off IS NULL
 AND percentage_laid_off IS NULL;
 
 select *
 from layoffs_staging2
 where industry IS NULL
 OR industry='';
 
 select t1.industry,t2.industry
 from layoffs_staging2 t1
 join layoffs_staging2 t2
	on t1.company=t2.company
	and t1.location=t2.location
 where (t1.industry is null or t1.industry='')
 and t2.industry is not null;
 update layoffs_staging2 set industry=null where industry='';
 update layoffs_staging2 t1
 join layoffs_staging2 t2
	on t1.company=t2.company
	set t1.industry=t2.industry
 where(t1.industry is null)
 and t2.industry is not null;
 
 
 delete
 from layoffs_staging2
 where total_laid_off IS NULL
 AND percentage_laid_off IS NULL;

alter table layoffs_staging2
drop column row_num;

-- Exploratory Data Analysis
select max(total_laid_off),max(percentage_laid_off)
from layoffs_staging2;

select company,sum(total_laid_off)
from layoffs_staging2
group by company 
order by 2 desc;
select industry,sum(total_laid_off)
from layoffs_staging2
group by industry 
order by 2 desc;

select substring(date,1,7) as just_month, sum(total_laid_off)
from layoffs_staging2
where substring(date,1,7) is not null
group by just_month
order by 1 asc;

with Rolling_Total as(
select substring(date,1,7) as just_month, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(date,1,7) is not null
group by just_month
order by 1 asc
)
select just_month,total_off,sum(total_off) over(order by just_month)as rolling_total
from rolling_total;

-- TOP 5 Total_Laid_Off EVERY YEAR

with company_year(company,years,total_laid_off) as(
select company,year(date),sum(total_laid_off)
from layoffs_staging2
group by company,year(date)
),Company_Year_Rank as(
select * ,dense_rank() over(partition by years order by total_laid_off desc) as Ranking
from company_year
where years is not null
)
select * 
from Company_Year_Rank
where Ranking<=5  ;




















