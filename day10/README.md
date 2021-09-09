# 10일차. LGDE.com 일별 지표생성 실습

> 가상의 웹 쇼핑몰 LGDE.com 2일차에 전일자 데이터를 활용하여 누적된 데이터를 저장 관리하고, 운영 개발하는 과정을 학습합니다

- 범례
  * :green_book: : 기본, :blue_book: : 중급, :closed_book: : 고급

- 목차
  * [1. 최신버전 업데이트](#1-최신버전-업데이트)
  * [2. 테이블 수집 실습](#2-테이블-수집-실습)
  * [3. 파일 수집 실습](#3-파일-수집-실습)
  * [4. 노트북 컨테이너 기동](#4-노트북-컨테이너-기동)
  * [5. 수집된 데이터 탐색](#5-수집된-데이터-탐색)
  * [6. 기본 지표 생성](#6-기본-지표-생성)
  * [7. 고급 지표 생성](#7-고급-지표-생성)
  * [8. 질문 및 컨테이너 종료](#8-질문-및-컨테이너-종료)


- 정답
  * [프로젝트 2일차 정답](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day9/notebooks/answer/data-engineer-lgde-day2-answer.html)
  * [프로젝트 3일차 정답](https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day9/notebooks/answer/data-engineer-lgde-day3-answer.pdf)

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
> 아래와 같은 메시지가 출력되고 모든 컨테이너가 종료되면 정상입니다

```
[+] Running 4/5
 ⠿ Network default_network  Created   2.9s
 ⠿ Container mysqlStarted   5.6s
 ⠿ Container notebook       Started   9.3s
 ⠿ Container fluentd        Started   7.0s
 ⠿ Container sqoopStarting 10.0s
```
<br>


### 2-2. 수집 대상 테이블을 조회해 봅니다
```bash
# docker
hostname="mysql"
username="sqoop"
password="sqoop"
database="testdb"
```
```bash
# docker
ask sqoop eval --connect jdbc:mysql://mysql:3306/${database} --username ${username} --password ${password} -e "select * from user_20201026"
```
<details><summary> :blue_book: 1. [중급] 정답확인</summary>

> 아래의 총 9개의 레코드가 출력되면 성공입니다

```text
----------------------------------------------------------
| u_id       | u_name             | u_gender | u_signup   |
----------------------------------------------------------
| 1          | 정휘센             | 남       | 20201025   |
| 2          | 김싸이언           | 남       | 20201025   |
| 3          | 박트롬             | 여       | 20201025   |
| 4          | 청소기             | 남       | 20201025   |
| 5          | 유코드제로         | 여       | 20201025   |
| 6          | 윤디오스           | 남       | 20201026   |
| 7          | 임모바일           | 남       | 20201026   |
| 8          | 조노트북           | 여       | 20201026   |
| 9          | 최컴퓨터           | 남       | 20201026   |
----------------------------------------------------------
```

</details>
<br>

### 2-3. *일별 이용자 테이블*을 수집합니다
* 기간 : 2020/10/26
* 저장 : 파케이 포맷 <kbd>--as-parquetfile</kbd>
* 기타 : 경로가 존재하면 삭제 후 수집 <kbd>--delete-target-dir</kbd>
* 소스 : <kbd>user\_20201026</kbd>
* 타겟 : <kbd>file:///tmp/target/user/20201026</kbd>
```bash
# docker
basename="user"
basedate="<수집기준_일자를입력하세요>"
```

#### 2-3-1. ask 명령을 통해서 결과 명령어를 확인 후에 실행합니다
```bash
# docker
ask sqoop import -jt local -m 1 --connect jdbc:mysql://${hostname}:3306/${database} \
--username ${username} --password ${password} --table ${basename}_${basedate} \
--target-dir "file:///tmp/target/${basename}/${basedate}" --as-parquetfile --delete-target-dir
```
<details><summary> :blue_book: 2. [중급] 정답확인</summary>

> `21/07/10 16:27:47 INFO mapreduce.ImportJobBase: Retrieved 9 records.` 와 같은 메시지가 출력되면 성공입니다

</details>
<br>


### 2-4. *일별 매출 테이블*을 수집합니다
* 기간 : 2020/10/26
* 저장 : 파케이 포맷 <kbd>--as-parquetfile</kbd>
* 기타 : 경로가 존재하면 삭제 후 수집 <kbd>--delete-target-dir</kbd>
* 소스 : <kbd>purchase\_20201026</kbd>
* 타겟 : <kbd>file:///tmp/target/purchase/20201026</kbd>
```bash
# docker
basename="purchase"
basedate="<수집기준_일자를입력하세요>"
```

#### 2-4-1. ask 명령을 통해서 결과 명령어를 확인 후에 실행합니다
```bash
# docker
ask sqoop import -jt local -m 1 --connect jdbc:mysql://${hostname}:3306/$database \
--username ${username} --password ${password} --table ${basename}_${basedate} \
--target-dir "file:///tmp/target/${basename}/${basedate}" --as-parquetfile --delete-target-dir
```
<details><summary> :blue_book: 3. [중급] 정답확인</summary>

> `21/07/10 16:27:47 INFO mapreduce.ImportJobBase: Retrieved 11 records.` 와 같은 메시지가 출력되면 성공입니다

</details>
<br>


### 2-5. 모든 데이터가 정상적으로 수집 되었는지 검증합니다
> parquet-tools 는 파케이 파일의 스키마(schema), 일부내용(head) 및 전체내용(cat)을 확인할 수 있는 커맨드라인 도구입니다. 연관된 라이브러리가 존재하므로 hadoop 스크립를 통해서 수행하면 편리합니다

#### 2-5-1. 고객 및 매출 테이블 수집이 잘 되었는지 확인 후, 파일목록을 확인합니다
```bash
# docker
tree /tmp/target/user
tree /tmp/target/purchase
find /tmp/target -name "*.parquet"
```
#### 2-5-2. 출력된 파일 경로를 복사하여 경로르 변수명에 할당합니다
```bash
# docker
filename="<출력된_파케이파일의_경로를_입력하세요>"
```

#### 2-5-3. 대상 파일경로 전체를 복사하여 아래와 같이 스키마를 확인합니다
```bash
# docker
ask hadoop jar /jdbc/parquet-tools-1.8.1.jar schema file://${filename}
```
<details><summary> :blue_book: 4. [중급] 정답확인</summary>

> 매출(purchase) 테이블의 경우 아래와 같은 출력이 나오면 성공입니다
```
message user_20201026 {
  optional int32 u_id;
  optional binary u_name (UTF8);
  optional binary u_gender (UTF8);
  optional int32 u_signup;
}

message purchase_20201026 {
  optional binary p_time (UTF8);
  optional int32 p_uid;
  optional int32 p_id;
  optional binary p_name (UTF8);
  optional int32 p_amount;
}
```

</details>
<br>


#### 2-5-4. 파일 내용의 데이터가 정상적인지 확인합니다
```bash
# docker
ask hadoop jar /jdbc/parquet-tools-1.8.1.jar cat file://${filename}
```

<details><summary> :blue_book: 5. [중급] 정답확인</summary>

> 아래와 같은 데이터가 출력되면 정상입니다

```text
p_time = 1603586155
p_uid = 5
p_id = 2004
p_name = LG TV
p_amount = 2500000
```

</details>
<br>


#### 2-5-5. `원격 터미널` 장비에도 잘 저장 되어 있는지 확인합니다

*  <kbd><samp>Ctrl</samp>+<samp>D</samp></kbd> 혹은 <kbd>exit</kbd> 명령으로 컨테이너에서 빠져나와 `원격 터미널` 로컬 디스크에 모든 파일이 모두 수집되었다면 테이블 수집에 성공한 것입니다
```bash
# terminal
find notebooks -name '*.parquet'
```
<br>


## 3. 파일 수집 실습

### 3-1. *원격 터미널에 접속* 후, *플루언트디 컨테이너에 접속*합니다

#### 3-1-1. 서버를 기동합니다

> 서버가 이미 기동되어 있는 경우 Recreate 되며, 컨테이너의 상태는 별도의 볼륨에 저장되고 있으므로 문제는 없습니다만, 라이브 환경에서는 주의가 필요합니다

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
ask rm -rf /tmp/source/access.csv /tmp/source/access.pos /tmp/target/\$\{tag\}/ /tmp/target/access/20201026
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
<br>


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
cat /etc/fluentd/access.20201026.csv >> /tmp/source/access.csv
```

#### 3-2-3. 수집된 로그가 정상적인 JSON 파일인지 확인합니다
```bash
# docker
tree -L 2 /tmp/target
find /tmp/target -name '*.json' | head
```

#### 3-2-4. 원본 로그와, 최종 수집된 로그의 레코드 수가 같은지 확인합니다
```bash
# docker
cat `find /tmp/target/access/20201026 -name '*.json'` | wc -l
wc -l /tmp/source/access.csv
```

<details><summary> :blue_book: 6. [중급] 정답확인</summary>

> 수집된 파일의 라인 수와, 원본 로그의 라인 수가 16 라인으로 일치한다면 정상입니다 

</details>


#### 3-2-5. `원격 터미널 ` 로컬 스토리지에서 결과를 확인합니다

* 기동되어 있는 fluentd 애플리케이션은 <kbd><samp>Ctrl</samp>+<samp>C</samp></kbd> 명령으로 종료할 수 있습니다
* 기동되어 있는 docker 컨테이너는 터미널 화면에서 <kbd><samp>Ctrl</samp>+<samp>D</samp></kbd> 혹은 <kbd>exit</kbd> 명령으로 컨테이너에서 빠져나와 `원격 터미널` 로컬 디스크에 JSON 파일이 확인 되었다면 웹 로그 수집에 성공한 것입니다
* 열려 있는 2개 터미널 모두 종료합니다
```bash
# terminal
find notebooks -name '*.json'
```
<br>



## 4. 노트북 컨테이너 기동

> 본 장에서 수집한 데이터를 활용하여 데이터 변환 및 지표 생성작업을 위하여 주피터 노트북을 열어둡니다

### 4-1. 노트북 주소를 확인하고, 크롬 브라우저로 접속합니다

#### 4-1-1. 노트북 기동 및 확인
```bash
# terminal
docker compose logs notebook | grep 8888
```
> 출력된  URL을 복사하여 `127.0.0.1:8888` 대신 개인 `<hostname>.aiffelbiz.co.kr:8888` 으로 변경하여 크롬 브라우저를 통해 접속하면, jupyter notebook lab 이 열리고 work 폴더가 보이면 정상기동 된 것입니다

#### 4-1-2. 기 생성된 실습용 노트북을 엽니다
* 좌측 메뉴에서 "data-engineer-lgde-day2.ipynb" 을 더블클릭합니다

#### 4-1-3. 신규로 노트북을 만들고 싶은 경우
* `Launcher` 탭에서 `Notebook - Python 3` 를 선택하고
* 탭에서 `Rename Notebook...` 메뉴를 통해 이름을 변경할 수 있습니다

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
<details><summary> :blue_book: 7. [중급] 정답확인</summary>

> 스파크 엔진의 버전 `v3.0.1`이 출력되면 성공입니다

</details>
<br> 


#### 5-1-2. 수집된 테이블을 데이터프레임으로 읽고, 스키마 및 데이터 출력하기

> 파케이 포맷의 경우는 명시적인 스키마 정의가 되어 있지만, Json 포맷의 경우는 데이터의 값에 따라 달라질 수 있기 때문에 데이터를 읽어들일 때에 주의해야 합니다

* 데이터프레임 변수명 및 경로는 아래와 같습니다
  - 2020/10/26 일자 고객 (parquet) : <kbd>user26</kbd> <- <kbd>user/20201026</kbd> 
  - 2020/10/26 일자 매출 (parquet) : <kbd>purchase26</kbd> <- <kbd>purchase/20201026</kbd> 
  - 2020/10/26 일자 접속 (json) : <kbd>access26</kbd> <- <kbd>access/20201026</kbd> 

* 아래의 제약조건을 만족 시켜야 합니다
  - 입력 포맷이 Json 인 경우는 json 명령어와 추정(infer) 옵션을 사용하세요 <kbd>spark.read.option("inferSchema", "true").json("access/20201024")</kbd> 
  - 모든 데이터에 대한 스키마를 출력하세요 <kbd>dataFrame.printSchema()</kbd> 
  - 데이터 내용을 출력하여 확인하세요 <kbd>dataFrame.show() 혹은 display(dataFrame)</kbd> 

* 고객 정보 파일을 읽고, 스키마와 데이터 출력하기
```python
user26 = spark.read.parquet("user/20201026")
user26.printSchema()
user26.show(truncate=False)
display(user26)
```

* 매출 정보 파일을 읽고, 스키마와 데이터 출력하기
```python
purchase26 = <매출 데이터 경로에서 읽어서 스키마와, 데이터를 출력하는 코드를 작성하세요>
```

* 접속 정보 파일(json)을 읽고, 스키마와 데이터 출력하기
```python
access26 = <접속 데이터 경로에서 읽어서 스키마와, 데이터를 출력하는 코드를 작성하세요>
```
<details><summary> :blue_book: 8. [중급] 정답확인</summary>

> 고객, 매출 및 접속 데이터의 스키마와, 데이터가 모두 출력되면 성공입니다

</details>
<br>


### 5-2. 수집된 고객, 매출 및 접속 임시 테이블 생성

#### 5-2-1. 데이터프레임을 이용하여 임시테이블 생성하기
```python
user26.createOrReplaceTempView("user26")
purchase26.createOrReplaceTempView("purchase26")
access26.createOrReplaceTempView("access26")
spark.sql("show tables '*26'")
```
<details><summary> :blue_book: 9. [중급] 정답확인</summary>

> `show tables` 결과로 `user26`, `purchase26`, `access26` 3개 테이블이 출력되면 성공입니다

</details>
<br>


### 5-3. SparkSQL을 이용하여 테이블 별 데이터프레임 생성하기

#### 5-3-1. 아래에 비어있는 조건을 채워서 올바른 코드를 작성하세요

* 아래의 조건이 만족되어야 합니다
  - 2020/10/26 에 등록(`u_signup`)된 유저만 포함될 것 <kbd>`u_signup` >= '20201026' and `u_signup` < '20201027'</kbd>
  - 2020/10/26 에 발생한 매출(`p_time`)만 포함할 것 <kbd>`p_time` >= '2020-10-26 00:00:00' and `p_time` < '2020-10-27 00:00:00'</kbd>

```python
u_signup_condition = "<10월 26일자에 등록된 유저만 포함되는 조건을 작성합니다>"
user = spark.sql("select u_id, u_name, u_gender from user26").where(u_signup_condition)
user.createOrReplaceTempView("user")

p_time_condition = "<10월 26일자에 발생한 매출만 포함되는 조건을 작성합니다>"
purchase = spark.sql("select from_unixtime(p_time) as p_time, p_uid, p_id, p_name, p_amount from purchase26").where(p_time_condition)
purchase.createOrReplaceTempView("purchase")

access = spark.sql("select a_id, a_tag, a_timestamp, a_uid from access26")
access.createOrReplaceTempView("access")

spark.sql("show tables")
```
<details><summary> :blue_book: 10. [중급] 정답확인</summary>

> `show tables` 결과에 총 6개의 테이블이 출력되면 성공입니다

</details>
<br>


### 5-4. 생성된 테이블을 SQL 문을 이용하여 탐색하기
> SQL 혹은 DataFrame API 어느 쪽을 이용하여도 무관하며, 결과만 동일하게 나오면 정답입니다

#### 5-4-1. 남녀별 인원수를 구하는 질의문을 작성하세요
```python
spark.sql("describe user")
# groupByCount = "<성별 인원 수를 구하는 질의문을 작성하세요>"
# spark.sql(groupByCount)
```

#### 5-4-2. 최소, 최대 금액을 출력하는 질의문을 작성
```python
spark.sql("describe purchase")
# selectClause = "<최소, 최대 금액을 출력하는 질의문을 작성하세요>"
# spark.sql(selectClause)
```

#### 5-4-3. 가장 접속횟수가 많은 고객의 아이디를 1명을 출력하세요

* 아래의 조건이 만족 되어야 합니다
  - 접속의 기준은 **login** 로그 기준으로만 계산하시면 
  - 동점이 발생하는 경우 어느 쪽을 선택하더라도 정답입니다

```python
spark.sql("describe access")
# countTop="<가장 접속횟수가 많은 고객의 아이디를 출력하세요>"
# spark.sql(countTop)
```
<details><summary> :blue_book: 11. [중급] 정답확인</summary>

> 위에서부터 각각 "여:1, 남:3", "최소: 1000000, 최대: 4500000", "2, 4" 둘 중에 하나가 나오면 정답입니다

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
<details><summary> :blue_book: 12. [중급] 정답확인</summary>

> "DAU : 9"가 나오면 정답입니다 

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
<details><summary> :blue_book: 13. [중급] 정답확인</summary>

> "PU : 5"가 나오면 정답입니다

</details>
<br>


### 6-3. DR (Daily Revenue) 지표를 생성하세요

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 지정한 일자에 발생한 총 매출 금액 <kbd>sum(`p_amount`)</kbd>
  - 지표산식 : 지정한 일자의 구매 테이블에 저장된 전체 매출 금액의 합
  - 입력형태 : purchase 테이블
  - 출력형태 : number (컬럼명: DR)

```python
display(purchase)
# sumOfDailyRevenue = "<일 별 구매금액 집계함수>"
# dr = spark.sql(sumOfDailyRevenue)
# display(dr)
```
<details><summary> :blue_book: 14. [중급] 정답확인</summary>

> "DR : 12900000" 이 나오면 정답입니다

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
<details><summary> :blue_book: 15. [중급] 정답확인</summary>

> "ARPU : 1433333.3333333333" 가 나오면 정답입니다

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
<details><summary> :blue_book: 16. [중급] 정답확인</summary>

> "ARPPU : 2580000.0" 가 나오면 정답입니다

</details>
<br>


## 7. 고급 지표 생성

* 아래의 조건이 만족해야 합니다
  - 지표정의 : 이용자 누적 상태 정보 디멘젼 (2020/10/25 정보가 포함)
  - 지표산식 : 어제까지 접속한 모든 유저 dimension 정보를 읽어옵니다
  - 입력형태 : 어제 저장한 dimension 경로 -> `yesterday`
  - 출력형태 : `yesterday` 디멘젼 스키마

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

### 7-1. 전체 고객의 ID 추출

> 전체 고객의 ID를 추출하고 계속 붙여나가는 식으로 구성하는 것이 간결하게 구현이 가능합니다. 동일한 uid 를 union 하기 위해서는 스키마가 일치해야 하므로, 컬럼 이름을 일치시켜야 하며, 이후에 join 시를 감안하여 `a_uid`로 통일합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 어제까지 접속한 이용자 UID + 오늘 접속한 이용자 <kbd>yestday.union(today)</kbd>
  - 지표산식 : 어제 dimension 의 uid 전체와 오늘 dimension 의 전체 uid 를 union 후 distinct 합니다
  - 입력형태 : `yesterday`, `access` -> `all_uids`
  - 출력형태 : `a_uid`
  - 정렬형태 : `a_uid` asc


### 7-2. 어제 디멘젼 정보와 결합

> 전체 고객의 IDs 정보에 어제 생성한 dimension 정보를 결합합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 어제 dimension 정보를 결합 <kbd>dataFrame.join(dataFrame, joinCondition, joinHow)</kbd>
  - 지표산식 : 7-1 에서 생성한 모든 UIDs 와 어제 dimension 을 join 합니다
  - 입력형태 : `all_uids`, `yesterday` -> `uids`
  - 출력형태 : `d_uid`, `d_name`, `d_gender`, `d_acount`, `d_pamount`, `d_pcount`, `d_first_purchase`
  - 정렬형태 : `d_uid` asc

* uid 에서 생성된 id 값이 모든 `user_id` 이므로, drop 함수를 통해 기존의 `d_uid` 는 제거하고, withColumnRenamed 함수를 통해, uid 를 `d_uid` 로 변경 합니다
```python
all_uids.printSchema()
yesterday.printSchema()
# joinCondition = "<UIDs 와 어제 Dimension 테이블과 조인 조건>"
# joinHow = "<조인방식>"
# 
# uids = (
#     all_uids.join(yesterday, joinCondition, joinHow)
#     .drop("d_uid")
#     .withColumnRenamed("a_uid", "d_uid")
#     .sort(asc("d_uid"))
# )
# 
# uids.printSchema()
# display(uids)
```
<details><summary> :blue_book: 17. [중급] 정답확인</summary>

> 총 9명의 고객정보가 출력되고, 5명은 어제의 정보를 가지고 있으나, 4명은 null 값을 가지고 있다면 정답입니다

</details>
<br>


### 7-3. 이름과 성별을 결합

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 이용자의 이름 및 성별을 결합합니다 <kbd>case when col1 is null then col2 else col1 end </kbd>
  - 지표산식 : case 문을 사용하여, 어제 디멘젼에 값이 null 인 경우에는 오늘 생성한 디멘젼을 이용하여 업데이트합니다
  - 입력형태 : `uids`, `user` -> `dim1`
  - 출력형태 : `d_uid`, `d_acount`, `d_pamount`, `d_pcount`, `d_first_purchase`, `d_name`, `d_gender`
  - 정렬형태 : `d_uid` asc

* 컬럼의 값이 널인 경우에 대체될 수 있도록 case 문을 이용합니다
  - 이름의 경우 `d_name` 이 null 이면 `u_name` 을 사용하고 그렇지 않으면 `d_name` 을 사용합니다
  - 성별의 경우 `d_gender` 이 null 이면 `u_gender` 을 사용하고 그렇지 않으면 `d_gender` 을 사용합니다
```python
uids.printSchema()
user.printSchema()
# exprName = expr("<이름을 채우기 위한 case 구문>")
# exprGender = expr("<성별을 채우기 위한 case 구문>")
# 
# dim1 = (
#     uids.join(user, uids.d_uid == user.u_id, "left_outer")
#     .withColumn("name", exprName)
#     .withColumn("gender", exprGender)
#     .drop("d_name", "d_gender", "u_id", "u_name", "u_gender")
#     .withColumnRenamed("name", "d_name")
#     .withColumnRenamed("gender", "d_gender")
# ).orderBy(asc("d_uid"))
# 
# display(dim1)
```
<details><summary> :blue_book: 18. [중급] 정답확인</summary>

> 총 7개의 컬럼이 있고, 마지막에 `d_name`, `d_gener` 컬럼이 추가되며, 모든 고객의 이름과 성별이 추가되었다면 정답입니다

</details>
<br>


### 7-4. 숫자 필드에 널값은 0으로 기본값을 넣어줍니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 필드에 널값을 기본값으로 채우는 맵을 정의합니다 <kbd>defDict = { "col1":1, "col2": 2 }</kbd>
  - 지표산식 : 접속, 매출횟수, 매출금액 등의 null 값을 0으로 채우는 맵 변수를 정의합니다
  - 입력형태 : `dim1` -> `dim2`
  - 출력형태 : `d_uid`, `d_acount`, `d_pamount`, `d_pcount`, `d_first_purchase`, `d_name`, `d_gender`
  - 정렬형태 : `d_uid` asc

* `d_acount`, `d_pamount`, `d_pcount` 필드의 기본값을 0으로 지정하는 맵 변수를 생성하세요
```python
# fillDefaultValue = { <기본값을 설정하기 위한 맵> }
# 
# dim2 = dim1.na.fill(fillDefaultValue)
# display(dim2)
```
<details><summary> :blue_book: 19. [중급] 정답확인</summary>

> 고객번호 6~9번까지의 접속, 매출횟수, 매출금액이 null 이 아니라 0으로 채워졌다면 성공입니다

</details>
<br>


### 7-5. 접속횟수를 결합

> 어제까지 누적된 접속횟수가 있기 때문에 누적된 접속 횟수를 구해야 합니다. *앞에서 null 에 대한 기본값 처리를 해 두었기 때문에 case 구문 대신에 덧셈 연산을 해도 문제가 없지*만, 추후 예외처리 핛브을 위해 case 구문을 통해 작성하는 것을 실습합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 고객의 접속횟수를 계산합니다 <kbd>select id, count(id) from table group by id</kbd>
  - 지표산식 : 접속 횟수는 이전 접속횟수와 누적되어야 합니다 <kbd>case when col2 is null then col1 else col1 + col2 end</kbd>
  - 입력형태 : `dim2`, `access` -> `dim3`
  - 출력형태 : `d_uid`, `d_pamount`, `d_pcount`, `d_first_purchase`, `d_name`, `d_gender`, `d_acount`
  - 정렬형태 : `d_uid` asc

* 아래의 두 가지 구문을 작성하세요
  - `access_sum` 구문은 오늘 발생한 고객 당, 접속횟수를 구하는 구문입니다
  - `access-sum` 구문은 오늘 접속 수치(`a_count`)가 null 이면 디멘젼의 `d_acount` 값을 사용하고, 그렇지 않으면 `d_acount` + `a_count` 를 사용하는 case 구문입니다
```python
access.printSchema()
dim2.printSchema()

# access_sum = spark.sql("<오늘 고객 별 접속횟수 구문>")
# access_sum.printSchema()
# access_sum.show()
# sumOfAccess = expr("<접속 횟수를 구하는 case 구문>")
# 
# dim3 = (
#     dim2.join(access_sum, dim2.d_uid == access_sum.a_uid, "left_outer")
#     .withColumn("sum_of_access", sumOfAccess)
#     .drop("a_uid", "a_count", "d_acount")
#     .withColumnRenamed("sum_of_access", "d_acount")
# ).orderBy(asc("d_uid"))
# dim3.printSchema()
# display(dim3)
```
<details><summary> :blue_book: 20. [중급] 정답확인</summary>

> 마지막 컬럼에 `d_acount` 가 추가되고 모든 고객의 접속횟수가 0 이상으로 나오면 정답입니다

</details>
<br>


### 7-6. 매출횟수 및 매출을 결합

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 매출횟수와 매출을 결합합니다 <kbd>select id, sum(col2), count(col3) from table group by id</kbd>
  - 지표산식 : 횟수나, 금액도 누적되기 때문에 <kbd>case when col2 is null then col1 else col1 + col2 end</kbd>
  - 입력형태 : `dim3`, `purchase` -> `dim4`
  - 출력형태 : `d_uid`, `d_first_purchase`, `d_name`, `d_gender`, `d_acount`, `d_pamount`, `d_pcount`
  - 정렬형태 : `d_uid` asc

* 아래의 가이드대로 코드를 완성하세요
  - `purchase_sum` 구문은 오늘 발생한 고객별 총 구매횟수와 총 구매금액을 구하는 구문입니다
  - `sumOfAmount` 구문은 오늘 발생한 매출(pamount)이 null 이면 디멘젼 매출(`d_pamount`)를 그렇지 않으면 둘의 합(`d_pamount` + pamount)을 구하는 case 문을 작성합니다
  - `sumOfcount` 구무은 오늘 발생한 매출빈도(pcount)가 null 이면 디멘젼 매출빈도(`d_pcount`)를 그렇지 않으면 둘의 합(`d_pcount` + pcount)을 구합니다
```python
purchase.printSchema()
dim3.printSchema()

# purchase_sum = spark.sql("<구매횟수와, 구매금액의 집계하는 SQL구문>")
# purchase_sum.show()
# 
# sumOfAmount = expr("<매출금액의 합을 구하는 case 구문>")
# sumOfCount = expr("<매출횟수의 합을 구하는 case 구문>")
# 
# dim4 = (
#     dim3.join(purchase_sum, dim3.d_uid == purchase_sum.p_uid, "left")
#     .withColumn("sum_of_amount", sumOfAmount)
#     .withColumn("sum_of_count", sumOfCount)
#     .drop("p_uid", "pamount", "pcount", "d_pamount", "d_pcount")
#     .withColumnRenamed("sum_of_amount", "d_pamount")
#     .withColumnRenamed("sum_of_count", "d_pcount")
# ).orderBy(asc("d_uid"))
# 
# dim4.printSchema()
# display(dim4)
```
<details><summary> :blue_book: 21. [중급] 정답확인</summary>

> 마지막 두 개 컬럼이 고객의 매출금액(`d_pamount`)과 매출횟수(`d_pcount`)가 추가되었고 값이 계산되었다면 정답입니다

</details>
<br>


### 7-7. 최초 구매 일자를 결합

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 오늘 발생한 구매일시 가운데 가장 작은 값 <kbd>select id, min(time) from table group by id</kbd>
  - 지표산식 : 이전 구매일이 null 인 경우에만 최초 구매일을 갱신합니다 <kbd>case when col1 is null then col2 else col1 end</kbd>
  - 입력형태 : `dim4` -> `dimension`
  - 출력형태 : `d_uid`, `d_name`, `d_gender`, `d_acount`, `d_pamount`, `d_pcount`, `d_first_purchase`
  - 정렬형태 : `d_uid` asc

* 아래의 요건에 맞는 코드를 작성하세요
  - `selectFirstPurchaseTime` 경우 하루에 여러번 구매가 있을 수 있으므로 group by `p_uid` 집계를 통해 가장 먼저 구매한 정보 즉, min(`p_time`)함수를 통해 일시를 선택하는 SQL 문을 작성하세요
  - `exprFirstPurchase` 는 디멘젼의 최초구매일(`d_first_purchase`)이 null 이라면 오늘 발생한 `p_time` 을 사용하고 그렇지 않으면 `d_first_purchase` 를 사용하는 case 구문을 작성하세요
```python
purchase.printSchema()
dim4.printSchema()

# selectFirstPurchaseTime = "<최소 구매일시를 가져오는 SQL구문>"
# first_purchase = spark.sql(selectFirstPurchaseTime)
# first_purchase.printSchema()
# first_purchase.show()
# 
# exprFirstPurchase = expr("<최초 구매일시를 계산하는 case 구문>")
# 
# dimension = (
#     dim4.join(first_purchase, dim4.d_uid == first_purchase.p_uid, "left")
#     .withColumn("first_purchase", exprFirstPurchase)
#     .drop("p_uid", "p_time", "d_first_purchase")
#     .withColumnRenamed("first_purchase", "d_first_purchase")
# ).orderBy("d_uid")
# 
# dimension.printSchema()
# display(dimension)
```
<details><summary> :blue_book: 22. [중급] 정답확인</summary>

> 마지막 컬럼에 `d_first_purchase`이 추가되었고, 4,8번 고객을 제외한 모든 고객은 구매이력이 있다면 정답입니다

</details>
<br>


### 7-8. 신규유저를 계산

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 오늘 처음으로 접속한 고객의 수를 계산합니다 <kbd>df1.subtract(df2).count()</kbd>
  - 지표산식 : 오늘 접속 유저의 전체 ID 에서 어제 dimension 고객 ID 를 집합연산(subtract)를 통해 계산합니다
  - 입력형태 : `dimension`, `yesterday` -> `NU`

* 아래의 기준에 맞는 코드를 작성하세요
  - `today_uids` 는 오늘 생성된 전체 고객 ID 를 가져오는 API 구문 혹은 SQL
  - `yesterday_uids` 는 어제 생성된 디멘젼에서 고객 ID 를 가져오는 API 혹은 SQL
  - `nu` 는 오늘 ID 전체에서 어제 ID 전체를 빼는 집합연산 API 구문
```python
dimension.printSchema()
yesterday.printSchema()
# today_uids = "<오늘 디멘젼의 고객 ID>"
# yesterday_uids = "<어제 디멘젼의 고객 ID>"
# 
# nu = <오늘 ID - 어제 ID>
# nu.printSchema()
# nu.show()
# v_nu = nu.count()
# print(v_nu)
```
<details><summary> :blue_book: 23. [중급] 정답확인</summary>

> 신규유저 `NU : 4` 면 정답입니다

</details>
<br>


### 7-9. 생성된 디멘젼을 저장소에 저장합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 저장위치 : "dimension/dt=20201026" <kbd>dataFrame.write</kbd>
  - 저장옵션 : 대상 경로가 존재하더라도 덮어씁니다 <kbd>.mode("overwrite")</kbd>
  - 저장포맷 : 파케이  <kbd>.parquet("dimension/dt=20201026")</kbd>

```python
dimension.printSchema()
# target_dir="<저장경로>"
# dimension.write.mode(<저장모드>).parquet(target_dir)
```
<details><summary> :blue_book: 24. [중급] 정답확인</summary>

> 저장 시에 오류가 없고 대상 경로(dimension/dt=20201026)가 생성되었다면 성공입니다

</details>
<br>


### 7-10. 생성된 디멘젼을 다시 읽어서 출력합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 저장위치 : "dimension/dt=20201026" <kbd>spark.read</kbd>
  - 저장포맷 : 파케이  <kbd>.parquet("dimension/dt=20201026")</kbd>

```python
# newDimension = <디멘젼을 읽어옵니다>
# newDimension.printSchema()
# display(newDimension)
```
<details><summary> :blue_book: 25. [중급] 정답확인</summary>

> 디멘젼 테이블을 정상적으로 읽어왔고, 동일한 스키마와 데이터가 출력되었다면 정답입니다

</details>


### 7-11. 오늘 생성된 지표를 MySQL testdb.lgde 테이블로 저장합니다

> **어제의 데이터가 삭제되어서는 안되**며, **여러번 실행해도 멱등하게 동작해야 합**니다 

* 테이블 정보
  - host : mysql
  - port : 3306
  - user : sqoop
  - password : sqoop
  - db : testdb
  - table : lgde
  - schema : `dt char(10), dau int, pu int, dr int`


```python
today = "2020-10-26"
# lgde_origin = <Spark JDBC 를 이용하여 어제까지의 데이터를 가져옵니다>
# lgde_today = <spark createDataFrame 메소드를 이용하여 오늘자 저장 데이터프레임을 생성합니다>
# lgde_union = <어제까지의 데이터와 오늘 데이터를 유니온합니다>
# lgde_local = <lgde_union 데이터 프레임을 collect 통해 로컬 객체로 생성합니다>
# lgde = spark.createDataFrame(lgde_local)
# lgde.write.mode("overwrite").jdbc("jdbc:mysql://mysql:3306/testdb", "testdb.lgde", properties={"user": "sqoop", "password": "sqoop"})
```

<details><summary> :blue_book: 28. [기본] 정답확인</summary>

> MySQL 테이블에 2020-10-25 ~ 26 일자의 지표가 저장되었다면 정답입니다

```sql
mysql> select * from lgde order by dt asc;
+------------+------+------+----------+
| DT         | DAU  | PU   | DR       |
+------------+------+------+----------+
| 2020-10-25 |    5 |    4 | 12200000 |
| 2020-10-26 |    9 |    5 | 12900000 |
+------------+------+------+----------+
```

</details>
<br>


## 8. 질문 및 컨테이너 종료

### 8-1. 질문과 답변

### 8-2. 컨테이너 종료

```python
docker compose down
```

> 아래와 같은 메시지가 출력되고 모든 컨테이너가 종료되면 정상입니다
```text
[+] Running 2/3
⠿ Container fluentd   Removed        1.3s
⠿ Container notebook  Removed        3.7s
⠹ Container sqoop     Stopping       5.3s
```
<br>

