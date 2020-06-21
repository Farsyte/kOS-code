{ parameter n. local _ is lex(
"pr", {parameter n,s. until s:length >= n {set s to s+" ".} return s.},
"pl", {parameter n,s. until s:length >= n {set s to " "+s.} return s.},
"pd", {parameter n,v. return _:pl(n,""+round(v)).},).
export(n, _).}