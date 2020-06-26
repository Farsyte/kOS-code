// Phases of Flight
{ parameter n.

  local ss is import("setstage"):go.
  deletepath("setstage.ks").

  // can we put this at the top?
  export(n, lex(
    "launch", launch@,
    "circ", circ@,
    "node", node@)).

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

  local bv is v(0,0,0).
  local v0 is v(0,0,0).
  local dv is 0.
  local dt is 0.

  // pof:node() -- subroutine for mnv node processing
  // returns remaining delta-v, or -1 if really done.
  // uses bv, v0, dv, dt in the parent scope for state.
  function node {
    local mnv is NEXTNODE.
    set bv to mnv:BURNVECTOR.
    set dv to bv:mag.
    set dt to mt(dv).
    if v0:mag = 0 set v0 to bv.
    local wt is mnv:ETA - mt(v0:MAG)/2.
    if wt > 0 {
      LOCAL t0 IS TIME:SECONDS + wt.
      LOCK THROTTLE TO 0.
      LOCK STEERING TO bv.
      if wt > 20 WARPTO(t0 - 10).
      if time:seconds < t0 return dv.
    }
    if warp > 0 set warp to 0.
    if (VDOT(bv, v0) <= 0) {
      lock throttle to 0.
      unlock steering.
      remove mnv.
      set dv to 0. set dt to 0.
      set bv to v(0,0,0).
      set v0 to v(0,0,0).
      return -1.
    }
    // TODO improve the throttle lock!
    // TODO reduce throttle if not pointed right!
    LOCK STEERING TO bv.
    LOCK THROTTLE TO MIN(dt, 1).
    return dv.
  }

  local Cs is facing.
  local Ct is 0.

  // pof:grav(Ho) -- subroutine to follow a gravity turn
  // returns true if apoapsis exceeds Ho + 1000.
  function grav {
    parameter Ho.
    local pct_alt is alt:radar / H0.
    local target_pitch is -115.23935 * pct_alt^0.4095114 + 88.963.
    local pitch is max(0, target_pitch).
    ss(). set Cs to heading(Dir, pitch, 0). set Ct to 1.
    lock steering to Cs. lock throttle to Ct.
    return ship:apoapsis > Ho + 1000.
  }
}
