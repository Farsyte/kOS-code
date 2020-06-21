local home is "0:/n/"+ship:name+"/".
local pack is "0:/p/".
local package is lex().
function export {
  parameter n, p.
  set package[n] to p.
}.
function import {
  function nf {
    parameter src, ks.
    if not exists(src+ks) return true.
    copypath(src+ks,ks). return false.
  }.
  parameter n.
  local ks is n + ".ks".
  if package:haskey(n) return package[n].
  if homeconnection:isconnected and nf(home,ks) and nf(home+"../",ks) nf(pack,ks).
  if exists(ks) runoncepath(ks,n).
  if package:haskey(n) return package[n].
  return lex().
}.