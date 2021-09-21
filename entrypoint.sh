#!/bin/bash


# how execute phpmd
#EXEC='php ${INPUT_PHPMD_BIN_PATH}'
#EXEC='php phpmd.phar'

# check changed files if want to check just changes
if [ -n "${INPUT_ONLY_CHANGED_FILES}" ] && [ "${INPUT_ONLY_CHANGED_FILES}" = "true" ]; then
    echo "Will only check changed files"
    USE_CHANGED_FILES="true"
    PR="$(jq -r '.pull_request.number' < "${GITHUB_EVENT_PATH}")"
    URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls/${PR}/files"
    AUTH="Authorization: Bearer ${INPUT_TOKEN}"

    CURL_RESULT=$(curl --request GET --url "${URL}" --header "${AUTH}")
    CHANGED_FILES=$(echo "${CURL_RESULT}" | jq -r '.[] | select(.status != "removed") | .filename')
else
    echo "Will check all files"
    USE_CHANGED_FILES="false"
fi
test $? -ne 0 && echo "Could not determine changed files" && exit 1


# Run command 

if [ "${USE_CHANGED_FILES}" = "true" ]; then
    echo "${EXEC} ${CHANGED_FILES} ${INPUT_RENDERERS} ${INPUT_RULES}"
    ${EXEC} ${CHANGED_FILES} ${INPUT_RENDERERS} ${INPUT_RULES}
else
    echo"${EXEC} ${INPUT_FILES} ${INPUT_RENDERERS} ${INPUT_RULES}"
    ${EXEC} ${INPUT_FILES} ${INPUT_RENDERERS} ${INPUT_RULES}
fi

status=$?


#if [ "${USE_CHANGED_FILES}" = "true" ]; then
#    ${INPUT_PHPMD_BIN_PATH} ${CHANGED_FILES} ${INPUT_RENDERERS} ${INPUT_RULES}
#else
#    ${INPUT_PHPMD_BIN_PATH} ${CHANGED_FILES} ${INPUT_RENDERERS} ${INPUT_RULES}
#fi
