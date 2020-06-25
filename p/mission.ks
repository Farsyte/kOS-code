{ parameter n.
  local json is import("json").
  local _ is lex(

    "name", { return _:s[i-1]. },
    "mode", { parameter i. set _:i to i. set _:n to _:s[i-1].
      json:st("runmode", lex("i",_:i,"n",_:n)). },

    "jump", { parameter n. _:mode(_:m[n]). },
    "next", { _:mode(_:i + 2). },
    "back", { _:mode(_:i - 2). },

    "steps", { parameter s. set _:s to s. set _:m to lex(). local i is 1.
      until i >= s:length { _:m:add(s[i-1],i). set i to i + 2. }
      set _:i to json:ld("runmode", lex("i",1)):i. set _:n to _:s[_:i-1].
      until false { _:display(). _:s[_:i](). wait 0.01. }
    },

    "display", { print "RUNMODE: " + _:name at (0,40). },
    "s", list(), "m", lex(), "i", 1).
  export(n, _).
}