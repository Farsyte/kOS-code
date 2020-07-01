{ parameter n. local _ is lex(
    "steps", steps@, // initiate mission sequence
    "mode", mode@, // set mode number
    "jump", jump@, // jump to named mode
    "next", next@, // step to next mode
    "back", back@, // step to previous mode
    "name", name@, // [DEPRECATED] get current mode name
    "display", display@, // update display before running runmode
    "tim", tim@, // compute Time In Mode
    "s", list(), // access to current step list
    "m", lex(), // access to name index into step list
    "i", 1, // access to runmode number
    "t", 0, // time:seconds when mode last changed
    "n", "?" // access to runmode name
  ). export(n, _).
  local json is import("json").

  function steps { parameter s. set _:s to s. set _:m to lex().
    local i is 1. until i >= s:length { _:m:add(s[i-1],i). set i to i + 2. }
    set j to json:ld("runmode", lex("i",1,"t",0,"n","?")).
    set _:i to j:i. set _:t to j:t. set _:n to _:s[_:i-1].
    until false { _:display(). _:s[_:i](). wait 1/60. }
  }

  function mode { parameter i. set _:i to i. set _:n to _:s[i-1].
    set warp to 0. set _:t to time:seconds.
    json:st("runmode", lex("i",_:i,"t",_:t,"n",_:n)).
  }

  function jump { parameter n. _:mode(_:m[n]). }
  function next { _:mode(_:i + 2). }
  function back { _:mode(_:i - 2). }
  function name { return _:n. }

  function display {
      local i is 0. until i >= _:s:length {
        print "                                   " at (0,i/2).
        print "- [ ] " + _:s[i] at (0,i/2).
        set i to i + 2.
      }
      print "->[*] " + _:n at (0,(_:i-1)/2).
  }

  function tim { return time:seconds - _:t. }
}