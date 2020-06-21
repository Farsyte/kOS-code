{ parameter n. local ev is import("bootx"):ev. local l is lex("go", {

  lock steering to heading(0,90).
  lock throttle to 0.
  ev("ready").
  wait until availableThrust > 0.
  ev("launch").
  lock throttle to 1. wait 1.
  when availableThrust <= 0 then {
    ev("meco").
    lock throttle to 0.
  }
  wait until verticalspeed < 0.
  ev("alt " + round(altitude)).
  wait until verticalspeed < -10.
  ev("chute").
  stage.
  wait until verticalspeed > 0.
  ev("landed").

}).  export(n, l). }