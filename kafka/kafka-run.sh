
#!/bin/bash
# Clean environment for Kafka tools only

# Remove polluted CLASSPATH from Hadoop/Hive
export CLASSPATH=""
export KAFKA_CLASSPATH=""

# Execute the actual Kafka tool (same name as the script called)
exec /home/bigdata/kafka/bin/"$(basename "$0")" "$@"
``

