# 데이터 적재 서비스 실습

* 목차
  * [하이브 서비스 기동](#하이브_서비스_기동)
  * [하이브 트러블슈팅 가이드](#하이브_트러블슈팅_가이드)
    * [1. 파티셔닝을 통한 성능 개선](#1_파티셔닝을_통한_성능_개선)
    * [2. 파일포맷 변경을 통한 성능 개선](#2_파일포맷_변경을_통한_성능_개선)
    * [3. 비정규화를 통한 성능 개선](#3_비정규화를_통한_성능_개선)
    * [4. 글로벌 정렬 회피를 통한 성능 개선](#4_글로벌_정렬_회피를_통한_성능_개선)
    * [5. 버킷팅을 통한 성능 개선](#5_버킷팅을_통한_성능_개선)


## 하이브 서비스 기동
* 하이브 도커 이미지를 다운로드 후, 서비스를 기동합니다
```bash
git clone https://github.com/psyoblade/docker-hive.git
cd docker-hive
docker-compose up -d
```
* 테이블 생성에 필요한 파일을 서버로 복사합니다
```bash
docker cp data/imdb.tsv hive_hive-server_1:/opt/hive/examples/imdb.tsv
```


## 하이브 트러블슈팅 가이드
> IMDB 영화 예제를 통해 테이블을 생성하고, 다양한 성능 개선 방법을 시도해보면서 왜 그리고 얼마나 성능에 영향을 미치는 지 파악합니다


### 1 파티셔닝을 통한 성능 개선
* 하이브 터미널을 통해 JDBC Client 로 하이브 서버에 접속합니다
```bash
docker-compose exec hive-server bash

beeline 
beeline> !connect jdbc:hive2://localhost:10000 scott tiger
beeline> use default;
```
* 테이블 생성 및 조회를 합니다 
```bash
drop table if exists imdb_movies;

create table imdb_movies (rank int, title string, genre string, description string, director string, actors string, year string, runtime int, rating string, votes int, revenue string, metascore int) row format delimited fields terminated by '\t';

load data local inpath '/opt/hive/examples/imdb.tsv' into table imdb_movies;

select year, count(1) as cnt from imdb_movies group by year;
```
* 기존 테이블을 이용하여 파티션 구성된 테이블을 생성합니다
```bash
drop table if exists imdb_partitioned;

create table imdb_partitioned (rank int, title string, genre string, description string, director string, actors string, runtime int, rating string, votes int, revenue string, metascore int) partitioned by (year string) row format delimited fields terminated by '\t';

# https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DML#LanguageManualDML-DynamicPartitionInserts : 다이나믹 파티션은 마지막 SELECT 절 컬럼을 사용합니다
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table imdb_partitioned partition (year) select rank, title, genre, description, director, actors, runtime, rating, votes, revenue, metascore, year from imdb_movies;

select year, count(1) as cnt from imdb_partitioned group by year;
```
* 2가지 테이블 조회 시의 차이점을 비교합니다
```bash
explain select year, count(1) as cnt from imdb_movies group by year;
explain select year, count(1) as cnt from imdb_partitioned group by year;
```
* 관련 링크
  * [Hive Language Manul DML](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DML#LanguageManualDML-DynamicPartitionInserts)


### 2 파일포맷 변경을 통한 성능 개선
> 파일포맷을 텍스트 대신 파케이 포맷으로 변경하는 방법을 익히고, 예상한 대로 결과가 나오는지 확인합니다 

* 파케이 포맷 기반의 테이블을 CTAS (Create Table As Select) 통해 생성합니다 (단, CTAS 는 SELECT 절을 명시하지 않습니다)
```bash
beeline>
drop table if exists imdb_parquet;
create table imdb_parquet row format delimited stored as parquet as select * from imdb_movies;
select year, count(1) as cnt from imdb_parquet group by year;
```
* 텍스트, 파티션 및 파케이 테이블의 조회시에 어떤 차이점이 있는지 확인해 봅니다.
```bash
beeline>
explain select year, count(1) as cnt from imdb_movies group by year;
# Statistics: Num rows: 3096 Data size: 309656 Basic stats: COMPLETE Column stats: NONE

explain select year, count(1) as cnt from imdb_partitioned group by year;
# Statistics: Num rows: 1000 Data size: 302786 Basic stats: COMPLETE Column stats: NON

explain select year, count(1) as cnt from imdb_parquet group by year;
#  Statistics: Num rows: 1000 Data size: 12000 Basic stats: COMPLETE Column stats: NONE

create table imdb_parquet_sorted stored as parquet as select title, rank, metascore, year from imdb_movies sort by metascore;
```
* 파케이 파일 테이블의 경우에도 필요한 컬럼만 유지하는 것이 효과가 있는지 확인해봅니다
```bash
beeline>
create table imdb_parquet_small stored as parquet as select title, rank, metascore, year from imdb_movies sort by metascore;
```bash
beeline>
explain select rank, title, metascore from imdb_parquet order by metascore desc limit 10;
# Statistics: Num rows: 1000 Data size: 12000 Basic stats: COMPLETE Column stats: NONE

explain select rank, title, metascore from imdb_parquet_small order by metascore desc limit 10;
# Statistics: Num rows: 1000 Data size: 4000 Basic stats: COMPLETE Column stats: NONE
```

### 3 비정규화를 통한 성능 개선
> 일반적으로 관계형 데이터베이스의 경우 Redundent 한 데이터 적재를 피해야만 Consistency 문제를 회피할 수 있고 변경 시에 일관된 데이터를 저장할 수 있습니다. 그래서 PK, FK 등으로 Normalization & Denormalization 과정을 거치면서 모델링을 하게 됩니다. 하지만 분산 환경에서의 정규화 했을 때의 관리 비용 보다 Join 에 의한 리소스 비용이 더 큰 경우가 많고 Join 의 문제는 Columnar Storage 나 Spark 의 도움으로 많은 부분 해소될 수 있기 때문에 Denormalization 을 통해 Superset 데이터를 가지는 경우가 더 많습니다. 
> Daily Batch 작업에서 아주 큰 Dimension 데이터를 생성하고 Daily Logs 와 Join 한 모든 데이터를 가진 Fact 데이터를 생성 (User + Daily logs) 하고 이 데이터를 바탕으로 일 별 Summary 혹은 다양한 분석 지표를 생성하는 것이 효과적인 경우가 많습니다
* 분산 환경의 대부분의 프레임워크나 엔진들은 트랜잭션 및 Consistency 성능을 희생하여 처리량과 조회 레이턴시를 향상시키는 경우가 많습니다
* OLTP 가 아니라 OLAP 성 데이터 분석 및 조회의 경우에는 Join 을 통해 실시간 데이터 보다 Redundent 한 데이터를 가지고 빠른 분석이 더 유용한 경우가 많습니다
* 특히 Spark 의 경우에도 RDD 는 Immutable 이며 모든 RDD 는 새로 생성되는 구조인 점을 보면 더 이해가 빠르실 것입니다 

### 4 글로벌 정렬 회피를 통한 성능 개선
>  Order By, Group By, Distribute By, Sort By, Cluster By 실습을 통해 차이점을 이해하고 활용합니다
* Q1) 예제 emp.txt 파일은 중복된 레코드가 많아서 어떻게 하면 중복을 제거하고 emp.uniq.txt 파일을 생성할 수 있을까요?
  * Hint) cat, sort and redirection
```bash
bash>
docker exec -it hive_hive-server_1 bash
cd /opt/hive/examples
cat emp.txt
```
* 비라인을 통해 직원 및 부서 테이블을 생성합니다
```bash
bash>
beeline jdbc:hive2://localhost:10000 scott tiger
use default;

beeline>
drop table if exists employee;
create table employee (name string, dept_id int, seq int) row format delimited fields terminated by '|';
load data local inpath '/opt/hive/examples/files/emp.uniq.txt' into table employee;

drop table if exists department;
create table department (id int, name string) row format delimited fields terminated by '|';
load data local inpath '/opt/hive/examples/files/dept.txt' into table department;
```
* Q2) 테이블의 정보를 조회하고 어떻게 조인해야 employee + department 정보를 가진 테이블을 조회할 수 있을까요?
  * Hint) SELECT a.kly, b.key FROM tableA a JOIN tableB b ON A.key = B.key
```bash
beeline>
desc employee;
desc department;
```
* Q3) 직원 이름, 지원 부서 아이디, 직원 부서 이름을 가진 users 테이블을 생성할 수 있을까요?
  * Hint) CREATE TABLE users AS SELECT ...
```bash
beeline>
```
* Order By - 모든 데이터가 해당 키에 대해 정렬됨을 보장합니다
```bash
beeline>
select * from employee order by dept_id;
```
* Group By - 군집 후 집계함수를 사용할 수 있습니다
```bash
beeline>
select dept_id, count(*) from employee group by dept_id;
```
* Sort By - 해당 파티션 내에서만 정렬을 보장합니다 - mapred.reduce.task = 2 라면 2개의 개별 파티션 내에서만 정렬됩니다
```bash
beeline>
set mapred.reduce.task = 2;
select * from employee sort by dept_id desc;
```
* Distribute By - 단순히 해당 파티션 별로 구분되어 실행됨을 보장합니다 - 정렬을 보장하지 않습니다.
```bash
beeline>
select * from employee distribute by dept_id;
```
* Distribute By Sort By - 파티션과 해당 필드에 대해 모두 정렬을 보장합니다
```bash
beeline>
select * from employee distribute by dept_id sort by dept_id asc, seq desc;
```
* Cluster By - 파티션 정렬만 보장합니다 - 특정필드의 정렬이 필요하면 Distribute By Sort By 를 사용해야 합니다
```bash
beeline>
select * from employee cluster by dept_id;
```
* 전체 Global Order 대신 어떤 방법을 쓸 수 있을까?
  * Differences between rank and row\_number : rank 는 tiebreak 시에 같은 등수를 매기고 다음 등수가 없으나 row\_number 는 아님
```bash
beeline>
select * from ( select name, dept_id, seq, rank() over (partition by dept_id order by seq desc) as rank from employee ) t where rank < 2;
```


### 5 버킷팅을 통한 성능 개선
> 버킷팅을 통해 생성된 테이블의 조회 성능이 일반 파케이 테이블과 얼마나 성능에 차이가 나는지 비교해봅니다
* 파케이 테이블의 생성시에 버킷을 통한 인덱스를 추가해서 성능을 비교해 봅니다 (단, CTAS 에서는 partition 혹은 clustered 를 지원하지 않습니다)
```bash
beeline>
create table imdb_parquet_bucketed (rank int, title string, genre string, description string, director string, actors string, runtime int, rating string, votes int, revenue string, metascore int) partitioned by (year string) clustered by (rank) sorted by (metascore) into 10 buckets row format delimited fields terminated by ',' stored as parquet;

insert overwrite table artist_parquet partition(pid=0) select id, name from artist where id % 3 = 0;

+-------+
| year  |
+-------+
| 2006  |
| 2007  |
| 2008  |
| 2009  |
| 2010  |
| 2011  |
| 2012  |
| 2013  |
| 2014  |
| 2015  |
| 2016  |
+-------+

set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;

insert overwrite table imdb_parquet_bucketed partition(year='2006') select rank, title, genre, description, director, actors, runtime, rating, votes, revenue, metascore from imdb_movies where year = '2006';
...
insert overwrite table imdb_parquet_bucketed partition(year='2016') select rank, title, genre, description, director, actors, runtime, rating, votes, revenue, metascore from imdb_movies where year = '2016';
```
* 생성된 파케이 테이블이 정상적으로 버킷이 생성되었는지 확인합니다
```bash
beeline>
desc formatted imdb_parquet_bucketed;
...
| Num Buckets:                  | 10                                                 | NULL                        |
| Bucket Columns:               | [rank]                                             | NULL                        |
| Sort Columns:                 | [Order(col:metascore, order:1)]                    | NULL                        |
...
```
* 일반 파케이 테이블과 버킷이 생성된 테이블의 스캔 성능을 비교해봅니다
> TableScan 텍스트 대비 레코드 수에서는 2% (44/1488 Rows)만 읽어오며, 데이터 크기 수준에서는 약 0.1% (484/309,656 Bytes)만 읽어오는 것으로 성능 향상이 있습니다
```bash
select rank, metascore, title from imdb_parquet where year = '2006' and rank < 101 order by metascore desc;
# Statistics: Num rows: 1000 Data size: 12000 Basic stats: COMPLETE Column stats: NONE

select rank, metascore, title from imdb_parquet_bucketed where year = '2006' and rank < 101 order by metascore desc;
# Statistics: Num rows: 44 Data size: 484 Basic stats: COMPLETE Column stats: NONE

select rank, metascore, title from imdb_movies where year = '2006' and rank < 101 order by metascore desc;
# Statistics: Num rows: 1488 Data size: 309656 Basic stats: COMPLETE Column stats: NONE
```


