{ parameter n.
  local json is import("json").
  local _ is lex(

    // mission:steps(l) -- run a mission using the given list of
    // runmodes. The list alternates runmode names and function
    // delegates, and we progress from runmode to runmode as other
    // methods are called.

    "steps", { parameter s. set _:s to s. set _:m to lex(). local i is 1.
      until i >= s:length { _:m:add(s[i-1],i). set i to i + 2. }
      set _:i to json:ld("runmode", lex("i",1)):i. set _:n to _:s[_:i-1].
      until false { _:display(). _:s[_:i](). wait 0.01. }
    },

    // mission:mode(j): set to mission runmode number j
    // j needs to be the index in s of the runmode delegate.
    // not normally called by the mission but might be overloaded
    // with "do other stuff then call normal mode delegate"

    "mode", { parameter i. set _:i to i. set _:n to _:s[i-1].
      json:st("runmode", lex("i",_:i,"n",_:n)). },

    // mission:jump(n): jump to the runmode with name n.
    "jump", { parameter n. _:mode(_:m[n]). },

    "next", { _:mode(_:i + 2). }, // next loop will use the next runmode.
    "back", { _:mode(_:i - 2). }, // next loop will use the previous runmode.
    "name", { return _:n. }, // compatibility, use mission:n, not mission:name().

    // display update called before each step starts.
    // mission can replace the delegate with their own
    // display manager.
    "display", { print "RUNMODE: " + _:n at (0,40). },

    "s", list(), // access to current step list
    "m", lex(), // access to name index into step list
    "i", 1, // access to runmode number
    "n", "?" // access to runmode name
    ).
  export(n, _).
}