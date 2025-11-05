# Ads-block
### AdGuard Home 专用规则 - 自动更新(2025-11-06 01:26:56)

本项目专为 AdGuard Home 优化，仅包含域名拦截规则，确保最佳性能和兼容性。

## 订阅链接

| 名称 | GitHub 订阅链接 | GitHub 加速订阅链接 |
| :-- | :-- | :-- |
| AdGuard Home 规则 | [订阅](https://raw.githubusercontent.com/existyay/Ads-block/refs/heads/main/Rules/adblock_auto.txt) | [订阅](https://raw.gitmirror.com/existyay/Ads-block/refs/heads/main/Rules/adblock_auto.txt)

## 特性

- ✅ 仅包含 AdGuard Home 完全兼容的规则
- ✅ 域名拦截规则 (`||domain.com^`)
- ✅ 白名单规则 (`@@||domain.com^`)
- ✅ **元素隐藏规则** (`domain.com##selector`) - 隐藏页面广告元素
- ✅ **手机端弹窗广告拦截** (`$popup`, `$document`)
- ✅ 基本修饰符支持 (`$important`, `$third-party`, `$script`, `$image` 等)
- ✅ 支持基本 CSS 选择器（如 `.class`, `#id`, `element`, `:nth-of-type()` 等）
- ❌ 不包含扩展 CSS（`:has()`, `:has-text()`, `:matches-css()` 等）
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
<li> <a href="https://easylist-downloads.adblockplus.org/easylist.txt" target="_blank">EasyList</a> - 弹窗拦截规则（仅提取 $popup 相关规则）</li>
<li> <a href="https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/mv.txt" target="_blank">乘风视频过滤规则</a> - 弹窗拦截规则（仅提取 $popup 相关规则）</li>
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
- 格式：`domain.com##selector` 或 `##selector`
- 功能：隐藏网页中的广告元素，如应用下载提示、二维码等
- 示例：`12306.cn##li.menu-item:nth-of-type(3) > .menu-hd`
- 来源：NoAppDownload、Ad-J 等规则集

**2. 弹窗拦截规则**
- 格式：`||domain.com^$popup` 或 `||domain.com^$document`
- 功能：拦截弹窗窗口和整页广告
- 适用场景：手机浏览器、应用内弹窗广告
- 来源：EasyList、乘风规则等

**3. 域名拦截规则**
- 格式：`||domain.com^`
- 功能：DNS 级别拦截广告域名
- 来源：anti-AD、adblockdns、ad-wars 等

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=existyay/Ads-block&type=Date)](https://star-history.com/#existyay/Ads-block&Date)

---

**注意**: 本规则集已针对 AdGuard Home 进行优化，不再兼容浏览器扩展（如 uBlock Origin、AdBlock Plus）。
