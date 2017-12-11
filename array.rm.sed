#!/bin/sed -rnf
# vim: sw=4 et tw=80 wrap
# array.rm.sed  Generates entries to remove macros made by array class.
/^\.de array$/,/^\.{2}$/ {
    s/\.\sde (\\\\\$1\..+) end/.\trm \1/p
}
