# 데이터 엔지니어링 기본 - Docker
> 도커 엔진의 기본적인 동작 방식을 이해하기 위한 실습을 수행합니다


## 도커 이미지 크기 비교
```bash
docker pull alpine
docker pull ubuntu
docker image ls
```

## 간단한 명령어 실습
```bash
docker run alpine top
docker run alpine uname -a
docker run alpine cat /etc/issue
```

## bash 가 없기 때문에 /bin/sh 을 통해 --interactive --tty 를 생성해봅니다
```bash
docker run -it alpine /bin/sh
```

## vim 도 없기 때문에 패키지 도구인 apk 및 apk add/del 를 통해 vim 을 설치 및 제거합니다
```bash
# apk { add, del, search, info, update, upgrade } 등의 명령어를 사용할 수 있습니다
$ apk update # 를 통해
$ apk add vim
$ apk del vim
```

# 각종 기본 도커 명령어 실습
```bash
docker inspect upbeat_jackson
docker image prune
docker stats upbeat_jackson
```

## 메모리 설정을 변경한 상태 확인 - https://docs.docker.com/config/containers/start-containers-automatically/
```bash
docker run -it -m 500m ubuntu
docker run -it --restart=on-failure:3 -m 500m ubuntu
docker run -it --restart=always -m 500m ubuntu
docker stats stoic_shamir
docker container prune
```


## 도커 컨테이너 사용 후 삭제 여부
```bash
docker run -it ubuntu /bin/bash
docker run --rm -it ubuntu /bin/bash
```
