from datetime import datetime
from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator

def print_hello():
    return 'Hello world!'

args = {'owner': 'psyoblade', 'start_date': days_ago(n=1)}
dag = DAG('hello_world',
           default_args=args,
           description='Simple tutorial DAG',
           schedule_interval='30 0 * * *',
           start_date=datetime(2020, 8, 25), catchup=False)

dummy_operator = DummyOperator(task_id='dummy_task', retries=3, dag=dag)

hello_operator = PythonOperator(task_id='hello_task', python_callable=print_hello, dag=dag)

dummy_operator >> hello_operator
