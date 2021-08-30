# DOCKER_NAME=kamailio-config-tests-bullseye
FROM docker.mgm.sipwise.com/sipwise-bullseye:latest

# Important! Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT 2021-07-01

RUN apt-get update && apt-get install --assume-yes python3-yaml python3-junitxml \
  make libtemplate-perl libyaml-perl python3-pytest

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
# echo "deb https://deb.sipwise.com/autobuild/ release-trunk-bullseye main" > t/sources.list.d/builddeps.list
#
# % docker build --tag="kamailio-config-tests-bullseye" -f t//Dockerfile .
# % docker run --rm -i -t -v $(pwd):/code:rw kamailio-config-tests-bullseye:latest bash
#
# Use the existing docker image:
# % docker pull docker.mgm.sipwise.com/kamailio-config-tests-bullseye
# % docker run --rm -i -t -v $(pwd):/code:rw docker.mgm.sipwise.com/kamailio-config-tests-bullseye:latest bash
#
# Inside docker (the command is in history, just press UP button):
#   ./t/testrunner
#
################################################################################
