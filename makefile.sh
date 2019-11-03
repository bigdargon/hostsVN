#!/bin/sh

echo "Making titles..."
# make time stamp & count blocked
TIME_STAMP=`date +'%d %b %Y %H:%M'`
DOMAIN=$(printf "%'.f\n" $(cat source/hosts-group.txt source/hosts-VN-group.txt source/hosts-VN.txt source/hosts.txt source/hosts-extra.txt | grep "0.0.0.0" | wc -l))
DOMAIN_VN=$(printf "%'.f\n" $(cat source/hosts-VN-group.txt source/hosts-VN.txt | grep "0.0.0.0" | wc -l))
RULE=$(printf "%'.f\n" $(cat source/adservers.txt source/adservers-all.txt source/adservers-extra.txt | grep -v '!' | wc -l))
RULE_VN=$(printf "%'.f\n" $(cat source/adservers.txt | grep -v '!' | wc -l))

# update titles
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_domain_/$DOMAIN/g" tmp/title-hosts.txt > tmp/title-hosts.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_domain_/$DOMAIN/g" tmp/title-hosts-iOS.txt > tmp/title-hosts-iOS.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_domain_vn_/$DOMAIN_VN/g" tmp/title-hosts-VN.txt > tmp/title-hosts-VN.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_rule_/$RULE/g" tmp/title-adserver-all.txt > tmp/title-adserver-all.tmp
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_rule_vn_/$RULE_VN/g" tmp/title-adserver.txt > tmp/title-adserver.tmp

echo "Creating hosts file..."
# create hosts files
cat tmp/title-hosts.tmp source/hosts-group.txt source/hosts-VN-group.txt source/hosts-VN.txt source/hosts.txt source/hosts-extra.txt > hosts
cat tmp/title-hosts-VN.tmp source/hosts-VN-group.txt source/hosts-VN.txt > option/hosts-VN

# create hosts-iOS file
cat hosts | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0 "$2}' >> tmp/hosts-iOS.tmp
cat tmp/title-hosts-iOS.tmp tmp/hosts-iOS.tmp > option/hosts-iOS

# create domain file
cat hosts | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $2}' >> tmp/domain.txt
mv tmp/domain.txt option/

echo "Creating adserver file..."
# create temp adserver files
cat source/adservers.txt | grep -v '!' | awk '{print $1}' >> tmp/adservers.tmp
cat source/adservers-all.txt | grep -v '!' |awk '{print $1}' >> tmp/adservers-all.tmp
cat source/adservers-extra.txt | grep -v '!' |awk '{print $1}' >> tmp/adservers-extra.tmp

# create adserver files
cat tmp/adservers.tmp | awk '{print "||"$1"^"}' >> tmp/adservers-rule.tmp
cat tmp/adservers.tmp tmp/adservers-all.tmp tmp/adservers-extra.tmp | awk '{print "||"$1"^"}' >> tmp/adservers-all-rule.tmp
cat tmp/adservers.tmp tmp/adservers-all.tmp | awk '{print "*"$1" = 0.0.0.0"}' >> tmp/adservers-config.tmp

echo "Creating config file..."
# create rule
cat source/config-rule.txt | awk '{print "HOST-KEYWORD,"$1",REJECT"}' > option/hostsVN-quantumult-rule.conf
cat tmp/adservers.tmp tmp/adservers-all.tmp | awk '{print "HOST-SUFFIX,"$1",REJECT"}' >> option/hostsVN-quantumult-rule.conf
cat source/config-rule.txt | awk '{print "DOMAIN-KEYWORD,"$1}' > option/hostsVN-surge-rule.conf
cat tmp/adservers.tmp tmp/adservers-all.tmp | awk '{print "DOMAIN-SUFFIX,"$1}' >> option/hostsVN-surge-rule.conf
cat source/config-rule.txt | awk '{print "DOMAIN-KEYWORD,"$1",REJECT"}' > tmp/shadowrocket-rule.tmp
cat tmp/adservers.tmp tmp/adservers-all.tmp | awk '{print "DOMAIN-SUFFIX,"$1",REJECT"}' >> tmp/shadowrocket-rule.tmp

# create rewrite
cat source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $1}' > option/hostsVN-quantumult-rejection.conf
cat source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $1" - reject"}' > tmp/rewrite-surge.tmp
cat source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $1" reject"}' > tmp/rewrite-shadowrocket.tmp
cat source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $1" url reject-img"}' > option/hostsVN-quantumultX-rewrite.conf

# create config
HOSTNAME=$(cat source/config-hostname.txt)
sed -e "s/!_hostname_/$HOSTNAME/g" tmp/title-config-quantumultX.txt > option/hostsVN-quantumultX.conf
sed -e "s/!_hostname_/$HOSTNAME/g" -e '/!_rejection_quantumult_/r option/hostsVN-quantumult-rejection.conf' -e '/!_rejection_quantumult_/d' -e '/!_rule_quantumult_/r option/hostsVN-quantumult-rule.conf' -e '/!_rule_quantumult_/d' tmp/title-config-quantumult.txt > option/hostsVN-quantumult.conf
sed -e "s/!_hostname_/$HOSTNAME/g" -e '/!_rewrite_shadowrocket_/r tmp/rewrite-shadowrocket.tmp' -e '/!_rewrite_shadowrocket_/d' -e '/!_rule_shadowrocket_/r tmp/shadowrocket-rule.tmp' -e '/!_rule_shadowrocket_/d' tmp/title-config-shadowrocket.txt > option/hostsVN-shadowrocket.conf
sed -e "s/!_hostname_/$HOSTNAME/g" -e '/!_rewrite_surge_/r tmp/rewrite-surge.tmp' -e '/!_rewrite_surge_/d' tmp/title-config-surge-pro.txt > option/hostsVN-surge-pro.conf

echo "Adding to file..."
# add to files
cat tmp/title-adserver.tmp tmp/adservers-rule.tmp > filters/adservers.txt
cat tmp/title-adserver-all.tmp tmp/adservers-all-rule.tmp > filters/adservers-all.txt
cat tmp/title-adserver-all.tmp tmp/adservers.tmp tmp/adservers-all.tmp tmp/adservers-extra.tmp > filters/domain-adservers-all.txt
cat tmp/title-config-surge.txt tmp/adservers-config.tmp > option/hostsVN.conf

# remove tmp file
rm -rf tmp/*.tmp

# check duplicate
echo "Checking duplicate..."
sort option/domain.txt | uniq -d
sort filters/adservers-all.txt | uniq -d
read -p "Completed! Press enter to close"
