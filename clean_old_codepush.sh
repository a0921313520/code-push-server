#!/bin/bash

ROOT_PATH="/var/lib/docker/volumes/code-push-server_data-storage/_data"
CUTOFF_DATE="2022-01-01"
CUTOFF_FILE="/tmp/codepush_cutoff_ref"

# 创建参考时间戳文件
touch -d "$CUTOFF_DATE" "$CUTOFF_FILE"

echo "🔍 以下是将被删除的目录（修改时间早于 $CUTOFF_DATE）："
echo "------------------------------------------------------------"
printf "%-20s  %-8s  %s\n" "修改时间" "大小" "路径"
echo "------------------------------------------------------------"

# 收集符合条件的目录
TO_DELETE=()

# 遍历所有一级 app 文件夹（如 fg、fi、...）
for appdir in "$ROOT_PATH"/*; do
  [ -d "$appdir" ] || continue

  # 遍历每个 app 目录下的一级子目录（更新版本目录）
  while IFS= read -r version_dir; do
    [ -d "$version_dir" ] || continue
    MOD_TIME=$(date -r "$version_dir" "+%Y-%m-%d %H:%M:%S")
    SIZE=$(du -sh "$version_dir" 2>/dev/null | cut -f1)
    printf "%-20s  %-8s  %s\n" "$MOD_TIME" "$SIZE" "$version_dir"
    TO_DELETE+=("$version_dir")
  done < <(find "$appdir" -mindepth 1 -maxdepth 1 -type d ! -newer "$CUTOFF_FILE")

done

echo "------------------------------------------------------------"
read -p "⚠️ 确认删除以上 ${#TO_DELETE[@]} 个目录？输入 y 执行删除：" confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
  for item in "${TO_DELETE[@]}"; do
    rm -rf "$item"
  done
  echo "✅ 删除完成"
else
  echo "❌ 已取消删除"
fi

# 清除临时基准时间文件
rm -f "$CUTOFF_FILE"
