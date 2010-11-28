#/bin/bash

# Utilities absolute paths
GREP=`which grep`
SORT=`which sort`
UNIQ=`which uniq`
SED=`which sed`
CAT=`which cat`

# Absolute path to example application's root
cd "`dirname $0`/.."
PATH="`pwd`"

# Apache virtuel host configuration file
VHOST="$PATH/application/configs/vhost.conf"

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
        $SED -i -e "${REGEX}" "${VHOST}"
    done
done

