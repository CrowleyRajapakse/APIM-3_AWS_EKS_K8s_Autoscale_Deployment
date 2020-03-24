# Auto Generated Dockerfile
FROM ballerina/jre8:v1

LABEL maintainer="dev@ballerina.io"

RUN addgroup troupe \
    && adduser -S -s /bin/bash -g 'ballerina' -G troupe -D ballerina \
    && apk add --update --no-cache bash \
    && chown -R ballerina:troupe /usr/bin/java \
    && rm -rf /var/cache/apk/*

WORKDIR /home/ballerina

COPY hello.jar /home/ballerina

EXPOSE  8080
USER ballerina

CMD java -jar hello.jar
