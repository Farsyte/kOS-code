#!/bin/bash -
set -euo pipefail # informal strict mode
set -x # debugging

series="$*"
dir="n/$series/A"
mkdir -p "$dir"
cat > "$dir/go.ks" << EOF
{ parameter n. export(n, lex("go",go@)).
  function go {

  }
}
EOF
