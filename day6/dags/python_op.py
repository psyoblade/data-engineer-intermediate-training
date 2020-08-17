#!/usr/bin/env python
# -*- coding:utf-8 -*

from airflow.models import DAG
from airflow.utils.dates import days_ago
from airflow.operators.python_operator import PythonOperator
import time
from pprint import pprint

args = {'owner': 'psyoblade',
        'start_date': days_ago(n=1)}

dag = DAG(dag_id='my_python_dag',
          default_args=args,
          schedule_interval='@daily')


def print_fruit(fruit_name, **kwargs):
    print('=' * 60)
    print('fruit_name:', fruit_name)
    print('=' * 60)
    pprint(kwargs)
    print('=' * 60)
    return 'print complete!!!'

def sleep_seconds(seconds, **kwargs):
    print('=' * 60)
    print('seconds:' + str(seconds))
    print('=' * 60)
    pprint(kwargs)
    print('=' * 60)
    print('sleeping...')
    time.sleep(seconds)
    return 'sleep well!!!'

t1 = PythonOperator(task_id='task_1',
                    provide_context=True,
                    python_callable=print_fruit,
                    op_kwargs={'fruit_name': 'apple'},
                    dag=dag)

t2 = PythonOperator(task_id='task_2',
                    provide_context=True,
                    python_callable=print_fruit,
                    op_kwargs={'fruit_name': 'banana'},
                    dag=dag)

t3 = PythonOperator(task_id='task_3',
                    provide_context=True,
                    python_callable=sleep_seconds,
                    op_kwargs={'seconds': 10},
                    dag=dag)

t4 = PythonOperator(task_id='task_4',
                    provide_context=True,
                    python_callable=print_fruit,
                    op_kwargs={'fruit_name': 'cherry'},
                    dag=dag)

t1 >> [t2, t3]
[t2, t3] >> t4
