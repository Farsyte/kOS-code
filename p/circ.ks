{ parameter n. export(n, lex("circ", {
  parameter kT,lA,lE.
  LOCK STEERING TO Cs. LOCK THROTTLE TO Ct.
  LOCAL Sc IS SQRT(BODY:MU/(BODY:RADIUS+ALTITUDE)).
  LOCAL dV IS VXCL(UP:VECTOR,VELOCITY:ORBIT):NORMALIZED*Sc-VELOCITY:ORBIT.
  LOCAL dVm IS dV:MAG.
  IF dVm > lE {
    SET Cs TO LOOKDIRUP(dV,facing:topvector).
    IF MAXTHRUST > 0 {
      SET Ct TO min(1,max(0,MAX(0,1-VANG(FACING:VECTOR,dV)/lA)*kT*dVm*mass/maxthrust)).
    } ELSE {
      SET Ct TO 0.
    }
    return false.
  }
  SET Cs TO FACING.
  SET Ct TO 0.
  return true.
})).}
