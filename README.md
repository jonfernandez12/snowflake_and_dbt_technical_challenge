# Snowflake and DBT technical challenge

> [!WARNING]
> Currently this project is deprecated since the trial for using Snowflake has expired,
please connect a new Snowflake account and update the credentials or pay for the
existing Snowflake account. Furthermore, all the data related with the company involved in the challenge will deleted for privacy reasons.

In the following sections you will find more information about the challenge
itself as well as the technical details about the infrastructure, data model
design and the data processing ELT.

# Index

- [Technical Challenge Statement](docs/statement.md)
- [Modus Operandi](docs/modus_operandi.md)
- [Faced problems](docs/faced_problems.md)
- [Future implementations](docs/future_implementations.md)
- [Test report](docs/tests/index.md)

## Install dependencies
 I could only try it out on macOS, so it might be that it does not work in
 Linux, but it should.
```
make set-up
```
If the environment is not activating automatically, please run 
`source .venv/bin/activate` as mentioned in the uv logs.

## Airflow Server

Deploy an [astro](https://www.astronomer.io/docs/) container with Airflow webserver, scheduler and 
executor (triggerer).

```shell
make start-airflow
make stop-airflow
```

**The very first time starting the astro server might fail with some webserver 
backend secrets error, just run `make restart-airflow`, go to
http://0.0.0.0:8080 and enter `admin`-`admin`.**

In case of updating Airflow start up connections, variables or pools in 
`airflow_setting.yaml` or in case you can not see the `snowflake_connection_id`
in Airflow UI, please run:

```shell
make restart-airflow
```

## Add/remove dependency

Install dependency:
```
make install dep={{dependency}} ver={{dependency_version}} # Example: make install dep=requests ver=2.26.0
```

Uninstall dependency:
```
make uninstall dep={{dependency}} # Example: make uninstall dep=requests
```

## Run tests

Run all tests defined in `dags/dbt/dbt_cosmos/tests/dags/`.

```
make run-tests
```

## Check format

Checks and automatically fixes SQL and python code formats using SQLfluff 
and Ruff requirements.

```
make fix-format
```

## Generate test report


```
make docs
```

## Start documentation server

There is a small surprise here:
```
make docs-serve
```