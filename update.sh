#!/bin/sh

# AdGuard Home 完整功能规则生成脚本
# 生成包含所有高级语法的 AdGuard Home 规则
# 支持：域名拦截、元素隐藏、扩展CSS、JavaScript注入、Scriptlet、弹窗拦截等

# 加载公共函数
source "$(pwd)/until_function.sh"

# 指定目录
Download_Folder="$(pwd)/temple/download_Rules"
Sort_Folder="$(pwd)/temple/sort"
Rules_Folder="$(pwd)/Rules"

# 清理旧文件并创建目录
rm -rf "${Rules_Folder}" "$(pwd)/temple" 2>/dev/null
mkdir -p "${Download_Folder}" "${Sort_Folder}" "${Rules_Folder}"
echo "※$(date +'%F %T') 初始化目录完成"
chmod -R 777 "$(pwd)"

# 下载规则源
echo "※$(date +'%F %T') 开始下载规则源..."
download_link "${Download_Folder}"

# 处理规则源 - 提取 AdGuard Home 支持的所有类型规则（包含高级语法）
echo "※$(date +'%F %T') 开始处理规则源..."

# 处理 adblockdns 规则
if [ -f "${Download_Folder}/adblockdns.txt" ]; then
    echo "※$(date +'%F %T') 处理 adblockdns.txt"
    sort_adguard_rules "${Sort_Folder}" "${Download_Folder}/adblockdns.txt"
fi

# 处理 anti-AD 规则
if [ -f "${Download_Folder}/Adguard_filter_21.txt" ]; then
    echo "※$(date +'%F %T') 处理 Adguard_filter_21.txt (anti-AD)"
    sort_adguard_rules "${Sort_Folder}" "${Download_Folder}/Adguard_filter_21.txt"
fi

# 处理 NoAppDownload 规则（包含元素隐藏）
if [ -f "${Download_Folder}/NoAppDownload.txt" ]; then
    echo "※$(date +'%F %T') 处理 NoAppDownload.txt (元素隐藏规则)"
    sort_adguard_rules "${Sort_Folder}" "${Download_Folder}/NoAppDownload.txt"
fi

# 处理 Ad-J 规则（包含元素隐藏）
if [ -f "${Download_Folder}/Ad-J.txt" ]; then
    echo "※$(date +'%F %T') 处理 Ad-J.txt (元素隐藏规则)"
    sort_adguard_rules "${Sort_Folder}" "${Download_Folder}/Ad-J.txt"
fi

# 处理 EasyList 规则（提取弹窗拦截规则）
if [ -f "${Download_Folder}/easylist.txt" ]; then
    echo "※$(date +'%F %T') 从 easylist.txt 提取弹窗拦截规则"
    extract_popup_rules "${Download_Folder}/easylist.txt" "${Sort_Folder}/popup_rules.txt"
fi

# 处理乘风视频规则（提取弹窗拦截规则）
if [ -f "${Download_Folder}/mv.txt" ]; then
    echo "※$(date +'%F %T') 从 mv.txt 提取弹窗拦截规则"
    extract_popup_rules "${Download_Folder}/mv.txt" "${Sort_Folder}/popup_rules.txt"
fi

# 处理 hosts 格式并转换
if [ -f "${Download_Folder}/ad-wars_hosts.txt" ]; then
    echo "※$(date +'%F %T') 转换 hosts 格式为 AdGuard Home 格式"
    convert_hosts_to_adguard "${Download_Folder}/ad-wars_hosts.txt"
    mv "${Download_Folder}/ad-wars_hosts.txt" "${Sort_Folder}/ad-wars_hosts.txt"
fi

# 合并所有规则
echo "※$(date +'%F %T') 合并规则文件..."
Combine_adblock_original_file "${Rules_Folder}/adblock_auto.txt" "${Sort_Folder}"

# 净化和优化规则
echo "※$(date +'%F %T') 净化规则..."
modtify_adblock_original_file "${Rules_Folder}/adblock_auto.txt"

# 移除不支持的修饰符
echo "※$(date +'%F %T') 移除 AdGuard Home 不支持的修饰符..."
remove_unsupported_modifiers "${Rules_Folder}/adblock_auto.txt"

# 应用白名单（如果存在）
if [ -f "$(pwd)/white_list/white_list.prop" ]; then
    echo "※$(date +'%F %T') 应用白名单规则..."
    make_white_rules "${Rules_Folder}/adblock_auto.txt" "$(pwd)/white_list/white_list.prop"
fi

# 清理和去重
echo "※$(date +'%F %T') 清理和去重规则..."
clean_adguard_rules "${Rules_Folder}/adblock_auto.txt"

# 格式化输出
echo "※$(date +'%F %T') 格式化规则..."
format_adguard_rules "${Rules_Folder}/adblock_auto.txt"

# 写入文件头
echo "※$(date +'%F %T') 写入文件头信息..."
write_head "${Rules_Folder}/adblock_auto.txt" \
    "AdGuard Home 完整规则集 (更新日期 $(date '+%F %T'))" \
    "AdGuard Home 完整功能规则集，包含域名拦截、元素隐藏、扩展CSS选择器、JavaScript注入、Scriptlet、弹窗拦截等所有高级语法。同时兼容 uBlock Origin 和 AdGuard 浏览器扩展"

echo "※$(date +'%F %T') 规则生成完成！"

# 清理临时文件
rm -rf "$(pwd)/temple"

# 更新 README
echo "※$(date +'%F %T') 更新 README..."
update_README_info

echo "※$(date +'%F %T') 全部完成！"