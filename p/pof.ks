// Phases of Flight
{ parameter n.

  local ss is import("setstage"):go.
  deletepath("setstage.ks").

  // can we put this at the top?
  export(n, lex(
    "launch", launch@,
    "circ", circ@)).

  local ev is import("boot"):ev.

  // pof:launch(launch_azimuth, orbit_altitude, release_altitude) -- launch
  function launch {
    parameter Dir, Ho, Atm.
    set Ct to 1. set Cs to facing.
    unlock steering. unlock throttle.
    ev("push GO to launch").
    wait until availablethrust > 0.
    lock steering to Cs. lock throttle to Ct.
    ev("launch ...").
    wait until ship:velocity:surface:mag > 10.
    lock Cs to heading(Dir, 90).

    ss().
    runpath("auto_stage.ks").
    deletepath("auto_stage.ks").

    wait until ship:velocity:surface:mag > 100.
    ev("pitch over").

    lock pct_alt to alt:radar / Ho.
    lock target_pitch to -115.23935 * pct_alt^0.4095114 + 88.963.
    lock pitch to max(0, target_pitch).

    lock Cs to heading(Dir, pitch, 0).

    wait until ship:apoapsis > Ho + 1000.
    ev("meco at " + round(altitude/1000) + " km").
    lock Cs to prograde.
    set Ct to 0.

    wait until (eta:apoapsis < 30) or (ship:altitude >= Ho - 2000) or (ship:verticalspeed < 0).

    unlock steering. unlock throttle.
    ev("launch done").
  }

  // pof:circ() -- basic circularization
  function circ {
    LOCAL Sc IS SQRT(BODY:MU/(BODY:RADIUS+ALTITUDE)).
    LOCAL dV IS VXCL(UP:VECTOR,VELOCITY:ORBIT):NORMALIZED*Sc-VELOCITY:ORBIT.
    LOCAL dVm IS dV:MAG.
    SET Cs TO LOOKDIRUP(dV,facing:topvector).
    IF MAXTHRUST > 0 {
      SET Ct TO min(1,max(0,MAX(0,1-VANG(FACING:VECTOR,dV)/5)*5*dVm*mass/maxthrust)).
    } ELSE {
      SET Ct TO 0.
    }
    return list(dVm,Cs,Ct).
  }
}
