# this is multi stage 
FROM openjdk:11 as base 
WORKDIR /app
COPY . . 
RUN chmod +x gradlew
RUN ./gradlew build 

FROM tomcat:9
WORKDIR webapps
COPY --from=base /app/build/libs/java-app-0.0.1-SNAPSHOT.war .
RUN rm -rf ROOT && mv java-app-0.0.1-SNAPSHOT.war ROOT.war
