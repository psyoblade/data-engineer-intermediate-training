# 데이터 적재 서비스 실습


## 하이브 트러블 슈팅 가이드
> IMDB 영화 예제를 통해 테이블을 생성하고, 다양한 성능 개선 방법을 시도해보면서 왜 그리고 얼마나 성능에 영향을 미치는 지 파악합니다

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

### 1. 파티셔닝을 통한 성능 개선
* 하이브 터미널을 통해 JDBC Client 로 하이브 서버에 접속합니다
```bash
docker-compose exec hive-server bash
beeline jdbc:hive2://localhost:10000 scott tiger
use default
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


### 2. 파일포맷 변경을 통한 성능 개선

### 3. 비정규화를 통한 성능 개선

### 4.글로벌 정렬 회피를 통한 성능 개선

### 5. 버킷팅을 통한 성능 개선




