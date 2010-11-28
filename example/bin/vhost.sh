#/bin/bash

# Utilities absolute paths
GREP=`which grep`
SORT=`which sort`
UNIQ=`which uniq`
SED=`which sed`
CAT=`which cat`

if [ $? -ne 1 ]
then
    echo "Usage: $0 <file>"
    echo ""
    echo "Writes to <file> the virtual host configuration."
    exit 1
fi

# Absolute path to example application's root
cd "`dirname $0`/.."
PATH="`pwd`"

# Apache virtuel host configuration file
VHOST_SRC="$PATH/application/configs/vhost-template"
VHOST_DST="$1"

# For each file with placeholders...
for FILE in "$VHOST"
do
    # Extract placeholders present in file and...
    PLACEHOLDERS=`${GREP} -RoE '\{[a-zA-Z_]+\}' "${FILE}" | ${SORT} | ${UNIQ}`
    for P in $PLACEHOLDERS
    do
        # Find value for placeholder
        eval REPLACEMENT="\$$P"
        echo "${P} -> ${REPLACEMENT}..."

        # Expression for replacement
        REGEX="s/${P//\//\\/}/${REPLACEMENT//\//\\/}/g"

        # Replace value pof placeholder
        $SED -e "${REGEX}" "${VHOST_SRC}" > "${VHOST_DST}"
    done
done

