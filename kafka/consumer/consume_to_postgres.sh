#!/bin/bash
# Simple Kafka to PostgreSQL Consumer

KAFKA_HOME="/home/bigdata/kafka"
TOPIC="pgserver1.public.test_table"

echo "Starting consumer for topic: $TOPIC"
echo "Press Ctrl+C to stop"

"$KAFKA_HOME/bin/kafka-console-consumer.sh" \
    --bootstrap-server localhost:9092 \
    --topic "$TOPIC" \
    --from-beginning | \
while read -r line; do
    
    echo "Processing: $line"
    
    # Try to extract data
    id=$(echo "$line" | sed 's/.*"id":\([0-9]*\).*/\1/')
    name=$(echo "$line" | sed 's/.*"name":"\([^"]*\)".*/\1/')
    value=$(echo "$line" | sed 's/.*"value":\([0-9]*\).*/\1/')
    
    # Check if we got valid data
    if [[ "$id" =~ ^[0-9]+$ ]]; then
        echo "Found record: id=$id, name='$name', value=$value"
        
        # Insert into PostgreSQL
        PGPASSWORD=bigdata123 psql -U bigdata -d postgres -h localhost -c "
            INSERT INTO public.result_table (id, name, value) 
            VALUES ($id, '$name', $value)
            ON CONFLICT (id) DO UPDATE SET
                name = EXCLUDED.name,
                value = EXCLUDED.value;
        " 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "  ✓ Inserted successfully"
        else
            echo "  ✗ Failed to insert"
        fi
    else
        echo "  Skipping - invalid data"
    fi
done
