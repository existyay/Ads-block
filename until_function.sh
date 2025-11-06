#!/bin/sh
export PATH="`pwd`:${PATH}"

# 下载规则文件
function download_link(){
    local IFS=$'\n'
    local target_dir="${1}"
    test "${target_dir}" = "" && target_dir="`pwd`/temple/download_Rules"
    mkdir -p "${target_dir}"

    # 强力广告拦截规则源 - 覆盖手机端、PC端、各类网站
    local list='
# === 核心规则集 - 必备 ===
https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockdns.txt|adblockdns.txt
https://adguardteam.github.io/HostlistsRegistry/assets/filter_21.txt|Adguard_filter_21.txt
https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts|ad-wars_hosts.txt

# === 中文规则 - 强力拦截 ===
https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/ABP.txt|xinggsf_ABP.txt
https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/mv.txt|xinggsf_mv.txt
https://raw.githubusercontent.com/Noyllopa/NoAppDownload/master/NoAppDownload.txt|NoAppDownload.txt
https://raw.githubusercontent.com/jk278/Ad-J/main/Ad-J.txt|Ad-J.txt
https://raw.githubusercontent.com/damengzhu/banad/main/jiekouAd.txt|jiekouAd.txt

# === 国际规则 - EasyList 系列 ===
https://easylist-downloads.adblockplus.org/easylist.txt|easylist.txt
https://easylist-downloads.adblockplus.org/easylistchina.txt|easylistchina.txt
https://easylist-downloads.adblockplus.org/easyprivacy.txt|easyprivacy.txt
https://secure.fanboy.co.nz/fanboy-annoyance.txt|fanboy-annoyance.txt

# === 移动端优化 ===
https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt|hagezi_pro.txt
https://raw.githubusercontent.com/Cats-Team/AdRules/main/adguard_mobile.txt|adguard_mobile.txt

# === AdGuard 官方规则集 ===
https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt|Adguard_Base.txt
https://adguardteam.github.io/HostlistsRegistry/assets/filter_3.txt|Adguard_Tracking.txt
https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt|Adguard_Social.txt
https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt|Adguard_Mobile.txt
https://adguardteam.github.io/HostlistsRegistry/assets/filter_17.txt|Adguard_Annoyances.txt

# === 视频网站专用 ===
https://raw.githubusercontent.com/Silentely/AdBlock-Acceleration/master/AdGuard_Simplified_Domain.txt|video_ads.txt
https://raw.githubusercontent.com/o0HalfLife0o/list/master/ad.txt|halflife_ad.txt

# === 隐私保护 ===
https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt|windows_spy.txt
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

# 净化规则 - 保留 AdGuard Home 支持的所有格式（包含高级语法）
function modtify_adblock_original_file() {
    local file="${1}"
    local exclude_pattern="${2}"
    
    # AdGuard Home 支持的完整规则格式：
    # ✅ ||domain.com^ - 域名拦截
    # ✅ @@||domain.com^ - 白名单
    # ✅ domain.com##selector - 元素隐藏（基本 CSS 选择器）
    # ✅ domain.com#?#selector - 扩展 CSS 选择器（:has, :has-text, :matches-css 等）
    # ✅ domain.com#$#script - JavaScript 注入
    # ✅ domain.com#%#//scriptlet - Scriptlet 注入
    # ✅ ##selector - 通用规则
    # ✅ $redirect= - 重定向规则
    # ✅ $removeparam= - 移除 URL 参数
    
    if test "${exclude_pattern}" = ""; then
        local new=`cat "${file}" | \
            iconv -t 'utf8' | \
            grep -E '^\|\||^@@\|\||^[a-zA-Z0-9].*##|^[a-zA-Z0-9].*#\?#|^[a-zA-Z0-9].*#\$#|^[a-zA-Z0-9].*#%#|^##|^#\?#|^#\$#|^#%#|^[0-9]|^!|^~' | \
            busybox sed 's|^[[:space:]]@@|@@|g' | \
            sort -u | \
            busybox sed '/^!/d;/^[[:space:]]*$/d'`
        echo "$new" > "${file}"
    else
        local new=`cat "${file}" | \
            iconv -t 'utf8' | \
            grep -E '^\|\||^@@\|\||^[a-zA-Z0-9].*##|^[a-zA-Z0-9].*#\?#|^[a-zA-Z0-9].*#\$#|^[a-zA-Z0-9].*#%#|^##|^#\?#|^#\$#|^#%#|^[0-9]|^!|^~' | \
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

# 筛选 AdGuard Home 兼容的规则（包含所有高级语法）
function sort_adguard_rules() {
    local output_folder="${1}"
    local file="${2}"
    
    test ! -f "${file}" && return
    
    local IFS=$'\n'
    # 提取 AdGuard Home 支持的所有规则格式：
    # 1. 域名格式规则 (||domain.com^)
    # 2. 白名单规则 (@@||domain.com^)
    # 3. 元素隐藏规则 (domain.com##selector 或 ##selector)
    # 4. 扩展 CSS 规则 (domain.com#?#selector)
    # 5. JavaScript 注入 (domain.com#$#script)
    # 6. Scriptlet 注入 (domain.com#%#//scriptlet)
    # 7. 所有修饰符（$popup, $document, $redirect, $removeparam 等）
    local new=$(cat "${file}" | \
        grep -E '^\|\||^@@\|\||^[a-zA-Z0-9].*##|^[a-zA-Z0-9].*#\?#|^[a-zA-Z0-9].*#\$#|^[a-zA-Z0-9].*#%#|^##|^#\?#|^#\$#|^#%#|^~' | \
        sort -u | \
        busybox sed '/^!/d;/^[[:space:]]*$/d')
    
    mkdir -p "${output_folder}"
    echo "$new" > "${output_folder}/${file##*/}"
}

# 添加规则到已存在的文件（包含所有高级语法）
function add_adguard_rules() {
    local output_folder="${1}"
    local file="${2}"
    
    test ! -f "${file}" && return
    
    local IFS=$'\n'
    local new=$(cat "${file}" | \
        grep -E '^\|\||^@@\|\||^[a-zA-Z0-9].*##|^[a-zA-Z0-9].*#\?#|^[a-zA-Z0-9].*#\$#|^[a-zA-Z0-9].*#%#|^##|^#\?#|^#\$#|^#%#|^~' | \
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

# 移除 AdGuard Home 不支持的修饰符（保留所有支持的高级功能）
function remove_unsupported_modifiers(){
    local file="${1}"
    test ! -f "${file}" && return
    
    # AdGuard Home 支持的修饰符（保留）：
    # ✅ $popup, $document - 弹窗拦截
    # ✅ $third-party - 第三方请求
    # ✅ $script, $image, $stylesheet, $media, $font - 资源类型
    # ✅ $important - 重要规则优先
    # ✅ $redirect - 重定向
    # ✅ $removeparam - 移除参数
    # ✅ $csp - 内容安全策略
    # ✅ $all - 所有类型
    # ❌ 仅移除真正不支持的修饰符
    busybox sed -i -E \
        -e 's/\$badfilter//g' \
        -e 's/,badfilter//g' \
        -e 's/\$empty//g' \
        -e 's/,empty//g' \
        -e 's/\$mp4//g' \
        -e 's/,mp4//g' \
        "${file}"
    
    # 清理可能产生的多余逗号和美元符号
    busybox sed -i -E \
        -e 's/,+/,/g' \
        -e 's/\$,/\$/g' \
        -e 's/,\$/\$/g' \
        -e 's/\$\$+/\$/g' \
        -e 's/\^\$\$/\^\$/g' \
        "${file}"
    
    echo "※`date +'%F %T'` 保留所有 AdGuard Home 支持的高级语法和修饰符"
}

# 提取弹窗拦截规则
function extract_popup_rules(){
    local file="${1}"
    local output_file="${2}"
    
    test ! -f "${file}" && return
    
    # 提取包含 $popup 或 $document 的规则
    local popup_rules=$(cat "${file}" | \
        grep -E '^\|\||^@@\|\|' | \
        grep -E '\$.*popup|\$.*document' | \
        grep -Ev '##|#\?#|#\$#|redirect=' | \
        sort -u)
    
    if [ ! -z "${popup_rules}" ]; then
        echo "${popup_rules}" >> "${output_file}"
        echo "※`date +'%F %T'` 提取到 $(echo "${popup_rules}" | wc -l) 条弹窗拦截规则"
    fi
}

# 规则分类和格式化输出（支持所有高级语法）
function format_adguard_rules(){
    local file="${1}"
    test ! -f "${file}" && return
    
    # 分类规则
    local js_rules=$(cat "${file}" | grep -E '#\$#|#%#' | sort -u)
    local extended_css_rules=$(cat "${file}" | grep -E '#\?#' | sort -u)
    local element_hiding_rules=$(cat "${file}" | grep -E '##' | grep -Ev '^\|\||#\?#|#\$#|#%#' | sort -u)
    local popup_rules=$(cat "${file}" | grep -E '^\|\|.*\$(popup|document)' | sort -u)
    local domain_rules=$(cat "${file}" | grep -E '^\|\|' | grep -Ev '\$(popup|document)|##|#\?#|#\$#|#%#' | sort -u)
    local whitelist_rules=$(cat "${file}" | grep -E '^@@' | sort -u)
    
    local js_count=$(echo "${js_rules}" | grep -c '^' || echo "0")
    local extended_count=$(echo "${extended_css_rules}" | grep -c '^' || echo "0")
    local element_count=$(echo "${element_hiding_rules}" | grep -c '^' || echo "0")
    local popup_count=$(echo "${popup_rules}" | grep -c '^' || echo "0")
    local domain_count=$(echo "${domain_rules}" | grep -c '^' || echo "0")
    local whitelist_count=$(echo "${whitelist_rules}" | grep -c '^' || echo "0")
    
    cat << EOF > "${file}"
! ===== JavaScript / Scriptlet 注入规则 (共 ${js_count} 条) =====
! 注入脚本以拦截或修改页面行为
${js_rules}

! ===== 扩展 CSS 选择器规则 (共 ${extended_count} 条) =====
! 使用高级选择器（:has, :has-text, :matches-css 等）
${extended_css_rules}

! ===== 元素隐藏规则 (共 ${element_count} 条) =====
! 隐藏网页中的广告元素（基本 CSS 选择器）
${element_hiding_rules}

! ===== 弹窗拦截规则 (共 ${popup_count} 条) =====
! 专门拦截手机端和网页弹窗广告
${popup_rules}

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
# (参考并感谢作者https://github.com/lingeringsound/adblock_auto/)
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

**注意**: 本规则集包含 AdGuard Home 的完整高级语法，包括 JavaScript 注入、Scriptlet、扩展 CSS 等。同时也兼容 uBlock Origin 和 AdGuard 浏览器扩展。
EOF
}