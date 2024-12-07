#!/bin/bash

cat ../source/adult.txt ../source/adult-VN.txt ../source/gambling.txt ../source/gambling-VN.txt ../source/threat.txt ../source/threat-VN.txt | grep -v '#' | sort | uniq -d > duplicate_domains.txt
cat ../source/ip-ads.txt ../source/ip-adult.txt ../source/ip-gambling.txt ../source/ip-threat.txt | grep -v '#' | sort | uniq -d > duplicate_ips.txt

# check duplicate hosts file
if [ -s duplicate_domains.txt ]; then
    echo "Duplicate domains:"
    cat duplicate_domains.txt
fi

# check duplicate adservers file
if [ -s duplicate_ips.txt ]; then
    echo "Duplicate ips:"
    cat duplicate_ips.txt
fi

read -p "Checked duplicate. Press Enter to continue..."

# if not duplicate, run makefile.sh
if [ ! -s duplicate_domains.txt ] && [ ! -s duplicate_ips.txt ]; then
    rm -f duplicate_domains.txt duplicate_ips.txt
    cd ..
    ./makefile.sh
else
    rm -f duplicate_domains.txt duplicate_ips.txt
fi
