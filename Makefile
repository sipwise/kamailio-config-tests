SCENARIOS:=$(shell find -maxdepth 1 -type d -name 'scenarios*'|sed 's_\./__g')
TESTS=$(addprefix test_,$(SCENARIOS))

RESULTS ?= reports

# do nothing as default
all:

# python-junitxml 0.6 has this bug
# https://bugs.launchpad.net/pyjunitxml/+bug/892293
$(TESTS):
	@mkdir -p $(RESULTS)
	$(eval SCEN_DIR := $(@:test_%=%))
	./tests/do_test_yaml_format.sh $(SCEN_DIR)

test_check: tests/test_check.py
	mkdir -p $(RESULTS)
	./tests/test_check.py > $(RESULTS)/$(@).xml

# run this in parallel!! -j is your friend
test: $(TESTS) test_check

.PHONY: all $(TESTS)
