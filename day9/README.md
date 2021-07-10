# 9일차. LGDE.com 일별 지표생성 실습 (1일차)
> 가상의 웹 쇼핑몰 LGDE.com 접속정보, 매출 및 고객정보를 통해 각종 지표를 생성하는 실습을 수행합니다


## 1. 노트북 기동
* [터미널] 최신 소스를 내려 받습니다
```bash
cd /home/ubuntu/work/data-engineer-intermediate-training
git pull
```
* [터미널] 스파크 워크스페이스로 이동하여 도커를 기동합니다
```bash
cd /home/ubuntu/work/data-engineer-intermediate-training/day9
docker compose up -d
docker compose logs notebook
```
* 출력되는 로그 가운데 마지막에 URL 이 출력되는데 해당 URL에서 127.0.0.1 값을 개인 hostname 으로 변경하여 접속합니다
  * 접속하면 jupyter notebook lab 이 열리고 work 폴더가 보이면 정상 기동 된 것입니다


## 2. 테이블 수집 실습

### 2-1. 원격 서버에 터미널을 통해 접속 후, 스쿱 서버에 접속합니다
* [터미널] 아래의 명령어를 통해 스쿱 컨테이너를 기동하고, 접속합니다
```bash
cd /home/ubuntu/work/data-engineer-intermediate-training/day9
docker compose up -d
docker compose ps
echo "sleep 5 seconds"
sleep 5
docker compose exec sqoop bash
```

### 2-2. 수집 대상 데이터베이스 목록을 확인합니다
* [컨테이너] 아래의 명령어를 참고하여, 현재 MySQL 서버에 존재하는 데이터베이스 목록을 확인합니다
```bash
hostname="mysql"
username="sqoop"
password="sqoop"
sqoop list-databases --connect jdbc:mysql://${hostname}:3306 --username ${username} --password ${password}
```

### 2-3. 수집 대상 테이블 목록을 확인합니다
* [컨테이너] MySQL 서버의 특정 데이터베이스에 존재하는 테이블 목록을 확인합니다
```bash
database="testdb"
sqoop list-tables --connect jdbc:mysql://${hostname}:3306/$database --username ${username} --password ${password}
```

### 2-4. 일자별 이용자 테이블을 수집합니다
* [컨테이너] 이용자 테이블 10/25~10/26 이틀치를 아래의 경로에 각각 수집하되, 파케이 포맷으로 저장 해야하며, 대상경로가 존재하면 삭제 후 수집 합니다
  - table\_name : user\_20201025, user\_20201026
  - target\_dir : file:///tmp/target/user/20201025, file:///tmp/target/user/20201026
  - --as-parquetfile : 옵션을 통해 파케이 포맷으로 저장합니다
  - --delete-target-dir	: 옵션을 통해 대상 경로가 존재하면 삭제 후 수집합니다
```bash
basedate=""
basename="user"
table_name="${basename}_${basedate}"
target_dir="file:///tmp/target/${basename}/${basedate}"
sqoop import --connect jdbc:mysql://${hostname}:3306/$database --username ${username} --password ${password} --table ${table_name} --target-dir ${target_dir} --as-parquetfile --delete-target-dir	
```

### 2-5. 일자별 매출 테이블을 수집합니다
* [컨테이너] 매출 테이블 10/25~10/26 이틀치를 아래의 경로에 각각 수집하되, 파케이 포맷으로 저장 해야하며, 대상경로가 존재하면 삭제 후 수집 합니다
  - table-name : purchase\_20201025, purchase\_20201026
  - target-dir : file:///tmp/target/purchase/20201025, file:///tmp/target/purchase/20201026
  - --as-parquetfile : 옵션을 통해 파케이 포맷으로 저장합니다
  - --delete-target-dir	: 옵션을 통해 대상 경로가 존재하면 삭제 후 수집합니다
```bash
basedate=""
basename="purchase"
table_name="${basename}_${basedate}"
target_dir="file:///tmp/target/purchase/$basedate"
sqoop import --connect jdbc:mysql://${hostname}:3306/$database --username ${username} --password ${password} --table ${table_name} --target-dir ${target_dir} --as-parquetfile --delete-target-dir	
```


## 3. 파일 수집 실습


## 4. 지표 변환 실습


