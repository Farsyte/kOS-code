{ parameter n. export(n, lex("normal", normal@)).
  local vn is north:vector.
  local vu is up:vector.
  local ve is vcrs(vn, vu).
  function ap { parameter nc, ec.
    local xv is body:geopositionof(ship:position + nc*vn + ec*ve).
    return xv:altitudeposition(xv:terrainheight).
  }
  function normal {
    local av is ap(5,0).
    local bv is ap(-3,4).
    local cv is ap(-3,-4).
    return vcrs(cv - av, bv - av).
  }
}