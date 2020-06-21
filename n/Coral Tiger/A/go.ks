{ parameter n. local ev is import("bootx"):ev. local l is lex("go", {

  lock steering to heading(0,90).
  lock throttle to 0.
  ev("ready").
  wait until availableThrust > 0.
  ev("launch").
  lock throttle to 1. wait 1.
  when availableThrust <= 0 or apoapsis > 80000 then {
    ev("meco").
    lock throttle to 0.
  }
  wait until verticalspeed < 0.
  ev("alt " + round(altitude)).
  wait until verticalspeed < -10.
  lock steering to srfprograde.
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

}).  export(n, l). }