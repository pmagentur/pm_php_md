#!/bin/bash


# how execute phpmd
#EXEC='php ${INPUT_PHPMD_BIN_PATH}'
EXEC='phpmd'
ECCLUDES="--exclude 'tests/*,vendor/*'"
BASELINE_FILE="${GITHUB_REPOSITORY#*/}.baseline.xml"
BASELINE_OPTION=""

# check changed files if want to check just changes
if [ -n "${INPUT_ONLY_CHANGED_FILES}" ] && [ "${INPUT_ONLY_CHANGED_FILES}" = "true" ]; then
    echo "Will only check changed files"
    USE_CHANGED_FILES="true"
    PR="$(jq -r '.pull_request.number' < "${GITHUB_EVENT_PATH}")"
    URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls/${PR}/files"
    AUTH="Authorization: Bearer ${INPUT_TOKEN}"
    CURL_RESULT=$(curl --request GET --url "${URL}" --header "${AUTH}")
    CHANGED_FILES=$(echo "${CURL_RESULT}" | jq -r '.[] | select(.status != "removed") | .filename')
    # PHPMD files should be separated via comma
    CHANGED_FILES=$(echo ${CHANGED_FILES} | sed s/' '/','/g)
else
    USE_CHANGED_FILES="false"
fi
test $? -ne 0 && echo "Could not determine changed files" && exit 1

# Check if basline file exists
if [[ ! -z ${BASELINE_PATH} ]] && [ -f ${BASELINE_PATH}/${BASELINE_FILE} ] ; then
    echo "${BASELINE_PATH}/${BASELINE_FILE}"
    cp "${BASELINE_PATH}/${BASELINE_FILE}" .
    BASELINE_OPTION="--baseline-file ${BASELINE_FILE}"
fi

# Check if basline file exists
#if [ -f ${BASELINE_FILE} ]; then
#    BASELINE_OPTION="--baseline-file ${BASELINE_FILE}"
#fi

# Run command 
if [ "${USE_CHANGED_FILES}" = "true" ]; then
    echo "${EXEC} ${CHANGED_FILES} ${INPUT_RENDERERS} ${INPUT_RULES} ${EXCLUDES} ${BASELINE_OPTION}"
    OUTPUT=$(${EXEC} ${CHANGED_FILES} ${INPUT_RENDERERS} ${INPUT_RULES} ${EXCLUDES} ${BASELINE_OPTION})
    echo ${OUTPUT}
    OWNER=${GITHUB_REPOSITORY_OWNER}
    echo ${OWNER}
    REPO_NAME=${GITHUB_REPOSITORY#*/}
    echo ${REPO_NAME}
    echo ${INPUT_HEAD_SHA_ANNOTATIONS}
    URL="https://pm-code-check.pm-projects.de/my-checks/phpmd_check?owner=${OWNER}&repo_name=${REPO_NAME}&head_sha=${INPUT_HEAD_SHA_ANNOTATIONS}"
    echo ${URL}
    curl -X POST -H "Content-Type: application/json" -d "${OUTPUT}" ${URL}

else
    ${EXEC} ${INPUT_FILES} ${INPUT_RENDERERS} ${INPUT_RULES} ${EXCLUDES} ${BASELINE_OPTION} 
fi

# exit code of phpmd
MD_EXIT_CODE="$?"

# Check the exit status regarding https://phpmd.org/documentation/index.html
if [ "0" == ${MD_EXIT_CODE} ]; then
    # This exit code indicates that everything worked as expected.
    status="success"
elif [ "1" == ${MD_EXIT_CODE} ]; then
    # This exit code indicates that an exception occurred which has interrupted PHPMD during execution.
    status="failure"
elif [ "2" == ${MD_EXIT_CODE} ]; then
    # This exit code means that PHPMD has processed the code under test without the occurrence of an error/exception,
    # but it has detected rule violations in the analyzed source code. You can also prevent this behaviour with the 
    # --ignore-violations-on-exit flag, which will result to a 0 even if any violations are found
    status="failure"
elif [ "3" == ${MD_EXIT_CODE} ]; then
    # This exit code means that one or multiple files under test could not be processed because of an error. 
    # There may also be violations in other files that could be processed correctly
    status="failure"
fi

exit $MD_EXIT_CODE
#if [ "${USE_CHANGED_FILES}" = "true" ]; then
#    ${INPUT_PHPMD_BIN_PATH} ${CHANGED_FILES} ${INPUT_RENDERERS} ${INPUT_RULES}
#else
#    ${INPUT_PHPMD_BIN_PATH} ${CHANGED_FILES} ${INPUT_RENDERERS} ${INPUT_RULES}
#fi
