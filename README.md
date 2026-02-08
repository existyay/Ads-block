# Ads-block
# 源码参考自https://github.com/lingeringsound/adblock_auto/
### 🚀 强力广告拦截规则集 - 自动更新(2026-02-08 10:31:14)

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
| **DNS 拦截** | `\|\|example.com^` | 拦截整个域名 |
| **Hosts** | `0.0.0.0 example.com` | 转换为 DNS 拦截 |
| **元素隐藏** | `##.ad-banner` | 隐藏页面广告元素 |
| **特定域名元素隐藏** | `example.com##.ad` | 仅在指定域名隐藏 |
| **扩展CSS选择器** | `#?#div:has(.ad)` | 高级元素匹配 |
| **带修饰符规则** | `\|\|ad.com^$third-party` | 条件拦截 |
| **Clash/Surge** | `DOMAIN,example.com` | 转换为 DNS 拦截 |
| **dnsmasq** | `address=/example.com/` | 转换为 DNS 拦截 |

### 规则类型说明

- **DNS 拦截规则** - 适用于 AdGuard Home、AdGuard DNS 等 DNS 级拦截
- **元素隐藏规则** - 需要 AdGuard 客户端或浏览器扩展（可精准隐藏页面元素而不影响域名访问）

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=existyay/Ads-block&type=Date)](https://star-history.com/#existyay/Ads-block&Date)

---

**注意**: 本规则集为标准 `||domain^` 格式的 DNS 拦截规则，专为 AdGuard Home 优化。

⚠️ **重要提示**：DNS 拦截能力有限，无法 100% 拦截所有开屏/弹窗广告。如需更强效果，建议：
- Android：安装 AdGuard 客户端或使用 Magisk 模块（如 AdAway）
- iOS：安装 AdGuard Pro 或使用 Quantumult X 等工具
- 使用支持 SSL 拦截的方案可获得最佳效果
