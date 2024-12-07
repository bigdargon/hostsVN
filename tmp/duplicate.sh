#!/bin/bash

cat ../source/hosts-VN-group.txt ../source/hosts-VN.txt ../source/hosts-group.txt ../source/hosts-extra.txt ../source/hosts.txt | grep -v '#' | sort | uniq -d > duplicate_domains.txt
cat ../source/adservers.txt ../source/adservers-all.txt ../source/adservers-extra.txt | grep -v '!' | sort | uniq -d > duplicate_rules.txt

# check duplicate hosts file
if [ -s duplicate_domains.txt ]; then
    echo "Duplicate domains:"
    cat duplicate_domains.txt
fi

# check duplicate adservers file
if [ -s duplicate_rules.txt ]; then
    echo "Duplicate rules:"
    cat duplicate_rules.txt
fi

read -p "Checked duplicate. Press Enter to continue..."

# if not duplicate, run makefile.sh
if [ ! -s duplicate_domains.txt ] && [ ! -s duplicate_rules.txt ]; then
    rm -f duplicate_domains.txt duplicate_rules.txt
    cd ..
    ./makefile.sh
else
    rm -f duplicate_domains.txt duplicate_rules.txt
fi
