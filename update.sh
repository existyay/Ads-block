#!/bin/sh

# AdGuard Home DNS 拦截规则生成脚本
# 专为 luci-app-adguardhome / AdGuard Home 优化
# 仅生成 DNS 拦截规则 (||domain^)，避免误封 Cloudflare 和 PT 站点

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

# 处理规则源 - 转换各种格式为 AdGuard 标准格式
echo "※$(date +'%F %T') 开始处理规则源..."

# 批量处理所有下载的规则文件
echo "※$(date +'%F %T') 批量转换和处理所有规则源..."

for rule_file in "${Download_Folder}"/*.txt; do
    if [ -f "${rule_file}" ]; then
        filename=$(basename "${rule_file}")
        echo "※$(date +'%F %T') 处理 ${filename}"
        
        # 使用 DNS 模式处理（仅保留 ||domain^ 格式规则，兼容 luci-app-adguardhome）
        sort_adguard_rules "${Sort_Folder}" "${rule_file}" "dns"
    fi
done

# 额外处理特殊格式文件（Clash 格式等）
for rule_file in "${Download_Folder}"/*.list; do
    if [ -f "${rule_file}" ]; then
        filename=$(basename "${rule_file}")
        echo "※$(date +'%F %T') 转换 Clash 格式: ${filename}"
        convert_all_formats_to_adguard "${rule_file}"
        sort_adguard_rules "${Sort_Folder}" "${rule_file}"
    fi
done

# 合并所有规则
echo "※$(date +'%F %T') 合并规则文件..."
Combine_adblock_original_file "${Rules_Folder}/adblock_auto.txt" "${Sort_Folder}"

# 净化和优化规则（DNS 模式）
echo "※$(date +'%F %T') 净化规则..."
modtify_adblock_original_file "${Rules_Folder}/adblock_auto.txt" "" "dns"

# 移除不支持的修饰符（保留元素隐藏语法）
echo "※$(date +'%F %T') 规范化规则格式..."
remove_unsupported_modifiers "${Rules_Folder}/adblock_auto.txt"

# 应用白名单（如果存在）
if [ -f "$(pwd)/white_list/white_list.prop" ]; then
    echo "※$(date +'%F %T') 应用白名单规则..."
    make_white_rules "${Rules_Folder}/adblock_auto.txt" "$(pwd)/white_list/white_list.prop"
fi

# 清理和去重（DNS 模式）
echo "※$(date +'%F %T') 清理和去重规则..."
clean_adguard_rules "${Rules_Folder}/adblock_auto.txt" "dns"

# 移除冗余子域名（无论规则数量多大都执行）
rule_count=$(wc -l < "${Rules_Folder}/adblock_auto.txt")
echo "※$(date +'%F %T') 执行子域名去重（当前规则数：${rule_count}）..."
echo "※$(date +'%F %T') 注意：规则数较大时此步骤可能需要较长时间，请耐心等待..."
remove_redundant_subdomains "${Rules_Folder}/adblock_auto.txt"

# 格式化输出
echo "※$(date +'%F %T') 格式化规则..."
format_adguard_rules "${Rules_Folder}/adblock_auto.txt"

# 写入文件头
echo "※$(date +'%F %T') 写入文件头信息..."
write_head "${Rules_Folder}/adblock_auto.txt" \
    "AdGuard Home DNS 拦截规则集 (更新日期 $(date '+%F %T'))" \
    "专为 luci-app-adguardhome / AdGuard Home 优化的 DNS 拦截规则，国内广告优先，避免误封 Cloudflare 和 PT 站点"

echo "※$(date +'%F %T') 规则生成完成！"

# 清理临时文件
rm -rf "$(pwd)/temple"

# 更新 README
echo "※$(date +'%F %T') 更新 README..."
update_README_info

echo "※$(date +'%F %T') 全部完成！"