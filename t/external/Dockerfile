# DOCKER_NAME=k-c-t-bullseye
FROM docker.mgm.sipwise.com/sipwise-bullseye:latest

# Important! Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT 2023-03-07
ENV BASE_DIR=/code

RUN apt-get update && apt-get install --assume-yes \
    parallel python3-yaml sip-tester tcpdump \
    libconfig-tiny-perl libdata-dump-perl libjson-perl \
    liblist-moreutils-perl libtemplate-perl libtext-csv-perl \
    libtext-diff-perl libtry-tiny-perl libyaml-libyaml-perl \
    libfile-slurp-perl libhash-merge-perl libwww-perl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /code/
################################################################################
# Instructions for usage
# ----------------------
# When you want to build the base image from scratch
# (jump to the next section if you don't want to build yourself!):
#
# % docker build --tag="k-c-t-bullseye" -f t/external/Dockerfile .
# % docker run --rm -i -t -v $(pwd):/code:rw k-c-t-bullseye:latest bash
#
# Use the existing docker image:
# % docker pull docker.mgm.sipwise.com/k-c-t-bullseye
# % docker run --rm -i -t -v $(pwd):/code:rw docker.mgm.sipwise.com/k-c-t-bullseye:latest bash
#
################################################################################
