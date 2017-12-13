#!/bin/sh

cat << EOF
lists.tmac      A macro package for exceptionally well-typeset lists in Troff.

EOF

ynprompt() {
    echo -n "$@"
    read inp
    [ "$?" -ne 0 ] && return false
    grep -i "^y" <<< $inp > /dev/null
    return $?
}

less -Xe LICENSE
echo
ynprompt "Do you accept the license [y/n]?  "
[ "$?" -ne 0 ] && exit 1

echo

EXT_TROFF="`which groff`"
for f in /usr/{,local}/share/groff/site-tmac/
do
    if [ -d "$f" ]; then
        EXT_SITETMAC="`sed "s_//_/_g" <<< "$f"`"
        break
    fi
done

while :
do
    echo -n "Full filename to /.ROFF/ compiler [$EXT_TROFF]?  "
    read inp
    EXT_TROFF="${inp:-$EXT_TROFF}"
    [ \! -f "$EXT_TROFF" ] && echo "File does not exist." || break
done

while :
do
    echo -n "Full path to site-tmac directory [$EXT_SITETMAC]?  "
    read inp
    EXT_SITETMAC="${inp:-$EXT_SITETMAC}"
    [ \! -d "$EXT_SITETMAC" ] && echo "Directory does not exist." || break
done

$EXT_TROFF -Tutf8 -Kutf8 << EOF | grep -q "1🙈🙉🙊"
.nf
.cp 0
\\n(.g\\[u1F648]\\[u1F649]\\[u1F64A]
EOF
if [ "$?" -ne 0 ]; then
    echo -n "Troff compiler may be incompatible.  " 
    ynprompt "Are you sure you want to continue [y/n]?  "
    [ "$?" -ne 0 ] && exit 1
fi

echo

echo "Checking SHA512 checksums..."
sha512sum -c SHA512SUM
if [ "$?" -ne 0 ]; then
    echo -n "SHA512 check failed.  "
    ynprompt "Are you sure you want to continue [y/n]?  "
    [ "$?" -ne 0 ] && exit 1
fi

echo

TMACS="`awk '{ print $2 }' < SHA512SUM`"
echo "The following files will be copied to \`\`$EXT_SITETMAC''"
for f in $TMACS
do
    echo -e "\t$f"
done
ynprompt "Are you sure you want to continue [y/n]?  "
[ "$?" -ne 0 ] && exit 1

echo

if [ "`sed -rn -e "/^\/home\/$USER\/?/p" -e "s/^$/a/" <<< "$EXT_SITETMAC"`" != \
    "$EXT_SITETMAC" ] && [ "`whoami`" != "root" ]; then
    echo "Root privilleges are required."
    exit 1
fi

echo "Copying now..."
for f in $TMACS
do
    cp -v $f $EXT_SITETMAC
done

echo

$EXT_TROFF -Tutf8 -Kutf8 << EOF | head -n 10
.ce
Thanks for using lists.tmac.  😊❤️

You should definitely check out \\fImanual.me\\fP and \\fIREADME.rst\\fP.
They contain really useful stuff about what this macro package is/does, how to
use it, how to report bugs, what or who is behind it, &c.

.ad r
\(em Stephanie Björk; December 14, 2017
EOF
