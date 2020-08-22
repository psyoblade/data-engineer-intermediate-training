# 7일차. 샌드박스 환경에서 데이터 가공 및 시각화 실습
> 조별 프로젝트를 진행하기에 앞서 스파크를 통해 데이터 가공 및 시각화에 이르는 실습을 통해 내가 집중해서 진행해야 할 파트를 검토하고, 보다 집중해서 진행하고 싶은 프로젝트의 방향을 정하기 위한 실습입니다


## 스파크 실습을 위한 도커 컨테이너를 기동합니다
* 최신 소스를 내려 받습니다
```bash
cd /home/ubuntu/work/data-engineer-intermediate-training
git pull
```
* 스파크 워크스페이스로 이동하여 도커를 기동합니다
```bash
cd /home/ubuntu/work/data-engineer-intermediate-training/day3
docker-compose up -d
docker-compose logs -f notebook
```
* 출력되는 로그 가운데 마지막에 URL 이 출력되는데 해당 URL에서 127.0.0.1 값을 student#.lgebigdata.com 으로 변경하여 접속합니다
  * http://student#.lgebigdata.com:8888/?token=d508d3a860cbc00c1095b078f9f7bd755a3b3f95f715692e
  * 접속하면 jupyter notebook lab 이 열리고 work 폴더가 보이면 정상 기동 된 것입니다
* 프로젝트 실습을 위한 샌드박스 환경의 노트북을 엽니다
  * work/day6\_visualization.ipynb

