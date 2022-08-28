#!/bin/sh

echo "Making titles..."
# make time stamp & count blocked
TIME_STAMP=$(date +'%d %b %Y %H:%M')
VERSION=$(date +'%y%m%d%H%M')
LC_NUMERIC="en_US.UTF-8"
DOMAIN_ADULT=$(printf "%'.3d\n" $(cat source/adult.txt | grep -v '#' | wc -l))
DOMAIN_GAMBLING=$(printf "%'.3d\n" $(cat source/gambling.txt | grep -v '#' | wc -l))
DOMAIN_THREAT=$(printf "%'.3d\n" $(cat source/threat.txt | grep -v '#' | wc -l))
IP_BLOCKLIST=$(printf "%'.3d\n" $(cat source/ip.txt | grep -v '#' | wc -l))

# update titles
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_domain_adult_/$DOMAIN_ADULT/g" tmp/title-hosts-adult.txt > tmp/title-hosts-adult.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_domain_gambling_/$DOMAIN_GAMBLING/g" tmp/title-hosts-gambling.txt > tmp/title-hosts-gambling.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_domain_threat_/$DOMAIN_THREAT/g" tmp/title-hosts-threat.txt > tmp/title-hosts-threat.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_ip_blocklist_/$IP_BLOCKLIST/g" tmp/title-ip.txt > tmp/title-ip.tmp

echo "Creating hosts file..."
# create hosts files
cat source/adult.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' > tmp/adult-hosts.tmp
cat source/gambling.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' > tmp/gambling-hosts.tmp
cat source/threat.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' > tmp/threat-hosts.tmp
cat source/ip.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' > tmp/ip.tmp

sort -o tmp/adult-hosts.tmp tmp/adult-hosts.tmp
sort -o tmp/gambling-hosts.tmp tmp/gambling-hosts.tmp
sort -o tmp/threat-hosts.tmp tmp/threat-hosts.tmp
sort -o tmp/ip.tmp tmp/ip.tmp

cat tmp/title-hosts-adult.tmp tmp/adult-hosts.tmp > adult/hosts
cat tmp/title-hosts-gambling.tmp tmp/gambling-hosts.tmp > gambling/hosts
cat tmp/title-hosts-threat.tmp tmp/threat-hosts.tmp > threat/hosts
cat tmp/title-ip.tmp tmp/ip.tmp > ip/list

# check duplicate
echo "Checking duplicate..."
cat tmp/adult-hosts.tmp | uniq -d
cat tmp/gambling-hosts.tmp | uniq -d
cat tmp/threat-hosts.tmp | uniq -d
cat tmp/ip.tmp | uniq -d

# remove tmp file
rm -rf tmp/*.tmp
read -p "Completed! Press enter to close"
