{ parameter n.

  local Ho is 100000.
  local Dir is 90.

  local ev is import("boot"):ev.
  local mission is import("mission").

  local _ is import(n).
  local pof is import("pof").
  local mt is import("node"):mt.

  local ss is {
    import("setstage"):go().
    deletepath("setstage.ks").
    runpath("auto_stage.ks").
    deletepath("auto_stage.ks").
    set ss to {
      // empty, so ss() only does stuff the first time after each boot.
    }.
  }.

  local bv is v(0,0,0).
  local v0 is v(0,0,0).
  local dv is 0.
  local dt is 0.

  // TODO move this out to a supporting package for re-use
  // and refactor bv/dv/dt/v0 as it will no longer be present
  // inside the scope of those variables (pass in a lex?)

  function nodestep {
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

  local unhold is true.

  global Cs is facing.
  global Ct is 0.

  on gear set unhold to true.
  local mode is mission:mode.
  local next is mission:next.
  local jump is mission:jump.

  set mission:mode to {
    parameter i.
    set warp to 0.
    set unhold to false.
    mode(i).
  }.

  // TODO start moving these flight stages out to a library
  // so different missions can simply pick the ones they want
  // and place them in the order they want.

  local seq is list(
  
  "ready", { if availablethrust > 0 next(). },
  "launch", {
    lock steering to heading(0,90). lock throttle to 1.
    if ship:velocity:surface:mag > 10 next().
  },
  "clear", {
    lock steering to heading(Dir, 90). lock throttle to 1.
    if ship:velocity:surface:mag > 100 next().
  },
  "pitchover", {
    local pct_alt is alt:radar / Ho.
    local target_pitch is -115.23935 * pct_alt^0.4095114 + 88.963.
    local pitch is max(0, target_pitch).
    ss(). set Cs to heading(Dir, pitch, 0). set Ct to 1.
    lock steering to Cs. lock throttle to Ct.
    if ship:apoapsis > Ho + 1000 { next(). }
  },
  "meco", {
    lock steering to prograde. lock throttle to 0.
    if altitude > 70000 next().
  },
  "wait", {
    if eta:apoapsis > 30 and eta:apoapsis < eta:periapsis and altitude > 70000 {
      if warp < 1 { ev("warping"). set warpmode to "RAILS". set warp to 3. wait 1. }}
    else if warp > 0 { ev("unwarp"). set warp to 0. wait 1. }
    if (eta:apoapsis < 30) or (ship:altitude >= Ho - 2000) or (ship:verticalspeed < 0) next().
    lock steering to prograde. lock throttle to 0.
  },
  "circ", {
    if warp > 0 { ev("unwarp"). set warp to 0. }
    ss(). local Cst is pof:circ().
    if Cst[0] < 0.1 { lock throttle to 0. ev("arrived"). toggle lights. next(). }
    set Cs to Cst[1]. set Ct to Cst[2].
    lock steering to Cs. lock throttle to Ct.
  },
  "fine", {
    if hasnode { jump("node"). return. }
    ss(). local Cst is pof:circ().
    if Cst[0] < 0.001 { lock throttle to 0. ev("park"). next(). }
    set Cs to Cst[1]. set Ct to Cst[2].
    lock steering to Cs. lock throttle to Ct.
  },
  "hold", {
    lock throttle to 0. lock steering to heading(0,0).
    if unhold { jump("fine"). return. }
  },
  "node", {
    if not hasnode { jump("fine"). return. }
    ss(). if nodestep() <= 0 jump("hold").
  }

  ).

  set mission:display to {
    print "VESSEL:                                 " at (0, 0).
    print "RUNMODE:                                " at (0, 1).
    print "ALTITUDE:                               " at (0, 2).
    print "APOAPSIS:                               " at (0, 3).
    print "BURN X:                                 " at (0, 4).
    print "BURN Y:                                 " at (0, 5).
    print "BURN Z:                                 " at (0, 6).
    print "dv:                                     " at (0, 7).
    print "dt:                                     " at (0, 8).
    print "                                        " at (0, 9).

    local i is 1. local r is 10.
    until i >= seq:length {
    print "- [ ]                                   " at (0, r).
    print seq[i-1] at (6,r).
    if i = mission:i print "->[*]" at (0,r).
      set i to i + 2. set r to r + 1.
    }

    print ship:name at(12,0).
    print mission:s[mission:i-1] at(12,1).
    print round(altitude) at(12, 2).
    print round(apoapsis) at(12, 3).
    print bv:x at(12, 4).
    print bv:y at(12, 5).
    print bv:z at(12, 6).
    print dv at(12, 7).
    print dt at(12, 8).
  }.
  
  local term is import("term"):term.

  function go {
    term(96,80).
    print " ".
    print " ".
    print " ".
    print " ".
    print " ".
    print " ".
    print " ".
    print " ".
    print " ".
    print " ".
    local i is 1. until i >= seq:length {
      print " ". set i to i + 2.
    }
    print " ".

    mission:steps(seq).
  }

  export(n, lex("go",go@)).
}