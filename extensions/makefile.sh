#!/bin/sh

echo "Preparing files..."
# convert hosts to filters
cat source/adult.txt | grep -v '#' | awk '{print $1}' > source/adult.tmp
sed -i "s/www\.//g" source/adult.tmp
sort -u -o source/adult.tmp source/adult.tmp
cat source/adult-VN.txt | grep -v '#' | awk '{print $1}' > source/adult-VN.tmp
sed -i "s/www\.//g" source/adult-VN.tmp
sort -u -o source/adult-VN.tmp source/adult-VN.tmp
cat source/gambling.txt | grep -v '#' | awk '{print $1}' > source/gambling.tmp
sed -i "s/www\.//g" source/gambling.tmp
sort -u -o source/gambling.tmp source/gambling.tmp
cat source/gambling-VN.txt | grep -v '#' | awk '{print $1}' > source/gambling-VN.tmp
sed -i "s/www\.//g" source/gambling-VN.tmp
sort -u -o source/gambling-VN.tmp source/gambling-VN.tmp
cat source/threat.txt | grep -v '#' | awk '{print $1}' > source/threat.tmp
sed -i "s/www\.//g" source/threat.tmp
sort -u -o source/threat.tmp source/threat.tmp
cat source/threat-VN.txt | grep -v '#' | awk '{print $1}' > source/threat-VN.tmp
sed -i "s/www\.//g" source/threat-VN.tmp
sort -u -o source/threat-VN.tmp source/threat-VN.tmp

echo "Making titles..."
# make time stamp & count blocked
TIME_STAMP=$(date +'%d %b %Y %H:%M')
VERSION=$(date +'%y%m%d%H%M')
LC_NUMERIC="en_US.UTF-8"
DOMAIN_ADULT=$(printf "%'.3d\n" $(cat source/adult.txt source/adult-VN.txt | grep -v '#' | wc -l))
DOMAIN_GAMBLING=$(printf "%'.3d\n" $(cat source/gambling.txt source/gambling-VN.txt | grep -v '#' | wc -l))
DOMAIN_THREAT=$(printf "%'.3d\n" $(cat source/threat.txt source/threat-VN.txt | grep -v '#' | wc -l))
DOMAIN_ADULT_VN=$(printf "%'.3d\n" $(cat source/adult-VN.txt | grep -v '#' | wc -l))
DOMAIN_GAMBLING_VN=$(printf "%'.3d\n" $(cat source/gambling-VN.txt | grep -v '#' | wc -l))
DOMAIN_THREAT_VN=$(printf "%'.3d\n" $(cat source/threat-VN.txt | grep -v '#' | wc -l))
IP_BLOCKLIST=$(printf "%'.3d\n" $(cat source/ip.txt | grep -v '#' | wc -l))
RULE_ADULT=$(printf "%'.3d\n" $(cat source/adult.tmp source/adult-VN.tmp | wc -l))
RULE_GAMBLING=$(printf "%'.3d\n" $(cat source/gambling.tmp source/gambling-VN.tmp | wc -l))
RULE_THREAT=$(printf "%'.3d\n" $(cat source/threat.tmp source/threat-VN.tmp | wc -l))
RULE_ADULT_VN=$(printf "%'.3d\n" $(cat source/adult-VN.tmp | wc -l))
RULE_GAMBLING_VN=$(printf "%'.3d\n" $(cat source/gambling-VN.tmp | wc -l))
RULE_THREAT_VN=$(printf "%'.3d\n" $(cat source/threat-VN.tmp | wc -l))

# update titles
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_domain_adult_/$DOMAIN_ADULT/g" tmp/title-hosts-adult.txt > tmp/title-hosts-adult.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_domain_gambling_/$DOMAIN_GAMBLING/g" tmp/title-hosts-gambling.txt > tmp/title-hosts-gambling.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_domain_threat_/$DOMAIN_THREAT/g" tmp/title-hosts-threat.txt > tmp/title-hosts-threat.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_domain_adult_vn_/$DOMAIN_ADULT_VN/g" tmp/title-hosts-adult-VN.txt > tmp/title-hosts-adult-VN.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_domain_gambling_vn_/$DOMAIN_GAMBLING_VN/g" tmp/title-hosts-gambling-VN.txt > tmp/title-hosts-gambling-VN.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_domain_threat_vn_/$DOMAIN_THREAT_VN/g" tmp/title-hosts-threat-VN.txt > tmp/title-hosts-threat-VN.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_ip_blocklist_/$IP_BLOCKLIST/g" tmp/title-ip.txt > tmp/title-ip.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_rule_adult_/$RULE_ADULT/g" tmp/title-filter-adult.txt > tmp/title-filter-adult.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_rule_gambling_/$RULE_GAMBLING/g" tmp/title-filter-gambling.txt > tmp/title-filter-gambling.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_rule_threat_/$RULE_THREAT/g" tmp/title-filter-threat.txt > tmp/title-filter-threat.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_rule_adult_vn_/$RULE_ADULT_VN/g" tmp/title-filter-adult-VN.txt > tmp/title-filter-adult-VN.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_rule_gambling_vn_/$RULE_GAMBLING_VN/g" tmp/title-filter-gambling-VN.txt > tmp/title-filter-gambling-VN.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_rule_threat_vn_/$RULE_THREAT_VN/g" tmp/title-filter-threat-VN.txt > tmp/title-filter-threat-VN.tmp

echo "Creating hosts file..."
# create hosts files
cat source/adult.txt source/adult-VN.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/adult-hosts.tmp
cat source/gambling.txt source/gambling-VN.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/gambling-hosts.tmp
cat source/threat.txt source/threat-VN.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/threat-hosts.tmp
cat source/adult-VN.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/adult-hosts-VN.tmp
cat source/gambling-VN.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/gambling-hosts-VN.tmp
cat source/threat-VN.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/threat-hosts-VN.tmp
cat source/ip.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | sort -n > tmp/ip.tmp

cat tmp/title-hosts-adult.tmp tmp/adult-hosts.tmp > adult/hosts
cat tmp/title-hosts-gambling.tmp tmp/gambling-hosts.tmp > gambling/hosts
cat tmp/title-hosts-threat.tmp tmp/threat-hosts.tmp > threat/hosts
cat tmp/title-hosts-adult-VN.tmp tmp/adult-hosts-VN.tmp > adult/hosts-VN
cat tmp/title-hosts-gambling-VN.tmp tmp/gambling-hosts-VN.tmp > gambling/hosts-VN
cat tmp/title-hosts-threat-VN.tmp tmp/threat-hosts-VN.tmp > threat/hosts-VN
cat tmp/title-ip.tmp tmp/ip.tmp > ip/list

echo "Creating filter file..."
# create filter files
cat source/adult.tmp source/adult-VN.tmp | grep -v -e '^[[:space:]]*$' | awk '{print "||"$1"^"}' | sort > tmp/adult-filter.tmp
cat source/gambling.tmp source/gambling-VN.tmp | grep -v -e '^[[:space:]]*$' | awk '{print "||"$1"^"}' | sort > tmp/gambling-filter.tmp
cat source/threat.tmp source/threat-VN.tmp | grep -v -e '^[[:space:]]*$' | awk '{print "||"$1"^"}' | sort > tmp/threat-filter.tmp
cat source/adult-VN.tmp | grep -v -e '^[[:space:]]*$' | awk '{print "||"$1"^"}' | sort > tmp/adult-filter-VN.tmp
cat source/gambling-VN.tmp | grep -v -e '^[[:space:]]*$' | awk '{print "||"$1"^"}' | sort > tmp/gambling-filter-VN.tmp
cat source/threat-VN.tmp | grep -v -e '^[[:space:]]*$' | awk '{print "||"$1"^"}' | sort > tmp/threat-filter-VN.tmp

cat tmp/title-filter-adult.tmp tmp/adult-filter.tmp > adult/filter.txt
cat tmp/title-filter-gambling.tmp tmp/gambling-filter.tmp > gambling/filter.txt
cat tmp/title-filter-threat.tmp tmp/threat-filter.tmp > threat/filter.txt
cat tmp/title-filter-adult-VN.tmp tmp/adult-filter-VN.tmp > adult/filter-VN.txt
cat tmp/title-filter-gambling-VN.tmp tmp/gambling-filter-VN.tmp > gambling/filter-VN.txt
cat tmp/title-filter-threat-VN.tmp tmp/threat-filter-VN.tmp > threat/filter-VN.txt

echo "Creating rule file..."
# create rule
cat source/adult.tmp source/adult-VN.tmp | awk '{print "HOST-SUFFIX,"$1",REJECT"}' > adult/quantumult-rule.conf
cat source/gambling.tmp source/gambling-VN.tmp | awk '{print "HOST-SUFFIX,"$1",REJECT"}' > gambling/quantumult-rule.conf
cat source/threat.tmp source/threat-VN.tmp | awk '{print "HOST-SUFFIX,"$1",REJECT"}' > threat/quantumult-rule.conf
cat source/adult.tmp source/adult-VN.tmp | awk '{print "DOMAIN-SUFFIX,"$1}' > adult/surge-rule.conf
cat source/gambling.tmp source/gambling-VN.tmp | awk '{print "DOMAIN-SUFFIX,"$1}' > gambling/surge-rule.conf
cat source/threat.tmp source/threat-VN.tmp | awk '{print "DOMAIN-SUFFIX,"$1}' > threat/surge-rule.conf

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
