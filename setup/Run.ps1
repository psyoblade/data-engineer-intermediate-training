# Run.ps1
# 목적: Docker Desktop 실행 확인 → WSL 확인 → WSL로 pull-images.sh 실행

$ErrorActionPreference = "Stop"

function Fail($msg) {
  Write-Host "[ERROR] $msg" -ForegroundColor Red
  exit 1
}

Write-Host "[INFO] 사전 점검 중..."

# 1) Docker Desktop 실행 확인(Windows 서비스/프로세스 기준 대략적 체크)
$dockerOk = $false
try {
  docker version | Out-Null
  $dockerOk = $true
} catch {
  Write-Host "[WARN] docker CLI가 바로 실행되지 않음. Docker Desktop 실행 여부 확인..."
}

if (-not $dockerOk) {
  Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe" | Out-Null
  Start-Sleep -Seconds 8
  try { docker version | Out-Null } catch { Fail "Docker Desktop가 실행되지 않았습니다. 수동 실행 후 재시도하세요." }
}

# 2) WSL 확인
wsl.exe -l -q | Out-Null
if ($LASTEXITCODE -ne 0) { Fail "WSL이 설치되지 않았습니다. 'WSL + Ubuntu' 설치 후 다시 시도하세요." }

# 3) 작업 폴더가 WSL에서 접근 가능한 경로인지 확인(기본: 현재 폴더)
$cur = (Get-Location).Path
Write-Host "[INFO] 현재 폴더: $cur"

# 4) WSL 내부에서 스크립트 실행
#    - WSL Ubuntu 배포판 이름을 명시하고 싶으면 -d Ubuntu 추가 가능
wsl.exe bash -lc "cd '$(wslpath $cur)' && chmod +x ./pull-images.sh ./load-offline.sh && ./pull-images.sh" 
if ($LASTEXITCODE -ne 0) { Fail "WSL 내부 스크립트 실행 실패" }

Write-Host "[INFO] 완료되었습니다." -ForegroundColor Green
