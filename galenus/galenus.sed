#!/bin/sed -E -f
# Chained substitutions on a TEI generated from WordProcessor mess
# should work as a sed script in unicode (on one line, no dotall option)
# those regexp will be interpreted in PHP, Java, may be Python
# default MacOSX sed is not perl compatible, there is no support for backreference in search “\1”, and assertions (?…)

# double comma
s@,,+@,@g
# correct spaces around comma
s@ *, *@, @g
# verses
s@</hi>( *[^\p{L}]) *</p>@\1</hi></p>@g
s@<p rend="indent"><hi>(.*)</hi></p>@<l>\1</l>@g
# caesura
s@[——\-]\s*<lb/> *([^\s]+) *@\1\n<lb/>@g

