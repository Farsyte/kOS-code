{ parameter n.
  export(n, lex("mt",mnv_time@,"mx",mx@)).

  // mt(dv): compute time to perform manuver with this delta-V
  // this is wrong and I've not fixed it yet.
  function mt { parameter dv.
    local sT is 0.
    local sI is 0.
    local nE is 0.
    list engines in myengines.
    for en in myengines {
      if en:ignition = true and en:flameout = false {
        set sT to sT + en:availablethrust.
        set sI to sI + en:isp.
        set nE to nE + 1.
      }
    }
    if sT = 0 or sI = 0 or nE = 0 {
      ev("mt: no engines?").
      return 0.
    }
    local e is constant():e.        // base of natural log
    local mu is ship:orbit:body:mu.
    local Rb is ship:orbit:body:radius^2.
    local g is mu/Rb^2.             // gravitational acceleration constant (m/s²)
    local f is sT * 1000.           // engine thrust (kg * m/s²)
    local m is ship:mass * 1000.    // starting mass (kg)
    local p is sI/nE.               // engine isp (s) support to average different isp values
    return g * m * p * (1 - e^(-dv/(g*p))) / f.
  }

  // mnv_time(dv): same thing but works right.
  // code from kevin with my mods:
  // - avoid divde by zero when no thrust
  // - isp average is weighted by engine thrust
  // works for Field Orca
  function mnv_time {
    parameter dV.

    local g is ship:orbit:body:mu/ship:obt:body:radius^2.
    local m is ship:mass * 1000.
    local e is constant():e.

    local engine_count is 0.
    local thrust is 0.
    local isp is 0.

    list engines in all_engines.
    for en in all_engines if en:ignition and not en:flameout {
      set thrust to thrust + en:availablethrust.
      set isp to isp + en:isp * en:availablethrust.
    }

    if thrust > 0 {
      set isp to isp / thrust.
      set thrust to thrust * 1000.
      return g * m * isp * (1 - e^(-dV/(g*isp))) / thrust.
    }
    return 0.
  }

  // mx(aW): execute next node. aW: auto-warp.
  FUNCTION mx { PARAMETER aW.
    LOCAL n IS NEXTNODE.
    LOCAL v0 IS n:BURNVECTOR.
    LOCAL t0 IS TIME:SECONDS + n:ETA - mt(v0:MAG)/2.
    LOCK STEERING TO n:BURNVECTOR.
    IF aW and t0 > 45 { WARPTO(t0 - 30). }
    WAIT UNTIL TIME:SECONDS >= t0.
    LOCK THROTTLE TO MIN(mt(n:BURNVECTOR:MAG), 1).
    WAIT UNTIL VDOT(n:BURNVECTOR, v0) < 0.
    LOCK THROTTLE TO 0.
    UNLOCK STEERING.
  }
}
