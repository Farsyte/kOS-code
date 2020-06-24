{ parameter n. export(n, lex(
  "ld", ld@, "st", st@)).
  function ld { parameter f,d.
    return choose d if not exists(f) else readjson(f).
  }
  function st { parameter f,v.
    writejson(v,f).
  }
}
