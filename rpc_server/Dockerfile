FROM debian:jessie

RUN rm -rf /var/lib/apt/lists/* && apt-get update
RUN apt-get install --assume-yes screen net-tools psmisc joe python-twisted less

VOLUME /code

# clean
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 8990

# docker build --no-cache --tag 'jsonscp:latest' .
# docker run --name jsonscp -v $(pwd):/code -i -t jsonscp:latest bash
