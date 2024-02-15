#!/bin/bash

# Check if source and destination directories are provided as arguments
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <source_directory> <destination_directory>"
  exit 1
fi

# Get source and destination directories from command line arguments
SOURCE_DIR="$1"
DESTINATION_DIR="$2"

# Step 1: Copy the contents of the source directory to the destination directory
echo "Step 1: Copying files from $SOURCE_DIR to $DESTINATION_DIR..."
cp -R "$SOURCE_DIR/lib/." "$DESTINATION_DIR/lib/"
echo "Step 1 completed successfully."

# Step 2: Replace import references in .dart files
echo "Step 2: Replacing import references in $DESTINATION_DIR/lib..."
find "$DESTINATION_DIR/lib" -type f -name '*.dart' -exec sed -i '' 's/import "package:'"$SOURCE_DIR"'/import "package:'"$DESTINATION_DIR"'/g' {} \;
echo "Step 2 completed successfully."

echo "Copy and replace completed successfully."
