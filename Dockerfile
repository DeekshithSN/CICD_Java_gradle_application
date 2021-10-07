FROM tomcat:9  
WORKDIR webapps 
COPY build/libs/test.war .

