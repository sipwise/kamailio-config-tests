SCENARIOS:=$(shell find -maxdepth 1 -type d -name 'scenarios*'|sed 's_\./__g')
TESTS=$(addprefix test_,$(SCENARIOS))

# do nothing as default
all:

.ONESHELL:
SHELL = /bin/bash
venv: requirements.txt
	virtualenv --python=python2.7 venv
	source ./venv/bin/activate && \
		pip install -r ./requirements.txt >install.log

# python-junitxml 0.6 has this bug
# https://bugs.launchpad.net/pyjunitxml/+bug/892293
$(TESTS):
	@mkdir -p reports
	$(eval SCEN_DIR := $(@:test_%=%))
	./tests/do_test_yaml_format.sh $(SCEN_DIR)

test_check: venv tests/test_check.py
	mkdir -p reports
	source ./venv/bin/activate && \
		./tests/test_check.py > reports/$(@).xml

# run this in parallel!! -j is your friend
test: $(TESTS) test_check

# get rid of test files
clean:
	rm -rf install.log

# also get rid of pip environment
dist-clean: clean
	rm -rf venv

.PHONY: all