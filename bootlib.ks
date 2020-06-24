local _ is lex("home", "0:/n/"+ship:name+"/", "pack", "0:/p/",
"st", {parameter f. if homeconnection:isconnected and exists(f) copypath(f,_:home+f).},
"ev", {parameter m. hudtext(m,5,2,24,WHITE,true).}).
local package is lex("boot",_).
function export {
  parameter n, p.
  set package[n] to p.
}.
function import { parameter n. local ks is n + ".ks".
  if package:haskey(n) return package[n].
  function nf {parameter d,f. if not exists(d+f) return true. copypath(d+f,f). return false.}.
  if homeconnection:isconnected and nf(_:home,ks) and nf(_:home+"../",ks) nf(_:pack,ks).
  if exists(ks) runoncepath(ks,n).
  if package:haskey(n) return package[n].
  return lex().
}.