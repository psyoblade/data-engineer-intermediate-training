# 아파치 스쿱을 통한 테이블 수집 실습
> 복사해서 붙여넣기에는 웹 페이지가 더 편할 듯 하여 별도의 스크립트로 작성 되었습니다


## 아파치 스쿱을 통한 테이블 수집

### 아파치 스쿱 테이블 수집 - 예제 테이블
* import users table on local
```bash
docker exec -it sqoop sqoop import -jt local -fs local -m 1 --connect jdbc:mysql://mysql:3306/testdb --username user --password pass --table users --target-dir /tmp/sqoop/users
docker exec -it sqoop ls /tmp/sqoop/users
docker exec -it sqoop cat /tmp/sqoop/users/part-m-00000
```
* import users table on cluster
```bash
docker exec -it sqoop sqoop import -m 1 --connect jdbc:mysql://mysql:3306/testdb --username user --password pass --table users --target-dir /tmp/sqoop/users
docker exec -it sqoop hadoop fs -ls /tmp/sqoop/users
docker exec -it sqoop hadoop fs -cat /tmp/sqoop/users/part-m-00000
```

### 리소스 매니저 접근을 위한 포트 오픈
* Expose PORTs (8088, 19888, 50070)
```bash
docker stop sqoop
docker rm sqoop
docker run --name sqoop --network sqoop-mysql -v $PROJECT_HOME/jars:/jdbc -p 8042:8042 -p 8088:8088 -p 19888:19888 -p 50070:50070 -dit psyoblade/data-engineer-intermediate-day1-sqoop
```


### 유형별 테이블 수집 
* sqoop import split-by
```bash
./sqoop-import.sh -m 4 --split-by id --table seoul_popular_trip --target-dir /home/sqoop/target/seoul_popular_trip_v1 --fields-terminated-by '\t'
```
* docker import split-by
```bash
docker exec -it sqoop sqoop import -m 4 --split-by id --connect jdbc:mysql://mysql:3306/testdb --table seoul_popular_trip --target-dir /home/sqoop/target/seoul_popular_trip_v2 --fields-terminated-by '\t' --delete-target-dir --verbose --username sqoop --password sqoop
```


### 파티션 테이블 수집
* sqoop eval min(id), max(id)
```bash
./sqoop-eval.sh "select min(id), max(id) from seoul_popular_trip"
./sqoop-eval.sh "select count(1) from seoul_popular_trip"
```
* sqoop import w/ partitions
```bash
./hadoop.sh fs -mkdir -p /user/sqoop/target/seoul_popular_partition
./sqoop-print.sh -m 1 --table seoul_popular_trip --where "\"id > 10000\"" --target-dir /user/sqoop/target/seoul_popular_partition/part=10000
```
* sqoop import every partitions
```bash
docker exec -it sqoop sqoop import --connect jdbc:mysql://mysql:3306/testdb --username user --password pass --delete-target-dir -m 1 --table seoul_popular_trip --where "id < 10000" --target-dir /user/sqoop/target/seoul_popular_partition/part=0
docker exec -it sqoop sqoop import --connect jdbc:mysql://mysql:3306/testdb --username user --password pass --delete-target-dir -m 1 --table seoul_popular_trip --where "id > 10001 and id < 20000" --target-dir /user/sqoop/target/seoul_popular_partition/part=10000
docker exec -it sqoop sqoop import --connect jdbc:mysql://mysql:3306/testdb --username user --password pass --delete-target-dir -m 1 --table seoul_popular_trip --where "id > 20001" --target-dir /user/sqoop/target/seoul_popular_partition/part=20000
```


### 증분 테이블 수집
* create table inc\_table
```bash
docker exec -it mysql mysql -uuser -p

create table inc_table (id int not null auto_increment, name varchar(30), salary int, primary key (id));
insert into inc_table (name, salary) values ('suhyuk', 10000);
```
* sqoop import incremental table
```bash
./sqoop-import.sh --table inc_table --incremental append --check-column id --last-value 0 --target-dir /user/sqoop/target/seoul_popular_inc
```


### 모든 테이블 수집
* import-all-tables
```bash
docker exec -it sqoop sqoop imoprt-all-tables --connect jdbc:mysql://mysql:3306/testdb --warehouse-dir /user/sqoop/target/testdb --username user --password pass
./hadoop.sh fs -rm -r /user/sqoop/target/testdb
docker exec -it sqoop sqoop imoprt-all-tables -m 1 --connect jdbc:mysql://mysql:3306/testdb --warehouse-dir /user/sqoop/target/testdb --username user --password pass
```



## 아파치 스쿱을 통한 테이블 적재

### 새로운 테이블을 생성하고 적재
* sqoop export seoul\_popular\_exp
```bash
create table testdb.seoul_popular_exp (category int not null, id int not null, name varchar(100), address varchar(100), naddress varchar(100), tel varchar(20), tag varchar(500)) character set utf8 collate utf8_general_ci;

./sqoop-eval.sh "show tables"
./sqoop-export.sh -m 1 --table seoul_popular_exp --export-dir /user/sqoop/target/seoul_popular_exp
```
* sqoop import w/ tab delimiter
```bash
./sqoop-import.sh -m 1 --table seoul_popular_trip --target-dir /user/sqoop/target/seoul_popular_trip
./sqoop-import.sh -m 1 --table seoul_popular_trip --fields-terminated-by '\t' --delete-target-dir --target-dir /user/sqoop/target/seoul_popular_trip
```
* sqoop export again
```bash
./sqoop-export.sh -m 1 --table seoul_popular_exp --fields-terminated-by '\t' --export-dir /user/sqoop/target/seoul_popular_trip
./sqoop-eval.sh "select count(1) from seoul_popular_exp"
```
