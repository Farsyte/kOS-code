@lazyglobal off.
set ship:control:pilotmainthrottle to 0. wait 3.
if homeconnection:isconnected
  copypath("0:/bootlib.ks","bootlib.ks").
if exists("bootlib.ks")
  runoncepath("bootlib.ks").
import("go"):go().