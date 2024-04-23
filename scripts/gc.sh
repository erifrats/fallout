#!/bin/sh

# Define array containing names of directories or files to delete
collectables=(
    "artifacts"
    "*.qcow2"
    "result"
)

for entry in "${collectables[@]}"; do
    fd -I -H -L -g "$entry" -x echo Collecting {} \; -x rm -rf {}
done
