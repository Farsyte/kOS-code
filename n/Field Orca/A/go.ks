{ parameter n.

  local Ho is 100000.
  local Dir is 90.

  local json is import("json").
  local ev is import("boot"):ev.

  local mission is lex(

  "jump", {
    parameter n.
    if n:typename() = "String" {
      local i is 1.
      until i >= mission:sequence:length {
        if n = mission:sequence[i-1] {
          mission:jump(i).
          return.
        }
        set i to i + 2.
      }
    }
    set mission:runmode to n.
    json:st("runmode", lex("runmode", n)).
    ev("runmode: " + mission:sequence[n-1]).
  },

  "next", {
    mission:jump(mission:runmode + 2).
  },

  "back", {
    mission:jump(mission:runmode - 2).
  },

  "steps", {
    mission:jump(json:ld("runmode", lex("runmode",1)):runmode).
    until false {
      mission:display().
      mission:sequence[mission:runmode]().
      wait 0.01.
    }
  },

  "display", {
    print "RUNMODE: " + mission:sequence[mission:runmode-1] at (0,40).
  },

  "sequence", list(),
    "runmode", 1).

  export(n, lex(
    "go",go@)).

  local _ is import(n).
  local pof is import("pof").
  local mt is import("node"):mt.

  local ss is {
    import("setstage"):go().
    deletepath("setstage.ks").
    runpath("auto_stage.ks").
    deletepath("auto_stage.ks").
    set ss to {
    }.
  }.

  local bv is v(0,0,0).
  local v0 is v(0,0,0).
  local dv is 0.
  local dt is 0.
  set mission:display to {
    print "RUNMODE:                                " at (0, 4).
    print "ALTITUDE:                               " at (0, 5).
    print "APOAPSIS:                               " at (0, 6).
    print "BURN:                                   " at (0, 7).
    print "dv:                                     " at (0, 8).
    print "dt:                                     " at (0, 9).

    print mission:sequence[mission:runmode-1] at(12,4).
    print round(altitude) at(12, 5).
    print round(apoapsis) at(12, 6).
    print bv at(12, 7).
    print dv at(12, 8).
    print dt at(12, 9).
  }.

  function go {
    print " ".
    print " ".
    print " ".
    print " ".
    print " ".
    print " ".
    print " ".
    print " ".
    mission:steps().
  }

  local unhold is true.
  lock Cs to facing.
  lock Ct to 0.
  lock steering to Cs.
  lock throttle to Ct.

  on gear set unhold to true.

  local jump is {
    parameter s.
    set warp to 0.
    set unhold to false.
    mission:jump(s).
  }.

  local next is {
    set warp to 0.
    set unhold to false.
    mission:next().
  }.

  set mission:sequence to list(

  "ready", {
    if availablethrust > 0
      next().
  },
  
  "launch", {
    set Cs to facing. set Ct to 1.
    if ship:velocity:surface:mag > 10
      next().
  },
  
  "clear", {
    set Cs to heading(Dir, 90).
    set Ct to 1.
    if ship:velocity:surface:mag > 100
      next().
  },

  "pitchover", {
    ss().
    local pct_alt is alt:radar / Ho.
    local target_pitch is -115.23935 * pct_alt^0.4095114 + 88.963.
    local pitch is max(0, target_pitch).
    set Cs to heading(Dir, pitch, 0).
    set Ct to 1.
    if ship:apoapsis > Ho + 1000 {
      ev("meco").
      next().
    }
  },
  
  "meco", {
    set Ct to 0.
    lock Cs to prograde.
    if altitude > 70000
      next().
  },

  "wait", {
    if eta:apoapsis > 30 and eta:apoapsis < eta:periapsis and altitude > 70000 and warp < 1 {
      ev("warping").
      set warpmode to "RAILS". set warp to 3.
    }
    if (eta:apoapsis < 30) or (ship:altitude >= Ho - 2000) or (ship:verticalspeed < 0)
      next().
  },

  "circ", {
    local Cst is pof:circ().
    set Cs to Cst[1]. set Ct to Cst[2].
    if Cst[0] < 0.1 {
      ev("arrived").
      toggle lights.
      next().
    }
  },
  
  "fine", {
    if hasnode {
      jump("node").
      return.
    }
    local Cst is pof:circ().
    if Cst[0] < 0.001 {
      ev("ready").
      next().
    }
    set Cs to Cst[1]. set Ct to Cst[2].
  },
  
  "hold", {
    lock throttle to 0.
    lock steering to heading(0,0).
    if unhold {
      jump("fine").
      return.
    }
  },

  "node", {
    if not hasnode {
      jump("fine").
      return.
    }

    local n is NEXTNODE.
    set bv to n:BURNVECTOR.
    LOCK STEERING TO bv.
    set dv to bv:mag.
    set dt to mt(dv).

    if v0:mag = 0 set v0 to bv.

    local wt is n:ETA - mt(v0:MAG)/2.
    if wt > 0 {
      LOCAL t0 IS TIME:SECONDS + wt.
      LOCK THROTTLE TO 0.
      if wt > 20 WARPTO(t0 - 10).
      if time:seconds < t0
        return.
    }
    set warp to 0.
    if (VDOT(bv, v0) <= 0) {
      lock throttle to 0.
      remove n.
      set dv to 0. set dt to 0. set bv to v(0,0,0).
      jump("hold").
    }
    LOCK THROTTLE TO MIN(dt, 1).
  }

  ).
}
