#!/bin/sh

# check duplicate & export files
cat source/hosts-VN-group.txt source/hosts-VN.txt source/hosts-group.txt source/hosts-extra.txt source/hosts.txt | grep -v '#' | sort | uniq -d > tmp/duplicate_domains.tmp
cat source/adservers.txt source/adservers-all.txt source/adservers-extra.txt | grep -v '!' | sort | uniq -d > tmp/duplicate_rules.tmp

# check duplicate hosts file
if [ -s tmp/duplicate_domains.tmp ]; then
    echo "Duplicate domains:"
    cat tmp/duplicate_domains.tmp
fi

# check duplicate adservers file
if [ -s tmp/duplicate_rules.tmp ]; then
    echo "Duplicate rules:"
    cat tmp/duplicate_rules.tmp
fi

# if duplicate, exit
if [ -s tmp/duplicate_domains.tmp ] || [ -s tmp/duplicate_rules.tmp ]; then
    rm -f tmp/duplicate_domains.tmp tmp/duplicate_rules.tmp
    read -p "Duplicate found. Exiting..."
    exit 1
fi

echo "Preparing files..."
# function to process files
process_hosts_file() {
    local input_file=$1
    local output_file=$2
    grep -vE '^#|^[[:space:]]*$' "$input_file" | awk '{print $1}' | sed 's/www\.//g' | sort -u > "$output_file"
}

# process files
process_hosts_file source/hosts.txt source/adserver-all.tmp
process_hosts_file source/hosts-VN.txt source/adserver.tmp

echo "Making titles..."
# make time stamp & version
TIME_STAMP=$(date +'%d %b %Y %H:%M')
VERSION=$(date +'%y%m%d%H%M')
LC_NUMERIC="vi_VN.UTF-8"

# common function to count lines
count_lines() {
  grep -v -e '#' -e '!' "$@" | grep -v -e '^[[:space:]]*$' | wc -l
}

# count domains and rules
DOMAIN=$(printf "%'d\n" $(count_lines source/hosts-group.txt source/hosts-VN-group.txt source/hosts-VN.txt source/hosts.txt source/hosts-extra.txt))
DOMAIN_VN=$(printf "%'d\n" $(count_lines source/hosts-VN-group.txt source/hosts-VN.txt))
RULE=$(printf "%'d\n" $(count_lines source/adservers.txt source/adservers-all.txt source/adserver.tmp source/adserver-all.tmp source/adservers-extra.txt source/exceptions.txt))
RULE_VN=$(printf "%'d\n" $(count_lines source/adservers.txt source/adserver.tmp))
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

# list of template files to update
declare -A TEMPLATES=(
    ["tmp/title-hosts.txt"]="tmp/title-hosts.tmp"
    ["tmp/title-hosts-VN.txt"]="tmp/title-hosts-VN.tmp"
    ["tmp/title-adserver-all.txt"]="tmp/title-adserver-all.tmp"
    ["tmp/title-adserver.txt"]="tmp/title-adserver.tmp"
    ["tmp/title-config-shadowrocket.txt"]="option/hostsVN-shadowrocket.conf"
    ["tmp/title-config-loon.txt"]="option/hostsVN-loon.conf"
    ["tmp/title-config-surge.txt"]="option/hostsVN-surge-pro.conf"
    ["tmp/title-config-surge.txt"]="tmp/title-config-surge.tmp"
)

# loop through templates and update each
for template in "${!TEMPLATES[@]}"; do
  update_template "$template" "${TEMPLATES[$template]}"
done

echo "Creating hosts file..."
# create hosts files
awk '{if ($0 ~ /^#/) {print $0} else {print "0.0.0.0 "$0}}' tmp/title-hosts.tmp source/hosts-group.txt source/hosts-VN-group.txt source/hosts-VN.txt source/hosts.txt source/hosts-extra.txt > hosts
awk '{if ($0 ~ /^#/) {print $0} else {print "0.0.0.0 "$0}}' tmp/title-hosts-VN.tmp source/hosts-VN-group.txt source/hosts-VN.txt > option/hosts-VN

# create domain file
cat hosts | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $2}' > option/domain.txt
cat option/hosts-VN | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $2}' > option/domain-VN.txt

# create ip file
cat source/ip-ads.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | sort -n > option/ip-ads.txt

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

echo 'payload:' > option/hostsVN-open-clash-rule.yaml
cat tmp/adservers.tmp tmp/adservers-all.tmp tmp/adservers-extra.tmp | awk '{print "  - DOMAIN-SUFFIX,"$1}'  >> option/hostsVN-open-clash-rule.yaml

# create sing-box rule
cat tmp/adservers.tmp tmp/adservers-all.tmp tmp/adservers-extra.tmp | tr '\n' ',' | sed 's/,$//' | sed 's/^/"/;s/$/"/;s/,/","/g' > tmp/sing-box-ads.tmp
sed "s/_singboxdomain_/$(cat tmp/sing-box-ads.tmp)/" tmp/sing-box-rule.txt > option/hostsVN-sing-box-rule.json

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
process_json_file() {
    cat "$@" | grep -v '^#' | awk '{print $1}' | sort -u
}

# create json structure
create_json_array() {
    local id=$1
    shift
    local files=("$@")
    echo -n "  \"$id\": ["
    process_json_file "${files[@]}" | awk 'BEGIN { ORS=""; } { printf "\"%s\",", $0; }' | sed 's/,$//'
    echo "],"
}

# begin write json file
echo "{" > "$output_file"

# add domain to json file
create_json_array "ads&trackingVN" source/hosts-VN-group.txt source/hosts-VN.txt >> "$output_file"
create_json_array "ads&tracking" source/hosts-group.txt source/hosts-extra.txt source/hosts.txt >> "$output_file"
create_json_array "ip-ads" source/ip-ads.txt >> "$output_file"
create_json_array "adultVN" extensions/source/adult-VN.txt >> "$output_file"
create_json_array "adult" extensions/source/adult.txt >> "$output_file"
create_json_array "gamblingVN" extensions/source/gambling-VN.txt >> "$output_file"
create_json_array "gambling" extensions/source/gambling.txt >> "$output_file"
create_json_array "threatVN" extensions/source/threat-VN.txt >> "$output_file"
create_json_array "threat" extensions/source/threat.txt >> "$output_file"
create_json_array "ip-adult" extensions/source/ip-adult.txt >> "$output_file"
create_json_array "ip-gambling" extensions/source/ip-gambling.txt >> "$output_file"
create_json_array "ip-threat" extensions/source/ip-threat.txt >> "$output_file"

# end write json file
sed -i '$ s/,$//' "$output_file"
echo "}" >> "$output_file"

# remove tmp file
echo "Removing temp files..."
rm -rf tmp/*.tmp
rm -rf source/*.tmp

read -p "Completed! Press enter to close"
