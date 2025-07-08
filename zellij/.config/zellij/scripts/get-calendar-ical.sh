#!/bin/sh

# Run the ical-buddy command and store its output in a variable
# ==> REPLACE THE COMMAND BELOW WITH YOUR OWN <==
EVENT_OUTPUT=$(icalBuddy -ic "kevin.vncnt@gmail.com, AI Assistant Schedule" -li 1 -n -nc -nrd -ss "" -ps "/ /" -po "title,datetime" -tf "%H:%M" eventsToday)

# Check if the output is empty
if [ -z "$EVENT_OUTPUT" ]; then
  # If it's empty, print a fallback message
  echo "✅ No more events today"
else
  # If there is an event, print the formatted output from ical-buddy
  echo "$EVENT_OUTPUT"
fi
