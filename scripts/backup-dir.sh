#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "使い方: $0 <対象ディレクトリ> <出力先ディレクトリ>" >&2
    echo "例:     $0 /var/www/html /backup/www" >&2
    exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

SOURCE_DIR="$1"
DEST_DIR="$2"

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "エラー: 対象ディレクトリが存在しません: $SOURCE_DIR" >&2
    exit 1
fi

mkdir -p "$DEST_DIR"

DIR_NAME="$(basename "$SOURCE_DIR")"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
ARCHIVE_FILE="$DEST_DIR/${DIR_NAME}_${TIMESTAMP}.tar.gz"

echo "バックアップを開始します"
echo "  対象: $SOURCE_DIR"
echo "  出力: $ARCHIVE_FILE"

tar -czf "$ARCHIVE_FILE" -C "$(dirname "$SOURCE_DIR")" "$DIR_NAME"

echo "バックアップが完了しました: $ARCHIVE_FILE"

# 世代管理: 最新 7 件だけ残す
cd "$DEST_DIR"
# shellcheck disable=SC2012
ls -1t "${DIR_NAME}_"*.tar.gz 2>/dev/null | tail -n +8 | while IFS= read -r old_file; do
    echo "古いバックアップを削除: $old_file"
    rm -f "$old_file"
done

echo "完了"
