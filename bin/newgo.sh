#!/bin/bash -
set -euo pipefail # informal strict mode
set -x # debugging

series="$*"
dir="n/$series/A"
mkdir -p "$dir"
cat > "$dir/go.ks" << EOF
{ parameter n.
  local _ is lex(
"go", {

   // add code for $series here.

}).
  export(n, _).
}
EOF
