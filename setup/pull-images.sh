#!/usr/bin/env bash
# pull-images.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGES_FILE="${ROOT_DIR}/images.txt"
CACHE_DIR="${ROOT_DIR}/cache"
LOG_DIR="${ROOT_DIR}/logs"
ENV_FILE="${ROOT_DIR}/.env"            # 선택 사용

mkdir -p "$CACHE_DIR" "$LOG_DIR"

log()   { printf "[%s] %s\n" "$(date +'%F %T')" "$*"; }
fail()  { printf "[%s] [ERROR] %s\n" "$(date +'%F %T')" "$*" >&2; exit 1; }

# 0) 전제 점검
command -v docker >/dev/null 2>&1 || fail "docker 명령을 찾을 수 없음(WSL에서 Docker Desktop 연동 필요)"
[ -f "$IMAGES_FILE" ] || fail "images.txt가 없습니다: $IMAGES_FILE"

# 1) 디스크 용량 안내
log "WSL 디스크 용량:"
df -h .
log "Docker 디스크 사용량:"
docker system df || true

# 2) 프록시/레지스트리 계정(.env) 로드(선택)
#    .env 예시:
#    HTTP_PROXY=http://proxy:8080
#    HTTPS_PROXY=http://proxy:8080
#    NO_PROXY=localhost,127.0.0.1
#    DOCKER_REGISTRY=registry.example.com
#    DOCKER_USERNAME=user
#    DOCKER_PASSWORD=pass
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
  export http_proxy="${HTTP_PROXY:-}" https_proxy="${HTTPS_PROXY:-}" no_proxy="${NO_PROXY:-}"
  if [ -n "${DOCKER_REGISTRY:-}" ] && [ -n "${DOCKER_USERNAME:-}" ] && [ -n "${DOCKER_PASSWORD:-}" ]; then
    log "프라이빗 레지스트리에 로그인 시도: ${DOCKER_REGISTRY}"
    echo "$DOCKER_PASSWORD" | docker login "$DOCKER_REGISTRY" -u "$DOCKER_USERNAME" --password-stdin || fail "레지스트리 로그인 실패"
  fi
fi

# 3) Pull + 검증 + tar 캐시
RETRY=3
while IFS= read -r line; do
  # skip comments/blank
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  image="$line"

  # 태그 미지정 방지
  if [[ "$image" != *:* ]]; then
    fail "태그가 없는 이미지가 있습니다(금지): $image  (예: repo/name:1.2.3 형식)"
  fi

  log "이미지 처리 시작: $image"

  # pull with retry (직렬로 안정성 확보)
  for attempt in $(seq 1 "$RETRY"); do
    if docker pull "$image" >>"$LOG_DIR/pull.log" 2>&1; then
      log "Pull 성공: $image"
      break
    fi
    log "Pull 실패($attempt/$RETRY): $image"
    sleep $(( attempt * 2 ))
    if [ "$attempt" -eq "$RETRY" ]; then
      fail "Pull 최종 실패: $image (네트워크/프록시/권한 확인)"
    fi
  done

  # 이미지 식별자/다이제스트 확보(가능한 경우)
  id="$(docker image inspect --format='{{.Id}}' "$image" 2>/dev/null || true)"
  digest="$(docker image inspect --format='{{index .RepoDigests 0}}' "$image" 2>/dev/null || true)"
  log "검증: Id=$id Digest=${digest:-N/A}"

  # tar 캐시 파일명: repo_name_tag 형식으로 안전 치환
  safe_name="$(echo "$image" | sed 's|/|_|g; s|:|_|g')"
  tar_path="${CACHE_DIR}/${safe_name}.tar"

  # 이미 캐시가 존재하면 스킵(필요 시 --force 옵션을 받아도 됨)
  if [ -f "$tar_path" ]; then
    log "캐시 존재: $tar_path (스킵)"
  else
    log "캐시 생성: $tar_path"
    docker save "$image" -o "$tar_path"
    # 무결성 체크 파일(sha256)
    (cd "$CACHE_DIR" && sha256sum "$(basename "$tar_path")" > "${safe_name}.sha256")
  fi

  log "완료: $image"
done < "$IMAGES_FILE"

log "모든 이미지 처리 완료."
log "오프라인 로드용: ./load-offline.sh 실행 시 cache/*.tar에서 로드합니다."
