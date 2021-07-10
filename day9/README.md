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

### 2-2. 수집 대상 *데이터베이스 목록*을 확인합니다
```bash
# docker
hostname="mysql"
username="sqoop"
password="sqoop"
```
```bash
sqoop list-databases --connect jdbc:mysql://${hostname}:3306 --username ${username} --password ${password}
```

### 2-3. 수집 대상 *테이블 목록*을 확인합니다
```bash
# docker
database="testdb"
```
```bash
sqoop list-tables --connect jdbc:mysql://${hostname}:3306/$database --username ${username} --password ${password}
```

### 2-4. *일별 이용자 테이블*을 수집합니다
* 기간 : 2020/10/25 ~ 2020/10/26
* 저장 : 파케이 포맷 <kbd>--as-parquetfile</kbd>
* 기타 : 경로가 존재하면 삭제 후 수집 <kbd>--delete-target-dir</kbd>
* 소스 : <kbd>user\_20201025</kbd>, <kbd>user\_20201026</kbd>
* 타겟 : <kbd>file:///tmp/target/user/20201025</kbd>, <kbd> file:///tmp/target/user/20201026</kbd>
```bash
# docker
basedate=""
basename="user"
if [[ -z $basedate ]]; then echo "수집 대상 기준일자(basedate)를 변경해서 수집해 주세요"; fi
```
```bash
table_name="${basename}_${basedate}"
target_dir="file:///tmp/target/${basename}/${basedate}"
sqoop import --connect jdbc:mysql://${hostname}:3306/$database --username ${username} --password ${password} \
--table ${table_name} --target-dir ${target_dir} --as-parquetfile --delete-target-dir	
```

### 2-5. *일별 매출 테이블*을 수집합니다
* 기간 : 2020/10/25 ~ 2020/10/26
* 저장 : 파케이 포맷 <kbd>--as-parquetfile</kbd>
* 기타 : 경로가 존재하면 삭제 후 수집 <kbd>--delete-target-dir</kbd>
* 소스 : <kbd>purchase\_20201025</kbd>, <kbd>purchase\_20201026</kbd>
* 타겟 : <kbd>file:///tmp/target/purchase/20201025</kbd>, <kbd> file:///tmp/target/purchase/20201026</kbd>
```bash
# docker
basedate=""
basename="purchase"
table_name="${basename}_${basedate}"
target_dir="file:///tmp/target/purchase/$basedate"
if [[ -z $basedate ]]; then echo "수집 대상 기준일자(basedate)를 변경해서 수집해 주세요"; fi
```
```bash
sqoop import --connect jdbc:mysql://${hostname}:3306/$database --username ${username} --password ${password} \
--table ${table_name} --target-dir ${target_dir} --as-parquetfile --delete-target-dir	
```

### 2-6. 모든 데이터가 정상적으로 수집 되었는지 검증합니다

```bash
# docker
hadoop jar /jdbc/parquet-tools-1.10.1.jar cat /home/sqoop/target/
```

> <kbd><samp>Ctrl</samp>+<samp>D</samp></kbd> 명령으로 컨테이너에서 빠져나와 `원격 터미널` 로컬 디스크에 모든 파일이 모두 수집되었다면 테이블 수집에 성공한 것입니다
<br>


## 3. 파일 수집 실습

### 3-1. 


## 4. 지표 변환 실습


