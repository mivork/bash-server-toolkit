#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "使い方: $0 <ディレクトリ> <日数> [--execute]" >&2
    echo "" >&2
    echo "指定ディレクトリ内の *.log ファイルのうち、指定日数より古いものを gzip 圧縮します。" >&2
    echo "デフォルトはドライラン（対象一覧を表示するだけ）です。" >&2
    echo "--execute を付けると実際に圧縮を実行します。" >&2
    echo "" >&2
    echo "例: $0 /var/log/myapp 30"           >&2
    echo "    $0 /var/log/myapp 30 --execute"  >&2
    exit 1
}

if [[ $# -lt 2 ]]; then
    usage
fi

LOG_DIR="$1"
DAYS="$2"
EXECUTE=false

if [[ $# -ge 3 && "$3" == "--execute" ]]; then
    EXECUTE=true
fi

if [[ ! -d "$LOG_DIR" ]]; then
    echo "エラー: ディレクトリが存在しません: $LOG_DIR" >&2
    exit 1
fi

if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
    echo "エラー: 日数は正の整数で指定してください: $DAYS" >&2
    exit 1
fi

# 対象ファイルを検索
mapfile -t TARGET_FILES < <(find "$LOG_DIR" -maxdepth 1 -name "*.log" -type f -mtime +"$DAYS" | sort)

if [[ ${#TARGET_FILES[@]} -eq 0 ]]; then
    echo "${DAYS} 日より古い .log ファイルは見つかりませんでした: $LOG_DIR"
    exit 0
fi

echo "${DAYS} 日より古い .log ファイル: ${#TARGET_FILES[@]} 件"
echo ""

for file in "${TARGET_FILES[@]}"; do
    size="$(du -h "$file" | cut -f1)"
    mod_date="$(date -r "$file" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || stat -c '%y' "$file" 2>/dev/null | cut -d. -f1)"
    echo "  $file  ($size, $mod_date)"
done

echo ""

if [[ "$EXECUTE" == true ]]; then
    echo "圧縮を実行します..."
    for file in "${TARGET_FILES[@]}"; do
        echo "  gzip: $file"
        gzip "$file"
    done
    echo "完了: ${#TARGET_FILES[@]} 件を圧縮しました"
else
    echo "[ドライラン] 実際に圧縮するには --execute を付けて再実行してください"
fi
