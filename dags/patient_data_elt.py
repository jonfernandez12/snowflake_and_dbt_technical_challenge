from datetime import datetime
import os
from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping
from pathlib import Path

dbt_project_path = Path("/usr/local/airflow/dags/dbt/caspar_health_dbt_cosmos")

profile_config = ProfileConfig(
    profile_name="caspar_health_technical_challenge",
    target_name="dev",
    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id="snowflake_connection_id",
    ))


patient_data_elt = DbtDag(
    project_config=ProjectConfig(dbt_project_path,),
    operator_args={"install_deps": True},
    profile_config=profile_config,
    execution_config=ExecutionConfig(
        dbt_executable_path=f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt",),
    schedule_interval="@daily",
    start_date=datetime(2024, 11, 27),
    catchup=False,
    dag_id="patient_data_elt",
)

