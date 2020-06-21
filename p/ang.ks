{ parameter n. local ish is import("ish"):ish. local _ is lex(
"sa", {parameter a. if a < 0 return -b:sa(-a). return mod(a+180,360)-180.},
"ua", {parameter a. if a < 0 return 360-b:ua(-a). return mod(a,360).},
"angish", {parameter a,b,e. return ish(b:sa(a-b),0,e).}).
export(n, _).}