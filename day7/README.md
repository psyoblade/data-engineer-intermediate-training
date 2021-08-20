# 7일차. 아파치 스파크 데이터 변환 스트리밍

> 아파치 스파크를 통해 스트리밍 예제를 실습합니다. 이번 장에서 사용하는 외부 오픈 포트는 4040, 4041, 8888 입니다


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


## 2. 데이터 변환 스트리밍

### [1. Spark Streaming Introduction](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day4/notebooks/lgde-spark-stream/lgde-spark-stream-1-introduction.html)
### [2. Spark Streaming Basic](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day4/notebooks/lgde-spark-stream/lgde-spark-stream-2-basic.html)
### [3. Spark Streaming Tools](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day4/notebooks/lgde-spark-stream/lgde-spark-stream-3-tools.html)
### [4. Spark Streaming External](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day4/notebooks/lgde-spark-stream/lgde-spark-stream-4-external.html)
### [5. Spark Streaming Aggregation](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day4/notebooks/lgde-spark-stream/lgde-spark-stream-5-aggregation.html)
### [6. Spark Streaming Join](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day4/notebooks/lgde-spark-stream/lgde-spark-stream-6-join.html)
### [7. Spark Streaming Questions](http://htmlpreview.github.io/?https://github.com/psyoblade/data-engineer-intermediate-training/blob/master/day4/notebooks/lgde-spark-stream/lgde-spark-stream-7-questions.html)

<br>

