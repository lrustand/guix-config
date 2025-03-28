#!/usr/bin/env bash

# Import new messages to notmuch database
notmuch new

# Show notification on new unread mail
NEW_MAIL="$(notmuch search tag:new and tag:unread)"
while IFS= read -r MESSAGE; do
    DATE="$(echo $MESSAGE | cut -d ' ' -f 2)"
    COUNT="$(echo $MESSAGE | cut -d ' ' -f 3)"
    SENDER="$(echo $MESSAGE | cut -d ' ' -f 5- | cut -d ';' -f 1)"
    TITLE="$(echo $MESSAGE | cut -d ' ' -f 5- | cut -d ';' -f 2 | sed -e 's/^ //g')"
    if [[ ! -z "$TITLE" ]]; then
        notify-send "$SENDER" "$TITLE" || fyi "$SENDER" "$TITLE"
    fi
done <<< "$NEW_MAIL"

# Remove "new" tag
notmuch tag -new -- tag:new
