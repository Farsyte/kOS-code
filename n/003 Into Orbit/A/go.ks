{ parameter n. export(n, lex("go",go@)).
  set Cs to facing. set Ct to 0. set Qt to 1. set Et to 1.
  lock steering to Cs. lock throttle to Ct*Qt.
  local ev is import("boot"):ev.
  local msn is import("mission").
  local srf is import("surface").
  local pof is import("pof").
  local next is { msn:next(). ev(msn:n). set warp to 0. }.

  local Dir is 0.
  local Ho is 100000.
  local Atm is 70000.

  local ss is {
    import("setstage"):go().
    runoncepath("auto_stage.ks").
    deletepath("auto_stage.ks").
    set ss to { }.
  }.

  when altitude > 25000 then {
    set Qt to 1/3.
    when altitude > 40000 then {
      set Qt to 1.
    }
  }

  local pct_alt is 0.
  local target_pitch is 90.
  local pitch is 90.
  local r0 is 1.
  local done is false.
  on lights set done to true.

  local seq is list(
    "ready", {
      set Ct to 0. set Cs to heading(0,90).
      if availableThrust > 0 next().
    },
    
    // inline pof:launch
    "launch", {
      set Ct to 1. set Cs to heading(0,90).
      if alt:radar > 100 and verticalSpeed > 100 next().
    },
    "pitchover", { ss().
      set pct_alt to alt:radar / Ho.
      set target_pitch to -115.23935 * pct_alt^0.4095114 + 88.963.
      set pitch to max(0, target_pitch).
      set Cs to heading(Dir, pitch, 0).
      if ship:apoapsis > Ho + 1000 next().
    },
    "coast", {
      set Cs to srfPrograde.
      set Ct to (Ho - apoapsis)/1000.
      set Et to max(0.01,min(1,1-vang(Cs:vector,facing:vector)/20)).
      if eta:apoapsis < 30 or ship:altitude >= Ho - 2000 or ship:verticalspeed < 0 next().
    },

    "circ", { ss().
      local dst is pof:circ().
      set Cs to dst[1]. set Ct to dst[2]. set Et to 1.
      if dst[0] < 1 next().
    },

    "orbit", { set Ct to 0. set Cs to srfRetrograde.
      if lights next().
    },
    "retro", { set Ct to periapsis-30000. set Cs to srfRetrograde.
      if periapsis < 30000 next().
    },
    "fall", { set Ct to 0. set Cs to srfRetrograde.
      if msn:tim() > 2 and stage:number > 1 and stage:ready stage.
      if alt:radar < 5000 and verticalSpeed > -300 next().
    },
    "land", {
      if stage:number > 0 and stage:ready stage.
      gear on. set Cs to srf:normal().
      local nv is north:vector.
      local uv is up:vector.
      local ee is vcrs(nv, uv).
      print "Cs dot U: " + vdot(Cs,uv) + "     " at (0,r0+1).
      print "Cs dot N: " + vdot(Cs,nv) + "     " at (0,r0+2).
      print "Cs dot E: " + vdot(Cs,ee) + "     " at (0,r0+3).
    }
  ).
  set r0 to seq:length / 2.
  import("term"):term(40,r0 + 16).
  function go {
    msn:steps(seq).
  }
}