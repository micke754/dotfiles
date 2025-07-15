#!/bin/sh

# This script fetches the next calendar event and prints it to stdout.
# It's designed to be called by the zjstatus `command` widget.

# Run gcalcli, skip the header, and get the first event.
NEXT_EVENT=$(gcalcli --nocolor agenda now | tail -n +5 | grep . | head -n 1)

# Check if an event was found.
if [ -n "$NEXT_EVENT" ]; then
    # If yes, format it and print it.
    echo "$NEXT_EVENT" | awk '{
        event_time=$1; 
        title=""; 
        for(i=4; i<=NF; i++) {
            title=title $i " "
        }; 
        print " " event_time " " title
    }'
else
    # If no, print an empty string to clear the space.
    echo ""
fi
