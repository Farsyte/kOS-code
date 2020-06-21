{ parameter n. local _ is lex(
"rng", {parameter lo,v,hi. return (lo <= v) and (v <= hi).},
"ish", {parameter a,b,e. return _:rng(-e,a-b,e).}).
export(n, _).}