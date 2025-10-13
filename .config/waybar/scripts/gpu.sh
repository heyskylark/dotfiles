#!/usr/bin/env bash
# Shows GPU%, VRAM%, Temp°C
read -r GPU MEM TEMP <<<"$(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits \
  | awk -F',' '{g=$1+0; mu=$2+0; mt=$3+0; t=$4+0; printf "%d %d %d\n", g, (mt?int(mu*100/mt):0), t}')"
printf '{"text":"%s%% %s%% %s°C","alt":"gpu","tooltip":"GPU %s%% | VRAM %s%% | %s°C"}\n' "$GPU" "$MEM" "$TEMP" "$GPU" "$MEM" "$TEMP"

