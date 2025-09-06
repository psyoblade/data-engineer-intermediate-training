#!/usr/bin/env bash
# load-offline.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${ROOT_DIR}/cache"

log(){ printf "[%s] %s\n" "$(date +'%F %T')" "$*"; }

[ -d "$CACHE_DIR" ] || { echo "cache 폴더가 없습니다."; exit 1; }

for tar in "$CACHE_DIR"/*.tar; do
  [ -e "$tar" ] || { echo "캐시 tar가 없습니다."; exit 0; }
  base="$(basename "$tar" .tar)"
  # 무결성 검증(있으면)
  if [ -f "$CACHE_DIR/${base}.sha256" ]; then
    (cd "$CACHE_DIR" && sha256sum -c "${base}.sha256")
  fi
  log "로드: $tar"
  docker load -i "$tar"
done

log "오프라인 로드 완료."
