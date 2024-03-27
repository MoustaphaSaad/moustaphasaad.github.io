#!/bin/bash

# Define the folder path
folder_path="src"

# Loop over each file in the folder
for file in "$folder_path"/*
do
  # Execute a command on the file
  # Example command: echo the file name
  # Extract the file name from the path
  filename=$(basename "$file")

  # Change the extension from .md to .html
  export_file="${filename%.md}.html"

  echo "Processing file: $file -> $export_file"
  pandoc -s $file -o $export_file --template=tufte-template/tufte.html5 --css=tufte-template/tufte.css --title-prefix="Moustapha Saad"
done
