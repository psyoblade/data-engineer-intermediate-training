# 9일차. LGDE.com 일별 지표생성 실습 (1일차)
> 가상의 웹 쇼핑몰 LGDE.com 접속정보, 매출 및 고객정보를 통해 각종 지표를 생성하는 실습을 수행합니다


## 1. 노트북 기동
> 원격 터미널에 접속하여 관련 코드를 최신 버전으로 내려받고, 실습을 위한 도커 컨테이너를 기동합니다

### 1-1. 최신 소스를 내려 받습니다
```bash
# terminal
cd /home/ubuntu/work/data-engineer-intermediate-training
git pull
```

### 1-2. 스파크 워크스페이스로 이동하여 도커를 기동합니다
```bash
# terminal
cd /home/ubuntu/work/data-engineer-intermediate-training/day9
docker compose up -d
docker compose logs notebook | grep 8888
```
> 출력된  URL을 복사하여 `127.0.0.1` 대신 개인 hostname 으로 변경하여 크롬 브라우저를 통해 접속하면, jupyter notebook lab 이 열리고 work 폴더가 보이면 정상기동 된 것입니다
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
ask echo hello world
```
> "hello world" 가 출력되면 정상입니다


### 2-2. 수집 대상 *데이터베이스 목록*을 확인합니다
```bash
# docker
hostname="mysql"
username="sqoop"
password="sqoop"
```
```bash
ask sqoop list-databases --connect jdbc:mysql://${hostname}:3306 --username ${username} --password ${password}
```

### 2-3. 수집 대상 *테이블 목록*을 확인합니다
```bash
# docker
database="testdb"
```
```bash
ask sqoop list-tables --connect jdbc:mysql://${hostname}:3306/$database --username ${username} --password ${password}
```

### 2-4. *일별 이용자 테이블*을 수집합니다
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
```bash
ask sqoop import -jt local -m 1 --connect jdbc:mysql://${hostname}:3306/${database} \
--username ${username} --password ${password} --table ${basename}_${basedate} \
--target-dir "file:///tmp/target/${basename}/${basedate}" --as-parquetfile --delete-target-dir
```

### 2-5. *일별 매출 테이블*을 수집합니다
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
```bash
ask sqoop import -jt local -m 1 --connect jdbc:mysql://${hostname}:3306/$database \
--username ${username} --password ${password} --table ${basename}_${basedate} \
--target-dir "file:///tmp/target/${basename}/${basedate}" --as-parquetfile --delete-target-dir
```

### 2-6. 모든 데이터가 정상적으로 수집 되었는지 검증합니다
> parquet-tools 는 파케이 파일의 스키마(schema), 일부내용(head) 및 전체내용(cat)을 확인할 수 있는 커맨드라인 도구입니다. 연관된 라이브러리가 존재하므로 hadoop 스크립를 통해서 수행하면 편리합니다

* 고객 및 매출 테이블 수집이 잘 되었는지 확인 후, 파일목록을 확인합니다
```bash
# docker
tree /tmp/target/user
tree /tmp/target/purchase
find /tmp/target -name "*.parquet"
```
* 출력된 파일 경로를 복사하여 경로르 변수명에 할당합니다
```bash
# docker
filename=""
```
* 대상 파일경로 전체를 복사하여 아래와 같이 스키마를 확인합니다
```bash
# docker
ask hadoop jar /jdbc/parquet-tools-1.8.1.jar schema file://${filename}
```
* 파일 내용의 데이터가 정상적인지 확인합니다
```bash
# docker
ask hadoop jar /jdbc/parquet-tools-1.8.1.jar cat file://${filename}
```
> <kbd><samp>Ctrl</samp>+<samp>D</samp></kbd> 혹은 <kbd>exit</kbd> 명령으로 컨테이너에서 빠져나와 `원격 터미널` 로컬 디스크에 모든 파일이 모두 수집되었다면 테이블 수집에 성공한 것입니다
* `원격 터미널` 장비에도 잘 저장 되어 있는지 확인합니다
```bash
# terminal
find notebooks -name '*.parquet'
```
<br>


## 3. 파일 수집 실습

### 3-1. 


## 4. 지표 변환 실습


