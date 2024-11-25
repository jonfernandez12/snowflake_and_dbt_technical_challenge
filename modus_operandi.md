# Modus Operandi

The following document will aim to gather all the steps I thought about during 
the development.

# Landing the challenge

First, I read the challenge several times to makes sure I understood the task. 
At first glance, it does not seem a very complex task, also the datasets are 
not very big so I suppose I will not have any issue processing the data.

The final output is based on the join of patients with steps and exercises 
accordingly and calculating the maximum sum of minutes (coming from steps and 
exercises) grouped by patient.

# Infrastructure decision

Since I am familiar with Airflow and DBT (I did no use it in 2 years but I am 
eager to see what changed) and the challenge itself does not seem extremely 
complex I would love to invest some time in creating a proper infrastructure:
 - Dockerized Airflow and DBT with connection to Snowflake

However, I have never deployed Airflow locally from scratch so I will leave it
for the end.

I decided to use Snowflake as database based on:
- I did not use it before and I want to learn a new DB engine.
- It was listed in the nice-to-have list of the job offer.

Also, I would like to implement data QA tests (table constraints, bussiness
criteria and schema checks) on the CI/CD pipeline and add renovate bot, 
pytest coverage and documentation deployment to the git project.

Not sure if I will create a dashboard for the results but it would be cool. I
have some ideas for other KPIs:
- Apart from total minutes, we can show as well the minutes coming from steps and the 
ones coming from exercises, it could be a useful KPI to get more insights about 
the rehabilitation.
- We can also split total minutes per country and, as in the previous point,
split it in exercises and steps.
- Step and exercise submission time graphs (respectively) , it would be great 
to know when are usually the patients doing their steps and exercises,
maybe it has some effect on their rehabilitation time. We could `country` column
in patients to define each UTC offset if necessary.

# Setting up Github

I am not sure if it is relevant but as I am using a laptop with a paired Gitlab 
account, I had to create another SSH key and assign this new SSH key to the
Github account I am going to use for the challenge:

```shell
ssh-keygen -t ed25519 -C "my@mail.com"
ssh-add --apple-use-keychain ~/.ssh/my_id 
nano /Users/jonfernandez/.ssh/config
```

And here add:

```
  Host *
    UseKeychain yes
    AddKeysToAgent yes
    IdentityFile ~/.ssh/my_id
```
In Github SSH config add the content of `cat ~/.ssh/my_id.pub`.

Finally I had to log in with github-cli `gh auth login`.

# Setting up Snowflake

I am starting by setting up Snowflake user for dbt as recommended in their
[documentation](https://quickstarts.snowflake.com/guide/data_engineering_with_apache_airflow/index.html#0)

```snowflake
USE ROLE SECURITYADMIN;

-- We create the role that DBT user will use: dbt_developer_role 
CREATE OR REPLACE ROLE dbt_developer_role COMMENT='DBT developer role';
GRANT ROLE dbt_developer_role TO ROLE SYSADMIN;

-- Create the DBT user
CREATE OR REPLACE USER dbt_user PASSWORD='dbt_password'
	DEFAULT_ROLE=dbt_developer_role
	DEFAULT_WAREHOUSE=dbt_warehouse
	COMMENT='DBT User';

GRANT ROLE dbt_developer_role TO USER dbt_user;

-- To grant privileges to the role we need to use a role with higher permissions 
USE ROLE ACCOUNTADMIN;

GRANT CREATE DATABASE ON ACCOUNT TO ROLE dbt_developer_role;

USE ROLE SYSADMIN;

-- Create Warehouse for DBT
CREATE OR REPLACE WAREHOUSE dbt_developer_warehouse
  WITH WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 120
  AUTO_RESUME = true
  INITIALLY_SUSPENDED = TRUE;

GRANT ALL ON WAREHOUSE dbt_developer_warehouse TO ROLE dbt_developer_role;
```

After that we create the data model for our patients, exercises and steps.
The assumptions and standards I chose to follow:

- We prefer plural from singular table namings so as SQL code is more
intuitive: `SELECT * FROM patients;`
- We prefer explicit over implicit type definition (i.e. instead of INTEGER, 
we use NUMBER(38,0) so the type is properly defined in the code even though 
`NUMBER(38,0)` is the [standard in Snowflake for numeric data types](https://docs.snowflake.com/en/sql-reference/data-types-numeric#number))
- Same goes for string data types, we will be using `VARCHAR(16777216)` which
would be the same as using `VARCHAR` but we rather define the maximum length
of the field in our code.
- It would be great to align with the team in charge of building the app so as
can define properly the limits of the values in the columns and use it as a 
type validation.
- In exercises and steps tables, `external_id` column names has been modified
to `patient_id`.
- For the timestamp columns, I used [TIMESTAMP_TZ](https://docs.snowflake.com/en/sql-reference/data-types-datetime#timestamp-ltz-timestamp-ntz-timestamp-tz)
Snowflake type since it looks like the UTC offset is defined after the 
timestamp (i.e. `2024-04-11T14:25:23.708+0200`).
However, we will need to take into account that `Attention` section
when using this field for creating KPIs, since the offset of some countries 
change during the year but not the value of the field.
If possible I would ask the team in charge app to send us the values of the 
TIMEZONE instead, together with the timestamp (without UTC offset in this case)
so as we can calculate the UTC time in place when needed.
- In steps tables, `submission_time` column name has been modified 
to `submitted_at`, like that all the timestamp have the same suffix and we can
identify the type of the column by the name.
- When trying to test how Snowflake is reading the timestamp values from the 
spreadsheet `SELECT '2023-04-19T19:03:58.0520200'::TIMESTAMP_TZ` I got
`Timestamp '2023-08-04T21:26:24.871+0200' is not recognized` so I tried 
```snowflake
ALTER SESSION SET TIMESTAMP_TZ_OUTPUT_FORMAT = 'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM';
SELECT TRY_TO_TIMESTAMP_TZ('2023-08-04T21:26:24.871+0200', 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM')
```
It looks like it can read it know, we will take care of this when importing the
data to Snowflake.

The script looks like following:
```snowflake
CREATE OR REPLACE DATABASE caspar_health;

CREATE TABLE patients (
    id NUMBER(38, 0),
    first_name VARCHAR(16777216),
    last_name VARCHAR(16777216),
    country VARCHAR(16777216)
);
CREATE TABLE exercises (
    id NUMBER(38, 0),
    patient_id NUMBER(38, 0),
    minutes NUMBER(38, 0),
    completed_at TIMESTAMP_TZ,
    updated_at TIMESTAMP_TZ
);
CREATE TABLE steps (
    id NUMBER(38, 0),
    patient_id NUMBER(38, 0),
    steps NUMBER(38, 0),
    submitted_at TIMESTAMP_TZ,
    updated_at TIMESTAMP_TZ
);

ALTER SESSION SET TIMESTAMP_TZ_OUTPUT_FORMAT = 'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM';
```


# Setting up DBT

I am going to be using [uv](https://github.com/astral-sh/uv) as a python package to start with DBT dependencies. 
It is being a while since I wanted to try uv out, is supposed to be very fast.

```
brew install uv
uv init caspar_health_technical_challenge
uv add dbt-core
uv add dbt-snowflake
dbt deps
```

I am not using dbt-cloud since looks expensive for what it offers and it is not
really complicated to set up and deploy dbt-core but maybe I regret.

I added a `generate_schema_name` and `set_query_tag` macros as recommended 
in the [documentation]([documentation](https://quickstarts.snowflake.com/guide/data_engineering_with_apache_airflow/index.html#0)) 
