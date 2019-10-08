# DOCKER_NAME=kamailio-config-tests-buster
FROM docker.mgm.sipwise.com/sipwise-buster:latest

# Important! Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT 2019-06-27

# test execution; we need the backport of python3-junitxml from our own
# repository since it's not part of Debian/buster
# files that get-code generates
COPY t/sources.list.d/builddeps.list /etc/apt/sources.list.d/
COPY t/sources.list.d/preferences /etc/apt/preferences.d/

RUN apt-get update
RUN apt-get install --assume-yes python3-yaml python3-junitxml \
  make libtemplate-perl libyaml-perl

RUN echo './t/testrunner' >>/root/.bash_history

WORKDIR /code/

################################################################################
# Instructions for usage
# ----------------------
# When you want to build the base image from scratch
# (jump to the next section if you don't want to build yourself!):
#
# you need to put the proper NGCP sources at t/sources.list.d/builddeps.list
# for instance, trunk:
# echo "deb https://deb.sipwise.com/autobuild/ release-trunk-buster main" > t/sources.list.d/builddeps.list
#
# % docker build --tag="kamailio-config-tests-buster" -f t//Dockerfile .
# % docker run --rm -i -t -v $(pwd):/code:rw kamailio-config-tests-buster:latest bash
#
# Use the existing docker image:
# % docker pull docker.mgm.sipwise.com/kamailio-config-tests-buster
# % docker run --rm -i -t -v $(pwd):/code:rw docker.mgm.sipwise.com/kamailio-config-tests-buster:latest bash
#
# Inside docker (the command is in history, just press UP button):
#   ./t/testrunner
#
################################################################################
