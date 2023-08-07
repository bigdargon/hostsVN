#!/bin/sh

rm -r gambling*

echo "Spliting files..."
split -l 45000 --numeric-suffixes hosts gambling

read -p "Completed! Press enter to close"
