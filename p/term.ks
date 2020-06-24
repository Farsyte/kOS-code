{ parameter n. local _ is lex(
  "term",{
    parameter w, h.
    clearscreen.
    set terminal:width to w.
    set terminal:height to h.
    if career():candoactions
      core:doAction("open terminal", true).
  }).
export(n, _).}
