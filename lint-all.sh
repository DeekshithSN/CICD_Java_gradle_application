#!/bin/bash
echo "Running Checkstyle..."
java -jar /opt/checkstyle.jar -c /google_checks.xml src/**/*.java

echo "Running SpotBugs..."
spotbugs -textui target/classes

echo "Running Hadolint on Dockerfile..."
hadolint Dockerfile

echo "Running ShellCheck..."
shellcheck scripts/*.sh

echo "Checking Jenkinsfile syntax..."
jq . Jenkinsfile