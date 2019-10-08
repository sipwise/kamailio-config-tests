SCENARIOS:=$(shell find -maxdepth 1 -type d -name 'scenarios*'|sed 's_\./__g')
TESTS=$(addprefix test_,$(SCENARIOS))

BASH_SCRIPTS = bench.sh get_results.sh run_tests.sh t/testrunner bin/*.sh
PERL_SCRIPTS = bin/*.pl
PYTHON_SCRIPTS = tests/test_check.py tests/test_yaml_format.py bin/*.py
SHELL_SCRIPTS = tests/do_test_yaml_format.sh

RESULTS ?= reports

# do nothing as default
all:
	$(MAKE) syntaxcheck

syntaxcheck: bashismcheck perlcheck pythoncheck shellcheck

bashismcheck:
	@echo -n "Checking for bashisms: "; \
	for SCRIPT in $(SHELL_SCRIPTS); do \
		checkbashisms -x $${SCRIPT} || exit 1 ; \
	done; \
	echo "done."; \

perlcheck:
	@echo "Checking for perl syntax errors: "; \
	mkdir -p perl-dummy/Sipwise ; \
	for f in Sipwise/API.pm ; do \
		echo '1;' > perl-dummy/$$f ; \
	done; \
	for SCRIPT in $(PERL_SCRIPTS); do \
		perl -Iperl-dummy/ -cw $${SCRIPT} || exit 1 ; \
	done; \
	rm -r perl-dummy ; \
	echo "-> perl check done."; \

pythoncheck:
	@echo -n "Checking for python syntax errors: "; \
	for SCRIPT in $(PYTHON_SCRIPTS); do \
		python3 -m compileall -b $${SCRIPT} || exit 1 ; \
		rm $${SCRIPT}c # get rid of pyc files ; \
	done; \
	echo "done."; \

shellcheck:
	@echo -n "Checking for shell syntax errors: "; \
	for SCRIPT in $(BASH_SCRIPTS) $(SHELL_SCRIPTS); do \
		bash -n $${SCRIPT} || exit ; \
	done; \
	echo "done."; \

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
