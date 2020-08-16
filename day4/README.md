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

### 4 글로벌 정렬 회피를 통한 성능 개선

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


