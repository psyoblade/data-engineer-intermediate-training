# 플루언트디를 통한 파일 데이터 수집
> 실습 시에 복사해서 붙여넣기 위한 별도의 스크립트를 작성합니다


## 예제 #1. 웹 서버를 통해서 전송 받은 데이터를 표준 출력으로 전달
* fluent.conf
```conf
<source>
    @type http
    port 9880
    bind 0.0.0.0
</source>

<match test>
    @type stdout
</match>
```
* docker-compose.yml
```yml
version: "3"
services:
  fluentd:
    container_name: fluentd
    image: psyoblade/data-engineer-intermediate-day2-fluentd
    user: fluent
    tty: true
    ports:
      - 9880:9880
    volumes:
      - ./fluent.conf:/fluentd/etc/fluent.conf
```
* send\_http.sh
```bash
curl -i -X POST -d 'json={"action":"login","user":2}' http://localhost:9880/test
```

## 예제 #2. 더미 에이전트를 통해 생성된 이벤트를 로컬 저장소에 저장

## 예제 #3. 시스템 로그를 테일링 하면서 표준 출력으로 전달

## 예제 #4. 싱글 노드에서 성능 향상 방안

## 예제 #5. 컨테이너 환경에서의 로그 전송

## 예제 #6. 도커 컴포즈를 통한 로그 전송 구성

## 예제 #7. 멀티 프로세스를 통한 성능 향상 방안

## 예제 #8. 멀티 프로세스를 통해 하나의 위치에 저장

## 예제 #10. 전송되는 데이터를 분산 저장소에 저장
