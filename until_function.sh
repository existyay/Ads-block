#!/bin/sh
export PATH="`pwd`:${PATH}"

# 下载规则文件
function download_link(){
    local IFS=$'\n'
    local target_dir="${1}"
    test "${target_dir}" = "" && target_dir="`pwd`/temple/download_Rules"
    mkdir -p "${target_dir}"

    # 专为 AdGuard Home DNS 拦截优化的规则源（已去重优化）
    # 重点：移动端开屏广告、弹窗广告、广告SDK域名
    local list='
# === 核心 DNS 拦截规则 ===
# adblockdns: 217heidai 维护的综合 DNS 规则（已包含多个上游）
https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockdns.txt|adblockdns.txt
# AdGuard DNS filter: AdGuard 官方 DNS 过滤器（最权威）
https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt|AdGuard_DNS_filter.txt
# anti-AD: 中文区最流行的广告过滤规则
https://adguardteam.github.io/HostlistsRegistry/assets/filter_21.txt|anti-AD.txt

# === Hagezi 规则（选择最全面的 multi 版本）===
# multi 已包含 pro + 额外规则，无需重复添加 pro
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/multi.txt|hagezi_multi.txt
# 威胁情报源（恶意软件、钓鱼、诈骗）- 强烈推荐
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt|hagezi_tif.txt
# 弹窗广告专项拦截
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/popupads.txt|hagezi_popup.txt
# 假冒网站拦截（假商店、假流媒体、诈骗网站）
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/fake.txt|hagezi_fake.txt
# 动态 DNS 恶意使用防护
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/dyndns.txt|hagezi_dyndns.txt
# 恶意 TLD 拦截（.top, .xyz, .gdn 等高风险顶级域）
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/spam-tlds-adblock-aggressive.txt|hagezi_spam_tlds.txt

# === 手机厂商追踪器专项拦截（Hagezi Native 系列）===
# iOS/macOS 追踪器
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/native.apple.txt|hagezi_apple.txt
# Windows/Office 追踪器
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/native.winoffice.txt|hagezi_windows.txt
# 小米/红米/POCO
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/native.xiaomi.txt|hagezi_xiaomi.txt
# 华为/荣耀
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/native.huawei.txt|hagezi_huawei.txt
# OPPO/Realme/一加
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/native.oppo-realme.txt|hagezi_oppo.txt
# vivo/iQOO
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/native.vivo.txt|hagezi_vivo.txt
# 三星
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/native.samsung.txt|hagezi_samsung.txt
# TikTok/字节跳动
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/native.tiktok.txt|hagezi_tiktok.txt
# 亚马逊
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/native.amazon.txt|hagezi_amazon.txt
# LG WebOS (智能电视)
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/native.lgwebos.txt|hagezi_lgwebos.txt

# === 中国特色广告拦截 ===
# 秋风广告规则：专注国产 App 开屏广告（仓库已更名）
https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/AWAvenue-Ads-Rule.txt|AWAvenue.txt
# ad-wars: hosts 格式的中文广告规则
https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts|ad-wars_hosts.txt
# NoAppDownload: 拦截"下载 App"弹窗
https://raw.githubusercontent.com/Noyllopa/NoAppDownload/master/NoAppDownload.txt|NoAppDownload.txt
# ADgk: 开屏广告专用规则
https://raw.githubusercontent.com/banbendalao/ADgk/master/ADgk.txt|ADgk_splash.txt

# === 国产 App 广告 SDK 专项拦截 ===
# 广告联盟 SDK 域名（穿山甲、优量汇、快手联盟等）
https://raw.githubusercontent.com/Cats-Team/AdRules/main/dns.txt|CatsTeam_dns.txt
# 大圣净化规则（专注国产 App 广告）
https://raw.githubusercontent.com/jk278/Ad-J/main/Ad-J.txt|Ad-J.txt
# CatsTeam 域名集（补充 DNS 拦截）
https://raw.githubusercontent.com/Cats-Team/AdRules/main/adrules_domainset.txt|CatsTeam_domainset.txt
# blackmatrix7 广告规则（知乎/微博/抖音等热门 App）
https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/AdGuard/Advertising/Advertising.txt|blackmatrix7_ad.txt
# ACL4SSR 广告拦截规则
https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/Clash/BanAD.list|ACL4SSR_BanAD.txt

# === 威胁情报 & 恶意软件拦截 ===
# Phishing Army: 钓鱼网站实时更新（全球最大钓鱼数据库之一）
https://phishing.army/download/phishing_army_blocklist_extended.txt|phishing_army.txt
# URLhaus: Abuse.ch 维护的恶意软件 URL 数据库
https://urlhaus.abuse.ch/downloads/hostfile/|urlhaus_malware.txt
# Phishing Database: 活跃钓鱼域名数据库
https://raw.githubusercontent.com/mitchellkrogza/Phishing.Database/master/phishing-domains-ACTIVE.txt|phishing_db.txt
# Maltrail: 恶意软件/僵尸网络追踪器
https://raw.githubusercontent.com/stamparm/maltrail/master/trails/static/malware/generic.txt|maltrail_malware.txt
# DandelionSprout 反恶意软件规则（AdGuard Home 专用格式）
https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareAdGuardHome.txt|dandelion_antimalware.txt
# Scam Blocklist: 诈骗网站拦截
https://raw.githubusercontent.com/durablenapkin/scamblocklist/master/adguard.txt|scamblocklist.txt

# === BlockListProject 安全系列 ===
# 诈骗网站
https://raw.githubusercontent.com/blocklistproject/Lists/master/scam.txt|blp_scam.txt
# 钓鱼网站
https://raw.githubusercontent.com/blocklistproject/Lists/master/phishing.txt|blp_phishing.txt
# 恶意软件
https://raw.githubusercontent.com/blocklistproject/Lists/master/malware.txt|blp_malware.txt
# 勒索软件
https://raw.githubusercontent.com/blocklistproject/Lists/master/ransomware.txt|blp_ransomware.txt
# 隐私追踪
https://raw.githubusercontent.com/blocklistproject/Lists/master/tracking.txt|blp_tracking.txt

# === 隐私追踪专项拦截 ===
# WindowsSpyBlocker: Windows 遥测和隐私追踪
https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt|windows_spy.txt
# StevenBlack Hosts: 综合广告+恶意软件+追踪器
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts|stevenblack_hosts.txt
# KADhosts: 钓鱼/欺诈/追踪综合规则
https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt|kadhosts.txt

# === 国际规则（EasyList 系列）===
# EasyList: 国际广告拦截基础
https://easylist-downloads.adblockplus.org/easylist.txt|easylist.txt
# EasyList China: 中文网站补充
https://easylist-downloads.adblockplus.org/easylistchina.txt|easylistchina.txt
# EasyPrivacy: 隐私保护和追踪器拦截
https://easylist-downloads.adblockplus.org/easyprivacy.txt|easyprivacy.txt

# === 补充规则 ===
# HalfLife: 综合广告规则
https://raw.githubusercontent.com/o0HalfLife0o/list/master/ad.txt|halflife_ad.txt
# Loyalsoldier: 代理工具常用的拒绝列表
https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/reject-list.txt|loyalsoldier_reject.txt
'

    for i in ${list}; do
        test "$(echo "${i}" | grep -E '^#')" && continue
        local name=`echo "${i}" | cut -d '|' -f2`
        local URL=`echo "${i}" | cut -d '|' -f1`
        if [ ! -f "${target_dir}/${name}" ]; then
            curl -k -L -o "${target_dir}/${name}" "${URL}" >/dev/null 2>&1 && \
            echo "※ `date +'%F %T'` ${name} 下载成功！"
        fi
        dos2unix "${target_dir}/${name}" >/dev/null 2>&1
    done
}

# 写入规则文件头部信息
function write_head(){
    local file="${1}"
    local title="${2}"
    local Description="${3}"
    test "${Description}" = "" && Description="${title}"
    
    local count=`cat "${file}" | busybox sed '/^!/d;/^[[:space:]]*$/d' | wc -l`
    local original_file=`cat "${file}"`
    
    cat << EOF > "${file}"
! Title: ${title}
! Version: `date +'%Y%m%d%H%M%S'`
! Expires: 24 hours (update frequency)
! Last modified: `date +'%F %T'`
! Total Count: ${count}
! Description: ${Description} (AdGuard Home DNS 拦截规则)
! Homepage: https://github.com/existyay/Ads-block

EOF
    echo "${original_file}" >> "${file}"
    perl "`pwd`/addchecksum.pl" "${file}" 2>/dev/null
}

# 净化规则 - 仅保留 ||domain^ 标准 DNS 拦截格式
function modtify_adblock_original_file() {
    local file="${1}"
    local exclude_pattern="${2}"
    
    # AdGuard Home DNS 拦截仅支持：
    # ✅ ||domain.com^ - 域名拦截
    # ✅ @@||domain.com^ - 白名单
    # ❌ 元素隐藏、JS注入等浏览器扩展语法不支持
    
    if test "${exclude_pattern}" = ""; then
        local new=`cat "${file}" | \
            iconv -t 'utf8' | \
            grep -E '^\|\||^@@\|\|' | \
            grep -Ev '##|#\?#|#\$#|#%#' | \
            busybox sed -E 's/\$.*//g' | \
            busybox sed -E 's/\^$/\^/g' | \
            busybox sed 's|^[[:space:]]@@|@@|g' | \
            sort -u | \
            busybox sed '/^!/d;/^[[:space:]]*$/d'`
        echo "$new" > "${file}"
    else
        local new=`cat "${file}" | \
            iconv -t 'utf8' | \
            grep -E '^\|\||^@@\|\|' | \
            grep -Ev '##|#\?#|#\$#|#%#' | \
            grep -Ev "${exclude_pattern}" | \
            busybox sed -E 's/\$.*//g' | \
            busybox sed -E 's/\^$/\^/g' | \
            busybox sed 's|^[[:space:]]@@|@@|g' | \
            sort -u | \
            busybox sed '/^!/d;/^[[:space:]]*$/d'`
        echo "$new" > "${file}"
    fi
}

# 应用白名单规则
function make_white_rules(){
    local file="${1}"
    local IFS=$'\n'
    local white_list_file="${2}"
    test ! -f "${white_list_file}" && return
    
    for pattern in `cat "${white_list_file}" 2>/dev/null | busybox sed '/^!/d;/^[[:space:]]*$/d'`; do
        busybox sed -i -E "/${pattern}/d" "${file}"
    done
}

# 合并规则文件
function Combine_adblock_original_file(){
    local file="${1}"
    local target_folder="${2}"
    
    test "${target_folder}" = "" && echo "※`date +'%F %T'` 请指定合并目录……" && return 1
    test ! -d "${target_folder}" && return 1
    
    for i in "${target_folder}"/*.txt; do
        test -f "${i}" || continue
        dos2unix "${i}" >/dev/null 2>&1
        cat "${i}" >> "${file}"
    done
}

# 筛选 AdGuard Home DNS 拦截规则（仅 ||domain^ 格式）
# 先转换各种格式，再提取标准规则
function sort_adguard_rules() {
    local output_folder="${1}"
    local file="${2}"
    
    test ! -f "${file}" && return
    
    # 先将各种格式统一转换为 AdGuard Home 格式
    convert_all_formats_to_adguard "${file}"
    
    local IFS=$'\n'
    # 提取标准 DNS 拦截规则格式：
    # 1. 域名拦截规则 (||domain.com^)
    # 2. 白名单规则 (@@||domain.com^)
    # 排除所有浏览器扩展语法（##, #?#, #$#, #%# 等）
    local new=$(cat "${file}" | \
        grep -E '^\|\||^@@\|\|' | \
        grep -Ev '##|#\?#|#\$#|#%#' | \
        busybox sed -E 's/\$.*//g' | \
        busybox sed -E 's/\^\^/^/g' | \
        sort -u | \
        busybox sed '/^!/d;/^[[:space:]]*$/d')
    
    mkdir -p "${output_folder}"
    echo "$new" > "${output_folder}/${file##*/}"
}

# 添加规则到已存在的文件（仅 ||domain^ 格式）
function add_adguard_rules() {
    local output_folder="${1}"
    local file="${2}"
    
    test ! -f "${file}" && return
    
    local IFS=$'\n'
    local new=$(cat "${file}" | \
        grep -E '^\|\||^@@\|\|' | \
        grep -Ev '##|#\?#|#\$#|#%#' | \
        busybox sed -E 's/\$.*//g' | \
        busybox sed -E 's/\^$/\^/g' | \
        sort -u | \
        busybox sed '/^!/d;/^[[:space:]]*$/d')
    
    mkdir -p "${output_folder}"
    echo "$new" >> "${output_folder}/${file##*/}"
    
    # 去重
    local sort_file=`cat "${output_folder}/${file##*/}" | sort -u | busybox sed '/^!/d;/^[[:space:]]*$/d'`
    echo "${sort_file}" > "${output_folder}/${file##*/}"
}

# 转换 hosts 格式为 AdGuard Home 格式
function convert_hosts_to_adguard(){
    local file="${1}"
    test ! -f "${file}" && return
    
    # 将 hosts 格式 (0.0.0.0 domain.com 或 127.0.0.1 domain.com) 
    # 转换为 AdGuard Home 格式 (||domain.com^)
    busybox sed -i -E \
        -e '/^[[:space:]]*#/d' \
        -e '/^[[:space:]]*$/d' \
        -e 's/^(0\.0\.0\.0|127\.0\.0\.1)[[:space:]]+/||/g' \
        -e 's/$/^/g' \
        "${file}"
}

# 统一转换各种规则格式为 AdGuard Home 标准格式 ||domain^
# 支持的输入格式：
#   1. hosts 格式: 0.0.0.0 domain.com / 127.0.0.1 domain.com
#   2. 纯域名格式: domain.com
#   3. 带点前缀: .domain.com
#   4. Clash/Surge 格式: DOMAIN,domain.com / DOMAIN-SUFFIX,domain.com
#   5. dnsmasq 格式: address=/domain.com/
#   6. AdBlock 格式: ||domain.com^ (保持不变)
#   7. 白名单格式: @@||domain.com^
function convert_all_formats_to_adguard(){
    local file="${1}"
    test ! -f "${file}" && return
    
    local temp_file="${file}.tmp"
    
    cat "${file}" | \
    # 移除注释行和空行
    grep -Ev '^[[:space:]]*(#|!|;|\[|//)' | \
    grep -Ev '^[[:space:]]*$' | \
    # 移除行首行尾空格
    busybox sed -E 's/^[[:space:]]+//g; s/[[:space:]]+$//g' | \
    # 转换 hosts 格式: 0.0.0.0 domain.com 或 127.0.0.1 domain.com
    busybox sed -E 's/^(0\.0\.0\.0|127\.0\.0\.1)[[:space:]]+(.+)/||\2^/g' | \
    # 转换 Clash DOMAIN 格式: DOMAIN,domain.com
    busybox sed -E 's/^DOMAIN,(.+)/||\1^/gi' | \
    # 转换 Clash DOMAIN-SUFFIX 格式: DOMAIN-SUFFIX,domain.com
    busybox sed -E 's/^DOMAIN-SUFFIX,(.+)/||\1^/gi' | \
    # 转换 Surge 格式: .domain.com
    busybox sed -E 's/^\.([a-zA-Z0-9])/||\1/g' | \
    # 转换 dnsmasq 格式: address=/domain.com/ 或 server=/domain.com/
    busybox sed -E 's/^(address|server)=\/([^\/]+)\/.*/||\2^/g' | \
    # 转换纯域名格式（没有任何前缀的域名）
    busybox sed -E '/^\|\|/!{ /^@@/!{ /^[a-zA-Z0-9][-a-zA-Z0-9]*\.[a-zA-Z]/s/^(.+)$/||\1^/ } }' | \
    # 确保 AdBlock 格式的规则以 ^ 结尾
    busybox sed -E '/^\|\|.*[^^]$/s/$/^/' | \
    # 移除修饰符 $xxx
    busybox sed -E 's/\$.*//g' | \
    # 修复可能的双 ^ 问题
    busybox sed -E 's/\^\^/^/g' | \
    # 修复可能的 ^^ 在末尾
    busybox sed -E 's/\^$/^/g' \
    > "${temp_file}"
    
    mv "${temp_file}" "${file}"
    echo "※`date +'%F %T'` 格式转换完成: ${file##*/}"
}

# 提取并转换规则文件中的域名为标准格式
function extract_and_convert_domains(){
    local file="${1}"
    local output_file="${2}"
    
    test ! -f "${file}" && return
    test -z "${output_file}" && output_file="${file}"
    
    local temp_file="${file}.extract.tmp"
    
    cat "${file}" | \
    # 移除注释和空行
    grep -Ev '^[[:space:]]*(#|!|;|\[|//)' | \
    grep -Ev '^[[:space:]]*$' | \
    busybox sed -E 's/^[[:space:]]+//g; s/[[:space:]]+$//g' | \
    # 提取 hosts 格式中的域名
    busybox sed -E 's/^(0\.0\.0\.0|127\.0\.0\.1)[[:space:]]+/||/g' | \
    # 提取 Clash 格式中的域名
    busybox sed -E 's/^DOMAIN(-SUFFIX)?,//gi' | \
    # 提取 dnsmasq 格式中的域名
    busybox sed -E 's/^(address|server)=\/([^\/]+)\/.*/\2/g' | \
    # 提取已有 AdBlock 格式中的域名
    busybox sed -E 's/^\|\|//g' | \
    busybox sed -E 's/\^.*//g' | \
    # 移除通配符规则（不适用于 DNS 拦截）
    grep -Ev '^\*|^/' | \
    # 只保留有效域名格式
    grep -E '^[a-zA-Z0-9][-a-zA-Z0-9.]*\.[a-zA-Z]{2,}$' | \
    # 转换为标准格式
    busybox sed -E 's/^(.+)$/||\1^/g' | \
    sort -u \
    > "${temp_file}"
    
    if [ "${output_file}" = "${file}" ]; then
        mv "${temp_file}" "${file}"
    else
        cat "${temp_file}" >> "${output_file}"
        rm -f "${temp_file}"
    fi
}

# 清理和优化 AdGuard Home 规则
function clean_adguard_rules(){
    local file="${1}"
    test ! -f "${file}" && return
    
    echo "※`date +'%F %T'` 开始深度清理规则..."
    
    local temp_file="${file}.clean.tmp"
    
    cat "${file}" | \
    # 移除注释行和空行
    busybox sed '/^!/d;/^[[:space:]]*$/d' | \
    # 移除行首行尾空格
    busybox sed -E 's/^[[:space:]]+//g; s/[[:space:]]+$//g' | \
    # 只保留有效的 AdGuard Home 规则格式
    grep -E '^\|\|[a-zA-Z0-9][-a-zA-Z0-9.]*\^$|^@@\|\|[a-zA-Z0-9][-a-zA-Z0-9.]*\^$' | \
    # 移除无效域名（单个字符、纯数字等）
    grep -Ev '^\|\|[0-9]+\^$' | \
    grep -Ev '^\|\|[a-zA-Z]\^$' | \
    # 移除包含无效字符的规则
    grep -Ev '\|\|.*[_].*\^' | \
    # 移除过短的域名（如 ||a.b^）
    grep -Ev '^\|\|[a-zA-Z0-9]\.[a-zA-Z0-9]\^$' | \
    # 排序去重
    sort -u \
    > "${temp_file}"
    
    mv "${temp_file}" "${file}"
    
    local count=$(cat "${file}" | wc -l)
    echo "※`date +'%F %T'` 规则清理完成，共 ${count} 条有效规则"
}

# 高级去重：移除冗余的子域名规则
# 如果 ||example.com^ 存在，则 ||sub.example.com^ 是冗余的
function remove_redundant_subdomains(){
    local file="${1}"
    test ! -f "${file}" && return
    
    echo "※`date +'%F %T'` 移除冗余子域名规则..."
    
    local temp_file="${file}.dedup.tmp"
    local domains_file="${file}.domains.tmp"
    local result_file="${file}.result.tmp"
    
    # 提取所有被拦截的域名（不含 || 和 ^）
    cat "${file}" | \
        grep -E '^\|\|' | \
        grep -Ev '^@@' | \
        busybox sed -E 's/^\|\|//g; s/\^$//g' | \
        sort -u > "${domains_file}"
    
    # 保留白名单规则（@@开头的）
    cat "${file}" | grep -E '^@@' > "${result_file}"
    
    # 对每个域名检查是否有父域名已被拦截
    while IFS= read -r domain; do
        # 检查是否存在父域名
        local parent_blocked=0
        local check_domain="${domain}"
        
        # 逐级检查父域名
        while [[ "${check_domain}" == *.* ]]; do
            # 获取父域名（移除第一个子域）
            check_domain="${check_domain#*.}"
            
            # 如果父域名存在于拦截列表中，则当前域名是冗余的
            if grep -qFx "${check_domain}" "${domains_file}" 2>/dev/null; then
                parent_blocked=1
                break
            fi
        done
        
        # 如果没有父域名被拦截，则保留此规则
        if [ "${parent_blocked}" -eq 0 ]; then
            echo "||${domain}^" >> "${result_file}"
        fi
    done < "${domains_file}"
    
    # 排序并去重
    cat "${result_file}" | sort -u > "${temp_file}"
    mv "${temp_file}" "${file}"
    
    # 清理临时文件
    rm -f "${domains_file}" "${result_file}"
    
    local count=$(cat "${file}" | wc -l)
    echo "※`date +'%F %T'` 子域名去重完成，剩余 ${count} 条规则"
}

# 清理规则格式（确保 ||domain^ 标准格式）
function remove_unsupported_modifiers(){
    local file="${1}"
    test ! -f "${file}" && return
    
    # 移除所有修饰符，只保留纯净的 ||domain^ 格式
    busybox sed -i -E \
        -e 's/\$.*//g' \
        -e 's/\^$/\^/g' \
        "${file}"
    
    # 确保每行以 ^ 结尾
    busybox sed -i -E \
        -e '/^\|\|/{ /\^$/!s/$/\^/ }' \
        -e '/^@@\|\|/{ /\^$/!s/$/\^/ }' \
        "${file}"
    
    echo "※`date +'%F %T'` 已转换为标准 ||domain^ 格式"
}

# 提取域名拦截规则（从各种格式转换为 ||domain^）
function extract_domain_rules(){
    local file="${1}"
    local output_file="${2}"
    
    test ! -f "${file}" && return
    
    # 提取所有域名拦截规则并标准化
    local domain_rules=$(cat "${file}" | \
        grep -E '^\|\||^@@\|\|' | \
        grep -Ev '##|#\?#|#\$#|#%#' | \
        busybox sed -E 's/\$.*//g' | \
        busybox sed -E 's/\^$/\^/g' | \
        sort -u)
    
    if [ ! -z "${domain_rules}" ]; then
        echo "${domain_rules}" >> "${output_file}"
        echo "※`date +'%F %T'` 提取到 $(echo "${domain_rules}" | wc -l) 条域名拦截规则"
    fi
}

# 规则格式化输出（简洁输出，不添加分类注释）
function format_adguard_rules(){
    local file="${1}"
    test ! -f "${file}" && return
    
    # 分离白名单和拦截规则，白名单放在前面
    local whitelist_rules=$(cat "${file}" | grep -E '^@@\|\|' | sort -u)
    local domain_rules=$(cat "${file}" | grep -E '^\|\|' | grep -Ev '^@@' | sort -u)
    
    # 输出：先白名单，再拦截规则，保持纯净格式
    {
        # 输出白名单（如果有）
        if [ -n "${whitelist_rules}" ]; then
            echo "${whitelist_rules}"
        fi
        # 输出拦截规则
        if [ -n "${domain_rules}" ]; then
            echo "${domain_rules}"
        fi
    } > "${file}"
    
    local total=$(cat "${file}" | wc -l)
    echo "※`date +'%F %T'` 格式化完成，共 ${total} 条规则"
}

# 更新 README 信息
function update_README_info(){
    local file="`pwd`/README.md"
    test -f "${file}" && rm -rf "${file}"
    
    cat << EOF > "${file}"
# Ads-block
# 源码参考自https://github.com/lingeringsound/adblock_auto/
### 🚀 强力广告拦截规则集 - 自动更新(`date +'%F %T'`)

**涵盖 25+ 顶级规则源，近 50 万条规则**

## 订阅链接

| 名称 | GitHub 订阅链接 | GitHub 加速订阅链接 |
| :-- | :-- | :-- |
| AdGuard Home 规则 | [订阅](https://raw.githubusercontent.com/existyay/Ads-block/refs/heads/main/Rules/adblock_auto.txt) | [订阅](https://raw.gitmirror.com/existyay/Ads-block/refs/heads/main/Rules/adblock_auto.txt)

## 上游规则源

感谢以下规则源提供者 ❤️

<details>
<summary>点击查看上游规则</summary>
<ul>
<li><strong>核心规则集（必备）</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockdns.txt" target="_blank">adblockdns</a> - DNS 拦截规则</li>
<li><a href="https://adguardteam.github.io/HostlistsRegistry/assets/filter_21.txt" target="_blank">anti-AD</a> - 中文广告过滤列表</li>
<li><a href="https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts" target="_blank">ad-wars</a> - hosts 格式规则</li>
</ul>

<li><strong>中文规则集（强力拦截）</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/ABP.txt" target="_blank">乘风广告规则</a> - 综合中文广告拦截</li>
<li><a href="https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/mv.txt" target="_blank">乘风视频规则</a> - 视频网站广告</li>
<li><a href="https://raw.githubusercontent.com/Noyllopa/NoAppDownload/master/NoAppDownload.txt" target="_blank">NoAppDownload</a> - 应用下载提示拦截</li>
<li><a href="https://raw.githubusercontent.com/jk278/Ad-J/main/Ad-J.txt" target="_blank">Ad-J</a> - 综合广告拦截</li>
<li><a href="https://raw.githubusercontent.com/damengzhu/banad/main/jiekouAd.txt" target="_blank">接口广告规则</a> - API 广告拦截</li>
</ul>

<li><strong>国际规则集（EasyList 系列）</strong></li>
<ul>
<li><a href="https://easylist-downloads.adblockplus.org/easylist.txt" target="_blank">EasyList</a> - 国际广告拦截</li>
<li><a href="https://easylist-downloads.adblockplus.org/easylistchina.txt" target="_blank">EasyList China</a> - 中文补充规则</li>
<li><a href="https://easylist-downloads.adblockplus.org/easyprivacy.txt" target="_blank">EasyPrivacy</a> - 隐私保护</li>
<li><a href="https://secure.fanboy.co.nz/fanboy-annoyance.txt" target="_blank">Fanboy's Annoyance</a> - 反干扰规则</li>
</ul>

<li><strong>移动端专用规则</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt" target="_blank">HaGeZi Pro</a> - 专业级拦截</li>
<li><a href="https://raw.githubusercontent.com/Cats-Team/AdRules/main/adguard_mobile.txt" target="_blank">AdGuard Mobile</a> - 移动端优化</li>
</ul>

<li><strong>AdGuard 官方规则集</strong></li>
<ul>
<li><a href="https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt" target="_blank">Base Filter</a> - 基础过滤器</li>
<li><a href="https://adguardteam.github.io/HostlistsRegistry/assets/filter_3.txt" target="_blank">Tracking Protection</a> - 跟踪保护</li>
<li><a href="https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt" target="_blank">Social Media</a> - 社交媒体过滤</li>
<li><a href="https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" target="_blank">Mobile Ads</a> - 移动广告</li>
<li><a href="https://adguardteam.github.io/HostlistsRegistry/assets/filter_17.txt" target="_blank">Annoyances</a> - 反干扰</li>
</ul>

<li><strong>视频网站专用</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/Silentely/AdBlock-Acceleration/master/AdGuard_Simplified_Domain.txt" target="_blank">视频广告拦截</a></li>
<li><a href="https://raw.githubusercontent.com/o0HalfLife0o/list/master/ad.txt" target="_blank">HalfLife 广告规则</a></li>
</ul>

<li><strong>隐私保护</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt" target="_blank">Windows Spy Blocker</a> - 阻止 Windows 遥测</li>
</ul>
</ul>
</details>


## 使用说明

### 在 AdGuard Home 中使用

1. 在 AdGuard Home 管理界面进入「过滤器」>「DNS 封锁清单」
2. 添加自定义过滤器
3. 粘贴上方的订阅链接
4. 保存并更新

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=existyay/Ads-block&type=Date)](https://star-history.com/#existyay/Ads-block&Date)

---

**注意**: 本规则集为标准 ||domain^ 格式的 DNS 拦截规则，专为 AdGuard Home 优化。

⚠️ **重要提示**：DNS 拦截能力有限，无法 100% 拦截所有开屏/弹窗广告。如需更强效果，建议：
- Android：安装 AdGuard 客户端或使用 Magisk 模块（如 AdAway）
- iOS：安装 AdGuard Pro 或使用 Quantumult X 等工具
- 使用支持 SSL 拦截的方案可获得最佳效果
EOF
}