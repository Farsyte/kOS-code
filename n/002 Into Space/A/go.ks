{ parameter n. export(n, lex("go",go@)).
  set Cs to facing. set Ct to 0.
  lock steering to Cs. lock throttle to Ct.
  local ev is import("boot"):ev.
  local msn is import("mission").
  local srf is import("surface").
  local next is { msn:next(). ev(msn:n). set warp to 0. }.
  import("term"):term(80,80).

  local seq is list(
    "ready", { if availableThrust > 0 next().
      set Ct to 0. set Cs to heading(0,90).
    },
    "launch", {
      set Ct to 1. set Cs to heading(0,90).
      if availableThrust < 1 or apoapsis > 80000 {
        set Ct to 0. wait 1. stage. next(). }
    },
    "rise", { if altitude > 70000 next(). },
    "fall", { if altitude < 70000 next(). },
    "land", { if altitude < 10000 next().
      set Cs to srfRetrograde.
    },
    "armed", {
      if altitude < 5000 and verticalSpeed > -300 next().
    },
    "deploy", {
      if stage:number < 1 { gear on. next(). }
      else if stage:ready stage.
    },
    "settle", { set Cs to srf:normal(). if verticalSpeed >= 0 next(). },
    "park", {
      set Cs to srf:normal().
      if msn:tim() > 3 shutdown.
    }
  ).
  function go {
    msn:steps(seq).
  }
}