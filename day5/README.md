# 5일차. 지표 생성 프로젝트

> 가상의 웹 쇼핑몰의 주요 지표를 생성하기 위한, 접속정보, 매출 및 고객정보 등의 데이터를 수집하여 기본 지표를 생성합니다


- 범례
  * :green_book: : 기본, :blue_book: : 중급

- 목차
  * [1. :green_book: 최신버전 업데이트](#1-최신버전-업데이트)
  * [2. :green_book: 노트북 컨테이너 기동](#2-green_book-노트북-컨테이너-기동)
  * [3. :green_book: 수집된 데이터 탐색](#3-green_book-수집된-데이터-탐색)
  * [4. :green_book: 기본 지표 생성](#4-green_book-기본-지표-생성)
  * [5. :blue_book: 고급 지표 생성](#5-blue_book-고급-지표-생성)
  * [6. :green_book: 질문 및 컨테이너 종료](#6-green_book-질문-및-컨테이너-종료)

- 정답
  * [1. :green_book:/:blue_book: 시작 노트북](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day5/notebooks/html/data-engineer-training-course.html)
  * [2. :green_book:/:blue_book: 정답 노트북](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day5/notebooks/html/data-engineer-training-course-answer.html)

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

[목차로 돌아가기](#5일차-데이터-엔지니어링-프로젝트)
<br>
<br>


## 2. :green_book: 노트북 컨테이너 기동

> 본 장에서 수집한 데이터를 활용하여 데이터 변환 및 지표 생성작업을 위하여 주피터 노트북을 열어둡니다

### 2-1. 노트북 주소를 확인하고, 크롬 브라우저로 접속합니다

#### 2-1-1. 노트북 기동 및 확인

* 노트북을 기동합니다
```bash
# terminal
cd /home/ubuntu/work/data-engineer-intermediate-training/day5
docker-compose pull
docker-compose up -d
```

* 기동된 노트북의 접속정보를 확인하고 접속합니다
```bash
# terminal
docker-compose logs notebook | grep 8888
```
> 출력된  URL을 복사하여 `127.0.0.1:8888` 대신 개인 `<hostname>.aiffelbiz.co.kr:8888` 으로 변경하여 크롬 브라우저를 통해 접속하면, jupyter notebook lab 이 열리고 work 폴더가 보이면 정상기동 된 것입니다

#### 2-1-2. 기 생성된 실습용 노트북을 엽니다
* 좌측 메뉴에서 "data-engineer-lgde-day5.ipynb" 을 더블클릭합니다

#### 2-1-3. 신규로 노트북을 만들고 싶은 경우
* `Launcher` 탭에서 `Notebook - Python 3` 를 선택하고
* 탭에서 `Rename Notebook...` 메뉴를 통해 이름을 변경할 수 있습니다

<br>

[목차로 돌아가기](#5일차-데이터-엔지니어링-프로젝트)
<br>
<br>


## 3. :green_book: 수집된 데이터 탐색

> 스파크 세션을 통해서 수집된 데이터의 형태를 파악하고, 스파크의 기본 명령어를 통해 수집된 데이터 집합을 탐색합니다

### 3-1. 스파크 세션 생성

#### 3-1-1. 스파크 객체를 생성하는 코드를 작성하고, <kbd><kbd>Shift</kbd>+<kbd>Enter</kbd></kbd> 로 스파크 버전을 확인합니다
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


#### 3-1-2. 수집된 테이블을 데이터프레임으로 읽고, 스키마 및 데이터 출력하기

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


### 3-2. 수집된 고객, 매출 및 접속 임시 테이블 생성

#### 3-2-1. 데이터프레임을 이용하여 임시테이블 생성하기
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


### 3-3. SparkSQL을 이용하여 테이블 별 데이터프레임 생성하기

#### 3-3-1. 아래에 비어있는 조건을 채워서 올바른 코드를 작성하세요

* 아래의 조건이 만족되어야 합니다
  - 2020/10/25 에 등록(`u_signup`)된 유저만 포함될 것 <kbd>`u_signup` >= '20201025' and `u_signup` < '20201026'</kbd>
  - 2020/10/25 에 발생한 매출(`p_time`)만 포함할 것 <kbd>`p_time` >= '2020-10-25 00:00:00' and `p_time` < '2020-10-26 00:00:00'</kbd>

```python
u_signup_condition = "<10월 25일자에 등록된 유저만 포함되는 조건을 작성합니다>"
user = spark.sql("select u_id, u_name, u_gender from user25").where(u_signup_condition)
user.createOrReplaceTempView("user")
display(user)

p_time_condition = "<10월 25일자에 발생한 매출만 포함되는 조건을 작성합니다>"
purchase = spark.sql("select from_unixtime(p_time) as p_time, p_uid, p_id, p_name, p_amount from purchase25").where(p_time_condition)
purchase.createOrReplaceTempView("purchase")
display(purchase)

access = spark.sql("select a_id, a_tag, a_timestamp, a_uid from access25")
access.createOrReplaceTempView("access")
display(access)

spark.sql("show tables")
```
<details><summary> 정답확인</summary>

> `show tables` 결과에 총 6개의 테이블이 출력되면 성공입니다

</details>
<br>


### 3-4. 생성된 테이블을 SQL 문을 이용하여 탐색하기
> SQL 혹은 DataFrame API 어느 쪽을 이용하여도 무관하며, 결과만 동일하게 나오면 정답입니다

#### 3-4-1. 한 쪽의 성별('남' 혹은 '여')을 가진 목록을 출력하세요
```python
spark.sql("describe user")
spark.sql("select * from user")
# whereCondition = "<성별을 구별하는 조건을 작성하세요>"
# spark.sql("select * from user").where(whereCondition)
```

#### 3-4-2. 상품금액이 200만원을 초과하는 매출 목록을 출력하세요
```python
spark.sql("describe purchase")
spark.sql("select * from purchase")
# selectClause = "<금액을 필터하는 조건을 작성하세요>"
# spark.sql(selectClause)
```

#### 3-4-3. GroupBy 구문을 이용하여 로그인, 로그아웃 횟수를 출력하세요
```python
spark.sql("describe access")
spark.sql("select * from access")
# groupByClause="<로그인/아웃 컬럼을 기준으로 집계하는 구문을 작성하세요>"
# spark.sql(groupByClause)
```
<details><summary> 정답확인</summary>

> 위에서부터 각각 "남:3, 여:2", "2개", "login:7, logout:5" 이 나오면 정답입니다

</details>
<br>

[목차로 돌아가기](#5일차-데이터-엔지니어링-프로젝트)
<br>
<br>


## 4. :green_book: 기본 지표 생성

> 생성된 테이블을 통하여 기본 지표(DAU, DPU, DR, ARPU, ARPPU) 를 생성합니다

### 4-1. DAU (Daily Activer User) 지표를 생성하세요

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
# v_dau = dau.collect()[0]["DAU"]
```
<details><summary> 정답확인</summary>

> "DAU : 5"가 나오면 정답입니다 

</details>
<br>


### 4-2. DPU (Daily Paying User) 지표를 생성하세요

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
# v_pu = pu.collect()[0]["PU"]
```
<details><summary> 정답확인</summary>

> "PU : 4"가 나오면 정답입니다

</details>
<br>


### 4-3. DR (Daily Revenue) 지표를 생성하세요

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
# v_dr = dr.collect()[0]["DR"]
```
<details><summary> 정답확인</summary>

> "DR : 12200000" 이 나오면 정답입니다

</details>
<br> 


### 4-4. ARPU (Average Revenue Per User) 지표를 생성하세요

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 유저 당 평균 발생 매출 금액
  - 지표산식 : 총 매출 / 전체 유저 수 = DR / DAU
  - 입력형태 : Daily Revenue, Daily Active User
  - 출력형태 : number (문자열: ARPU )

```python
# print("ARPU : {}".format(<유저당 매출 금액 계산식>))
print("+------------------+")
print("|             ARPU |")
print("+------------------+")
print("|        {} |".format(v_dr / v_dau))
print("+------------------+")
```
<details><summary> 정답확인</summary>

> "ARPU : 2440000.0" 가 나오면 정답입니다

</details>
<br>


### 4-5. ARPPU (Average Revenue Per Paying User) 지표를 생성하세요

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 유저 당 평균 발생 매출 금액
  - 지표산식 : 총 매출 / 전체 유저 수 = DR / PU
  - 입력형태 : Daily Revenue, Daily Paying User
  - 출력형태 : number

```python
# print("ARPPU : {}".format(<구매유저 당 매출 금액 계산식>))
print("+------------------+")
print("|            ARPPU |")
print("+------------------+")
print("|        {} |".format(v_dr / v_pu))
print("+------------------+")
```
<details><summary> 정답확인</summary>

> "ARPPU : 3050000.0" 가 나오면 정답입니다

</details>
<br>

[목차로 돌아가기](#5일차-데이터-엔지니어링-프로젝트)
<br>
<br>


## 5. :blue_book: 고급 지표 생성

### 5-1. 디멘젼 테이블을 설계 합니다

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


### 5-2. 오픈 첫 날 접속한 모든 고객 및 접속 횟수를 가진 데이터프레임을 생성합니다

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


### 5-3. 일 별 이용자 별 총 매출 금액과, 구매 횟수를 가지는 데이터프레임을 생성합니다

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


### 5-4. 이용자 정보와 구매 정보와 조인합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 이용자 데이터와 매출 정보의 결합 <kbd>leftSide.join(rightSide, joinCondition, joinHow)</kbd>
  - 지표산식 : 이용자는 반드시 존재해야하며, 매출은 없어도 됩니다 (`left_outer`)
  - 입력형태 : accs, amts
  - 출력형태 : `a_uid`, `a_count`, `p_uid`, `p_count`, `p_amount`
  - 정렬형태 : `a_uid` asc

* 5-1 에서 생성한 accs 와 5-2 에서 생성한 amts 데이터를 uid 값을 기준으로 left outer 조인을 수행합니다
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


### 5-5. 고객 정보를 추가합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 고객의 이름과 성별을 추가합니다 
  - 지표산식 : dim1 테이블과 고객정보를 결합합니다
  - 입력형태 : dim1, user
  - 출력형태 : `a_uid`, `a_count`, `p_uid`, `p_count`, `p_amount`, `u_id`, `u_name`, `u_gender`
  - 정렬형태 : `a_uid` asc

* 5-4 에서 생성한 dim1 데이터와 user 데이터를 결합합니다
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


### 5-6. 중복되는 ID 컬럼은 제거하고, 숫자 필드에 널값은 0으로 기본값을 넣어줍니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 중복되는 uid 컬럼을 제거하고, 매출정보가 없는 계정은 0으로 기본값을 넣어줍니다
  - 지표산식 : <kbd>fillDefaultValue = {"`p_amount`":0, "`p_count`":0}</kbd>
  - 입력형태 : dim2
  - 출력형태 : `a_uid`, `a_count`, `p_amount`, `p_count`, `u_name`, `u_gender`
  - 정렬형태 : `a_uid` asc

* 5-4 에서 생성한 dim1 데이터와 user 데이터를 결합하되, 중복 컬럼은 제거하고, 기본값을 0으로 채우는 `fillDefaultValue`를 작성하세요
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


### 5-7. 생성된 유저 테이블을 재사용 가능하도록 컬럼 명을 변경합니다

* 아래의 조건이 만족하는 코드를 작성하세요
  - 지표정의 : 컬럼명이 `d_`로 시작하도록 일괄 변경합니다
  - 지표산식 : <kbd>withColumnRenamed("`a_uid`", "`d_uid`" )</kbd>
  - 입력형태 : dim4
    - dimension 테이블이므로 `d_`로 시작하는 컬럼 규칙을 따릅니다
    - access, purchase 와 같이 개별 테이블의 prefix 를 이용해서 `d_a<column-name>` 혹은 `d_p<column-name>` 규칙을 따릅니다
  - 출력형태 : `d_uid`, `d_name`, `d_gender`, `d_acount`, `d_pamount`, `d_pcount`
  - 정렬형태 : `d_uid` asc

* 5-6 에서 생성한 dim4 의 모든 컬럼이 `d_`로 시작하도록 Rename 하여 정리합니다
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


### 5-8. 최초 구매 유저 정보를 추가합니다

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


### 5-9. 생성된 디멘젼을 저장소에 저장합니다

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


### 5-10. 생성된 디멘젼을 다시 읽어서 출력합니다

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
<br>

#### 최종 결과가 아래와 일치하는 지 확인합니다
```python
print("+------------------+")
print("|              DAU |")
print("+------------------+")
print("|                {} |".format(v_dau))
print("+------------------+")
print("+------------------+")
print("|               PU |")
print("+------------------+")
print("|                {} |".format(v_pu))
print("+------------------+")
print("+------------------+")
print("|               DR |")
print("+------------------+")
print("|         {} |".format(v_dr))
print("+------------------+")
print("+------------------+")
print("|             ARPU |")
print("+------------------+")
print("|        {} |".format(v_dr / v_dau))
print("+------------------+")
print("+------------------+")
print("|            ARPPU |")
print("+------------------+")
print("|        {} |".format(v_dr / v_pu))
print("+------------------+")
```

<details><summary> 정답확인</summary>

* 아래와 일치한다면 정답입니다
```python
+------------------+
|              DAU |
+------------------+
|                5 |
+------------------+
+------------------+
|               PU |
+------------------+
|                4 |
+------------------+
+------------------+
|               DR |
+------------------+
|         12200000 |
+------------------+
+------------------+
|             ARPU |
+------------------+
|        2440000.0 |
+------------------+
+------------------+
|            ARPPU |
+------------------+
|        3050000.0 |
+------------------+
```

</details>

[목차로 돌아가기](#5일차-데이터-엔지니어링-프로젝트)
<br>
<br>


## 6. :green_book: 질문 및 컨테이너 종료

### 6-1. 질문과 답변

### 6-2. 컨테이너 종료

```python
docker-compose down
```

> 아래와 같은 메시지가 출력되고 모든 컨테이너가 종료되면 정상입니다
```text
[+] Running 2/3
⠿ Container fluentd   Removed        1.3s
⠿ Container notebook  Removed        3.7s
⠹ Container sqoop     Stopping       5.3s
```
<br>

