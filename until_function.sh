#!/bin/sh
export PATH="`pwd`:${PATH}"

# 下载规则文件
function download_link(){
    local IFS=$'\n'
    local target_dir="${1}"
    test "${target_dir}" = "" && target_dir="`pwd`/temple/download_Rules"
    mkdir -p "${target_dir}"

    # 精简高效版 - 精选高质量规则源
    # 支持格式：AdBlock、Hosts、元素隐藏、追踪拦截
    local list='
# === 核心规则（精简高效）===
# AWAvenue 秋风广告规则：专注国产 App 开屏广告
https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/AWAvenue-Ads-Rule.txt|AWAvenue_main.txt

# === 移动端广告拦截 ===
# AdGuard Mobile Ads Filter：移动端广告专用规则（含元素隐藏）
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_11_Mobile/filter.txt|adguard_mobile.txt
# 大圣净化规则：专注国产 App 广告
https://raw.githubusercontent.com/jk278/Ad-J/main/Ad-J.txt|Ad-J.txt
# NoAppDownload：应用下载提示拦截
https://raw.githubusercontent.com/Noyllopa/NoAppDownload/master/NoAppDownload.txt|NoAppDownload.txt

# === 追踪拦截规则 ===
# AdGuard Tracking Protection：追踪保护规则
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt|adguard_tracking.txt
# EasyPrivacy：隐私保护规则
https://easylist.to/easylist/easyprivacy.txt|easyprivacy.txt

# === Hosts 格式规则 ===
# StevenBlack Hosts：统一多源的 hosts 广告拦截
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts|stevenblack_hosts.txt

# === 元素隐藏规则 ===
# AdGuard Chinese Filter：中文网站元素隐藏
https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_224_Chinese/filter.txt|adguard_chinese.txt

# === 安全威胁拦截 ===
# DandelionSprout 反恶意软件：安全威胁拦截
https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareAdGuardHome.txt|dandelion_antimalware.txt
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

# 净化规则 - 保留 DNS 拦截和元素隐藏规则
# 支持 AdGuard 客户端/浏览器扩展的完整语法
function modtify_adblock_original_file() {
    local file="${1}"
    local exclude_pattern="${2}"
    local mode="${3:-full}"  # full=完整规则, dns=仅DNS拦截
    
    # AdGuard 支持的规则类型：
    # ✅ ||domain.com^ - 域名拦截（DNS/客户端均支持）
    # ✅ @@||domain.com^ - 白名单（DNS/客户端均支持）
    # ✅ ##.ad-class - 元素隐藏（仅客户端/扩展支持）
    # ✅ #@#.ad-class - 元素隐藏白名单
    # ✅ #?#.ad-class - 扩展CSS选择器
    # ✅ domain.com##.ad - 针对特定域名的元素隐藏
    # ✅ $third-party,$image 等修饰符（客户端支持）
    
    if test "${mode}" = "dns"; then
        # DNS模式：仅保留域名拦截规则
        local new=`cat "${file}" | \
            iconv -t 'utf8' | \
            grep -E '^\|\||^@@\|\|' | \
            grep -Ev '##|#\?#|#\$#|#%#|#@#' | \
            busybox sed -E 's/\$.*//g' | \
            busybox sed -E 's/\^$/\^/g' | \
            busybox sed 's|^[[:space:]]@@|@@|g' | \
            sort -u | \
            busybox sed '/^!/d;/^[[:space:]]*$/d'`
        echo "$new" > "${file}"
    else
        # 完整模式：保留元素隐藏和修饰符规则
        if test "${exclude_pattern}" = ""; then
            local new=`cat "${file}" | \
                iconv -t 'utf8' | \
                grep -E '^\|\||^@@\|\||^[a-zA-Z0-9.*-]*##|^[a-zA-Z0-9.*-]*#@#|^[a-zA-Z0-9.*-]*#\?#|^##|^#@#|^#\?#' | \
                busybox sed 's|^[[:space:]]@@|@@|g' | \
                sort -u | \
                busybox sed '/^!/d;/^[[:space:]]*$/d'`
            echo "$new" > "${file}"
        else
            local new=`cat "${file}" | \
                iconv -t 'utf8' | \
                grep -E '^\|\||^@@\|\||^[a-zA-Z0-9.*-]*##|^[a-zA-Z0-9.*-]*#@#|^[a-zA-Z0-9.*-]*#\?#|^##|^#@#|^#\?#' | \
                grep -Ev "${exclude_pattern}" | \
                busybox sed 's|^[[:space:]]@@|@@|g' | \
                sort -u | \
                busybox sed '/^!/d;/^[[:space:]]*$/d'`
            echo "$new" > "${file}"
        fi
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

# 筛选 AdGuard 规则（支持 DNS 拦截 + 元素隐藏）
# 先转换各种格式，再提取有效规则
function sort_adguard_rules() {
    local output_folder="${1}"
    local file="${2}"
    local mode="${3:-full}"  # full=完整规则, dns=仅DNS拦截
    
    test ! -f "${file}" && return
    
    # 先将各种格式统一转换为 AdGuard 格式
    convert_all_formats_to_adguard "${file}"
    
    local IFS=$'\n'
    
    if test "${mode}" = "dns"; then
        # DNS模式：仅提取域名拦截规则
        local new=$(cat "${file}" | \
            grep -E '^\|\||^@@\|\|' | \
            grep -Ev '##|#\?#|#\$#|#%#|#@#' | \
            busybox sed -E 's/\$.*//g' | \
            busybox sed -E 's/\^\^/^/g' | \
            sort -u | \
            busybox sed '/^!/d;/^[[:space:]]*$/d')
    else
        # 完整模式：提取所有有效规则
        # 1. 域名拦截规则 (||domain.com^)
        # 2. 白名单规则 (@@||domain.com^)
        # 3. 元素隐藏规则 (##.class, domain.com##.class)
        # 4. 扩展CSS选择器 (#?#)
        # 5. 带修饰符的规则 (||domain^$third-party)
        local new=$(cat "${file}" | \
            grep -E '^\|\||^@@\|\||^[a-zA-Z0-9.*-]*##|^[a-zA-Z0-9.*-]*#@#|^[a-zA-Z0-9.*-]*#\?#|^##|^#@#|^#\?#' | \
            busybox sed -E 's/\^\^/^/g' | \
            sort -u | \
            busybox sed '/^!/d;/^[[:space:]]*$/d')
    fi
    
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
#   1. Hosts 格式: 0.0.0.0 domain.com / 127.0.0.1 domain.com
#   2. AdBlock 格式: ||domain.com^ / ||domain.com^$important
#   3. 纯域名格式: domain.com
#   4. 带点前缀: .domain.com
#   5. Clash/Surge 格式: DOMAIN,domain.com / DOMAIN-SUFFIX,domain.com
#   6. dnsmasq 格式: address=/domain.com/
#   7. 白名单格式: @@||domain.com^
function convert_all_formats_to_adguard(){
    local file="${1}"
    test ! -f "${file}" && return
    
    local temp_file="${file}.tmp"
    
    cat "${file}" | \
    # 移除注释行（支持 # ! ; // 开头）
    grep -Ev '^[[:space:]]*(#|!|;|\[|//)' | \
    # 移除空行
    grep -Ev '^[[:space:]]*$' | \
    # 移除 localhost 和本地回环地址行
    grep -Ev '^(0\.0\.0\.0|127\.0\.0\.1)[[:space:]]+(localhost|local|broadcasthost)' | \
    grep -Ev '^(::1|fe80|ff00|ff02)' | \
    # 移除行首行尾空格
    busybox sed -E 's/^[[:space:]]+//g; s/[[:space:]]+$//g' | \
    # 移除行尾注释
    busybox sed -E 's/[[:space:]]+#.*$//g' | \
    # === Hosts 格式转换 ===
    # 转换 hosts 格式: 0.0.0.0 domain.com 或 127.0.0.1 domain.com
    busybox sed -E 's/^(0\.0\.0\.0|127\.0\.0\.1)[[:space:]]+([^[:space:]]+).*/||\2^/g' | \
    # === AdBlock 格式处理 ===
    # 移除 AdBlock 修饰符 $xxx（如 $important, $badfilter 等）
    busybox sed -E 's/\$[a-zA-Z0-9,~_=-]+$//g' | \
    # === Clash/Surge 格式转换 ===
    # 转换 Clash DOMAIN 格式: DOMAIN,domain.com
    busybox sed -E 's/^DOMAIN,(.+)/||\1^/gi' | \
    # 转换 Clash DOMAIN-SUFFIX 格式: DOMAIN-SUFFIX,domain.com
    busybox sed -E 's/^DOMAIN-SUFFIX,(.+)/||\1^/gi' | \
    # 转换 Surge 格式: .domain.com
    busybox sed -E 's/^\.([a-zA-Z0-9])/||\1/g' | \
    # === dnsmasq 格式转换 ===
    # 转换 dnsmasq 格式: address=/domain.com/ 或 server=/domain.com/
    busybox sed -E 's/^(address|server)=\/([^\/]+)\/.*/||\2^/g' | \
    # === 纯域名格式转换 ===
    # 转换纯域名格式（没有任何前缀的有效域名）
    busybox sed -E '/^\|\|/!{ /^@@/!{ /^[a-zA-Z0-9][-a-zA-Z0-9]*\.[a-zA-Z0-9][-a-zA-Z0-9.]*[a-zA-Z]$/s/^(.+)$/||\1^/ } }' | \
    # === 格式规范化 ===
    # 确保 AdBlock 格式的规则以 ^ 结尾
    busybox sed -E '/^\|\|.*[^^]$/s/$/^/' | \
    busybox sed -E '/^@@\|\|.*[^^]$/s/$/^/' | \
    # 修复可能的双 ^ 问题
    busybox sed -E 's/\^\^+/^/g' | \
    # 移除域名中可能的端口号
    busybox sed -E 's/:[0-9]+\^/^/g' \
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

# 清理和优化 AdGuard 规则（支持 DNS + 元素隐藏）
function clean_adguard_rules(){
    local file="${1}"
    local mode="${2:-full}"  # full=完整规则, dns=仅DNS拦截
    test ! -f "${file}" && return
    
    echo "※`date +'%F %T'` 开始深度清理规则..."
    
    local temp_file="${file}.clean.tmp"
    
    if test "${mode}" = "dns"; then
        # DNS模式：仅保留域名拦截规则
        cat "${file}" | \
        busybox sed '/^!/d;/^[[:space:]]*$/d' | \
        busybox sed -E 's/^[[:space:]]+//g; s/[[:space:]]+$//g' | \
        grep -E '^\|\|[a-zA-Z0-9][-a-zA-Z0-9.]*\^$|^@@\|\|[a-zA-Z0-9][-a-zA-Z0-9.]*\^$' | \
        grep -Ev '^\|\|[0-9]+\^$' | \
        grep -Ev '^\|\|[a-zA-Z]\^$' | \
        grep -Ev '\|\|.*[_].*\^' | \
        grep -Ev '^\|\|[a-zA-Z0-9]{1,3}\.[a-zA-Z]{1,3}\^$' | \
        grep -Ev '\|\|.*\.(local|internal|test|example|invalid|localhost)\^' | \
        grep -Ev '\|\|([0-9]{1,3}\.){3}[0-9]{1,3}\^' | \
        sort -u > "${temp_file}"
    else
        # 完整模式：保留 DNS 规则 + 元素隐藏规则
        cat "${file}" | \
        busybox sed '/^!/d;/^[[:space:]]*$/d' | \
        busybox sed -E 's/^[[:space:]]+//g; s/[[:space:]]+$//g' | \
        # 保留有效规则：域名拦截、元素隐藏、扩展选择器
        grep -E '^\|\||^@@\|\||^[a-zA-Z0-9.*-]*##|^[a-zA-Z0-9.*-]*#@#|^[a-zA-Z0-9.*-]*#\?#|^##|^#@#|^#\?#' | \
        # 清理无效的域名拦截规则
        grep -Ev '^\|\|[0-9]+\^' | \
        grep -Ev '^\|\|[a-zA-Z]\^' | \
        grep -Ev '\|\|.*\.(local|internal|test|example|invalid|localhost)\^' | \
        grep -Ev '\|\|([0-9]{1,3}\.){3}[0-9]{1,3}\^' | \
        sort -u > "${temp_file}"
    fi
    
    mv "${temp_file}" "${file}"
    
    local count=$(cat "${file}" | wc -l)
    echo "※`date +'%F %T'` 规则清理完成，共 ${count} 条有效规则"
}

# 高级去重：移除冗余的子域名规则（高性能版本）
# 如果 ||example.com^ 存在，则 ||sub.example.com^ 是冗余的
# 使用 awk 进行高效处理，适合百万级规则
function remove_redundant_subdomains(){
    local file="${1}"
    test ! -f "${file}" && return
    
    echo "※`date +'%F %T'` 移除冗余子域名规则（高性能模式）..."
    
    local temp_file="${file}.dedup.tmp"
    local domains_file="${file}.domains.tmp"
    local parents_file="${file}.parents.tmp"
    local result_file="${file}.result.tmp"
    
    # 保留白名单规则（@@开头的）
    cat "${file}" | grep -E '^@@' > "${result_file}"
    
    # 提取所有被拦截的域名（不含 || 和 ^）并排序
    cat "${file}" | \
        grep -E '^\|\|' | \
        grep -Ev '^@@' | \
        busybox sed -E 's/^\|\|//g; s/\^$//g' | \
        sort -u > "${domains_file}"
    
    local total_count=$(wc -l < "${domains_file}")
    echo "※`date +'%F %T'` 共 ${total_count} 条域名待处理..."
    
    # 提取所有可能的父域名（二级及以上域名）
    # 例如: a.b.example.com -> b.example.com, example.com
    cat "${domains_file}" | \
        awk -F'.' '{
            # 生成所有可能的父域名
            for (i = 2; i <= NF; i++) {
                parent = ""
                for (j = i; j <= NF; j++) {
                    if (parent == "") {
                        parent = $j
                    } else {
                        parent = parent "." $j
                    }
                }
                if (parent ~ /\./) {
                    print parent
                }
            }
        }' | sort -u > "${parents_file}"
    
    # 找出同时存在于域名列表和父域名列表中的域名（即被拦截的父域名）
    local blocked_parents="${file}.blocked_parents.tmp"
    comm -12 "${domains_file}" "${parents_file}" > "${blocked_parents}"
    
    local blocked_count=$(wc -l < "${blocked_parents}")
    echo "※`date +'%F %T'` 发现 ${blocked_count} 个被拦截的父域名..."
    
    # 如果没有被拦截的父域名，直接使用原文件
    if [ "${blocked_count}" -eq 0 ]; then
        cat "${domains_file}" | busybox sed 's/^/||/; s/$/^/' >> "${result_file}"
    else
        # 使用 awk 高效过滤：移除其父域名已被拦截的子域名
        # 但保留包含广告关键词的子域名（用于区分广告和内容）
        cat "${domains_file}" | awk -v parents_file="${blocked_parents}" '
        BEGIN {
            # 读取所有被拦截的父域名到数组
            while ((getline parent < parents_file) > 0) {
                blocked[parent] = 1
            }
            close(parents_file)
        }
        {
            domain = $0
            is_redundant = 0
            
            # 检查是否包含广告关键词，如果是则保留（不标记为冗余）
            if (domain ~ /(^|\.)ad(s?)\.|banner|popup|track|analytics|stat|log|counter|pixel|beacon|impression|click|view|doubleclick|googlesyndication|adsystem|advertisement|affiliate|promotion|marketing|retargeting|remarketing/) {
                is_redundant = 0
            } else {
                # 逐级检查父域名
                n = split(domain, parts, ".")
                for (i = 2; i <= n; i++) {
                    parent = ""
                    for (j = i; j <= n; j++) {
                        if (parent == "") {
                            parent = parts[j]
                        } else {
                            parent = parent "." parts[j]
                        }
                    }
                    if (parent in blocked) {
                        is_redundant = 1
                        break
                    }
                }
            }
            
            if (!is_redundant) {
                print "||" domain "^"
            }
        }' >> "${result_file}"
    fi
    
    # 排序并去重
    cat "${result_file}" | sort -u > "${temp_file}"
    mv "${temp_file}" "${file}"
    
    # 清理临时文件
    rm -f "${domains_file}" "${parents_file}" "${blocked_parents}" "${result_file}"
    
    local final_count=$(wc -l < "${file}")
    local removed=$((total_count - final_count + $(cat "${file}" | grep -c '^@@' || echo 0)))
    echo "※`date +'%F %T'` 子域名去重完成！移除 ${removed} 条冗余规则，剩余 ${final_count} 条"
}

# 清理规则格式（规范化但保留有效语法）
function remove_unsupported_modifiers(){
    local file="${1}"
    test ! -f "${file}" && return
    
    # 仅清理 DNS 拦截规则的修饰符，保留元素隐藏规则完整性
    # DNS规则：移除部分不常用修饰符，保留常用的如 $third-party, $important
    busybox sed -i -E \
        -e '/^\|\|.*\^/{ s/\$badfilter//g; s/\$replace=.*//g; }' \
        -e 's/\^\^+/^/g' \
        "${file}"
    
    # 确保 DNS 拦截规则格式正确
    busybox sed -i -E \
        -e '/^\|\|[^#]*$/{ /\^/!s/$/^/ }' \
        -e '/^@@\|\|[^#]*$/{ /\^/!s/$/^/ }' \
        "${file}"
    
    echo "※`date +'%F %T'` 规则格式规范化完成"
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

# 规则格式化输出（分类整理：DNS拦截 + 元素隐藏）
function format_adguard_rules(){
    local file="${1}"
    test ! -f "${file}" && return
    
    # 分离不同类型的规则
    local whitelist_rules=$(cat "${file}" | grep -E '^@@\|\|' | sort -u)
    local domain_rules=$(cat "${file}" | grep -E '^\|\|' | grep -Ev '^@@' | sort -u)
    local element_hide_rules=$(cat "${file}" | grep -E '^[a-zA-Z0-9.*-]*##|^##' | sort -u)
    local element_whitelist=$(cat "${file}" | grep -E '^[a-zA-Z0-9.*-]*#@#|^#@#' | sort -u)
    local extended_css=$(cat "${file}" | grep -E '^[a-zA-Z0-9.*-]*#\?#|^#\?#' | sort -u)
    
    # 输出：按类型分组，便于管理
    {
        # DNS白名单规则
        if [ -n "${whitelist_rules}" ]; then
            echo "${whitelist_rules}"
        fi
        # DNS拦截规则
        if [ -n "${domain_rules}" ]; then
            echo "${domain_rules}"
        fi
        # 元素隐藏白名单
        if [ -n "${element_whitelist}" ]; then
            echo "${element_whitelist}"
        fi
        # 元素隐藏规则
        if [ -n "${element_hide_rules}" ]; then
            echo "${element_hide_rules}"
        fi
        # 扩展CSS选择器
        if [ -n "${extended_css}" ]; then
            echo "${extended_css}"
        fi
    } > "${file}"
    
    local total=$(cat "${file}" | wc -l)
    local dns_count=$(echo "${domain_rules}${whitelist_rules}" | grep -c '.' || echo 0)
    local element_count=$(echo "${element_hide_rules}${element_whitelist}${extended_css}" | grep -c '.' || echo 0)
    echo "※`date +'%F %T'` 格式化完成，共 ${total} 条规则（DNS拦截: ${dns_count}, 元素隐藏: ${element_count}）"
}

# 更新 README 信息
function update_README_info(){
    local file="`pwd`/README.md"
    test -f "${file}" && rm -rf "${file}"
    
    cat << EOF > "${file}"
# Ads-block
# 源码参考自https://github.com/lingeringsound/adblock_auto/
### 🚀 强力广告拦截规则集 - 自动更新(`date +'%F %T'`)

**精选 4 个高质量规则源，支持 AdBlock 和 Hosts 格式**

## 订阅链接

| 名称 | GitHub 订阅链接 | GitHub 加速订阅链接 |
| :-- | :-- | :-- |
| AdGuard Home 规则 | [订阅](https://raw.githubusercontent.com/existyay/Ads-block/refs/heads/main/Rules/adblock_auto.txt) | [订阅](https://raw.gitmirror.com/existyay/Ads-block/refs/heads/main/Rules/adblock_auto.txt)

## 上游规则源

感谢以下规则源提供者 ❤️

<details>
<summary>点击查看上游规则</summary>
<ul>
<li><strong>核心规则</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/AWAvenue-Ads-Rule.txt" target="_blank">AWAvenue 秋风广告规则</a> - 精简高效的国产 App 开屏广告拦截</li>
</ul>

<li><strong>移动端广告拦截</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_11_Mobile/filter.txt" target="_blank">AdGuard Mobile Ads Filter</a> - 移动端广告专用规则（含元素隐藏）</li>
<li><a href="https://raw.githubusercontent.com/jk278/Ad-J/main/Ad-J.txt" target="_blank">大圣净化 Ad-J</a> - 国产 App 广告净化</li>
<li><a href="https://raw.githubusercontent.com/Noyllopa/NoAppDownload/master/NoAppDownload.txt" target="_blank">NoAppDownload</a> - 应用下载提示拦截</li>
</ul>

<li><strong>追踪拦截规则</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt" target="_blank">AdGuard Tracking Protection</a> - 追踪保护规则</li>
<li><a href="https://easylist.to/easylist/easyprivacy.txt" target="_blank">EasyPrivacy</a> - 隐私保护规则</li>
</ul>

<li><strong>Hosts 格式规则</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" target="_blank">StevenBlack Hosts</a> - 统一多源的 hosts 广告拦截</li>
</ul>

<li><strong>元素隐藏规则</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_224_Chinese/filter.txt" target="_blank">AdGuard Chinese Filter</a> - 中文网站元素隐藏</li>
</ul>

<li><strong>安全威胁</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareAdGuardHome.txt" target="_blank">DandelionSprout Anti-Malware</a> - 恶意软件拦截</li>
</ul>
</ul>
</details>


## 使用说明

### 在 AdGuard Home 中使用

1. 在 AdGuard Home 管理界面进入「过滤器」>「DNS 封锁清单」
2. 添加自定义过滤器
3. 粘贴上方的订阅链接
4. 保存并更新

## 支持的规则格式

本项目支持以下输入格式，自动转换为 AdGuard 标准格式：

| 格式类型 | 示例 | 作用 |
| :-- | :-- | :-- |
| **DNS 拦截** | \`\|\|example.com^\` | 拦截整个域名 |
| **Hosts** | \`0.0.0.0 example.com\` | 转换为 DNS 拦截 |
| **元素隐藏** | \`##.ad-banner\` | 隐藏页面广告元素 |
| **特定域名元素隐藏** | \`example.com##.ad\` | 仅在指定域名隐藏 |
| **扩展CSS选择器** | \`#?#div:has(.ad)\` | 高级元素匹配 |
| **带修饰符规则** | \`\|\|ad.com^\$third-party\` | 条件拦截 |
| **Clash/Surge** | \`DOMAIN,example.com\` | 转换为 DNS 拦截 |
| **dnsmasq** | \`address=/example.com/\` | 转换为 DNS 拦截 |

### 规则类型说明

- **DNS 拦截规则** - 适用于 AdGuard Home、AdGuard DNS 等 DNS 级拦截
- **元素隐藏规则** - 需要 AdGuard 客户端或浏览器扩展（可精准隐藏页面元素而不影响域名访问）

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=existyay/Ads-block&type=Date)](https://star-history.com/#existyay/Ads-block&Date)

---

**注意**: 本规则集为标准 \`||domain^\` 格式的 DNS 拦截规则，专为 AdGuard Home 优化。

⚠️ **重要提示**：DNS 拦截能力有限，无法 100% 拦截所有开屏/弹窗广告。如需更强效果，建议：
- Android：安装 AdGuard 客户端或使用 Magisk 模块（如 AdAway）
- iOS：安装 AdGuard Pro 或使用 Quantumult X 等工具
- 使用支持 SSL 拦截的方案可获得最佳效果
EOF
}