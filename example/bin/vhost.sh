#/bin/bash

# Utilities absolute paths
GREP=`which grep`
SORT=`which sort`
UNIQ=`which uniq`
SED=`which sed`
CP=`which cp`

if [ $# -ne 1 ]
then
    echo "Usage: $0 <file>"
    echo ""
    echo "Writes to <file> the virtual host configuration."
    exit 1
fi

# Absolute path to example application's root
ORIG_PWD="`pwd`"
cd "`dirname $0`/.."
PATH="`pwd`"

# Apache virtuel host configuration file
VHOST_SRC="$PATH/application/configs/vhost-template"
VHOST_DST="${ORIG_PWD}/$1"

# Copy inital template to destination
$CP "${VHOST_SRC}" "${VHOST_DST}"

# For each file with placeholders...
for FILE in "$VHOST_SRC"
do
    echo "Generating file ${VHOST_DST} ..."

    # Extract placeholders present in file and...
    PLACEHOLDERS=`${GREP} -RoE '\{[a-zA-Z_]+\}' "${FILE}" | ${SORT} | ${UNIQ}`
    for P in $PLACEHOLDERS
    do
        # Find value for placeholder
        eval REPLACEMENT="\$$P"
        echo "Replacing ${P} for ${REPLACEMENT}"

        # Expression for replacement
        REGEX="s/${P//\//\\/}/${REPLACEMENT//\//\\/}/g"

        # Replace value pof placeholder
        $SED -i "" -e "${REGEX}" "${VHOST_DST}"
    done
done

# Restore PWD
cd "$ORIG_PWD"
