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

* [1. 코드 최신버전 업데이트 및 컨테이너 정리](#1-코드-최신버전-업데이트-및-컨테이너-정리)
* [2. 테이블 수집 실습](#2-테이블-수집-실습)

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
> "hello world" 가 출력되면 정상입니다


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

### 2-4. 수집 대상 *테이블 목록*을 확인합니다
```bash
# docker
database="testdb"
```
```bash
# docker
ask sqoop list-tables --connect jdbc:mysql://${hostname}:3306/$database --username ${username} --password ${password}
```

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

#### 2-7-4. 파일 내용의 데이터가 정상적인지 확인합니다
```bash
# docker
ask hadoop jar /jdbc/parquet-tools-1.8.1.jar cat file://${filename}
```
> <kbd><samp>Ctrl</samp>+<samp>D</samp></kbd> 혹은 <kbd>exit</kbd> 명령으로 컨테이너에서 빠져나와 `원격 터미널` 로컬 디스크에 모든 파일이 모두 수집되었다면 테이블 수집에 성공한 것입니다

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

> 수집된 파일의 라인 수와, 원본 로그의 라인 수가 일치한다면 정상적으로 수집되었다고 볼 수 있으며, <kbd><samp>Ctrl</samp>+<samp>D</samp></kbd> 혹은 <kbd>exit</kbd> 명령으로 컨테이너에서 빠져나와 `원격 터미널` 로컬 디스크에 JSON 파일이 확인 되었다면 웹 로그 수집에 성공한 것입니다
```bash
# terminal
find notebooks -name '*.json'
```
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
from pyspark.sql import SparkSession
from pyspark.sql.functions import *

spark = (
    SparkSession
    .builder
    .appName("Data Engineer Training Course")
    .config("spark.sql.session.timeZone", "Asia/Seoul")
    .getOrCreate()
)
spark
```

### 5-2. 수집된 고객, 매출 및 접속 데이터 읽기

### 5-3. SparkSQL을 이용하여 테이블로 생성하기

### 5-4. 생성된 테이블을 SQL 문을 이용하여 탐색하기

<br>


## 6. 기본 지표 생성

> 생성된 테이블을 통하여 기본 지표(DAU, DPU, DR, ARPU, ARPPU) 를 생성합니다

### 6-1. DAU (Daily Activer User) 지표를 생성하세요

### 6-2. DPU (Daily Paying User) 지표를 생성하세요

### 6-3. DR (Daily Revenue) 지표를 생성하세요

### 6-4. ARPU (Average Revenue Per User) 지표를 생성하세요
j
### 6-5. ARPPU (Average Revenue Per Paying User) 지표를 생성하세요



## 7. 고급 지표 생성




