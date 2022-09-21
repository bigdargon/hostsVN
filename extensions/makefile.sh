#!/bin/sh

echo "Preparing files..."
# convert hosts to filters
cat source/adult.txt | grep -v '#' | awk '{print $1}' > source/adult.tmp
sed -i "s/www\.//g" source/adult.tmp
sort -u -o source/adult.tmp source/adult.tmp
cat source/gambling.txt | grep -v '#' | awk '{print $1}' > source/gambling.tmp
sed -i "s/www\.//g" source/gambling.tmp
sort -u -o source/gambling.tmp source/gambling.tmp
cat source/threat.txt | grep -v '#' | awk '{print $1}' > source/threat.tmp
sed -i "s/www\.//g" source/threat.tmp
sort -u -o source/threat.tmp source/threat.tmp

echo "Making titles..."
# make time stamp & count blocked
TIME_STAMP=$(date +'%d %b %Y %H:%M')
VERSION=$(date +'%y%m%d%H%M')
LC_NUMERIC="en_US.UTF-8"
DOMAIN_ADULT=$(printf "%'.3d\n" $(cat source/adult.txt | grep -v '#' | wc -l))
DOMAIN_GAMBLING=$(printf "%'.3d\n" $(cat source/gambling.txt | grep -v '#' | wc -l))
DOMAIN_THREAT=$(printf "%'.3d\n" $(cat source/threat.txt | grep -v '#' | wc -l))
IP_BLOCKLIST=$(printf "%'.3d\n" $(cat source/ip.txt | grep -v '#' | wc -l))
RULE_ADULT=$(printf "%'.3d\n" $(cat source/adult.tmp | wc -l))
RULE_GAMBLING=$(printf "%'.3d\n" $(cat source/gambling.tmp | wc -l))
RULE_THREAT=$(printf "%'.3d\n" $(cat source/threat.tmp | wc -l))

# update titles
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_domain_adult_/$DOMAIN_ADULT/g" tmp/title-hosts-adult.txt > tmp/title-hosts-adult.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_domain_gambling_/$DOMAIN_GAMBLING/g" tmp/title-hosts-gambling.txt > tmp/title-hosts-gambling.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_domain_threat_/$DOMAIN_THREAT/g" tmp/title-hosts-threat.txt > tmp/title-hosts-threat.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_ip_blocklist_/$IP_BLOCKLIST/g" tmp/title-ip.txt > tmp/title-ip.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_rule_adult_/$RULE_ADULT/g" tmp/title-filter-adult.txt > tmp/title-filter-adult.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_rule_gambling_/$RULE_GAMBLING/g" tmp/title-filter-gambling.txt > tmp/title-filter-gambling.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_rule_threat_/$RULE_THREAT/g" tmp/title-filter-threat.txt > tmp/title-filter-threat.tmp

echo "Creating hosts file..."
# create hosts files
cat source/adult.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/adult-hosts.tmp
cat source/gambling.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/gambling-hosts.tmp
cat source/threat.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/threat-hosts.tmp
cat source/ip.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | sort -n > tmp/ip.tmp

cat tmp/title-hosts-adult.tmp tmp/adult-hosts.tmp > adult/hosts
cat tmp/title-hosts-gambling.tmp tmp/gambling-hosts.tmp > gambling/hosts
cat tmp/title-hosts-threat.tmp tmp/threat-hosts.tmp > threat/hosts
cat tmp/title-ip.tmp tmp/ip.tmp > ip/list

echo "Creating filter file..."
# create filter files
cat source/adult.tmp | awk '{print "||"$1"^"}' | sort > tmp/adult-filter.tmp
cat source/gambling.tmp | awk '{print "||"$1"^"}' | sort > tmp/gambling-filter.tmp
cat source/threat.tmp | awk '{print "||"$1"^"}' | sort > tmp/threat-filter.tmp

cat tmp/title-filter-adult.tmp tmp/adult-filter.tmp > adult/filter
cat tmp/title-filter-gambling.tmp tmp/gambling-filter.tmp > gambling/filter
cat tmp/title-filter-threat.tmp tmp/threat-filter.tmp > threat/filter

# check duplicate
echo "Checking duplicate..."
cat tmp/adult-hosts.tmp | uniq -d
cat tmp/gambling-hosts.tmp | uniq -d
cat tmp/threat-hosts.tmp | uniq -d
cat tmp/ip.tmp | uniq -d

# remove tmp file
rm -rf tmp/*.tmp
rm -rf source/*.tmp
read -p "Completed! Press enter to close"
