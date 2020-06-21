# import and export

Inspired by CheersKevin!

## Style Note and Future Fixes

Because kOS flight units have limited storage, my normal `KS` style
tends to be to limit comments, whitespace, and long names in order
to avoid being out of onboard storage.

I believe that using `COMPILE` will allow me to go back to using the
comments, whitespace, and names that I prefer; and it would be a mere
matter of having `import` prefer the `.ksm` file.

Meanwhile, the scripts in this repository will probably be quite terse,
and I will try to use better names and indentation in this document.

## API: importing and using a package

Potentially, each actual KS script will have several packages
that it imports, and we want to hide all the details of finding
and loading up the file.

          local pkg is import("packagename").
          local result is pkg:something(arg1, arg2).

## API: exporting from a package

The `export` API has two important things to remember.

First, the script providing the package must take one parameter, and
the package system will provide the name under which the package is
being imported.

Second, to export something, the script places it in the package
dictionary, which is a lexicon mapping from exported names, to the
values or function delegates we want to export.

Let us take as an example a package that provides some output
formatting -- right-pad, left-pad, and integer-pad:

        {
            parameter package_name.

            function right_pad {
                parameter width, str.
                until str:length >= width {
                    set str to str+" ".
                }
                return str.
            }

            function left_pad {
                parameter width, str.
                until str:length >= width {
                    set str to " "+str.
                }
                return str.
            }

            function integer_pad {
                parameter width, value.
                return left_pad(width, ""+round(value)).
            }

            local package_dict is lex(
                "right_pad", right_pad@,
                "left_pad", left_pad@,
                "integer_pad", integer_pad@
            ).

            export(package_name, package_dict).
        }

Or, as this appears in the library,

        { parameter n. local _ is lex(
        "pr", {parameter n,s. until s:length >= n {set s to s+" ".} return s.},
        "pl", {parameter n,s. until s:length >= n {set s to " "+s.} return s.},
        "pd", {parameter n,v. return _:pl(n,""+round(v)).},).
        export(n, _).}

Note that folding the function definitions into the `lex` eliminates the
need to repeat the name of the exported item several times.

In my minimized code, I tend to use `_` for the package dictionary, making
it my convention for "current package" in this project.

While not shown in the example above, the package dictionary can map names
to arbitrary things -- numbers, strings, lists, function delegates, in fact
any thing you can assign to a variable in Kerboscript.

Nothing prevents code that imports the package from modifying the lex.

## IMPL: when do we re-use the previously imported package?

Once a package is imported, all subsequent import calls will return
the same imported package. If one module modifies the dictionary, then
its changes will be visible to the package code and to all other code
using the package.

## IMPL: when do we reinitialize?

Each time we boot, we start over without the lex present and must rebuild
it by running the package script.

Modifications to the package dictionary do **NOT** persist across reboots.

## IMPL: when do we update from the archive?

If the package has not yet been imported, and we have a connection
to the archive, import will copy the script from the archive.

Note that if we boot without a connection and import packages from
local storage, they will not automatically get updated.

The simplest way to arrange for this update to happen is to reboot the
processor when we reconnect.

## IMPL: where in the archive do we upate from?

When updating a package `pkg`, we check first to see if the file is in
the Mission Archive, found at `0:/n/<<shipname>>/<<pkg>>.ks` (bearing
in mind that the ship name could have slashes, indicating that it is
one of several similar vessels).

If that file exists, it is copied locally and run.

Because ship names are often of the form "group/one" we also check the
parent directory of the mission archive, to find libraries that are
common to all flights in a given series.

If it does not, it looks in `0:/p/<<pkg>>.ks` (the system package
archive directory) and runs what it finds there.

## SPECIAL CASE: the "GO" scripts

Not actualy a special case for the package manager, but this package
is loaded and run by the common boot firmware. This package is
required to provide an export of the `"go"` name, which takes no
parameters; the boot script hands control over to this method after
the source file has been executed.

## Remove onboard KS files with caution

Once a package is imported, in theory, the file could be removed from
local storage to free up space. However, if we subsequently reboot
without a connection, and we have removed the file, anyone importing
this package would get a failed load.
