{ parameter n.
  local q is char(34).
  set q to q + n + q.

  // Add to Stage List
  //
  // This function appends module "v" to the list of modules in
  // stage "i" for the "l" list. Appends empty lists to "l" as
  // needed to allow access to the l[i] list.

  function asl {
    parameter l, i, v.
    until l:length > i l:add(list()).
    if i >= 0 l[i]:add(v).
  }

  local m is list(). // modules activated at stage N
  local e is list(). // engines jettisoned by staging at N
  local f is list(). // modules with liquid fuel jettisoned by staging at N

  // recursive initialization of module and engine lists above
  //
  // Processes the "p" module and its subtree, where "s" is the
  // stage number imposed from the parent.

  function init {
    parameter s, p.

    // Try to determine what kind of part "p" is,
    // and insert it into the appropriate lists.

    for i in p:modules {

      // parachutes are deployed by staging.

      if i = "ModuleParachute" {
        if p:stage > s asl(m, p:stage, p).
        break.
      }

      // decouplers etc are activated by staging,
      // and jettison their children.

      if i = "ModuleAnchoredDecoupler" or i = "ModuleDecouple" or i = "LaunchClamp" {
        if p:stage > s {
          asl(m, p:stage, p).
          set s to p:stage.
        }
        break.
      }

      // engines are activated by staging,
      // and are jettisoned by their containing decoupler;
      // the generated script needs to NOT activate that
      // decoupler until this engine has flamed out.

      if i = "ModuleEngines" {
        if p:getmodule(i):getfield("status") = "Off"
          asl(m, p:stage, p).
        asl(e, s, p).
        break.
      }
    }

    // parts with liquid fuel are jettisoned by their
    // containing decoupler; the generated script needs
    // to NOT activate that decoupler until this fuel
    // tank is empty.
    //
    // Checking for SolidFuel here is not necessary as
    // solid rocket boosters are already correctly handled
    // based on their FLAMEOUT status above.
    //
    // Checking for RCS Fuel here is rarely correct; if we
    // do it by default, we would not be able to jettison
    // lower stages if they had any RCS fuel remaining,
    // probably not what was intended.

    for i in p:resources if i:name = "LiquidFuel" asl(f, s, p).

    // recursively process children.

    for i in p:children init(s, i).
  }

  function go {

    // start processing at the root of the ship.

    init(-1, ship:rootpart).

    // Start with the highest numbered stage, and assure that we
    // can index by stage into the engine and fuel module lists.

    set s to m:length - 1.
    until f:length > s f:add(list()).
    until e:length > s e:add(list()).

    // using the arrays as a guide, generate
    // the auto_stage script. Need to delete
    // the old script if it exists, but before
    // that we need to make sure it exists.

    local a is "auto_stage.ks".
    log " " to a. deletepath("auto_stage").
    log "local _ is import(" + q + ")." to a.
    log "local e is _:e. local f is _:f." to a.
    log " " to a.
    set closebraces to "".

    // Consider each stage in turn, high to low number,
    // and remember to process Stage Zero, too!

    until s < 0 {

      // Provide a short delay before starting to evaluate
      // the conditions to activate this stage.
      //
      // It is CRITICAL that everything from here down is
      // triggered as part of a WHEN clause, so the staging
      // script can return to the mission control script
      // leaving the logic running in the background.

      log "set stage_check_at to time:seconds+2." to a.
      log "when time:seconds >= stage_check_at" to a.

      // Do not stage if doing so would discard any engines
      // that are not yet in FLAMEOUT, using the list of engines
      // prepared above.

      set n to e[s]:length.
      set i to 0. until i >= n {
        log "and e["+s+"]["+i+"]:flameout"
          +"  // "+e[s][i]:title
          to a.
      set i to i+1. }

      // Do not stage if doing so would dicard any modules
      // whose current mass still exceeds their DRY mass,
      // using the list of "fuel tanks" prepared above.

      set n to f[s]:length.
      set i to 0. until i >= n {
        log "and f["+s+"]["+i+"]:mass"
          +" < "+(f[s][i]:drymass + 0.001)
        +" // "+f[s][i]:title
          to a.
      set i to i+1. }

      // FINALLY: do not stage unless there is at least one
      // unit of liquid fuel remaining somewhere in the ship,
      // and this last clause is written in such a way that
      // if it fails, the script stops doing work.
      
      log "then if ship:liquidfuel > 1 {" to a.

      // Cut warp, and stage.
      // Document the parts that are activated in this stage.

      log "SET WARP TO 0. STAGE. // "+s to a.
      for p in m[s] {
      log "// ACTIVATE "+p:title to a. }

      log " " to a.

      set closebraces to closebraces + "}".
      set s to s-1.
    }
    log closebraces+" // end of output from gen_stage." to a.

    // Downlink the generated script to the Ground Archive.
    import("boot"):st(a).
  }
  
  export(n, lex(
    "init", init@, "go", go@,
    "m", m, "e", e, "f", f)).
}
