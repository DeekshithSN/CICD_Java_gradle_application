# First stage: Build the Java application
FROM openjdk:11 as base
WORKDIR /app
COPY . .
RUN chmod +x gradlew
RUN ./gradlew build

# Second stage: Create the Tomcat container and deploy the built application
FROM tomcat:9
RUN rm -rf /usr/local/tomcat/webapps/ROOT

COPY --from=base /app/build/libs/sampleWeb-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080 (default Tomcat port)
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
