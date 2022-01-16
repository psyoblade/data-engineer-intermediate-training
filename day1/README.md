# 1일차. 데이터 엔지니어링 기본

> 전체 과정에서 사용하는 기본적인 명령어(docker, docker-compose)에 대해 실습하고 사용법을 익힙니다.

- 범례
  * :green_book: : 기본, :blue_book: : 중급, :closed_book: : 고급

- 목차
  * [1. 클라우드 장비에 접속](#1-클라우드-장비에-접속)
  * [2. 도커 컴포즈 명령어 실습](#2-Docker-Compose-명령어-실습)
  * [3. 참고 자료](#3-참고-자료)
<br>


## 1. 클라우드 장비에 접속

> 개인 별로 할당 받은 `ubuntu@vm[number].aiffelbiz.co.kr` 에 putty 혹은 terminal 을 이용하여 접속합니다


### 1-1. 원격 서버로 접속합니다
```bash
# terminal
# ssh ubuntu@vm001.aiffelbiz.co.kr
# password: ******
```

### 1-2. 패키지 설치 여부를 확인합니다
```bash
docker --version
docker-compose --version
git --version
```

<details><summary> :green_book: [실습] 출력 결과 확인</summary>

> 출력 결과가 오류가 발생하지 않고, 아래와 같다면 성공입니다

```text
Docker version 20.10.6, build 370c289
docker-compose version 1.29.1, build c34c88b2
git version 2.17.1
```

</details>

[목차로 돌아가기](#1일차-데이터-엔지니어링-기본)

<br>
<br>


## 2. Docker Compose 명령어 실습

> 도커 컴포즈는 **도커의 명령어들을 반복적으로 수행되지 않도록 yml 파일로 저장해두고 활용**하기 위해 구성되었고, *여러개의 컴포넌트를 동시에 기동하여, 하나의 네트워크에서 동작하도록 구성*한 것이 특징입니다. 내부 서비스들 간에는 컨테이너 이름으로 통신할 수 있어 테스트 환경을 구성하기에 용이합니다. 
<br>

### 실습을 위한 기본 환경을 가져옵니다

```bash
# terminal
mkdir -p /home/ubuntu/work
cd /home/ubuntu/work
git clone https://github.com/psyoblade/data-engineer-intermediate-training.git
cd /home/ubuntu/work/data-engineer-intermediate-training/day1
```
<br>


### Docker Compose 기본 명령어

> 도커 컴포즈는 **컨테이너를 기동하고 작업의 실행, 종료 등의 명령어**를 주로 다룬다는 것을 알 수 있습니다. 아래에 명시한 커맨드 외에도 도커 수준의 명령어들(pull, create, start, stop, rm)이 존재하지만 잘 사용되지 않으며 일부 deprecated 되어 자주 사용하는 명령어 들로만 소개해 드립니다

<br>


### 2-1. 컴포즈 명령어 옵션

#### 2-1-1. [config](https://docs.docker.com/compose/reference/config/) : 컨테이너 실행 설정을 확인합니다
  - <kbd>-q, --quiet</kbd> : 설정의 정상여부만 확인하고 출력하지 않습니다
```bash
# docker-compose config [options]
docker-compose config
```
<br>

#### 2-1-2. [up](https://docs.docker.com/compose/reference/up/) : `docker-compose.yml` 파일을 이용하여 컨테이너를 이미지 다운로드(pull), 생성(create) 및 시작(start) 시킵니다
  - <kbd>-d, --detach <filename></kbd> : 서비스들을 백그라운드 모드에서 수행합니다
```bash
# docker-compose up [options] <services>
docker-compose up -d
```
<br>

#### 2-1-3. [exec](https://docs.docker.com/compose/reference/exec/) : 컨테이너 내부에서 커맨드를 실행합니다
  - <kbd>-d, --detach</kbd> : 백그라운드 모드에서 실행합니다
  - <kbd>-e, --env `KEY=VAL`</kbd> : 환경변수를 전달합니다
  - <kbd>-u, --user [string]</kbd> : 이용자를 지정합니다
  - <kbd>-w, --workdir [string]</kbd> : 워킹 디렉토리를 지정합니다

```bash
# docker-compose exec [options] [-e KEY=VAL...] [--] SERVICE COMMAND [ARGS...]
docker-compose exec ubuntu echo hello world
```
<br>

#### 2-1-4. [down](https://docs.docker.com/compose/reference/down/) : 컨테이너를 종료 시킵니다
  - <kbd>-t, --timeout [int] <filename></kbd> : 셧다운 타임아웃을 지정하여 무한정 대기(SIGTERM)하지 않고 종료(SIGKILL)합니다 (default: 10초)
```bash
# docker-compose down [options] <services>
docker-compose down
```
<br>

<details><summary> :green_book: [실습] `up -d` 과 down 명령어를 통해 컨테이너를 기동하고, `hello data engineer` 출력 후, 종료해 보세요</summary>

> 출력 결과가 오류가 발생하지 않고, 아래와 같다면 성공입니다

```text
[+] Running 2/2
 ⠿ Container ubuntu Started
 ⠿ Container mysql  Started
```

> 아래와 같은 방법으로 실행할 수 있습니다
```bash
docker-compose up -d
docker-compose exec ubuntu echo hello data engineer
docker-compose down
```

</details>

<br>
<br>



### 2-2. 컴포즈 옵션

<br>

#### 2-2-1. compose options : 반드시 docker-compose 명령어 다음에 입력해야 하는 옵션 
  - <kbd>--file, -f [filename]</kbd> : 별도 yml 파일을 통해 기동시킵니다 (default: `-f docker-compose.yml`)
  - <kbd>--env-file [env-file]</kbd> : 별도 env 파일을 통해 환경변수를 지정합니다l (default: `--env-file .env`)
```bash
# docker-compose [compose options] [command] [command options]
docker-compose -f docker-compose.yml up -d
```
<br>

> [MySQL 서버에 접속](https://dev.mysql.com/doc/refman/8.0/en/connecting.html) 하는 방법

* 로컬 환경에서는 `--host` 정보는 입력하지 않아도 됩니다
```bash
mysql --host=localhost --user=scott --password=tiger default
mysql -hlocalhost -uscott -ptiger default
```
<br>


#### 2-2-2. 접속정보를 별도의 환경변수 파일에 저장하는 방법
> 코드와 동일한 수준에서 형상관리가 되는 docker-compose.yml 파일에 접속정보를 저장하는 것은 위험할 수 있으므로 별도로 관리(ansible 등)하는 경우 `.env` 파일에 저장관리될 수 있습니다

* default 값이 같은 경로에 `.env` 파일로 `KEY=VALUE` 형식으로 저장될 수 있습니다
```bash
# cat .env
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=default
MYSQL_USER=scott
MYSQL_PASSWORD=tiger
```

* `docker-compose.yml` 설정에서 environment 설정은 아래와 같이 변수로 치환됩니다
```yaml
# grep 'environment' -a5 docker-compose.yml
environment:
  MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD
  MYSQL_DATABASE: $MYSQL_DATABASE
  MYSQL_USER: $MYSQL_USER
  MYSQL_PASSWORD: $MYSQL_PASSWORD
```

* 현재 설정된 값을 출력하고 싶다면 `config` 명령으로 확인할 수 있습니다
```bash
$ docker-compose config | more
services:
  mysql:
    container_name: mysql
    environment:
      MYSQL_DATABASE: default
      MYSQL_PASSWORD: tiger
      MYSQL_ROOT_PASSWORD: root
      MYSQL_USER: scott
    healthcheck:
...
```

<details><summary> :green_book: [실습] .env 파일을 env 파일로 생성하고, 패스워드(=pass), 계정정보(=user) 및 데이터베이스(testdb)으로 변경하여 --env-file 옵션으로 config 를 통해 제대로 수정 되었는지 확인해 보세요</summary>

> 아래와 같이 config 결과가 나온다면 정답입니다
```bash
docker-compose --env-file env config | head -15
services:
  mysql:
    container_name: mysql
    environment:
      MYSQL_DATABASE: testdb
      MYSQL_PASSWORD: pass
      MYSQL_ROOT_PASSWORD: root
      MYSQL_USER: user
```

> `env` 파일 
```text
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=testdb
MYSQL_USER=user
MYSQL_PASSWORD=pass
```

> `docker-compose.yml` 파일
```yaml
version: "3"

services:
  mysql:
    container_name: mysql
    image: psyoblade/data-engineer-mysql:1.1
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD
      MYSQL_DATABASE: $MYSQL_DATABASE
      MYSQL_USER: $MYSQL_USER
      MYSQL_PASSWORD: $MYSQL_PASSWORD
    ports:
      - '3306:3306'
    networks:
      - default
    healthcheck:
      test: ["CMD", "mysqladmin" ,"ping", "-h", "localhost"]
      interval: 3s
      timeout: 1s
      retries: 3
    volumes:
      - ./mysql/etc:/etc/mysql/conf.d

networks:
  default:
    name: default_network
```

> 아래와 같은 방법으로 실행할 수 있습니다

```bash
docker-compose --env-file env config
```

> 기존의 데이터베이스를 종료하고 다시 기동하여 접속합니다

```bash
docker-compose down
docker-compose --env-file env up -d
docker-compose exec mysql mysql -uuser -ppass testdb
```

</details>

<br>
<br>


### 2-3. 기타 명령어

#### 2-3-1. [logs](https://docs.docker.com/compose/reference/logs/) : 컨테이너의 로그를 출력합니다
  - <kbd>-f, --follow</kbd> : 출력로그를 이어서 tailing 합니다
```bash
# terminal
docker-compose up -d mysql
docker-compose logs -f mysql
```
<br>

#### 2-3-2. [pull](https://docs.docker.com/compose/reference/pull/) : 컨테이너의 모든 이미지를 다운로드 받습니다
  - <kbd>-q, --quiet</kbd> : 다운로드 메시지를 출력하지 않습니다 
```bash
# terminal
docker-compose pull
```
<br>

#### 2-3-3. [ps](https://docs.docker.com/compose/reference/ps/) : 컨테이너 들의 상태를 확인합니다
  - <kbd>-a, --all</kbd> : 모든 서비스의 프로세스를 확인합니다
```bash
# terminal
docker-compose ps -a
```
<br>

#### 2-3-4. [cp](https://docs.docker.com/engine/reference/commandline/compose_cp/) : 컴포즈 컨테이너와 파일을 복사합니다
```bash
# docker compose cp [OPTIONS] SERVICE:SRC_PATH DEST_PATH|-
docker-compose cp ./local/path/filename ubuntu:/container/path/filename
```
<br>

#### 2-3-5. [top](https://docs.docker.com/compose/reference/top/) : 컨테이너 내부에 실행되고 있는 프로세스를 출력합니다
```bash
# docker-compose top <services>
docker-compose top
```
<br>

### Bash 스크립트 생성 예제

* 환경변수에 따라 다르게 동작하는 스크립트를 생성합니다
  - `cat > run.sh` <kbd>enter</kbd> 후에 아래 내용을 붙여넣고 <kbd>Ctrl+C</kbd> 하면 파일이 생성됩니다
```bash
#!/bin/bash
if [[ $DEBUG -eq 1 ]]; then
    echo "this is debug mode"
else
    echo "this is release mode"
fi
```

* 아래의 도커 `cp` 명령어로 컨테이너 내부로 스크립트를 복사합니다
```bash
docker cp ./run.sh ubuntu:/run.sh
```

<details><summary> :green_book: [실습] 환경변수 값(DEBUG=1)에 따라 결과가 달라지는 bash 스크립트를 생성 및 실행해 보세요</summary>

> 출력 결과가 오류가 발생하지 않고, 아래와 같다면 성공입니다

```text
$ this is debug mode
```

> 아래와 같은 방법으로 실행할 수 있습니다 (-e 옵션의 위치가 중요합니다)
```bash
docker-compose exec -e DEBUG=0 ubuntu bash run.sh
docker-compose exec -e DEBUG=1 ubuntu bash run.sh
```

</details>


[목차로 돌아가기](#1일차-데이터-엔지니어링-기본)

<br>


## 3. 참고 자료
* [Docker Compose Cheatsheet](https://devhints.io/docker-compose)
* [Compose Cheatsheet](https://buildvirtual.net/docker-compose-cheat-sheet/)

