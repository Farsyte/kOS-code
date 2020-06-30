{ parameter n. export(n, lex("go",go@)).
  local ev is import("boot"):ev.
  local msn is import("mission").
  local term is import("term"):term.
  local next is msn:next.
  set Cs to facing. set Ct to 0.
  lock steering to Cs.
  lock throttle to Ct.
  term(80,80).
  local seq is list(
    "ready", {
      set Cs to heading(0,90). set Ct to 0.
      if availableThrust > 0 {
      next(). }},
    "launch", {
      set Cs to heading(0,90). set Ct to 1.
      if (alt:radar > 100) next().
    },
    "ascend", {
      set Cs to heading(90,90). set Ct to 1.
      if verticalspeed < 0 next().
    },
    "descend", {
      set Cs to heading(90,90). set Ct to 0.
      if alt:radar < 5000 and verticalspeed >= -300 {
        stage. next().
      }
    },
    "land", {
      set Cs to heading(90,90). set Ct to 0.
    }
  ).
  function go {
    msn:steps(seq).
  }
}
