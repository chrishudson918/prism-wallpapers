#!/bin/bash
# ── Parse Arguments ──
# Accepts standard: ./generate.sh 6100 network
# Accepts mixed   : ./generate.sh 6100-2076 network
# Accepts skip    : ./generate.sh 6100-2076 network --skip-logos
# Accepts mdblist : ./generate.sh --url "username/list-slug" --sort imdbrating.desc

URL=""
SORT="score.desc"
IDS_INPUT=""
TYPE=""
SKIP_LOGOS=false

for arg in "$@"; do
    if [ "$arg" == "--skip-logos" ]; then
        SKIP_LOGOS=true
    fi
done

# ── Check for --url mode ──
i=1
while [ $i -le $# ]; do
    arg="${!i}"
    if [ "$arg" == "--url" ]; then
        i=$((i+1)); URL="${!i}"
    elif [ "$arg" == "--sort" ]; then
        i=$((i+1)); SORT="${!i}"
    fi
    i=$((i+1))
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY_CMD="python3"

# ── MDBList URL Mode ──
if [ -n "$URL" ]; then
    echo "=========================================="
    echo "Processing MDBList: $URL"
    echo "=========================================="
    echo "── 1. [SKIPPED] No logos needed for MDBList."
    echo ""
    echo "── 2. Generating T1 Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1.py" --url "$URL" --sort "$SORT"
    echo ""
    echo "── 3. Generating T1 Flat Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1_flat.py" --url "$URL" --sort "$SORT"
    echo ""
    echo "── 4. Generating T2 Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2.py" --url "$URL" --sort "$SORT"
    echo ""
    echo "── 5. Generating T2 Flat Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2_flat.py" --url "$URL" --sort "$SORT"
    echo "=========================================="
    echo "🎯 All tasks completed!"
    echo "=========================================="
    exit 0
fi

# ── Original ID Mode ──
IDS_INPUT=$1
TYPE=$2

if [ "$TYPE" == "curated" ]; then
    SKIP_LOGOS=true
fi

if [ -z "$IDS_INPUT" ] || [ -z "$TYPE" ]; then
    echo "Usage: $0 <id or id-id> <type> [--skip-logos]"
    echo "       $0 --url <mdblist-url> [--sort <sort>]"
    exit 1
fi

if [[ "$IDS_INPUT" == *"-"* ]] && [[ "$IDS_INPUT" != *"-movies"* ]] && [[ "$IDS_INPUT" != *"-tv"* ]]; then
    echo "── 🔀 Mixed IDs detected: $IDS_INPUT"
    CLEAN_IDS=$(echo "$IDS_INPUT" | tr '-' ' ')
    if [ "$SKIP_LOGOS" = false ]; then
        echo "── 1. Pulling logos for mixed sources..."
        for ID in $CLEAN_IDS; do
            echo "  -> Pulling for ID: $ID"
            $PY_CMD "$ROOT_DIR/scripts/logo_pull.py" --id "$ID" --type "$TYPE"
        done
    else
        echo "── 1. [SKIPPED] Skipping logo pull as requested."
    fi
    echo ""
    echo "── 2. Generating Mixed T1 Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1.py" --id $CLEAN_IDS --type "$TYPE"
    echo ""
    echo "── 3. Generating Mixed T1 Flat Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1_flat.py" --id $CLEAN_IDS --type "$TYPE"
    echo ""
    echo "── 4. Generating Mixed T2 Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2.py" --id $CLEAN_IDS --type "$TYPE"
    echo ""
    echo "── 5. Generating Mixed T2 Flat Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2_flat.py" --id $CLEAN_IDS --type "$TYPE"
else
    ID="$1"
    TYPE="$2"
    echo "=========================================="
    echo "Processing ID: $ID ($TYPE)"
    echo "=========================================="
    if [ "$SKIP_LOGOS" = false ]; then
        echo "── 1. Pulling logos..."
        $PY_CMD "$ROOT_DIR/scripts/logo_pull.py" --id "$ID" --type "$TYPE"
    else
        echo "── 1. [SKIPPED] Skipping logo pull as requested."
    fi
    echo ""
    echo "── 2. Generating T1 Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1.py" --id "$ID" --type "$TYPE"
    echo ""
    echo "── 3. Generating T1 Flat Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T1_flat.py" --id "$ID" --type "$TYPE"
    echo ""
    echo "── 4. Generating T2 Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2.py" --id "$ID" --type "$TYPE"
    echo ""
    echo "── 5. Generating T2 Flat Backdrops..."
    $PY_CMD "$ROOT_DIR/scripts/backdrop_T2_flat.py" --id "$ID" --type "$TYPE"
fi

echo "=========================================="
echo "🎯 All tasks completed!"
echo "=========================================="
