#!/bin/bash

# Check if file path is given
if [ $# -ne 1 ]; then
  echo "Usage: $0 <log_file_path>"
  exit 1
fi

LOG_FILE="$1"

# Check if the file exists
if [ ! -f "$LOG_FILE" ]; then
  echo "Error: File not found!"
  exit 1
fi

# Count message types
ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE")
WARNING_COUNT=$(grep -c "WARNING" "$LOG_FILE")
INFO_COUNT=$(grep -c "INFO" "$LOG_FILE")

# Extract most common ERROR messages (excluding timestamp)
echo -e "\nTop 5 Most Common ERROR Messages:"
grep "ERROR" "$LOG_FILE" | sed -E 's/.*ERROR\s+//' | sort | uniq -c | sort -nr | head -5

# Get first and last ERROR timestamps
FIRST_ERROR=$(grep "ERROR" "$LOG_FILE" | head -1 | grep -oE '^[0-9T: \-]+')
LAST_ERROR=$(grep "ERROR" "$LOG_FILE" | tail -1 | grep -oE '^[0-9T: \-]+')

# Summary report
echo -e "\nSummary Report:"
echo "-----------------------------"
echo "Total ERRORs  : $ERROR_COUNT"
echo "Total WARNINGs: $WARNING_COUNT"
echo "Total INFOs   : $INFO_COUNT"
echo "First ERROR at: $FIRST_ERROR"
echo "Last ERROR at : $LAST_ERROR"
echo "-----------------------------"
