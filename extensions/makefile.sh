#!/bin/sh

# check duplicate & export files
cat source/adult.txt source/adult-VN.txt source/gambling.txt source/gambling-VN.txt source/threat.txt source/threat-VN.txt | grep -v '#' | sort | uniq -d > tmp/duplicate_domains.tmp
cat source/ip-adult.txt source/ip-gambling.txt source/ip-threat.txt | grep -v '#' | sort | uniq -d > tmp/duplicate_ips.tmp

# check duplicate hosts file
if [ -s tmp/duplicate_domains.tmp ]; then
    echo "Duplicate domains:"
    cat tmp/duplicate_domains.tmp
fi

# check duplicate ips file
if [ -s tmp/duplicate_ips.tmp ]; then
    echo "Duplicate ips:"
    cat tmp/duplicate_ips.tmp
fi

# if duplicate, exit
if [ -s tmp/duplicate_domains.tmp ] || [ -s tmp/duplicate_ips.tmp ]; then
    rm -f tmp/duplicate_domains.tmp tmp/duplicate_ips.tmp
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
process_hosts_file source/adult.txt source/adult.tmp
process_hosts_file source/adult-VN.txt source/adult-VN.tmp
process_hosts_file source/gambling.txt source/gambling.tmp
process_hosts_file source/gambling-VN.txt source/gambling-VN.tmp
process_hosts_file source/threat.txt source/threat.tmp
process_hosts_file source/threat-VN.txt source/threat-VN.tmp

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
DOMAIN_ADULT=$(printf "%'d\n" $(count_lines source/adult.txt source/adult-VN.txt))
DOMAIN_GAMBLING=$(printf "%'d\n" $(count_lines source/gambling.txt source/gambling-VN.txt))
DOMAIN_THREAT=$(printf "%'d\n" $(count_lines source/threat.txt source/threat-VN.txt))
DOMAIN_ADULT_VN=$(printf "%'d\n" $(count_lines source/adult-VN.txt))
DOMAIN_GAMBLING_VN=$(printf "%'d\n" $(count_lines source/gambling-VN.txt))
DOMAIN_THREAT_VN=$(printf "%'d\n" $(count_lines source/threat-VN.txt))
RULE_ADULT=$(printf "%'d\n" $(count_lines source/adult.tmp source/adult-VN.tmp))
RULE_GAMBLING=$(printf "%'d\n" $(count_lines source/gambling.tmp source/gambling-VN.tmp))
RULE_THREAT=$(printf "%'d\n" $(count_lines source/threat.tmp source/threat-VN.tmp))
RULE_ADULT_VN=$(printf "%'d\n" $(count_lines source/adult-VN.tmp))
RULE_GAMBLING_VN=$(printf "%'d\n" $(count_lines source/gambling-VN.tmp))
RULE_THREAT_VN=$(printf "%'d\n" $(count_lines source/threat-VN.tmp))

# function to replace placeholders in template files
update_template() {
  local template="$1"
  local output="$2"
  sed \
    -e "s/_time_stamp_/$TIME_STAMP/g" \
    -e "s/_version_/$VERSION/g" \
    -e "s/_domain_adult_/$DOMAIN_ADULT/g" \
    -e "s/_domain_gambling_/$DOMAIN_GAMBLING/g" \
    -e "s/_domain_threat_/$DOMAIN_THREAT/g" \
    -e "s/_domain_adultvn_/$DOMAIN_ADULT_VN/g" \
    -e "s/_domain_gamblingvn_/$DOMAIN_GAMBLING_VN/g" \
    -e "s/_domain_threatvn_/$DOMAIN_THREAT_VN/g" \
    -e "s/_rule_adult_/$RULE_ADULT/g" \
    -e "s/_rule_gambling_/$RULE_GAMBLING/g" \
    -e "s/_rule_threat_/$RULE_THREAT/g" \
    -e "s/_rule_adultvn_/$RULE_ADULT_VN/g" \
    -e "s/_rule_gamblingvn_/$RULE_GAMBLING_VN/g" \
    -e "s/_rule_threatvn_/$RULE_THREAT_VN/g" \
    "$template" > "$output"
}

# list of template files to update
declare -A TEMPLATES=(
    ["tmp/title-hosts-adult.txt"]="tmp/title-hosts-adult.tmp"
    ["tmp/title-hosts-gambling.txt"]="tmp/title-hosts-gambling.tmp"
    ["tmp/title-hosts-threat.txt"]="tmp/title-hosts-threat.tmp"
    ["tmp/title-hosts-adult-VN.txt"]="tmp/title-hosts-adult-VN.tmp"
    ["tmp/title-hosts-gambling-VN.txt"]="tmp/title-hosts-gambling-VN.tmp"
    ["tmp/title-hosts-threat-VN.txt"]="tmp/title-hosts-threat-VN.tmp"
    ["tmp/title-filter-adult.txt"]="tmp/title-filter-adult.tmp"
    ["tmp/title-filter-gambling.txt"]="tmp/title-filter-gambling.tmp"
    ["tmp/title-filter-threat.txt"]="tmp/title-filter-threat.tmp"
    ["tmp/title-filter-adult-VN.txt"]="tmp/title-filter-adult-VN.tmp"
    ["tmp/title-filter-gambling-VN.txt"]="tmp/title-filter-gambling-VN.tmp"
    ["tmp/title-filter-threat-VN.txt"]="tmp/title-filter-threat-VN.tmp"
)

# loop through templates and update each
for template in "${!TEMPLATES[@]}"; do
  update_template "$template" "${TEMPLATES[$template]}"
done

echo "Creating hosts file..."
# create hosts files
cat source/adult.txt source/adult-VN.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/adult-hosts.tmp
cat source/gambling.txt source/gambling-VN.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/gambling-hosts.tmp
cat source/threat.txt source/threat-VN.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/threat-hosts.tmp
cat source/adult-VN.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/adult-hosts-VN.tmp
cat source/gambling-VN.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/gambling-hosts-VN.tmp
cat source/threat-VN.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "0.0.0.0 "$1}' | sort > tmp/threat-hosts-VN.tmp

cat tmp/title-hosts-adult.tmp tmp/adult-hosts.tmp > adult/hosts
cat tmp/title-hosts-gambling.tmp tmp/gambling-hosts.tmp > gambling/hosts
cat tmp/title-hosts-threat.tmp tmp/threat-hosts.tmp > threat/hosts
cat tmp/title-hosts-adult-VN.tmp tmp/adult-hosts-VN.tmp > adult/hosts-VN
cat tmp/title-hosts-gambling-VN.tmp tmp/gambling-hosts-VN.tmp > gambling/hosts-VN
cat tmp/title-hosts-threat-VN.tmp tmp/threat-hosts-VN.tmp > threat/hosts-VN

# create domain file
cat adult/hosts | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $2}' > adult/domain.txt
cat gambling/hosts | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $2}' > gambling/domain.txt
cat threat/hosts | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $2}' > threat/domain.txt
cat adult/hosts-VN | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $2}' > adult/domain-VN.txt
cat gambling/hosts-VN | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $2}' > gambling/domain-VN.txt
cat threat/hosts-VN | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $2}' > threat/domain-VN.txt

# create ip files
cat source/ip-adult.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | sort -n > ip/adult.txt
cat source/ip-gambling.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | sort -n > ip/gambling.txt
cat source/ip-threat.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | sort -n > ip/threat.txt

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

# create sing-box rule
cat source/adult.tmp source/adult-VN.tmp | tr '\n' ',' | sed 's/,$//' | sed 's/^/"/;s/$/"/;s/,/","/g' > tmp/sing-box-adult.tmp
sed "s/_singboxdomain_/$(cat tmp/sing-box-adult.tmp)/" tmp/sing-box-rule.txt > adult/sing-box-rule.json

cat source/gambling.tmp source/gambling-VN.tmp | tr '\n' ',' | sed 's/,$//' | sed 's/^/"/;s/$/"/;s/,/","/g' > tmp/sing-box-gambling.tmp
sed "s/_singboxdomain_/$(cat tmp/sing-box-gambling.tmp)/" tmp/sing-box-rule.txt > gambling/sing-box-rule.json

cat source/threat.tmp source/threat-VN.tmp | tr '\n' ',' | sed 's/,$//' | sed 's/^/"/;s/$/"/;s/,/","/g' > tmp/sing-box-threat.tmp
sed "s/_singboxdomain_/$(cat tmp/sing-box-threat.tmp)/" tmp/sing-box-rule.txt > threat/sing-box-rule.json

# remove tmp file
echo "Removing temp files..."
rm -rf tmp/*.tmp
rm -rf source/*.tmp

read -p "Completed! Press enter to close"
