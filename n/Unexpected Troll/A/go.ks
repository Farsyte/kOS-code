{ parameter n.
  local ev is import("bootx"):ev.
  local _ is lex(
"go", {
 
  lock steering to heading(0,90).
  lock throttle to 0.
  ev("ready").
  wait until availableThrust > 0.
  ev("launch").
  lock throttle to 1. wait 1.
  local avt to availableThrust.
  wait until availableThrust < avt - 10.
  ev("booster sep").
  lock throttle to 0. wait 1. stage. wait 1.
  lock throttle to 1.
  set avt to availableThrust.
  wait until apoapsis > 80000 or availableThrust < avt - 10.
  ev("meco").
  lock throttle to 0.
  unlock steering.
  wait until verticalspeed < 0.
  ev("alt " + round(altitude)).
  wait until verticalspeed < -10.
  wait until altitude < 40000.
  ev("separate").
  stage.
  wait 2.
  lock steering to heading(0,90).
  wait 10.
  unlock steering.
  wait until alt:radar < 5000 and verticalspeed > -300.
  print "deploy chute at " + round(alt:radar) + " over ground, descending at " + round(-verticalspeed) + " m/s".
  stage.
  ev("chute").
  wait until verticalspeed > 0.
  ev("landed").
  lock steering to heading(0,90).

}).
  export(n, _).
}
