#!/bin/sh

# 加载公共函数
source "$(pwd)/until_function.sh"

# 指定目录
Sort_Folder="$(pwd)/temple/sort" 
Download_Folder="$(pwd)/temple/download_Rules"
Combine_Folder="$(pwd)/temple/combine"
Rules_Folder="$(pwd)/Rules"

# 删除旧文件并创建目录
rm -rf "${Rules_Folder}" "$(pwd)/temple" 2>/dev/null
mkdir -p "${Download_Folder}" "${Sort_Folder}/lite" "${Combine_Folder}/lite" "${Rules_Folder}" && echo "※$(date +'%F %T') 创建临时目录成功！"
chmod -R 777 "$(pwd)"

# 下载规则
download_link "${Download_Folder}"

处理Easylist规则
echo "※$(date +'%F %T') 开始处理Easylist规则……"
wipe_white_list "${Sort_Folder}" "${Download_Folder}/easylistchina.txt" '^\@\@|^[[:space:]]\@\@\|\||^<<|<<1023<<|^\@\@\|\||^\|\|'
add_rules_file "${Sort_Folder}" "${Download_Folder}/easylistchina.txt" '^\|\|.*\^$'
sort_adblock_Rules "${Sort_Folder}" "${Download_Folder}/easylist.txt" '^##|^###|^\/|\/ad\/|^:\/\/|^_|^\?|^\.|^-|^=|^:|^~|^,|^&'
sort_web_rules "${Sort_Folder}" "${Download_Folder}/easylist.txt"
sort_adblock_Rules "${Sort_Folder}" "${Download_Folder}/easylist_adservers_popup.txt" '^\|\|'
wipe_fiter_popup_domain "${Sort_Folder}/easylist_adservers_popup.txt"

# 处理第三方规则
echo "※$(date +'%F %T') 开始处理第三方规则……"
sort_adblock_Rules "${Sort_Folder}" "${Download_Folder}/adblockdns.txt" '^\|\|'
sort_adblock_Rules "${Sort_Folder}" "${Download_Folder}/NoAppDownload.txt" '^\|\||^#'
sort_adblock_Rules "${Sort_Folder}" "${Download_Folder}/Ad-J.txt" '^\|\||^#'
sort_adblock_Rules "${Sort_Folder}" "${Download_Folder}/mv.txt" '^\|\||^#'
sort_adblock_Rules "${Sort_Folder}" "${Download_Folder}/abpmerge.txt" '^\|\||^#'
sort_adblock_Rules "${Sort_Folder}" "${Download_Folder}/Adguard_filter_53.txt" '^\|\||^#'
sort_adblock_Rules "${Sort_Folder}" "${Download_Folder}/Adguard_filter_29.txt" '^\|\||^#'
sort_adblock_Rules "${Sort_Folder}" "${Download_Folder}/Adguard_filter_21.txt" '^\|\||^#'
sort_adblock_Rules "${Sort_Folder}" "${Download_Folder}/fq.txt" '^\|\||^#'

# 处理hosts格式
if [ -f "${Download_Folder}/ad-wars_hosts.txt" ]; then
    echo "※$(date +'%F %T') 转换hosts格式……"
    grep -v '^#' "${Download_Folder}/ad-wars_hosts.txt" | grep -v '^$' | awk '{print "||"$2"^"}' > "${Sort_Folder}/ad-wars_hosts.txt"
fi

# 处理lite规则
echo "※$(date +'%F %T') 开始处理精简版规则……"
sort_adblock_Rules "${Sort_Folder}/lite" "${Download_Folder}/Adguard_Chinese.txt" '^#|^\|\||^\/[A-Za-z]|^:\/\/|^_|^\?|^-|^=|^:|^~|^,|^&|##\.ad|##ad|##\..*-ad'
sort_adblock_Rules "${Sort_Folder}/lite" "${Download_Folder}/Adguard_mobile.txt" '^\|\||^#'
sort_web_rules "${Sort_Folder}/lite" "${Download_Folder}/Adguard_mobile.txt"
sort_adblock_Rules "${Sort_Folder}/lite" "${Download_Folder}/easylist_adservers_popup.txt" '^\|\|'
sort_adblock_Rules "${Sort_Folder}/lite" "${Download_Folder}/AdGuard_Base_filter_dns.txt" '^\|\||^\/[A-Za-z0-9?]|^:\/\/|^_|^\?|^-|^=|^:|^,|^&|\^\.'
wipe_fiter_popup_domain "${Sort_Folder}/lite/easylist_adservers_popup.txt"
wipe_fiter_popup_domain "${Sort_Folder}/lite/AdGuard_Base_filter_dns.txt"

# 处理full规则
echo "※$(date +'%F %T') 开始处理完整版规则……"
wipe_white_list "${Sort_Folder}" "${Download_Folder}/Adguard_Chinese.txt" '^\@\@|^[[:space:]]\@\@\|\||^<<|<<1023<<|\@\@\|\|'
wipe_white_list "${Sort_Folder}" "${Download_Folder}/adguard_optimized.txt" '^\@\@|^[[:space:]]\@\@\|\||^<<|<<1023<<|\@\@\|\|'
sort_adblock_Rules "${Sort_Folder}" "${Download_Folder}/Adguard_mobile.txt" '^##|^###|^\/|\/ad\/|^:\/\/|^_|^\?|^\.|^-|^=|^:|^~|^,|^&|^\|\||^#\$#|^#\?#'
sort_web_rules "${Sort_Folder}" "${Download_Folder}/Adguard_mobile.txt"
sort_adblock_Rules "${Sort_Folder}" "${Download_Folder}/AdGuard_Base_filter_dns.txt" '^\|\||^#'

# 合并规则
echo "※$(date +'%F %T') 开始合并规则……"
Combine_adblock_original_file "${Combine_Folder}/adblock_combine.txt" "${Sort_Folder}"
cp -f "${Download_Folder}/antiadblockfilters.txt" "${Combine_Folder}/antiadblockfilters.txt"

# 处理完整版规则
process_full_rules() {
    local file="$1"
    Combine_adblock_original_file "${file}" "${Combine_Folder}"
    
    # 批量修复规则
    fix_Rules "${file}" '\$popup,domain=racaty\.io,0123movie\.ru' '\$popup,domain=racaty\.io\|0123movie\.ru'
    fix_Rules "${file}" '##aside:-abp-has' '#\?#aside:-abp-has'
    fix_Rules "${file}" '##tr:-abp-has' '#\?#tr:-abp-has'
    fix_Rules "${file}" '\$~media,~subdocument,third-party,domain=mixdrp\.co,123movies\.tw\|' '\$~media,~subdocument,third-party,domain=mixdrp\.co\|123movies\.tw\|'
    fix_Rules "${file}" '\$third-party,script,_____,domain=' '\$third-party,script,domain='
    fix_Rules "${file}" ',_____,domain=' ',domain='
    fix_Rules "${file}" ':-abp-has(' ':has('
    fix_Rules "${file}" ':-abp-contains(' ':has-text('
    
    # 净化处理
    modtify_adblock_original_file "${file}"
    wipe_badfilter "${file}"
    lite_Uadblock_Rules "${file}"
    make_white_rules "${file}" "$(pwd)/white_list/white_list.prop"
    fixed_css_white_conflict "${file}"
    Running_sort_domain_Combine "${file}"
    Running_sort_Css_Combine "${file}"
    fixed_Rules_error "${file}"
    modtify_adblock_original_file "${file}"
    sort_and_optimum_adblock "${file}"
}

process_full_rules "${Rules_Folder}/adblock_auto.txt"
write_head "${Rules_Folder}/adblock_auto.txt" "混合规则(更新日期$(date '+%F %T'))" "合并于各种知名的Adblock规则,适用于 Adguard / Ublock Origin / Adblock Plus(用Adblock Plus源码编译的软件也支持，例如嗅觉浏览器 ) 支持复杂语法的过滤器，或者能兼容大规则的浏览器例如 X浏览器" && echo "※$(date +'%F %T') 混合规则合并完成！"

# 处理lite版本
Combine_adblock_original_file "${Combine_Folder}/lite/adblock_combine.txt" "${Sort_Folder}/lite"
cp -f "${Download_Folder}/antiadblockfilters.txt" "${Combine_Folder}/lite/antiadblockfilters.txt"
Combine_adblock_original_file "${Rules_Folder}/adblock_auto_lite.txt" "${Combine_Folder}/lite"

# 修复lite规则
fix_Rules "${Rules_Folder}/adblock_auto_lite.txt" '\$popup,domain=racaty\.io,0123movie\.ru' '\$popup,domain=racaty\.io\|0123movie\.ru'
fix_Rules "${Rules_Folder}/adblock_auto_lite.txt" '##aside:-abp-has' '#\?#aside:-abp-has'
fix_Rules "${Rules_Folder}/adblock_auto_lite.txt" '##tr:-abp-has' '#\?#tr:-abp-has'
fix_Rules "${Rules_Folder}/adblock_auto_lite.txt" '\$~media,~subdocument,third-party,domain=mixdrp\.co,123movies\.tw\|' '\$~media,~subdocument,third-party,domain=mixdrp\.co\|123movies\.tw\|'
fix_Rules "${Rules_Folder}/adblock_auto_lite.txt" '\$third-party,script,_____,domain=' '\$third-party,script,domain='
fix_Rules "${Rules_Folder}/adblock_auto_lite.txt" ',_____,domain=' ',domain='

# 净化lite规则
modtify_adblock_original_file "${Rules_Folder}/adblock_auto_lite.txt"
Remove_regex_Rules_for_via "${Rules_Folder}/adblock_auto_lite.txt"
wipe_badfilter "${Rules_Folder}/adblock_auto_lite.txt"
lite_Adblock_Rules "${Rules_Folder}/adblock_auto_lite.txt"
make_white_rules "${Rules_Folder}/adblock_auto_lite.txt" "$(pwd)/white_list/white_list.prop"
fixed_css_white_conflict "${Rules_Folder}/adblock_auto_lite.txt"
Running_sort_domain_Combine "${Rules_Folder}/adblock_auto_lite.txt"
Running_sort_Css_Combine "${Rules_Folder}/adblock_auto_lite.txt"
fixed_Rules_error "${Rules_Folder}/adblock_auto_lite.txt"
modtify_adblock_original_file "${Rules_Folder}/adblock_auto_lite.txt"
lite_Adblock_Rules "${Rules_Folder}/adblock_auto_lite.txt"
sort_and_optimum_adblock "${Rules_Folder}/adblock_auto_lite.txt"
write_head "${Rules_Folder}/adblock_auto_lite.txt" "混合规则精简版(更新日期$(date '+%F %T'))" "合并于各种知名的Adblock规则，适用于移动端轻量的浏览器，例如 VIA / Rian / B仔浏览器" && echo "※$(date +'%F %T') 混合规则精简版合并完成！"

rm -rf "$(pwd)/temple"
update_README_info