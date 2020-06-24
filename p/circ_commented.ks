{ parameter n. export(n, lex("circ", {

  // set steering and throttle to make orbit more circular.
  //
  // parameters:
  //   first parameter is throttle_gain
  //   second parameter is max_facing_error
  //   third parameter is good_enough
  //
  // outputs:
  //   sets global Cs to the commanded steering
  //   sets global Ct to the commanded throttle
  //   returns the magnitude of the velocity error
  //
  // usage:
  //   local circ is import("circ"). // or "circ_commented"
  //   set Cs to facing.  // initial steering command
  //   set Ct to 0.       // initial throttle command
  //   lock steering to Cs. lock throttle to Ct.
  //   until circ:circ(gain,angle,limit) { wait 0. }
  //
  // example:
  //
  // set Cs to facing. set Ct to 0.
  // lock steering to Cs. lock throttle to Ct.
  // until circ(5,5,1) { wait 0.1. }
  // 
  //
  // operation:
  //   this function calculates the instantaneous
  //   change in velocity that would make our current
  //   orbit circular, then calculates the appropriate
  //   steering and throttle settings.
  //
  //   To compute the throttle setting, start with the
  //   desired chagne in velocity, and multiply by the
  //   throttle gain. This gives a desired force, so
  //   multiply by vehicle mass and divide by the currently
  //   available maximum thrust.
  //
  //   Compare where we are actually pointed versus the
  //   direction we want to make the burn, and reduce the
  //   thrust linearly based on how large this error is
  //   compared to the provided maximum angle error; if
  //   our pointing error is larger than the limit, then
  //   command zero thrust.
  //
  //   Singluarities are avoided:
  //   - If the current error does not exceed the minimum velocity
  //     change, then simply command the vehicle to maintain current
  //     facing at zero throttle.
  //   - If the maximum thrust of the vehicle is not positive,
  //     command zero thrust but still command steering in the
  //     direction of the desired burn.
  //   - If the direction we are pointed is too different from the
  //     direction we want to burn, command the proper facing and
  //     command zero throttle.

    parameter throttle_gain,max_facing_error,good_enough.
    LOCK STEERING TO Cs. LOCK THROTTLE TO Ct.
    LOCAL circular_speed IS SQRT(BODY:MU/(BODY:RADIUS+ALTITUDE)).
    LOCAL velocity_error IS VXCL(UP:VECTOR,VELOCITY:ORBIT):NORMALIZED*circular_speed-VELOCITY:ORBIT.
    LOCAL error_magnitude IS velocity_error:MAG.
    IF error_magnitude > good_enough {
      SET Cs TO LOOKDIRUP(velocity_error,facing:topvector).
      IF MAXTHRUST > 0 {
        LOCAL Ae IS VANG(FACING:VECTOR,velocity_error).
        LOCAL Ka IS MAX(0,max_facing_error-Ae)/max_facing_error.
        SET Ct TO min(1,max(0,Ka*throttle_gain*error_magnitude*mass/maxthrust)).
      } ELSE {
        SET Ct TO 0.
      }
      return false.
    }
    SET Cs TO FACING.
    SET Ct TO 0.
    return true.
  })).}
