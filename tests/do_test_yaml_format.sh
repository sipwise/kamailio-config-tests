#!/bin/sh
export BASE_DIR=$(pwd) DEST_DIR=${RESULTS}

./bin/generate_tests.sh -d "$1" tests/fixtures/scenario_ids.yml PRO
find "${RESULTS}/$1" -type f -name '*_test.yml' | while read -r i; do
  ./tests/test_yaml_format.py "$i" | sed -e 's/skip>/skipped>/g' > "$i.xml"
done
