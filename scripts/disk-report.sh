#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-/}"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "エラー: ディレクトリが存在しません: $TARGET_DIR" >&2
    exit 1
fi

echo "========================================"
echo " ディスク使用量レポート"
echo " 生成日時: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"
echo ""

echo "--- ファイルシステム概要 (df -h) ---"
echo ""
df -h
echo ""

echo "--- $TARGET_DIR 配下のサブディレクトリ使用量トップ 10 ---"
echo ""
du -sh "$TARGET_DIR"/*/ 2>/dev/null | sort -rh | head -n 10 || echo "(サブディレクトリが見つかりませんでした)"
echo ""

echo "レポート終了"
