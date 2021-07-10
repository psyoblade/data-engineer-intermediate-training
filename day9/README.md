# 9일차. LGDE.com 일별 지표생성 실습
> 가상의 웹 쇼핑몰 LGDE.com 주요 지표를 생성하기 위한, 접속정보, 매출 및 고객정보 등의 데이터를 수집하여 기본 지표를 생성합니다

- 목차
  * [1. 최신버전 업데이트](#1-최신버전-업데이트)
  * [2. 테이블 수집 실습](#2-테이블-수집-실습)
  * [3. 파일 수집 실습](#3-파일-수집-실습)
  * [4. 노트북 컨테이너 기동](#4-노트북-컨테이너-기동)
  * [5. 수집된 데이터 탐색](#5-수집된-데이터-탐색)
  * [6. 기본 지표 생성](#6-기본-지표-생성)
  * [7. 고급 지표 생성](#7-고급-지표-생성)

<br>

## 1. 최신버전 업데이트
> 원격 터미널에 접속하여 관련 코드를 최신 버전으로 내려받고, 과거에 실행된 컨테이너가 없는지 확인하고 종료합니다

### 1-1. 최신 소스를 내려 받습니다
```bash
# terminal
cd /home/ubuntu/work/data-engineer-intermediate-training
git pull
```

### 1-2. 현재 기동되어 있는 도커 컨테이너를 확인하고, 종료합니다

#### 1-2-1. 현재 기동된 컨테이너를 확인합니다
```bash
# terminal
docker ps -a
```

#### 1-2-2. 기동된 컨테이너가 있다면 강제 종료합니다
```bash
# terminal 
docker rm -f `docker ps -aq`
```
> 다시 `docker ps -a` 명령으로 결과가 없다면 모든 컨테이너가 종료되었다고 보시면 됩니다
<br>


## 2. 테이블 수집 실습
> 지표 생성에 필요한 고객 및 매출 테이블을 아파치 스쿱을 통해 수집합니다. <br>
로컬 환경에서 모든 데이터를 저장해두어야 테스트 및 검증이 편하기 때문에 저장은 원격 터미널의 로컬 디스크에 저장되며, 원격 터미널 서버의 로컬 디스크와 도커와는 도커 컴포즈 파일`docker-compose.yml`에서 볼륨 마운트로 구성되어 있습니다

### 2-1. *원격 터미널에 접속* 후, *스쿱 컨테이너에 접속*합니다
```bash
# terminal
cd /home/ubuntu/work/data-engineer-intermediate-training/day9
docker compose up -d
docker compose ps
echo "sleep 5 seconds"
sleep 5
docker compose exec sqoop bash
```

### 2-2. 실습명령어 검증을 위한 ask 를 리뷰하고 실습합니다
```bash
#!/bin/bash
while true; do
    echo
    echo "$ $@"
    echo
    read -p "위 명령을 실행 하시겠습니까? [y/n] " yn
    case $yn in
        [Yy]* ) $@; break;;
        [Nn]* ) exit;;
        * ) echo "[y/n] 을 입력해 주세요.";;
    esac
done
```
```bash
# docker
ask echo hello world
```
<details><summary> 정답확인</summary>

> "hello world" 가 출력되면 정상입니다

</details>
<br>


### 2-3. 수집 대상 *데이터베이스 목록*을 확인합니다
```bash
# docker
hostname="mysql"
username="sqoop"
password="sqoop"
```
```bash
# docker
ask sqoop list-databases --connect jdbc:mysql://${hostname}:3306 --username ${username} --password ${password}
```
<details><summary> 정답확인</summary>

> 아래의 총 2개의 데이터베이스가 출력되면 정답입니다 
`information_schema`
`testdb`

</details>
<br>


### 2-4. 수집 대상 *테이블 목록*을 확인합니다
```bash
# docker
database="testdb"
```
```bash
# docker
ask sqoop list-tables --connect jdbc:mysql://${hostname}:3306/$database --username ${username} --password ${password}
```
<details><summary> 정답확인</summary>

> 아래의 총 5개의 테이블이 출력되면 정답입니다
`purchase_20201025`
`purchase_20201026`
`seoul_popular_trip`
`user_20201025`
`user_20201026`

</details>
<br>


### 2-5. *일별 이용자 테이블*을 수집합니다
* 기간 : 2020/10/25 ~ 2020/10/26
* 저장 : 파케이 포맷 <kbd>--as-parquetfile</kbd>
* 기타 : 경로가 존재하면 삭제 후 수집 <kbd>--delete-target-dir</kbd>
* 소스 : <kbd>user\_20201025</kbd>, <kbd>user\_20201026</kbd>
* 타겟 : <kbd>file:///tmp/target/user/20201025</kbd>, <kbd> file:///tmp/target/user/20201026</kbd>
```bash
# docker
basename="user"
basedate=""
```

#### 2-5-1. ask 명령을 통해서 결과 명령어를 확인 후에 실행합니다
```bash
# docker
ask sqoop import -jt local -m 1 --connect jdbc:mysql://${hostname}:3306/${database} \
--username ${username} --password ${password} --table ${basename}_${basedate} \
--target-dir "file:///tmp/target/${basename}/${basedate}" --as-parquetfile --delete-target-dir
```
<details><summary> 정답확인</summary>

> `21/07/10 16:27:47 INFO mapreduce.ImportJobBase: Retrieved 5 records.` 와 같은 메시지가 출력되면 성공입니다

</details>
<br>


### 2-6. *일별 매출 테이블*을 수집합니다
* 기간 : 2020/10/25 ~ 2020/10/26
* 저장 : 파케이 포맷 <kbd>--as-parquetfile</kbd>
* 기타 : 경로가 존재하면 삭제 후 수집 <kbd>--delete-target-dir</kbd>
* 소스 : <kbd>purchase\_20201025</kbd>, <kbd>purchase\_20201026</kbd>
* 타겟 : <kbd>file:///tmp/target/purchase/20201025</kbd>, <kbd> file:///tmp/target/purchase/20201026</kbd>
```bash
# docker
basename="purchase"
basedate=""
```

#### 2-6-1. ask 명령을 통해서 결과 명령어를 확인 후에 실행합니다
```bash
# docker
ask sqoop import -jt local -m 1 --connect jdbc:mysql://${hostname}:3306/$database \
--username ${username} --password ${password} --table ${basename}_${basedate} \
--target-dir "file:///tmp/target/${basename}/${basedate}" --as-parquetfile --delete-target-dir
```
<details><summary> 정답확인</summary>

> `21/07/10 16:27:47 INFO mapreduce.ImportJobBase: Retrieved 6 records.` 와 같은 메시지가 출력되면 성공입니다

</details>
<br>


### 2-7. 모든 데이터가 정상적으로 수집 되었는지 검증합니다
> parquet-tools 는 파케이 파일의 스키마(schema), 일부내용(head) 및 전체내용(cat)을 확인할 수 있는 커맨드라인 도구입니다. 연관된 라이브러리가 존재하므로 hadoop 스크립를 통해서 수행하면 편리합니다

#### 2-7-1. 고객 및 매출 테이블 수집이 잘 되었는지 확인 후, 파일목록을 확인합니다
```bash
# docker
tree /tmp/target/user
tree /tmp/target/purchase
find /tmp/target -name "*.parquet"
```
#### 2-7-2. 출력된 파일 경로를 복사하여 경로르 변수명에 할당합니다
```bash
# docker
filename=""
```

#### 2-7-3. 대상 파일경로 전체를 복사하여 아래와 같이 스키마를 확인합니다
```bash
# docker
ask hadoop jar /jdbc/parquet-tools-1.8.1.jar schema file://${filename}
```
<details><summary> 정답확인</summary>

> 아래와 같은 출력이 나오면 성공입니다
```
message user_20201025 {
  optional int32 u_id;
  optional binary u_name (UTF8);
  optional binary u_gender (UTF8);
  optional int32 u_signup;
}
```

</details>
<br>


#### 2-7-4. 파일 내용의 데이터가 정상적인지 확인합니다
```bash
# docker
ask hadoop jar /jdbc/parquet-tools-1.8.1.jar cat file://${filename}
```
<details><summary> 정답확인</summary>

> <kbd><samp>Ctrl</samp>+<samp>D</samp></kbd> 혹은 <kbd>exit</kbd> 명령으로 컨테이너에서 빠져나와 `원격 터미널` 로컬 디스크에 모든 파일이 모두 수집되었다면 테이블 수집에 성공한 것입니다

</details>
<br>


#### 2-7-5. `원격 터미널` 장비에도 잘 저장 되어 있는지 확인합니다
```bash
# terminal
find notebooks -name '*.parquet'
```
<br>


## 3. 파일 수집 실습

### 3-1. *원격 터미널에 접속* 후, *플루언트디 컨테이너에 접속*합니다

#### 3-1-1. 서버를 기동합니다 (컨테이너가 종료된 경우)
```bash
# terminal
cd /home/ubuntu/work/data-engineer-intermediate-training/day9
docker compose up -d
docker compose ps
```

#### 3-1-2. 플루언트디 컨테이너에 접속합니다
```bash
# docker
docker compose exec fluentd bash
```

#### 3-1-3. 이전 작업내역을 모두 초기화 하고 다시 수집해야 한다면 아래와 같이 정리합니다
```bash
# docker
ask rm -rf /tmp/source/access.csv /tmp/source/access.pos /tmp/target/\$\{tag\}/ /tmp/target/access/
```

#### 3-1-4. 비어있는 이용자 접속로그를 생성합니다
```bash
# docker
ask touch /tmp/source/access.csv
```

#### 3-1-5. 수집 에이전트인 플루언트디를 기동시킵니다
```bash
# docker
ask fluentd -c /etc/fluentd/fluent.tail
```
<details> <summary> 플루언트디 설정을 확인합니다 </summary>
<p>

```bash
<source>
    @type tail
    @log_level info
    path /tmp/source/access.csv
    pos_file /tmp/source/access.pos
    refresh_interval 5
    multiline_flush_interval 5
    rotate_wait 5
    open_on_every_update true
    emit_unmatched_lines true
    read_from_head false
    tag access
    <parse>
        @type csv
        keys a_time,a_uid,a_id
        time_type unixtime
        time_key a_time
        keep_time_key true
        types a_time:time:unixtime,a_uid:integer,a_id:string
    </parse>
</source>

<match access>
    @type file
    @log_level info
    add_path_suffix true
    path_suffix .json
    path /tmp/target/${tag}/%Y%m%d/access.%Y%m%d.%H%M
    <format>
        @type json
    </format>
    <inject>
        time_key a_timestamp
        time_type string
        timezone +0900
        time_format %Y-%m-%d %H:%M:%S.%L
        tag_key a_tag
    </inject>
    <buffer time,tag>
        timekey 1m
        timekey_use_utc false
        timekey_wait 10s
        timekey_zone +0900
        flush_mode immediate
        flush_thread_count 8
    </buffer>
</match>

<match debug>
    @type stdout
    @log_level debug
</match>
```

</p>
</details>


### 3-2. 또 다른 `원격 터미널` 접속 후, 플로언트디 컨테이너에 접속합니다
> 기존의 터미널에서는 로그를 수집하는 에이전트가 데몬으로 항상 동작하고 있기 때문에, 별도의 터미널에서 실제 애플리케이션이 동작하는 것을 시뮬레이션 하기 위해 별도의 터미널로 접속하여 테스트를 합니다

#### 3-2-1. 새로운 `원격 터미널`을 접속합니다
```bash
# terminal
docker compose exec fluentd bash
```

#### 3-2-2. 실제 로그가 쌓이는 것 처럼 access.csv 파일에 임의의 로그를 redirect 하여 로그를 append 합니다
```bash
# docker
cat /etc/fluentd/access.csv >> /tmp/source/access.csv
```

#### 3-2-3. 수집된 로그가 정상적인 JSON 파일인지 확인합니다
```bash
# docker
tree -L2 /tmp/target
find /tmp/target -name '*.json' | head
```

#### 3-2-4. 원본 로그와, 최종 수집된 로그의 레코드 수가 같은지 확인합니다
```bash
# docker
cat `find /tmp/target -name '*.json'` | wc -l
wc -l /tmp/source/access.csv
```

<details><summary> 정답확인</summary>

> 수집된 파일의 라인 수와, 원본 로그의 라인 수가 일치한다면 정상적으로 수집되었다고 볼 수 있으며, <kbd><samp>Ctrl</samp>+<samp>D</samp></kbd> 혹은 <kbd>exit</kbd> 명령으로 컨테이너에서 빠져나와 `원격 터미널` 로컬 디스크에 JSON 파일이 확인 되었다면 웹 로그 수집에 성공한 것입니다
```bash
# terminal
find notebooks -name '*.json'
```

</details>
<br>


## 4. 노트북 컨테이너 기동

> 본 장에서 수집한 데이터를 활용하여 데이터 변환 및 지표 생성작업을 위하여 주피터 노트북을 열어둡니다

### 4-1. 노트북 주소를 확인하고, 크롬 브라우저로 접속합니다
```bash
# terminal
docker compose logs notebook | grep 8888
```
> 출력된  URL을 복사하여 `127.0.0.1:8888` 대신 개인 `<hostname>.aiffelbiz.co.kr:8888` 으로 변경하여 크롬 브라우저를 통해 접속하면, jupyter notebook lab 이 열리고 work 폴더가 보이면 정상기동 된 것입니다
<br>


## 5. 수집된 데이터 탐색

> 스파크 세션을 통해서 수집된 데이터의 형태를 파악하고, 스파크의 기본 명령어를 통해 수집된 데이터 집합을 탐색합니다

### 5-1. 스파크 세션 생성

#### 5-1-1. 스파크 객체를 생성하는 코드를 작성하고, <kbd><kbd>Shift</kbd>+<kbd>Enter</kbd></kbd> 로 스파크 버전을 확인합니다
```python
# 코어 스파크 라이브러리를 임포트 합니다
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *

spark = (
    SparkSession
    .builder
    .appName("Data Engineer Training Course")
    .config("spark.sql.session.timeZone", "Asia/Seoul")
    .getOrCreate()
)

# 노트북에서 테이블 형태로 데이터 프레임 출력을 위한 설정을 합니다
from IPython.display import display, display_pretty, clear_output, JSON
spark.conf.set("spark.sql.repl.eagerEval.enabled", True) # display enabled
spark.conf.set("spark.sql.repl.eagerEval.truncate", 100) # display output columns size
spark
```
<details><summary> 정답확인</summary>

> 스파크 엔진의 버전 `v3.0.1`이 출력되면 성공입니다

</details>
<br> 


#### 5-1-2. 수집된 테이블을 데이터프레임으로 읽고, 스키마 및 데이터 출력하기

> 파케이 포맷의 경우는 명시적인 스키마 정의가 되어 있지만, Json 포맷의 경우는 데이터의 값에 따라 달라질 수 있기 때문에 데이터를 읽어들일 때에 주의해야 합니다

* 데이터프레임 변수명 및 경로는 아래와 같습니다
  - 2020/10/25 일자 고객 (parquet) : <kbd>user25</kbd> <- <kbd>user/20201025</kbd> 
  - 2020/10/25 일자 매출 (parquet) : <kbd>purchase25</kbd> <- <kbd>purchase/20201025</kbd> 
  - 2020/10/25 일자 접속 (json) : <kbd>access25</kbd> <- <kbd>access/20201025</kbd> 

* 아래의 제약조건을 만족 시켜야 합니다
  - 입력 포맷이 Json 인 경우는 json 명령어와 추정(infer) 옵션을 사용하세요 <kbd>spark.read.option("inferSchema", "true").json("access/20201024")</kbd> 
  - 모든 데이터에 대한 스키마를 출력하세요 <kbd>dataFrame.printSchema()</kbd> 
  - 데이터 내용을 출력하여 확인하세요 <kbd>dataFrame.show() 혹은 display(dataFrame)</kbd> 

* 고객 정보 파일을 읽고, 스키마와 데이터 출력하기
```python
user25 = spark.read.parquet("user/20201025")
user25.printSchema()
user25.show(truncate=False)
display(user25)
```

* 매출 정보 파일을 읽고, 스키마와 데이터 출력하기
```python
purchase25 = <매출 데이터 경로에서 읽어서 스키마와, 데이터를 출력하는 코드를 작성하세요>
```

* 접속 정보 파일(json)을 읽고, 스키마와 데이터 출력하기
```python
access25 = <접속 데이터 경로에서 읽어서 스키마와, 데이터를 출력하는 코드를 작성하세요>
```
<details><summary> 정답확인</summary>

> 고객, 매출 및 접속 데이터의 스키마와, 데이터가 모두 출력되면 성공입니다

</details>
<br>


### 5-2. 수집된 고객, 매출 및 접속 임시 테이블 생성

#### 5-2-1. 데이터프레임을 이용하여 임시테이블 생성하기
```python
user25.createOrReplaceTempView("user25")
purchase25.createOrReplaceTempView("purchase25")
access25.createOrReplaceTempView("access25")
spark.sql("show tables '*25'")
```
<details><summary> 정답확인</summary>

> `show tables` 결과로 `user25`, `purchase25`, `access25` 3개 테이블이 출력되면 성공입니다

</details>
<br>


### 5-3. SparkSQL을 이용하여 테이블 별 데이터프레임 생성하기

#### 5-3-1. 아래에 비어있는 조건을 채워서 올바른 코드를 작성하세요

* 아래의 조건이 만족되어야 합니다
  - 2020/10/25 에 등록(`u_signup`)된 유저만 포함될 것 <kbd>`u_signup` >= '20201025' and `u_signup` < '20201026'</kbd>
  - 2020/10/25 에 발생한 매출(`p_time`)만 포함할 것 <kbd>`p_time` >= '2020-10-25 00:00:00' and `p_time` < '2020-10-26 00:00:00'</kbd>

```python
u_signup_condition = "<10월 25일자에 등록된 유저만 포함되는 조건을 작성합니다>"
user = spark.sql("select u_id, u_name, u_gender from user25").where(u_signup_condition)
user.createOrReplaceTempView("user")

p_time_condition = "<10월 25일자에 발생한 매출만 포함되는 조건을 작성합니다>"
purchase = spark.sql("select from_unixtime(p_time) as p_time, p_uid, p_id, p_name, p_amount from purchase25").where(p_time_condition)
purchase.createOrReplaceTempView("purchase")

access = spark.sql("select a_id, a_tag, a_timestamp, a_uid from access25")
access.createOrReplaceTempView("access")

spark.sql("show tables")
```
<details><summary> 정답확인</summary>

> `show tables` 결과에 총 6개의 테이블이 출력되면 성공입니다

</details>
<br>


### 5-4. 생성된 테이블을 SQL 문을 이용하여 탐색하기
> SQL 혹은 DataFrame API 어느 쪽을 이용하여도 무관하며, 결과만 동일하게 나오면 정답입니다

#### 5-4-1. 한 쪽의 성별('남' 혹은 '여')을 가진 목록을 출력하세요
```python
whereCondition = "<성별을 구별하는 조건을 작성하세요>"
spark.sql("select * from user").where(whereCondition)
```

#### 5-4-2. 상품금액이 200만원을 초과하는 매출 목록을 출력하세요
```python
selectClause = "<금액을 필터하는 조건을 작성하세요>"
spark.sql(selectClause)
```

#### 5-4-3. GroupBy 구문을 이용하여 로그인, 로그아웃 횟수를 출력하세요
```python
groupByClause="<로그인/아웃 컬럼을 기준으로 집계하는 구문을 작성하세요>"
spark.sql(groupByClause)
```
<details><summary> 정답확인</summary>

> 위에서부터 각각 "남:3, 여:2", "2개", "login:7, logout:5" 이 나오면 정답입니다

</details>
<br>


## 6. 기본 지표 생성

> 생성된 테이블을 통하여 기본 지표(DAU, DPU, DR, ARPU, ARPPU) 를 생성합니다

### 6-1. DAU (Daily Activer User) 지표를 생성하세요

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 지정한 일자의 접속한 유저 수 <kbd>count(distinct `a_uid`)</kbd>
  - 지표산식 : 지정한 일자의 접속 테이블에 로그(로그인 혹은 로그아웃)가 한 번 이상 발생한 이용자의 빈도수
  - 입력형태 : access 테이블
  - 출력형태 : number (컬럼명: DAU)

```python
display(access)
# distinctAccessUser = "select <고객수 집계함수> as DAU from access"
# dau = spark.sql(distinctAccessUser)
# display(dau)
```
<details><summary> 정답확인</summary>

> "DAU : 5"가 나오면 정답입니다 

</details>
<br>


### 6-2. DPU (Daily Paying User) 지표를 생성하세요

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 지정한 일자의 구매 유저 수 <kbd>count(distinct `p_uid`)</kbd>
  - 지표산식 : 지정한 일자의 구매 테이블에 한 번이라도 구매가 발생한 이용자의 빈도수
  - 입력형태 : purchase 테이블
  - 출력형태 : number (컬럼명: PU)

```python
display(purchase)
# distinctPayingUser = "<구매 고객수 집계함수>"
# pu = spark.sql(distinctPayingUser)
# display(pu)
```
<details><summary> 정답확인</summary>

> "PU : 4"가 나오면 정답입니다

</details>
<br>


### 6-3. DR (Daily Revenue) 지표를 생성하세요

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 지정한 일자에 발생한 총 매출 금액 <kbd>sum(`p_amount`)</kbd>
  - 지표산식 : 지정한 일자의 구매 테이블에 저장된 전체 매출 금액의 합
  - 입력형태 : access 테이블
  - 출력형태 : number (컬럼명: DR)

```python
display(purchase)
# sumOfDailyRevenue = "<일 별 구매금액 집계함수>"
# dr = spark.sql(sumOfDailyRevenue)
# display(dr)
```
<details><summary> 정답확인</summary>

> "DR : 12200000" 이 나오면 정답입니다

</details>
<br> 


### 6-4. ARPU (Average Revenue Per User) 지표를 생성하세요

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 유저 당 평균 발생 매출 금액
  - 지표산식 : 총 매출 / 전체 유저 수 = DR / DAU
  - 입력형태 : Daily Revenue, Daily Active User
  - 출력형태 : number (문자열: ARPU )

```python
v_dau = dau.collect()[0]["DAU"]
v_pu = pu.collect()[0]["PU"]
v_dr = dr.collect()[0]["DR"]

# print("ARPU : {}".format(<유저당 매출 금액 계산식>))
```
<details><summary> 정답확인</summary>

> "ARPU : 2440000.0" 가 나오면 정답입니다

</details>
<br>


### 6-5. ARPPU (Average Revenue Per Paying User) 지표를 생성하세요

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 유저 당 평균 발생 매출 금액
  - 지표산식 : 총 매출 / 전체 유저 수 = DR / PU
  - 입력형태 : Daily Revenue, Daily Paying User
  - 출력형태 : number

```python
# print("ARPPU : {}".format(<구매유저 당 매출 금액 계산식>))
```
<details><summary> 정답확인</summary>

> "ARPPU : 3050000.0" 가 나오면 정답입니다

</details>
<br>


## 7. 고급 지표 생성

### 7-1. 디멘젼 테이블을 설계 합니다

* 아래의 조건이 만족해야 합니다
  - 지표정의 : 이용자 누적 상태 정보
  - 지표산식 : 오늘까지 접속한 모든 유저의 정보를 저장하는 테이블
  - 입력형태 : user, purchase, access
  - 출력형태 : 아래와 같이 설계합니다

* 디멘젼 테이블의 스키마는 아래와 같습니다

| 컬럼명 | 컬럼타입 | 설명 |
| --- | --- | --- |
| `d_uid` | integer | 아이디 |
| `d_name` | string | 이름 |
| `d_pamount` | integer | 누적 구매 금액 |
| `d_pcount` | integer | 누적 구매 횟수 |
| `d_acount` | integer | 누적 접속 횟수 |
| `d_first_purchase` | string | 최초 구매 일시 |
| `dt` | string | 유저아이디 |

> 디멘젼 테이블을 통해서 어떻게 생성할 것인지 생각해 보시기 바랍니다
<br>


### 7-2. 오픈 첫 날 접속한 모든 고객 및 접속 횟수를 가진 데이터프레임을 생성합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 오늘 접속한 이용자 <kbd>select `a_uid`, count(`a_uid`) ... group by `a_uid`</kbd>
  - 지표산식 : 접속 여부는 'login' 로그가 존재하면 접속한 유저로 가정
  - 입력형태 : user
  - 출력형태 : `a_uid`, `a_count`
  - 정렬형태 : `a_uid` asc

* access 테이블로부터 `a_uid` 가 'login' 인 `a_uid` 값의 빈도수를 group by `a_uid` 집계를 통해 구하시오
```python
access.printSchema()
# countOfAccess = "select a_uid, <집계함수> from user <집계 구문>"
# accs = spark.sql(countOfAccess)
# display(accs)
```
<details><summary> 정답확인</summary>

> 접속 빈도가 가장 높은 이용자는 `a_id` 가 "2, 4"번으로 2명이 나오면 정답입니다

</details>
<br>


### 7-3. 일 별 이용자 별 총 매출 금액과, 구매 횟수를 가지는 데이터프레임을 생성합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 이용자 별 매출 횟수와, 합 <kbd>select `p_uid`, count(`p_uid`), sum(`p_amount`) ... group by `p_uid`</kbd>
  - 지표산식 : 매출 금액을 이용자 별 집계를 합니다
  - 입력형태 : purchase
  - 출력형태 : `p_uid`, `p_count`, `p_amount`
  - 정렬형태 : `p_count` desc`, p_amount` desc

* purchase 테이블로 부터 `p_uid` 별 매출 횟수(count)와, 매출 금액의 합(sum)을 구하는 집계 쿼리를 생성 하시오
```python
purchase.printSchema()
# sumOfCountAndAmount = "select p_uid, <빈도 집계함수>, <매출 집계함수> from purchase <집계조건>"
# amts = spark.sql(sumOfCountAndAmount)
# display(amts)
```
<details><summary> 정답확인</summary>

> 매출 금액이 600만원에 2회 발생한 5번 유저가 1위이면 정답입니다

</details>
<br>


### 7-4. 이용자 정보와 구매 정보와 조인합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 이용자 데이터와 매출 정보의 결합 <kbd>leftSide.join(rightSide, joinCondition, joinHow)</kbd>
  - 지표산식 : 이용자는 반드시 존재해야하며, 매출은 없어도 됩니다 (`left_outer`)
  - 입력형태 : accs, amts
  - 출력형태 : `a_uid`, `a_count`, `p_uid`, `p_count`, `p_amount`
  - 정렬형태 : `a_uid` asc

* 7-1 에서 생성한 accs 와 7-2 에서 생성한 amts 데이터를 uid 값을 기준으로 left outer 조인을 수행합니다
```python
accs.printSchema()
amts.printSchema()
# joinCondition = <고객과 매출 조인 조건>
# joinHow = "<조인 방식>"
# dim1 = accs.join(amts, joinCondition, joinHow)
# dim1.printSchema()
# display(dim1.orderBy(asc("a_uid")))
```
<details><summary> 정답확인</summary>

> uid 가 4번인 이용자만 매출 정보가 null 이면 정답입니다

</details>
<br>


### 7-5. 고객 정보를 추가합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 고객의 이름과 성별을 추가합니다 
  - 지표산식 : dim1 테이블과 고객정보를 결합합니다
  - 입력형태 : dim1, user
  - 출력형태 : `a_uid`, `a_count`, `p_uid`, `p_count`, `p_amount`, `u_id`, `u_name`, `u_gender`
  - 정렬형태 : `a_uid` asc

* 7-4 에서 생성한 dim1 데이터와 user 데이터를 결합합니다
```python
dim1.printSchema()
user.printSchema()
# joinCondition = <디멘젼과 고객정보 조인 조건>
# joinHow = "<조인 방식>"
# dim2 = dim1.join(user, joinCondition, joinHow)
# dim2.printSchema()
# display(dim2.orderBy(asc("a_uid")))
```
<details><summary> 정답확인</summary>

> uid 가 4번인 이용자만 매출 정보가 null 이면 정답입니다

</details>
<br>


### 7-6. 중복되는 ID 컬럼은 제거하고, 숫자 필드에 널값은 0으로 기본값을 넣어줍니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 중복되는 uid 컬럼을 제거하고, 매출정보가 없는 계정은 0으로 기본값을 넣어줍니다
  - 지표산식 : <kbd>fillDefaultValue = {"`p_amount`":0, "`p_count`":0}</kbd>
  - 입력형태 : dim2
  - 출력형태 : `a_uid`, `a_count`, `p_amount`, `p_count`, `u_name`, `u_gender`
  - 정렬형태 : `a_uid` asc

* 7-4 에서 생성한 dim1 데이터와 user 데이터를 결합하되, 중복 컬럼은 제거하고, 기본값을 0으로 채우는 `fillDefaultValue`를 작성하세요
```python
dim2.printSchema()
dim3 = dim2.drop("p_uid", "u_id")
# fillDefaultValue = {<기본값을 넣을 컬럼과 기본값 사전> }
# dim4 = dim3.na.fill(fillDefaultValue)
# dim4.printSchema()
# display(dim4.orderBy(asc("a_uid")))
```
<details><summary> 정답확인</summary>

> uid 가 4번인 이용자만 매출 정보가 0 이면 정답입니다

</details>
<br>


### 7-7. 생성된 유저 테이블을 재사용 가능하도록 컬럼 명을 변경합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 컬럼명이 `d_`로 시작하도록 일괄 변경합니다
  - 지표산식 : <kbd>withColumnRenamed("`a_uid`", "`d_uid`" )</kbd>
  - 입력형태 : dim4
    - dimension 테이블이므로 `d_`로 시작하는 컬럼 규칙을 따릅니다
    - access, purchase 와 같이 개별 테이블의 prefix 를 이용해서 `d_a<column-name>` 혹은 `d_p<column-name>` 규칙을 따릅니다
  - 출력형태 : `d_uid`, `d_name`, `d_gender`, `d_acount`, `d_pamount`, `d_pcount`
  - 정렬형태 : `d_uid` asc

* 7-6 에서 생성한 dim4 의 모든 컬럼이 `d_`로 시작하도록 Rename 하여 정리합니다
```python
dim4.printSchema()
# dim5 = (
#     dim4
#     .withColumnRenamed("a_uid", "d_uid")
#     <컬럼 a_count 부터 u_gender 까지 d_ 로 시작하도록 컬럼명 변경>
#    .drop("a_uid", "a_count", "p_amount", "p_count", "u_name", "u_gender")
#    .select("d_uid", "d_name", "d_gender", "d_acount", "d_pamount", "d_pcount")
# )
display(dim5.orderBy(asc("d_uid")))
```
<details><summary> 정답확인</summary>

> 모든 컬럼이 `d_`로 시작하고 6개의 컬럼으로 구성되어 있다면 정답입니다

</details>
<br>


### 7-8. 최초 구매 유저 정보를 추가합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 최초 구매 정보를 추가합니다 <kbd>expr("case when `d_first_purchase` is null then `p_time` else `d_first_purchase` end")</kbd>
  - 지표산식 : 해당 일자의 가장 처음 구매한 구매일시를 이용하여 최초구매일을 구합니다 <kbd>dim5.withColumn("`d_first_purchase`, lit(None))</kbd>
  - 입력형태 : dim5
  - 출력형태 : `d_uid`, `d_count`, `d_amount`, `d_count`, `d_name`, `d_gender`, `d_first_purchase`
  - 정렬형태 : `d_uid` asc

* selectFirstPurchaseTime 는 하루에 여러번 구매가 있을 수 있으므로 가장 먼저 구매한 일시를 min 함수를 `p_time` 의 최소값을 구합니다
```python
purchase.printSchema()
# selectFirstPurchaseTime = "select p_uid, <최소값함수> as p_time from purchase <집계구문>"
# 
# first_purchase = spark.sql(selectFirstPurchaseTime)
# dim6 = dim5.withColumn("d_first_purchase", lit(None))
# dim6.printSchema()
# 
# exprFirstPurchase = expr("case when d_first_purchase is null then p_time else d_first_purchase end")
# 
# dim7 = (
#     dim6.join(first_purchase, dim5.d_uid == first_purchase.p_uid, "left_outer")
#     .withColumn("first_purchase", exprFirstPurchase)
#     .drop("d_first_purchase", "p_uid", "p_time")
#     .withColumnRenamed("first_purchase", "d_first_purchase")
# )
#     
# dimension = dim7.orderBy(asc("d_uid"))
# dimension.printSchema()
# display(dimension)
```
<details><summary> 정답확인</summary>

> 4번 고객의 제외한 모든 첫 번째 구매 일시가 출력되면 정답입니다

</details>
<br>


### 7-9. 생성된 디멘젼을 저장소에 저장합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 저장위치 : "dimension/dt=20201025" <kbd>dataFrame.write</kbd>
  - 저장옵션 : 대상 경로가 존재하더라도 덮어씁니다 <kbd>.mode("overwrite")</kbd>
  - 저장포맷 : 파케이  <kbd>.parquet("dimension/dt=20201025")</kbd>

```python
dimension.printSchema()
# target_dir="<저장경로>"
# dimension.write.mode(<저장모드>).parquet(target_dir)
```
<details><summary> 정답확인</summary>

> 저장 시에 오류가 없고 대상 경로(dimension/dt=20201025)가 생성되었다면 성공입니다

</details>
<br>


### 7-10. 생성된 디멘젼을 다시 읽어서 출력합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 저장위치 : "dimension/dt=20201025" <kbd>spark.read</kbd>
  - 저장포맷 : 파케이  <kbd>.parquet("dimension/dt=20201025")</kbd>

```python
# newDimension = <디멘젼을 읽어옵니다>
# newDimension.printSchema()
# display(newDimension)
```
<details><summary> 정답확인</summary>

> 디멘젼 테이블을 정상적으로 읽어왔고, 동일한 스키마와 데이터가 출력되었다면 정답입니다

</details>

