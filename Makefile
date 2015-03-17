# do nothing as default
all:

.ONESHELL:
SHELL = /bin/bash
venv: requirements.txt
	virtualenv --python=python2.7 venv
	source ./venv/bin/activate && \
		pip install -r ./requirements.txt >install.log

test_check: venv tests/test_check.py
	mkdir -p reports
	source ./venv/bin/activate && \
		./tests/test_check.py > reports/$(@).xml

# run this in parallel!! -j is your friend
test: test_check

# get rid of test files
clean:
	rm -rf install.log

# also get rid of pip environment
dist-clean: clean
	rm -rf venv

.PHONY: all