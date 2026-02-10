# Ads-block
# 源码参考自https://github.com/lingeringsound/adblock_auto/
### 🚀 AdGuard Home DNS 拦截规则集 - 自动更新

**专为 luci-app-adguardhome / AdGuard Home 优化，国内广告优先，避免误封 Cloudflare 和 PT 站点**

## ✨ 特性

- ✅ 仅使用 `||domain^` 格式，100% 兼容 AdGuard Home / luci-app-adguardhome
- ✅ 国内广告规则优先，精准拦截开屏广告和应用内广告
- ✅ 内置白名单保护 Cloudflare、常见 PT 站点、支付服务等
- ✅ 移除了 EasyPrivacy 和 StevenBlack Hosts 等可能导致误封的规则源
- ✅ 每日自动更新，保持规则新鲜度

## 订阅链接

| 名称 | GitHub 订阅链接 | GitHub 加速订阅链接 |
| :-- | :-- | :-- |
| AdGuard Home 规则 | [订阅](https://raw.githubusercontent.com/existyay/Ads-block/refs/heads/main/Rules/adblock_auto.txt) | [订阅](https://raw.gitmirror.com/existyay/Ads-block/refs/heads/main/Rules/adblock_auto.txt)

## 上游规则源

感谢以下规则源提供者 ❤️

<details>
<summary>点击查看上游规则</summary>
<ul>
<li><strong>国内广告拦截（优先）</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/AWAvenue-Ads-Rule.txt" target="_blank">AWAvenue 秋风广告规则</a> - 专注国产 App 开屏广告（精准、低误杀）</li>
<li><a href="https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-adguard.txt" target="_blank">anti-AD</a> - 精准的中文区广告拦截规则（AdGuard Home 专用）</li>
<li><a href="https://raw.githubusercontent.com/jk278/Ad-J/main/Ad-J.txt" target="_blank">大圣净化 Ad-J</a> - 国产 App 广告净化</li>
<li><a href="https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/rule.txt" target="_blank">乘风视频广告规则</a> - 国内视频网站广告拦截</li>
</ul>

<li><strong>通用广告拦截</strong></li>
<ul>
<li><a href="https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt" target="_blank">AdGuard DNS Filter</a> - 专为 DNS 拦截优化的规则（误杀率低）</li>
<li><a href="https://raw.githubusercontent.com/Noyllopa/NoAppDownload/master/NoAppDownload.txt" target="_blank">NoAppDownload</a> - 应用下载提示拦截</li>
<li><a href="https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_224_Chinese/filter.txt" target="_blank">AdGuard Chinese Filter</a> - 中文网站广告拦截</li>
</ul>

<li><strong>隐私保护与安全</strong></li>
<ul>
<li><a href="https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt" target="_blank">AdGuard Tracking Protection</a> - 核心追踪保护（已移除 EasyPrivacy 避免 PT 误封）</li>
<li><a href="https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareAdGuardHome.txt" target="_blank">DandelionSprout Anti-Malware</a> - 恶意软件拦截</li>
</ul>
</ul>
</details>

## 白名单保护

本规则集内置白名单，保护以下服务不被误封：

- **Cloudflare**: cloudflare.com, 1.1.1.1, workers.dev, pages.dev 等
- **PT 站点**: 国内外常见 PT 站点及 Tracker 服务
- **支付服务**: 支付宝、微信支付等
- **云服务**: 阿里云、腾讯云、七牛云等
- **开发服务**: GitHub、npm、jsDelivr 等


## 使用说明

### 在 luci-app-adguardhome 中使用

1. 进入 OpenWrt 管理界面 > 服务 > AdGuard Home
2. 在「过滤器」>「DNS 封锁清单」中添加规则
3. 粘贴上方的订阅链接
4. 保存并更新

### 在 AdGuard Home 中使用

1. 在 AdGuard Home 管理界面进入「过滤器」>「DNS 封锁清单」
2. 添加自定义过滤器
3. 粘贴上方的订阅链接
4. 保存并更新

## 规则格式说明

本项目 **仅输出** `||domain^` 格式的 DNS 拦截规则，确保：

| 格式类型 | 示例 | 兼容性 |
| :-- | :-- | :-- |
| **DNS 拦截** | `\|\|ad.example.com^` | ✅ AdGuard Home / luci-app-adguardhome |
| **白名单** | `@@\|\|example.com^` | ✅ AdGuard Home / luci-app-adguardhome |

## 与其他规则的区别

| 对比项 | 本规则集 | 通用规则集 |
| :-- | :-- | :-- |
| Cloudflare 兼容 | ✅ 白名单保护 | ❌ 可能误封 |
| PT 站点兼容 | ✅ 白名单保护 | ❌ Tracker 被拦截 |
| 国内广告 | ⭐ 优先处理 | 一般 |
| 规则格式 | DNS 专用 | 混合格式 |
| luci-app-adguardhome | ✅ 完全兼容 | ⚠️ 部分规则不生效 |

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=existyay/Ads-block&type=Date)](https://star-history.com/#existyay/Ads-block&Date)

---

