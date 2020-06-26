{ parameter n.

  local Ho is 100000.
  local Dir is 90.

  local ev is import("boot"):ev.
  local mission is import("mission").
  local pof is import("pof").
  local term is import("term"):term.

  local next is mission:next.
  local mode is mission:mode.

  set mission:mode to {
    parameter i.
    set warp to 0.
    mode(i).
  }.

   // Falling Saxophone is a 2nd generation "orbital tour" ship.

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
      set Cs to heading(Dir, pitch, 0). set Ct to 1.
      lock steering to Cs. lock throttle to Ct.
      if ship:apoapsis > Ho + 1000 { next(). }
    },
    "meco", {
      lock steering to prograde. lock throttle to 0.
      if altitude > 70000 next().
    },
    "coast", {
      if eta:apoapsis > 30 and eta:apoapsis < eta:periapsis and altitude > 70000 {
        if warp < 1 { ev("warping"). set warpmode to "RAILS". set warp to 3. wait 1. }}
      else if warp > 0 { ev("unwarp"). set warp to 0. wait 1. }
      if (eta:apoapsis < 30) or (ship:altitude >= Ho - 2000) or (ship:verticalspeed < 0) next().
      lock steering to prograde. lock throttle to 0.
    },
    "circ", {
      if warp > 0 { ev("unwarp"). set warp to 0. }
      local Cst is pof:circ().
      if Cst[0] < 0.1 { lock throttle to 0. next(). }
      set Cs to Cst[1]. set Ct to Cst[2].
      lock steering to Cs. lock throttle to Ct.
    },
    "deorbit", {
      lock steering to srfretrograde. lock throttle to 1.
      if periapsis < 30000 next().
    },
    "descend", {
      lock throttle to 0. lock steering to srfretrograde.
      if alt:radar < 10000 next().
    },
    "land", {
      lock throttle to 0. unlock steering.
      if alt:radar < 5000 and verticalspeed > -3000 and stage:number > 0 and stage:ready { stage. }
      if stage:number < 1 next().
    },
    "park", {
      lock steering to heading(0,90). lock throttle to 0.
    }
  ).

  function display {
    print "VESSEL:                                 " at (0, 0).
    print "RUNMODE:                                " at (0, 1).
    print "ALTITUDE:                               " at (0, 2).
    print "APOAPSIS:                               " at (0, 3).
    print "                                        " at (0, 4).

    local i is 1. local r is 5.
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
  }.  

  local _ is lex("go", {
    when alt:radar > 100 then {
      import("setstage"):go().
      runpath("auto_stage.ks").
    }
    term(96,80).
    set mission:display to display@.
    mission:steps(seq).
  }).
  export(n, _).
}
