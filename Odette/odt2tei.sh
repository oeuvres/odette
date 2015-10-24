#!/bin/bash
# Transform OpenOffice.odt  in tei.xml
# Required unzip and xsltproc

here=`dirname $0`

# pass an odt filepath
# 1) unzip odt
# 2) merge some files (especially to get the metas)
# 3) xml normalization on odt.xml
# 4) the beef, transform odt xml in tei
# 5) normalize tei
# 6) Your step ? ex : | xsltproc tei_philo3.xsl -\
odt_tei() {
  if [ -z $1 ]
  then
    echo "  ERROR: odt_tei() an odt filepath is needed"
    return 1
  fi
  #name=$(basename "$1");
  basepath=${1%.*}
  echo $1 \> $basepath.xml
    unzip -p $1 meta.xml styles.xml content.xml \
  | sed -E -f $here/odtx.sed \
  | sed '/^$/d' \
  | xsltproc $here/odt_tei.xsl -\
  | sed -E -f $here/tei.sed \
  > $basepath.xml
  return 0
}

usage() {
  echo "USAGE: "
  echo "    ./odt_tei.sh path/to/file.odt"
  exit 0
}

if [ "$#" -eq 0 ]
  then
    usage
fi

# process script arguments
for f in $*
do
  #will echo all the variable passes as parameters
  odt_tei $f
done




exit $?
