#!/usr/bin/env bash

# benchmark.sh — 自動偵測最佳 XMRig threads 數量
# 用法: chmod +x benchmark.sh && ./benchmark.sh

XMRIG_BIN=$(command -v xmrig)
if [[ -z "$XMRIG_BIN" ]]; then
  echo "Error: 無法找到 xmrig 可執行檔，請先安裝並加入 PATH。"
  exit 1
fi

# 取得可用 vCPU 總數
CPU_COUNT=$(nproc)
echo "偵測到 $CPU_COUNT vCPU，開始跑 benchmark..."

# 要測試的 thread 值範圍（例如 50% ~ 100%）
MIN_HINT=0.5
MAX_HINT=1.0
STEP=0.1

BEST_HASH=0
BEST_THREADS=0

# 對 hint 值進行迴圈
for hint in $(seq $MIN_HINT $STEP $MAX_HINT); do
  # 計算真正的 threads 數量
  THREADS=$(printf "%.0f" "$(echo "$CPU_COUNT * $hint" | bc)")
  THREADS=$(( THREADS < 1 ? 1 : THREADS ))
  echo -n "測試 threads=$THREADS ... "

  # 執行 benchmark（每次測 10 秒，可依需調整 --benchmark-time）
  HASH=$(timeout 15s $XMRIG_BIN \
    --benchmark --benchmark-time=10 \
    --cpu-max-threads-hint=$hint \
    --print-time=0 \
    | awk '/total speed/{print $3}' )

  # 解析 Hashrate（H/s）
  HPS=$(printf "%.0f" "$HASH")

  echo "${HPS} H/s"

  # 比較並記錄最佳結果
  if (( HPS > BEST_HASH )); then
    BEST_HASH=$HPS
    BEST_THREADS=$THREADS
    BEST_HINT=$hint
  fi
done

echo
echo "🔥 最佳配置："
echo "   threads = $BEST_THREADS (hint = $BEST_HINT)"
echo "   Hashrate = $BEST_HASH H/s"
echo
echo "你可以在 config.json 中設定："
echo "  \"max-threads-hint\": $BEST_HINT"
