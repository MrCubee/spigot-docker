ARG SPIGOT_VERSION=1.21.8
ARG JAVA_MAJOR=21

FROM alpine AS buildtools
ARG SPIGOT_VERSION
ARG JAVA_MAJOR
RUN apk add --no-cache bash git "openjdk${JAVA_MAJOR}" && mkdir -p /opt/spigot-builder /build
ADD https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar /opt/spigot-builder/BuildTools.jar
WORKDIR /build
RUN java -jar /opt/spigot-builder/BuildTools.jar --rev "${SPIGOT_VERSION}"

FROM alpine
ARG SPIGOT_VERSION
ARG JAVA_MAJOR
RUN apk add --no-cache "openjdk${JAVA_MAJOR}" && mkdir -p /opt/spigot /usr/local/bin /data
COPY --from=buildtools /build/spigot-${SPIGOT_VERSION}.jar /opt/spigot/spigot-${SPIGOT_VERSION}.jar
COPY ./start.sh /usr/local/bin/start-spigot
RUN chmod ugo=rx /usr/local/bin/start-spigot; ln -s "/opt/spigot/spigot-${SPIGOT_VERSION}.jar" /opt/spigot/spigot-server.jar 
WORKDIR /data	
EXPOSE 25565/tcp
EXPOSE 25565/udp
EXPOSE 25575/tcp
ENTRYPOINT ["/usr/local/bin/start-spigot"]
