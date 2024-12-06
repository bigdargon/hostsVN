#!/bin/sh

echo "Preparing files..."
# convert hosts to filters
cat source/hosts.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $1}' > source/adserver-all.tmp
if [ "$(uname)" == "Darwin" ]; then
    sed -i "" "s/www\.//g" source/adserver-all.tmp
else
    sed -i "s/www\.//g" source/adserver-all.tmp
fi
sort -u -o source/adserver-all.tmp source/adserver-all.tmp

cat source/hosts-VN.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $1}' > source/adserver.tmp
if [ "$(uname)" == "Darwin" ]; then
    sed -i "" "s/www\.//g" source/adserver.tmp
else
    sed -i "s/www\.//g" source/adserver.tmp
fi
sort -u -o source/adserver.tmp source/adserver.tmp

echo "Making titles..."
# make time stamp & count blocked
TIME_STAMP=$(date +'%d %b %Y %H:%M')
VERSION=$(date +'%y%m%d%H%M')
LC_NUMERIC="en_US.UTF-8"

# common function to count lines
count_lines() {
  grep -v -e '#' -e '!' "$@" | grep -v -e '^[[:space:]]*$' | wc -l
}

# count blocks and rules
DOMAIN=$(printf "%'.3d\n" $(count_lines source/hosts-group.txt source/hosts-VN-group.txt source/hosts-VN.txt source/hosts.txt source/hosts-extra.txt))
DOMAIN_VN=$(printf "%'.3d\n" $(count_lines source/hosts-VN-group.txt source/hosts-VN.txt))
RULE=$(printf "%'.3d\n" $(count_lines source/adservers.txt source/adservers-all.txt source/adserver.tmp source/adserver-all.tmp source/adservers-extra.txt source/exceptions.txt))
RULE_VN=$(printf "%'.3d\n" $(count_lines source/adservers.txt source/adserver.tmp))
HOSTNAME=$(cat source/config-hostname.txt)

# function to replace placeholders in template files
update_template() {
  local template="$1"
  local output="$2"
  sed \
    -e "s/_time_stamp_/$TIME_STAMP/g" \
    -e "s/_version_/$VERSION/g" \
    -e "s/_domain_/$DOMAIN/g" \
    -e "s/_domainvn_/$DOMAIN_VN/g" \
    -e "s/_rule_/$RULE/g" \
    -e "s/_rulevn_/$RULE_VN/g" \
    -e "s/_hostname_/$HOSTNAME/g" \
    "$template" > "$output"
}

# update titles
update_template tmp/title-hosts.txt tmp/title-hosts.tmp
update_template tmp/title-hosts-iOS.txt tmp/title-hosts-iOS.tmp
update_template tmp/title-hosts-VN.txt tmp/title-hosts-VN.tmp
update_template tmp/title-adserver-all.txt tmp/title-adserver-all.tmp
update_template tmp/title-adserver.txt tmp/title-adserver.tmp

# additional configuration generation
update_template tmp/title-config-shadowrocket.txt option/hostsVN-shadowrocket.conf
update_template tmp/title-config-loon.txt option/hostsVN-loon.conf
update_template tmp/title-config-surge.txt option/hostsVN-surge-pro.conf
update_template tmp/title-config-surge.txt tmp/title-config-surge.tmp

echo "Creating hosts file..."
# create hosts files
awk '{if ($0 ~ /^#/) {print $0} else {print "0.0.0.0 "$0}}' tmp/title-hosts.tmp source/hosts-group.txt source/hosts-VN-group.txt source/hosts-VN.txt source/hosts.txt source/hosts-extra.txt > hosts
awk '{if ($0 ~ /^#/) {print $0} else {print "0.0.0.0 "$0}}' tmp/title-hosts-VN.tmp source/hosts-VN-group.txt source/hosts-VN.txt > option/hosts-VN

# create hosts-iOS file
cat hosts | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0 "$2}' >> tmp/hosts-iOS.tmp
cat tmp/title-hosts-iOS.tmp tmp/hosts-iOS.tmp > option/hosts-iOS

# create domain file
cat hosts | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $2}' > option/domain.txt
cat option/hosts-VN | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $2}' > option/domain-VN.txt

echo "Creating adserver file..."
# create temp adserver files
cat source/adservers.txt source/adserver.tmp | grep -v '!' | awk '{print $1}' >> tmp/adservers.tmp
cat source/adservers-all.txt source/adserver-all.tmp | grep -v '!' | awk '{print $1}' >> tmp/adservers-all.tmp
cat source/adservers-extra.txt | grep -v '!' | awk '{print $1}' >> tmp/adservers-extra.tmp
cat source/exceptions.txt | grep -v '!' | awk '{print $1}' >> tmp/exceptions.tmp

cat tmp/adservers.tmp | awk '{print "||"$1"^"}' >> tmp/adservers-rule.tmp
cat tmp/adservers.tmp tmp/adservers-all.tmp tmp/adservers-extra.tmp | awk '{print "||"$1"^"}' >> tmp/adservers-all-rule.tmp
cat tmp/exceptions.tmp | awk '{print "@@||"$1"^|"}' >> tmp/adservers-all-rule.tmp

# add to files
cat tmp/title-adserver.tmp tmp/adservers-rule.tmp > filters/adservers.txt
cat tmp/title-adserver-all.tmp tmp/adservers-all-rule.tmp > filters/adservers-all.txt

# create dnscrypt & dnsmasq file
cat tmp/adservers.tmp tmp/adservers-all.tmp tmp/adservers-extra.tmp | awk '{print "*."$1}' > option/dnscrypt-hostsVN.txt
cat option/domain.txt | awk '{print "local=/"$1"/"}' > option/dnsmasq-hostsVN.conf

echo "Creating rule file..."
# create rule
cat source/config-rule.txt | awk '{print "HOST-KEYWORD,"$1",REJECT"}' > option/hostsVN-quantumult-rule.conf
cat tmp/adservers.tmp tmp/adservers-all.tmp | awk '{print "HOST-SUFFIX,"$1",REJECT"}' >> option/hostsVN-quantumult-rule.conf
cat source/config-rule.txt | awk '{print "DOMAIN-KEYWORD,"$1}' > option/hostsVN-surge-rule.conf
cat tmp/adservers.tmp tmp/adservers-all.tmp | awk '{print "DOMAIN-SUFFIX,"$1}' >> option/hostsVN-surge-rule.conf

echo 'payload:' > option/hostsVN-clash-rule.yaml
cat tmp/adservers.tmp tmp/adservers-all.tmp tmp/adservers-extra.tmp | awk '{print "  - \047+."$1"\047"}' >> option/hostsVN-clash-rule.yaml

# create exceptions rule
cat tmp/exceptions.tmp | awk '{print "HOST,"$1",DIRECT"}' > option/hostsVN-quantumult-exceptions-rule.conf
cat tmp/exceptions.tmp | awk '{print "DOMAIN,"$1}' > option/hostsVN-surge-exceptions-rule.conf

echo "Creating rewrite file..."
# create rewrite
cat source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "URL-REGEX,"$1}' > option/hostsVN-surge-rewrite.conf
cat source/config-hostname.txt > option/hostsVN-quantumultX-rewrite.conf
cat source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $1" url reject-img"}' >> option/hostsVN-quantumultX-rewrite.conf
cat source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $1" - reject-img"}' > option/hostsVN-loon-rewrite.conf

echo "Creating config file..."
# create config
sed -i 's|hostsVN-surge-pro.conf|hostsVN-surge.conf|g' tmp/title-config-surge.tmp
cat tmp/adservers.tmp tmp/adservers-all.tmp | awk '{print "*"$1" = 0.0.0.0"}' >> tmp/adservers-surge.tmp
cat tmp/title-config-surge.tmp tmp/adservers-surge.tmp > option/hostsVN-surge.conf

echo "Creating block OTA & FB file..."
cat source/OTA.txt | grep -v '!' | awk '{print "HOST-SUFFIX,"$1",REJECT"}' > option/hostsVN-quantumult-OTA.conf
cat source/OTA.txt | grep -v '!' | awk '{print "DOMAIN-SUFFIX,"$1}' > option/hostsVN-surge-OTA.conf
cat source/FB.txt | grep -v '!' | awk '{print "HOST-SUFFIX,"$1",REJECT"}' > option/hostsVN-quantumult-FB.conf
echo "USER-AGENT,FBiOSSDK*,REJECT" >> option/hostsVN-quantumult-FB.conf
cat source/FB.txt | grep -v '!' | awk '{print "DOMAIN-SUFFIX,"$1}' > option/hostsVN-surge-FB.conf
echo "USER-AGENT,FBiOSSDK*" >> option/hostsVN-surge-FB.conf

echo "Creating json file..."
output_file="json/hostsVN.json"

# process file
process_file() {
    local file=$1
    grep -v '^#' "$file" | awk '{print $1}' | sort -u
}

# create json structure
create_json_array() {
    local id=$1
    shift
    local files=("$@")
    echo "  \"$id\": ["
    for file in "${files[@]}"; do
        process_file "$file" | sed -e 's/^/    "/' -e 's/$/",/'
    done | sort -u
    echo "  ],"
}

# begin write json file
echo "{" > "$output_file"

# add domain to json file
create_json_array "ads&trackingVN" source/hosts-VN-group.txt source/hosts-VN.txt >> "$output_file"
create_json_array "ads&tracking" source/hosts-group.txt source/hosts-extra.txt source/hosts.txt >> "$output_file"
create_json_array "adultVN" extensions/source/adult-VN.txt >> "$output_file"
create_json_array "adult" extensions/source/adult.txt >> "$output_file"
create_json_array "gamblingVN" extensions/source/gambling-VN.txt >> "$output_file"
create_json_array "gambling" extensions/source/gambling.txt >> "$output_file"
create_json_array "threatVN" extensions/source/threat-VN.txt >> "$output_file"
create_json_array "threat" extensions/source/threat.txt >> "$output_file"

# end write json file
sed -i '$ s/,$//' "$output_file"
echo "}" >> "$output_file"

# remove tmp file
echo "Removing temp files..."
rm -rf tmp/*.tmp
rm -rf source/*.tmp

read -p "Completed! Press enter to close"
