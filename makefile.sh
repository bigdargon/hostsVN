#!/bin/sh

# make time stamp & count blocked
TIME_STAMP=`date +'%d %b %Y %H:%M'`
COUNT_DOMAIN=$(cat source/list-hosts-group.txt source/list-hosts-VN-group.txt source/list-hosts-VN.txt source/list-hosts.txt | grep "0.0.0.0" | wc -l)
DOMAIN=$(printf "%'.f\n" "$COUNT_DOMAIN")
COUNT_DOMAIN_VN=$(cat source/list-hosts-VN-group.txt source/list-hosts-VN.txt | grep "0.0.0.0" | wc -l)
DOMAIN_VN=$(printf "%'.f\n" "$COUNT_DOMAIN_VN")

COUNT_RULE=$(cat source/list-adservers.txt source/list-adservers-all.txt | grep -v '!' | wc -l)
RULE=$(printf "%'.f\n" "$COUNT_RULE")
COUNT_RULE_VN=$(cat source/list-adservers.txt | grep -v '!' | wc -l)
RULE_VN=$(printf "%'.f\n" "$COUNT_RULE_VN")

# update titles
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_rule_vn_/$RULE_VN/g" tmp/title-adserver.txt > tmp/title-adserver.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_rule_/$RULE/g" tmp/title-adserver-all.txt > tmp/title-adserver-all.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_domain_/$DOMAIN/g" tmp/title-hosts.txt > tmp/title-hosts.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_domain_/$DOMAIN/g" tmp/title-hosts-iOS.txt > tmp/title-hosts-iOS.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_domain_vn_/$DOMAIN_VN/g" tmp/title-hosts-VN.txt > tmp/title-hosts-VN.tmp

# create hosts files
cat tmp/title-hosts.tmp source/list-hosts-group.txt source/list-hosts-VN-group.txt source/list-hosts-VN.txt source/list-hosts.txt > hosts
cat tmp/title-hosts-VN.tmp source/list-hosts-VN-group.txt source/list-hosts-VN.txt > option/hosts-VN
cat hosts | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0 "$2}' >> tmp/hosts-iOS.tmp
cat tmp/title-hosts-iOS.tmp tmp/hosts-iOS.tmp > option/hosts-iOS

# create domain file
cat hosts | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $2}' >> tmp/domain.txt
mv tmp/domain.txt option/

# create adserver files
cat source/list-adservers.txt | grep -v '!' | awk '{print $1}' >> tmp/list-adservers.tmp
cat source/list-adservers-all.txt | grep -v '!' | awk '{print $1}' >> tmp/list-adservers-all.tmp
cat tmp/title-adserver.tmp tmp/list-adservers.tmp > filters/domain-adservers.txt
cat tmp/title-adserver-all.tmp tmp/list-adservers.tmp tmp/list-adservers-all.tmp > filters/domain-adservers-all.txt

# create rule & config files
cat filters/domain-adservers.txt | grep -v '!' | awk '{print "||"$1"^"}' >> tmp/adservers-rule.tmp
cat filters/domain-adservers-all.txt | grep -v '!' | awk '{print "||"$1"^"}' >> tmp/adservers-all-rule.tmp
cat filters/domain-adservers-all.txt | grep -v '!' | awk '{print "*"$1" = 0.0.0.0"}' >> tmp/adservers-config.tmp

# add to files
cat tmp/title-adserver.tmp tmp/adservers-rule.tmp > filters/adservers.txt
cat tmp/title-adserver-all.tmp tmp/adservers-all-rule.tmp > filters/adservers-all.txt
cat tmp/title-config-surge.txt tmp/adservers-config.tmp > option/hostsVN.conf
cat tmp/title-config-quantumult.txt tmp/adservers-config.tmp > option/hostsVN-quantumult.conf

# remove tmp file
rm -rf tmp/*.tmp
