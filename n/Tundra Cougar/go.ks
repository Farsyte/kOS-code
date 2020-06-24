{ parameter n. export(n, lex("go", {

  local ev is import("boot"):ev.

  set Ho to 80000.
  set Dir to 0.
  set Th0 to 80.
  set Kps to 20.

  set Ct to 1.
  set Cs to facing.

  unlock steering. unlock throttle.
  ev("waiting for launch").
  wait until availablethrust > 0.
  lock steering to Cs. lock throttle to Ct.
  ev("liftoff").
  wait until ship:velocity:surface:mag > 10.
  lock Cs to heading(Dir, 90).

  import("setstage"):go().
  runpath("auto_stage.ks").
  deletepath("auto_stage.ks").
  deletepath("setstage.ks").

  local circ is import("circ"):circ.

  wait until ship:velocity:surface:mag > 100.
  ev("gravity turn").
  lock pitch to max(0, Th0 - ship:velocity:surface:mag / Kps).
  lock Cs to heading(Dir, pitch, 0).

  wait until ship:apoapsis > Ho + 1000.
  ev("meco").
  lock Cs to prograde.
  set Ct to 0.

  wait until (eta:apoapsis < 30) or (ship:altitude >= Ho - 2000) or (ship:verticalspeed < 0).

  ev("circ").
  until circ(5,5,1) {
    wait 0.1.
  }

  lock steering to prograde.
  lock throttle to 0.
  wait 5.
  ev("on orbit").

  // operator will toggle the gear when it is time to come home.
  gear off.
  wait until gear.

  ev("descent").

  lock steering to retrograde.
  lock throttle to 1.
  wait until periapsis < 30000.
  lock throttle to 0.
  wait 5.
  ev("separation").
  stage.
  lock steering to srfretrograde.
  wait 5.
  unlock steering.
  wait until altitude < 5000 and verticalspeed >= -300.
  ev("chutes").
  stage.
  lock steering to heading(0,90).

  ev("landing").
  wait until false.

})).}