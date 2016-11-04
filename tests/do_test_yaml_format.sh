#!/bin/sh

./bin/generate_tests.sh -d "$1" tests/fixtures/scenario_ids.yml PRO
find "$1" -type f -name '*_test.yml' | while read -r i; do
  mkdir -p "reports/$(dirname "$i")"
  ./tests/test_yaml_format.py "$i" | sed -e 's/skip>/skipped>/g' > "reports/$i.xml"
done
