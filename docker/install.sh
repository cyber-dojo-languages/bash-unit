#!/bin/bash -Eeu

# Appends one test framework to the test_frameworks list the base image
# wrote in /versions.json, keeping any entry an earlier image added. Stops
# the build if the list is not found, rather than record nothing. Short grep
# flags because busybox grep has no long ones.
add_test_framework()
{
  local -r name="${1}"
  local -r version="${2}"
  local -r entry="{\"name\": \"${name}\", \"version\": \"${version}\"}"
  if grep -q '"test_frameworks": \[\]' /versions.json; then
    sed -i "s|\"test_frameworks\": \[\]|\"test_frameworks\": [${entry}]|" /versions.json
  else
    sed -i "/\"test_frameworks\": \[/s|}\]|}, ${entry}]|" /versions.json
  fi
  if ! grep -q -F "${entry}" /versions.json; then
    echo "Could not add ${name} to /versions.json" >&2
    cat /versions.json >&2
    exit 1
  fi
}

apk add curl

# Install the newest bash_unit release. GitHub redirects releases/latest to
# the newest release's tag, which is resolved here at build time so a rebuild
# picks up the next release by itself.
readonly BASH_UNIT_LATEST_URL=$(curl --silent --fail --output /dev/null --write-out '%{redirect_url}' \
  https://github.com/bash-unit/bash_unit/releases/latest)
readonly BASH_UNIT_TAG="${BASH_UNIT_LATEST_URL##*/}"

# An empty tag means the redirect could not be read or has changed shape,
# not that bash_unit stopped releasing, so stop rather than install nothing.
if [ -z "${BASH_UNIT_TAG}" ]; then
  echo 'Found no bash_unit release tag at github.com/bash-unit/bash_unit' >&2
  exit 1
fi

curl --silent --fail --location --output /usr/bin/bash_unit \
  "https://raw.githubusercontent.com/bash-unit/bash_unit/${BASH_UNIT_TAG}/bash_unit"
chmod +x /usr/bin/bash_unit
apk del curl

add_test_framework bash_unit "${BASH_UNIT_TAG#v}"
cat /versions.json
