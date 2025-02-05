#!/bin/bash

# Database connection parameters
DB_NAME="grafana_db"
DB_USER="grafana_user"
DB_PASSWORD="grafana_pass"
DB_HOST="host.docker.internal"
DB_PORT="5432"
PGPASSWORD="grafana_pass"

# Number of unique IDs (total rows will be 4 times this number)
TOTAL_IDS=250000

# Function to generate a random timestamp within the last year
generate_base_timestamp() {
    # Generate a random number of seconds (between 0 and 31536000 for one year)
    RANDOM_SECONDS=$((RANDOM % 31536000))
    # Calculate the random timestamp
    TIMESTAMP=$(date -v-${RANDOM_SECONDS}S +"%Y-%m-%d %H:%M:%S")
    echo $TIMESTAMP
}

# Function to add minutes to a timestamp
add_minutes_to_timestamp() {
    local timestamp="$1"
    local minutes="$2"
    date -j -v+"${minutes}"M -f "%Y-%m-%d %H:%M:%S" "$timestamp" +"%Y-%m-%d %H:%M:%S"
}

# Insert records with random UUIDs and progressing status
for ((i=1; i<=TOTAL_IDS; i++)); do
    id=$(uuidgen | tr '[:upper:]' '[:lower:]') # Generate a random UUID and convert to lowercase
    base_timestamp=$(generate_base_timestamp)

    for status in A B C D; do
        created_at=$base_timestamp
        updated_at=$(add_minutes_to_timestamp "$base_timestamp" $((RANDOM % 60)))

        psql -U $DB_USER -d $DB_NAME -h $DB_HOST -p $DB_PORT -c \
            "INSERT INTO grafana_table (id, status, created_at, updated_at) \
             VALUES ('$id', '$status', '$created_at', '$updated_at');"

        base_timestamp=$updated_at
    done

    # Optional: Print progress every 1000 IDs
    if (( i % 1000 == 0 )); then
        echo "Processed $i IDs ($(( i * 4 )) rows)..."
    fi
done

echo "Insertion complete! Total rows inserted: $(( TOTAL_IDS * 4 ))"
