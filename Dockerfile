# Stage 1: Build the application
FROM openjdk:11 as base 
WORKDIR /app
COPY . . 
RUN chmod +x gradlew
RUN ./gradlew build 

# Stage 2: Create a custom Tomcat image
FROM tomcat:9
WORKDIR /usr/local/tomcat
RUN mkdir logs
RUN chown -R 1000:1000 logs

WORKDIR webapps
COPY --from=base /app/build/libs/sampleWeb-0.0.1-SNAPSHOT.war .
RUN rm -rf ROOT && mv sampleWeb-0.0.1-SNAPSHOT.war ROOT.war

