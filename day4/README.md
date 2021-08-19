# 4~5일차. 아파치 스파크 데이터 변환

> 아파치 스파크를 통해 다양한 변환 예제를 실습합니다. 이번 장에서 사용하는 외부 오픈 포트는 4040, 4041, 8888 입니다


## 1. 최신버전 업데이트 테이블

> 원격 터미널에 접속하여 관련 코드를 최신 버전으로 내려받고, 과거에 실행된 컨테이너가 없는지 확인하고 종료합니다

### 1-1. 최신 소스를 내려 받습니다
```bash
# terminal
cd /home/ubuntu/work/data-engineer-${course}-training
git pull
```
<br>

### 1-2. 실습을 위한 이미지를 내려받고 컨테이너를 기동합니다
```bash
# terminal
cd /home/ubuntu/work/data-engineer-${course}-training/day4
docker-compose pull
docker-compose up -d
```
<br>

### 1-3. 스파크 실습을 위해 노트북 페이지에 접속합니다
* logs 출력에 localhost:8888 페이지를 크롬 브라우저에서 오픈합니다
```bash
# terminal
docker-compose ps

sleep 5
docker-compose logs notebook
```
> `http://127.0.0.1:8888/?token=87e758a1fac70558a6c4b4c5dd499d420654c509654c6b01` 이러한 형식의 URL 에서 `127.0.0.1` 을 자신의 호스트 이름(`vm<number>.aiffelbiz.co.kr`)으로 변경하여 접속합니다
<br>


## 2. 데이터 변환 기본
### [1. 아파치 스파크 기본](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day4/notebooks/lgde-spark-core/lgde-spark-core-1-basic.html)
### [2. 아파치 스파크 연산자](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day4/notebooks/lgde-spark-core/lgde-spark-core-2-operators.html)
### [3. 아파치 스파크 데이타입](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day4/notebooks/lgde-spark-core/lgde-spark-core-3-data-types.html)
### [4. 아파치 스파크 조인](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day4/notebooks/lgde-spark-core/lgde-spark-core-4-join.html)
### [5. 아파치 스파크 집계](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day4/notebooks/lgde-spark-core/lgde-spark-core-5-aggregation.html)
### [6. 아파치 스파크 JDBC to MySQL](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day4/notebooks/lgde-spark-core/lgde-spark-core-6-jdbc-mysql.html)
### [7. 아파치 스파크 JDBC to MongoDB](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day4/notebooks/lgde-spark-core/lgde-spark-core-7-jdbc-mongodb.html)
<br>


## 3. 참고 자료
* 파이썬 첫걸음 (외부 문서링크) - Python 3.x 기준
  - [1. 파이썬 기초문법 1부](https://blog.myungseokang.dev/posts/python-basic-grammar1/)
  - [2. 파이썬 기초문법 2부](https://blog.myungseokang.dev/posts/python-basic-grammar2/)
  - [3. 코딩을 몰라도 쉽게 만드는 데이터수집기 만들기](https://book.coalastudy.com/data_crawling/)
* 파이썬 분석 첫걸음 (외부 문서링킁)
  - [1. Pandas 기초](https://doorbw.tistory.com/172)
  - [2. Numpy 기초](https://doorbw.tistory.com/171)
  - [3. Plotly 기초](https://dailyheumsi.tistory.com/118)

