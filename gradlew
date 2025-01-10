#!/usr/bin/env sh

#
# Gradle start-up script for UN*X systems
#

# Resolve APP_HOME
PRG="$0"
while [ -h "$PRG" ] ; do
    link=`ls -ld "$PRG" | sed 's/.*-> //'`
    if echo "$link" | grep '^/' >/dev/null; then
        PRG="$link"
    else
        PRG="`dirname \"$PRG\"`/$link"
    fi
done
APP_HOME="`cd \"\`dirname \"$PRG\"\`\" && pwd`"

APP_NAME="Gradle"
APP_BASE_NAME=`basename "$0"`

# Default JVM options
DEFAULT_JVM_OPTS='"-Xmx256m" "-Xms256m"'

# Ensure JAVA_HOME is set
if [ -n "$JAVA_HOME" ]; then
    JAVACMD="$JAVA_HOME/bin/java"
    if [ ! -x "$JAVACMD" ]; then
        echo "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME"
        echo "Please set JAVA_HOME to the correct location of your Java installation."
        exit 1
    fi
else
    JAVACMD=`which java 2>/dev/null`
    if [ -z "$JAVACMD" ]; then
        echo "ERROR: JAVA_HOME is not set, and no 'java' command could be found in your PATH."
        echo "Please set JAVA_HOME to the correct location of your Java installation."
        exit 1
    fi
fi

# Verify Java version (ensure compatibility with Java 17)
JAVA_VERSION=$("$JAVACMD" -version 2>&1 | awk -F '"' '/version/ {print $2}')
if [ "${JAVA_VERSION%%.*}" -lt 17 ]; then
    echo "ERROR: Java 17 or later is required. Current version is $JAVA_VERSION."
    exit 1
fi

# Determine the classpath
CLASSPATH="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"

# Prepare Gradle options
GRADLE_OPTS="${GRADLE_OPTS:-""}"

# Build the Java command
COMMAND="\"$JAVACMD\""
COMMAND="$COMMAND $DEFAULT_JVM_OPTS"
COMMAND="$COMMAND -Dorg.gradle.appname=\"$APP_BASE_NAME\""
COMMAND="$COMMAND -classpath \"$CLASSPATH\" org.gradle.wrapper.GradleWrapperMain \"$@\""

# Execute the command
eval exec $COMMAND
