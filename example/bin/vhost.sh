#/bin/bash

# Utilities absolute paths
GREP=`which grep`
SORT=`which sort`
UNIQ=`which uniq`
SED=`which sed`
if [ -z "$SED" ]
then
    SED=`which gsed`
fi
CP=`which cp`

# Preserve current working directory value
ORIG_PWD="`pwd`"

# Defaults
APPLICATION_DOMAIN="example.local"
APPLICATION_ENVIRONMENT="development"

# Parse parameters
case "$#" in
    1)
        ;;
    2)
        APPLICATION_DOMAIN="$2"
        ;;
    3)
        APPLICATION_DOMAIN="$2"
        APPLICATION_ENVIRONMENT="$3"
        ;;
    *)
        echo "Usage: $0 <file> [<domain>=${APPLICATION_DOMAIN} [<environment>=${APPLICATION_ENVIRONMENT}]]"
        echo ""
        echo "Writes to <file> the virtual host configuration."
        exit 1
        ;;
esac

# Absolute path to example application's root
cd "`dirname $0`/.."
APPLICATION_ROOT="`pwd`"

# Template source
TEMPLATE_FILE="${APPLICATION_ROOT}/application/configs/vhost-template"

# Detination file
DESTINATION_FILE="${ORIG_PWD}/$1"

# Copy template file
$CP "${TEMPLATE_FILE}" "${DESTINATION_FILE}"

# Extract placeholders present in file and...
echo "Generating file '${DESTINATION_FILE}' ..."
for P in `${GREP} -RoE '\{[a-zA-Z_]+\}' "${DESTINATION_FILE}" | ${SORT} | ${UNIQ}`
do
    # Find value for placeholder
    eval REPLACEMENT="\$$P"

    echo "Replacing: $P -> $REPLACEMENT"

    # Escape replacement value
    REPLACEMENT="${REPLACEMENT//\//\\/}"
    REPLACEMENT="${REPLACEMENT//\./\\.}"


    # Expression for replacement
    REGEX="s/${P//\//\\/}/${REPLACEMENT}/g"

    # Replace value pof placeholder
    $SED -e "${REGEX}" -i"" ${DESTINATION_FILE}
done

# Restore PWD
cd "$ORIG_PWD"
