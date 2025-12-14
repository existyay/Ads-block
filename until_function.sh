#!/bin/sh
export PATH="`pwd`:${PATH}"

# 下载规则文件
function download_link(){
    local IFS=$'\n'
    local target_dir="${1}"
    test "${target_dir}" = "" && target_dir="`pwd`/temple/download_Rules"
    mkdir -p "${target_dir}"

    # 精简高效版 - 基于 AWAvenue 高质量规则 + 优秀补充源
    # 涵盖追踪、隐私、安全、钓鱼、国内App广告
    local list='
# === AWAvenue 秋风广告规则（核心，精简高效）===
# 主规则：专注国产 App 开屏广告，规则精简命中率高
https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/AWAvenue-Ads-Rule.txt|AWAvenue_main.txt

# === AWAvenue 补充规则（可选激进拦截）===
# 补充规则：更激进的拦截，包含详细说明
https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/Filters/AWAvenue-Ads-Rule-Replenish.txt|AWAvenue_replenish.txt

# === 其他高质量规则源 ===
# hacamer adblock_lite: 精简广告拦截规则
https://bitbucket.org/hacamer/adrules/raw/main/adblock_lite.txt|hacamer_lite.txt
# lemon399 abpmerge: ABP格式合并规则
https://gitea.com/lemon399/AdRules/raw/branch/main/abpmerge.txt|lemon399_abpmerge.txt

# 大圣净化规则：专注国产 App 广告
https://raw.githubusercontent.com/jk278/Ad-J/main/Ad-J.txt|Ad-J.txt
# NoAppDownload: 应用下载提示拦截（CDN加速版）
https://gcore.jsdelivr.net/gh/Noyllopa/NoAppDownload@master/NoAppDownload.txt|NoAppDownload_cdn.txt

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
    # 移除过短的域名（少于4字符的有效部分）
    grep -Ev '^\|\|[a-zA-Z0-9]{1,3}\.[a-zA-Z]{1,3}\^$' | \
    # 移除明显无效的顶级域名（保留常见有效TLD）
    grep -Ev '\|\|.*\.(local|internal|test|example|invalid|localhost)\^' | \
    # 移除纯IP地址格式（如果有）
    grep -Ev '\|\|([0-9]{1,3}\.){3}[0-9]{1,3}\^' | \
    # 排序去重
    sort -u \
    > "${temp_file}"
    
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

**涵盖 8 优秀规则源，精简高效规则集**

## 订阅链接

| 名称 | GitHub 订阅链接 | GitHub 加速订阅链接 |
| :-- | :-- | :-- |
| AdGuard Home 规则 | [订阅](https://raw.githubusercontent.com/existyay/Ads-block/refs/heads/main/Rules/adblock_auto.txt) | [订阅](https://raw.gitmirror.com/existyay/Ads-block/refs/heads/main/Rules/adblock_auto.txt)

## 上游规则源

感谢以下规则源提供者 ❤️

<details>
<summary>点击查看上游规则</summary>
<ul>
<li><strong>AWAvenue 秋风广告规则（核心）</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/AWAvenue-Ads-Rule.txt" target="_blank">AWAvenue 主规则</a> - 精简高效的国产 App 开屏广告拦截</li>
<li><a href="https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/Filters/AWAvenue-Ads-Rule-Replenish.txt" target="_blank">AWAvenue 补充规则</a> - 更激进的拦截补充</li>
</ul>

<li><strong>其他高质量规则源</strong></li>
<ul>
<li><a href="https://bitbucket.org/hacamer/adrules/raw/main/adblock_lite.txt" target="_blank">hacamer adblock_lite</a> - 精简广告拦截规则</li>
<li><a href="https://gitea.com/lemon399/AdRules/raw/branch/main/abpmerge.txt" target="_blank">lemon399 abpmerge</a> - ABP格式合并规则</li>
</ul>

<li><strong>国内手机App广告</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/Cats-Team/AdRules/main/adguard_mobile.txt" target="_blank">CatsTeam Mobile</a> - 移动端广告拦截</li>
<li><a href="https://raw.githubusercontent.com/jk278/Ad-J/main/Ad-J.txt" target="_blank">Ad-J</a> - 国产 App 广告净化</li>
<li><a href="https://gcore.jsdelivr.net/gh/Noyllopa/NoAppDownload@master/NoAppDownload.txt" target="_blank">NoAppDownload (CDN)</a> - 应用下载提示拦截</li>
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