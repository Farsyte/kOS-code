{ parameter n. export(n, lex("normal", normal@)).
  local nv is north:vector.
  local uv is up:vector.
  local ev is vcrs(nv, uv).
  function ap { parameter nc, ec.
    local xv is body:geopositionof(ship:position + nc*nv + ec*ev).
    return xv:altitudeposition(xv:terrainheight).
  }
  function normal {
    local av is ap(5,0).
    local bv is ap(-3,4).
    local cv is ap(-3,-4).
    return vcrs(cv - av, bv - av).
  }
}