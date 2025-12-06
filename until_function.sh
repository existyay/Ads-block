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
# Android/iOS 原生追踪器（独立规则，不重复）
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/native.android.txt|hagezi_android_native.txt
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/native.apple.txt|hagezi_apple_native.txt

# === 中国特色广告拦截 ===
# 秋风广告规则：专注国产 App 开屏广告
https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Adblock-Rule/main/AWAvenue-Adblock-Rule.txt|AWAvenue.txt
# ad-wars: hosts 格式的中文广告规则
https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts|ad-wars_hosts.txt
# 接口广告规则：API 层面的广告拦截
https://raw.githubusercontent.com/damengzhu/banad/main/jiekouAd.txt|jiekouAd.txt
# NoAppDownload: 拦截"下载 App"弹窗
https://raw.githubusercontent.com/Noyllopa/NoAppDownload/master/NoAppDownload.txt|NoAppDownload.txt
# ADgk: 开屏广告专用规则
https://raw.githubusercontent.com/banbendalao/ADgk/master/ADgk.txt|ADgk_splash.txt

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
function sort_adguard_rules() {
    local output_folder="${1}"
    local file="${2}"
    
    test ! -f "${file}" && return
    
    local IFS=$'\n'
    # 仅提取标准 DNS 拦截规则格式：
    # 1. 域名拦截规则 (||domain.com^)
    # 2. 白名单规则 (@@||domain.com^)
    # 排除所有浏览器扩展语法（##, #?#, #$#, #%# 等）
    local new=$(cat "${file}" | \
        grep -E '^\|\||^@@\|\|' | \
        grep -Ev '##|#\?#|#\$#|#%#' | \
        busybox sed -E 's/\$.*//g' | \
        busybox sed -E 's/\^$/\^/g' | \
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

# 规则格式化输出（仅 ||domain^ 标准格式）
function format_adguard_rules(){
    local file="${1}"
    test ! -f "${file}" && return
    
    # 分类规则（仅域名拦截和白名单）
    local domain_rules=$(cat "${file}" | grep -E '^\|\|' | sort -u)
    local whitelist_rules=$(cat "${file}" | grep -E '^@@' | sort -u)
    
    local domain_count=$(echo "${domain_rules}" | grep -c '^' || echo "0")
    local whitelist_count=$(echo "${whitelist_rules}" | grep -c '^' || echo "0")
    
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