#!/bin/sh
export PATH="`pwd`:${PATH}"

# 下载规则文件
function download_link(){
    local IFS=$'\n'
    local target_dir="${1}"
    test "${target_dir}" = "" && target_dir="`pwd`/temple/download_Rules"
    mkdir -p "${target_dir}"

    # AdGuard Home 规则源（包含弹窗拦截和元素隐藏）
    local list='
https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockdns.txt|adblockdns.txt
https://adguardteam.github.io/HostlistsRegistry/assets/filter_21.txt|Adguard_filter_21.txt
https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts|ad-wars_hosts.txt
https://easylist-downloads.adblockplus.org/easylist.txt|easylist.txt
https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/mv.txt|mv.txt
https://raw.githubusercontent.com/Noyllopa/NoAppDownload/master/NoAppDownload.txt|NoAppDownload.txt
https://raw.githubusercontent.com/jk278/Ad-J/main/Ad-J.txt|Ad-J.txt
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

# 净化规则 - 保留 AdGuard Home 支持的格式
function modtify_adblock_original_file() {
    local file="${1}"
    local exclude_pattern="${2}"
    
    # AdGuard Home 支持的规则格式：
    # ✅ ||domain.com^ - 域名拦截
    # ✅ @@||domain.com^ - 白名单
    # ✅ domain.com##selector - 元素隐藏（基本 CSS 选择器）
    # ✅ ##selector - 通用元素隐藏
    # ❌ #?# - 扩展 CSS（不支持 :has, :has-text 等）
    # ❌ #$# - JavaScript 注入
    # ❌ #%# - Scriptlet 注入
    
    if test "${exclude_pattern}" = ""; then
        local new=`cat "${file}" | \
            iconv -t 'utf8' | \
            grep -Ev '^#\?#|^#\$#|^#\%#|^\$\$|^#@\?#|^\$@\$|^#@\$#|##\+js\(|#%#//scriptlet|#\$#//scriptlet|redirect=|removeparam=|:has\(|:has-text\(|:matches-css|:matches-css-before|:matches-css-after|:xpath\(|:nth-ancestor\(|:upward\(|:remove\(|:style\(' | \
            grep -E '^\|\||^@@\|\||^[a-zA-Z0-9].*##|^##|^[0-9]|^!' | \
            busybox sed 's|^[[:space:]]@@|@@|g' | \
            sort -u | \
            busybox sed '/^!/d;/^[[:space:]]*$/d'`
        echo "$new" > "${file}"
    else
        local new=`cat "${file}" | \
            iconv -t 'utf8' | \
            grep -Ev '^#\?#|^#\$#|^#\%#|^\$\$|^#@\?#|^\$@\$|^#@\$#|##\+js\(|#%#//scriptlet|#\$#//scriptlet|redirect=|removeparam=|:has\(|:has-text\(|:matches-css|:matches-css-before|:matches-css-after|:xpath\(|:nth-ancestor\(|:upward\(|:remove\(|:style\(' | \
            grep -E '^\|\||^@@\|\||^[a-zA-Z0-9].*##|^##|^[0-9]|^!' | \
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

# 筛选 AdGuard Home 兼容的规则（包含元素隐藏和弹窗拦截）
function sort_adguard_rules() {
    local output_folder="${1}"
    local file="${2}"
    
    test ! -f "${file}" && return
    
    local IFS=$'\n'
    # 提取 AdGuard Home 支持的规则：
    # 1. 域名格式规则 (||domain.com^)
    # 2. 白名单规则 (@@||domain.com^)
    # 3. 元素隐藏规则 (domain.com##selector 或 ##selector)
    # 4. 保留 $popup 和 $document 修饰符用于弹窗拦截
    # 排除：扩展CSS、JS注入、Scriptlet等
    local new=$(cat "${file}" | \
        grep -E '^\|\||^@@\|\||^[a-zA-Z0-9].*##|^##' | \
        grep -Ev '#\?#|#\$#|#\%#|\$\$|##\+js\(|#%#//scriptlet|#\$#//scriptlet|redirect=|removeparam=|:has\(|:has-text\(|:matches-css|:xpath\(|:nth-ancestor\(|:upward\(|:remove\(|:style\(' | \
        sort -u | \
        busybox sed '/^!/d;/^[[:space:]]*$/d')
    
    mkdir -p "${output_folder}"
    echo "$new" > "${output_folder}/${file##*/}"
}

# 添加规则到已存在的文件（包含元素隐藏和弹窗拦截）
function add_adguard_rules() {
    local output_folder="${1}"
    local file="${2}"
    
    test ! -f "${file}" && return
    
    local IFS=$'\n'
    local new=$(cat "${file}" | \
        grep -E '^\|\||^@@\|\||^[a-zA-Z0-9].*##|^##' | \
        grep -Ev '#\?#|#\$#|#\%#|\$\$|##\+js\(|#%#//scriptlet|redirect=|removeparam=|:has\(|:has-text\(|:matches-css|:xpath\(' | \
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

# 移除 AdGuard Home 不支持的修饰符（保留弹窗拦截相关）
function remove_unsupported_modifiers(){
    local file="${1}"
    test ! -f "${file}" && return
    
    # AdGuard Home 支持的修饰符：
    # ✅ $popup - 弹窗拦截
    # ✅ $document - 文档级拦截
    # ✅ $third-party - 第三方请求
    # ✅ $script - 脚本拦截
    # ✅ $image - 图片拦截
    # ✅ $stylesheet - 样式表拦截
    # ✅ $important - 重要规则优先
    # ❌ 移除不支持的修饰符
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
        -e 's/\$\$+/\$/g' \
        -e 's/\^\$\$/\^\$/g' \
        "${file}"
    
    echo "※`date +'%F %T'` 已保留 \$popup 和 \$document 修饰符用于弹窗拦截"
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

# 规则分类和格式化输出
function format_adguard_rules(){
    local file="${1}"
    test ! -f "${file}" && return
    
    # 分类规则
    local element_hiding_rules=$(cat "${file}" | grep -E '##' | grep -Ev '^\|\|' | sort -u)
    local popup_rules=$(cat "${file}" | grep -E '^\|\|.*\$(popup|document)' | sort -u)
    local domain_rules=$(cat "${file}" | grep -E '^\|\|' | grep -Ev '\$(popup|document)|##' | sort -u)
    local whitelist_rules=$(cat "${file}" | grep -E '^@@' | sort -u)
    
    local element_count=$(echo "${element_hiding_rules}" | grep -c '^' || echo "0")
    local popup_count=$(echo "${popup_rules}" | grep -c '^' || echo "0")
    local domain_count=$(echo "${domain_rules}" | grep -c '^' || echo "0")
    local whitelist_count=$(echo "${whitelist_rules}" | grep -c '^' || echo "0")
    
    cat << EOF > "${file}"
! ===== 元素隐藏规则 (共 ${element_count} 条) =====
! 隐藏网页中的广告元素（支持基本 CSS 选择器）
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
- ✅ **元素隐藏规则** (\`domain.com##selector\`) - 隐藏页面广告元素
- ✅ **手机端弹窗广告拦截** (\`\$popup\`, \`\$document\`)
- ✅ 基本修饰符支持 (\`\$important\`, \`\$third-party\`, \`\$script\`, \`\$image\` 等)
- ✅ 支持基本 CSS 选择器（如 \`.class\`, \`#id\`, \`element\`, \`:nth-of-type()\` 等）
- ❌ 不包含扩展 CSS（\`:has()\`, \`:has-text()\`, \`:matches-css()\` 等）
- ❌ 不包含 JavaScript 注入和 Scriptlet
- ❌ 不包含复杂的正则表达式

## 上游规则源

感谢以下规则源提供者 ❤️

<details>
<summary>点击查看上游规则</summary>
<ul>
<li> <a href="https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockdns.txt" target="_blank">adblockdns</a> - DNS 拦截规则</li>
<li> <a href="https://adguardteam.github.io/HostlistsRegistry/assets/filter_21.txt" target="_blank">anti-AD</a> - AdGuard 官方维护的中文广告过滤列表</li>
<li> <a href="https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts" target="_blank">ad-wars</a> - hosts 格式规则（已转换）</li>
<li> <a href="https://raw.githubusercontent.com/Noyllopa/NoAppDownload/master/NoAppDownload.txt" target="_blank">NoAppDownload</a> - 应用下载提示拦截（元素隐藏）</li>
<li> <a href="https://raw.githubusercontent.com/jk278/Ad-J/main/Ad-J.txt" target="_blank">Ad-J</a> - 综合广告拦截规则（元素隐藏）</li>
<li> <a href="https://easylist-downloads.adblockplus.org/easylist.txt" target="_blank">EasyList</a> - 弹窗拦截规则（仅提取 \$popup 相关规则）</li>
<li> <a href="https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/mv.txt" target="_blank">乘风视频过滤规则</a> - 弹窗拦截规则（仅提取 \$popup 相关规则）</li>
</ul>
</details>

## 使用说明

### 在 AdGuard Home 中使用

1. 在 AdGuard Home 管理界面进入「过滤器」>「DNS 封锁清单」
2. 添加自定义过滤器
3. 粘贴上方的订阅链接
4. 保存并更新

### 规则类型说明

本规则集包含三种类型的广告拦截规则：

**1. 元素隐藏规则**
- 格式：\`domain.com##selector\` 或 \`##selector\`
- 功能：隐藏网页中的广告元素，如应用下载提示、二维码等
- 示例：\`12306.cn##li.menu-item:nth-of-type(3) > .menu-hd\`
- 来源：NoAppDownload、Ad-J 等规则集

**2. 弹窗拦截规则**
- 格式：\`||domain.com^\$popup\` 或 \`||domain.com^\$document\`
- 功能：拦截弹窗窗口和整页广告
- 适用场景：手机浏览器、应用内弹窗广告
- 来源：EasyList、乘风规则等

**3. 域名拦截规则**
- 格式：\`||domain.com^\`
- 功能：DNS 级别拦截广告域名
- 来源：anti-AD、adblockdns、ad-wars 等

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=existyay/Ads-block&type=Date)](https://star-history.com/#existyay/Ads-block&Date)

---

**注意**: 本规则集已针对 AdGuard Home 进行优化，不再兼容浏览器扩展（如 uBlock Origin、AdBlock Plus）。
EOF
}