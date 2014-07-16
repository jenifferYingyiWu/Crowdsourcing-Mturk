#!/bin/bash
JAVA_AWS="/usr/local/java-aws-mturk-1.6.2"
cd $JAVA_AWS
/usr/local/apache-ant-1.9.4/bin/ant > "$JAVA_AWS/samples/site_category/output.txt"
