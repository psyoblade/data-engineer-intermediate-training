# 설치 가이드

```ps
# 1) 작업 폴더로 이동(예: C:\)
Set-Location C:\

# 2) 깃헙 리포지토리 내려받기(히스토리 최소화)
git clone --depth=1 https://github.com/psyoblade/data-engineer-intermediate-training.git

# 3) setup 폴더로 이동
Set-Location .\data-engineer-intermediate-training\setup

# 4) 스크립트 실행 정책(현재 세션만) 완화
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# 5) 실행! (Docker Desktop 실행 중인지 확인)
.\Run.ps1
```
