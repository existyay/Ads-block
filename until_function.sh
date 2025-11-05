#!/bin/sh
export PATH="`pwd`:${PATH}"

# 下载规则文件
function download_link(){
    local IFS=$'\n'
    local target_dir="${1}"
    test "${target_dir}" = "" && target_dir="`pwd`/temple/download_Rules"
    mkdir -p "${target_dir}"

    # 仅保留适合 AdGuard Home 的规则源
    local list='
https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockdns.txt|adblockdns.txt
https://adguardteam.github.io/HostlistsRegistry/assets/filter_21.txt|Adguard_filter_21.txt
https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts|ad-wars_hosts.txt
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
! Description: ${Description} (AdGuard Home 专用)
! Homepage: https://github.com/existyay/Ads-block

EOF
    echo "${original_file}" >> "${file}"
    perl "`pwd`/addchecksum.pl" "${file}" 2>/dev/null
}

# 净化规则 - 仅保留 AdGuard Home 支持的格式
function modtify_adblock_original_file() {
    local file="${1}"
    local exclude_pattern="${2}"
    
    # 过滤规则：
    # - 移除 CSS 选择器 (##, #?#, #$#, #%# 等)
    # - 移除 JavaScript 注入规则
    # - 移除高级修饰符 (AdGuard Home 不支持的)
    # - 仅保留域名规则和基本修饰符
    if test "${exclude_pattern}" = ""; then
        local new=`cat "${file}" | \
            iconv -t 'utf8' | \
            grep -Ev '^##|^#\?#|^#\$#|^#\%#|^#@#|^\$\$|^#@\?#|^\$@\$|##\+js\(|#%#//scriptlet|redirect=|removeparam=|:has\(|:has-text\(|:matches-css|:xpath\(' | \
            grep -E '^\|\||^@@\|\||^[0-9]|^!' | \
            busybox sed 's|^[[:space:]]@@|@@|g' | \
            sort -u | \
            busybox sed '/^!/d;/^[[:space:]]*$/d'`
        echo "$new" > "${file}"
    else
        local new=`cat "${file}" | \
            iconv -t 'utf8' | \
            grep -Ev '^##|^#\?#|^#\$#|^#\%#|^#@#|^\$\$|^#@\?#|^\$@\$|##\+js\(|#%#//scriptlet|redirect=|removeparam=|:has\(|:has-text\(|:matches-css|:xpath\(' | \
            grep -E '^\|\||^@@\|\||^[0-9]|^!' | \
            grep -Ev "${exclude_pattern}" | \
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

# 筛选 AdGuard Home 兼容的规则
function sort_adguard_rules() {
    local output_folder="${1}"
    local file="${2}"
    
    test ! -f "${file}" && return
    
    local IFS=$'\n'
    # 仅提取域名格式规则和白名单规则
    local new=$(cat "${file}" | \
        grep -E '^\|\||^@@\|\|' | \
        grep -Ev '##|#\?#|#\$#|#%#|\$\$|redirect=|removeparam=' | \
        sort -u | \
        busybox sed '/^!/d;/^[[:space:]]*$/d')
    
    mkdir -p "${output_folder}"
    echo "$new" > "${output_folder}/${file##*/}"
}

# 添加规则到已存在的文件
function add_adguard_rules() {
    local output_folder="${1}"
    local file="${2}"
    
    test ! -f "${file}" && return
    
    local IFS=$'\n'
    local new=$(cat "${file}" | \
        grep -E '^\|\||^@@\|\|' | \
        grep -Ev '##|#\?#|#\$#|#%#|\$\$|redirect=|removeparam=' | \
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

# 清理和优化 AdGuard Home 规则
function clean_adguard_rules(){
    local file="${1}"
    test ! -f "${file}" && return
    
    # 去重并排序
    local cleaned=$(cat "${file}" | \
        busybox sed '/^!/d;/^[[:space:]]*$/d' | \
        sort -u)
    
    echo "${cleaned}" > "${file}"
    echo "※`date +'%F %T'` 规则清理完成，共 $(echo "${cleaned}" | wc -l) 条"
}

# 移除 AdGuard Home 不支持的修饰符
function remove_unsupported_modifiers(){
    local file="${1}"
    test ! -f "${file}" && return
    
    # AdGuard Home 支持的修饰符有限，移除不支持的
    busybox sed -i -E \
        -e 's/\$badfilter//g' \
        -e 's/,badfilter//g' \
        -e 's/\$empty//g' \
        -e 's/,empty//g' \
        -e 's/\$mp4//g' \
        -e 's/,mp4//g' \
        -e 's/\$generichide//g' \
        -e 's/,generichide//g' \
        -e 's/\$genericblock//g' \
        -e 's/,genericblock//g' \
        -e 's/\$elemhide//g' \
        -e 's/,elemhide//g' \
        -e 's/\$\$//g' \
        -e '/redirect=/d' \
        -e '/removeparam=/d' \
        -e '/replace=/d' \
        -e '/csp=/d' \
        "${file}"
    
    # 清理可能产生的多余逗号和美元符号
    busybox sed -i -E \
        -e 's/,+/,/g' \
        -e 's/\$,/\$/g' \
        -e 's/,\$/\$/g' \
        -e 's/\$\$$/\$/g' \
        -e 's/\^\$\$/\^\$/g' \
        "${file}"
}

# 规则分类和格式化输出
function format_adguard_rules(){
    local file="${1}"
    test ! -f "${file}" && return
    
    local domain_rules=$(cat "${file}" | grep -E '^\|\|' | sort -u)
    local whitelist_rules=$(cat "${file}" | grep -E '^@@' | sort -u)
    local domain_count=$(echo "${domain_rules}" | grep -c '^')
    local whitelist_count=$(echo "${whitelist_rules}" | grep -c '^')
    
    cat << EOF > "${file}"
! ===== 域名拦截规则 (共 ${domain_count} 条) =====
${domain_rules}

! ===== 白名单规则 (共 ${whitelist_count} 条) =====
${whitelist_rules}
EOF
}

# 更新 README 信息
function update_README_info(){
    local file="`pwd`/README.md"
    test -f "${file}" && rm -rf "${file}"
    
    cat << EOF > "${file}"
# Ads-block
### AdGuard Home 专用规则 - 自动更新(`date +'%F %T'`)

本项目专为 AdGuard Home 优化，仅包含域名拦截规则，确保最佳性能和兼容性。

## 订阅链接

| 名称 | GitHub 订阅链接 | GitHub 加速订阅链接 |
| :-- | :-- | :-- |
| AdGuard Home 规则 | [订阅](https://raw.githubusercontent.com/existyay/Ads-block/refs/heads/main/Rules/adblock_auto.txt) | [订阅](https://raw.gitmirror.com/existyay/Ads-block/refs/heads/main/Rules/adblock_auto.txt)

## 特性

- ✅ 仅包含 AdGuard Home 完全兼容的规则
- ✅ 域名拦截规则 (\`||domain.com^\`)
- ✅ 白名单规则 (\`@@||domain.com^\`)
- ✅ 基本修饰符支持 (\`\$important\`, \`\$third-party\` 等)
- ❌ 不包含 CSS 选择器
- ❌ 不包含 JavaScript 注入
- ❌ 不包含复杂的正则表达式

## 上游规则源

感谢以下规则源提供者 ❤️

<details>
<summary>点击查看上游规则</summary>
<ul>
<li> <a href="https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockdns.txt" target="_blank">adblockdns</a> - DNS 拦截规则</li>
<li> <a href="https://adguardteam.github.io/HostlistsRegistry/assets/filter_21.txt" target="_blank">anti-AD</a> - AdGuard 官方维护的中文广告过滤列表</li>
<li> <a href="https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts" target="_blank">ad-wars</a> - hosts 格式规则（已转换）</li>
</ul>
</details>

## 使用说明

1. 在 AdGuard Home 管理界面进入「过滤器」>「DNS 封锁清单」
2. 添加自定义过滤器
3. 粘贴上方的订阅链接
4. 保存并更新

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=existyay/Ads-block&type=Date)](https://star-history.com/#existyay/Ads-block&Date)

---

**注意**: 本规则集已针对 AdGuard Home 进行优化，不再兼容浏览器扩展（如 uBlock Origin、AdBlock Plus）。
EOF
}