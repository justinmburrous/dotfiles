#!/usr/bin/env fish

echo "Deleting all completed reminders"

osascript -e 'tell application "Reminders" to delete (reminders whose completed is true)'

echo "done"
