# Ads-block
### 🚀 强力广告拦截规则集 - 自动更新(2025-11-06 01:47:03)

**涵盖 25+ 顶级规则源，超过 100 万条规则**

专为 AdGuard Home 打造的全能广告拦截规则集，完美支持：
- 📱 **移动端**：手机浏览器、APP 内广告、弹窗
- 💻 **PC端**：桌面浏览器、视频网站、新闻网站
- 🌐 **全平台**：Windows、macOS、Linux、Android、iOS
- 🎯 **全场景**：网页广告、视频广告、跟踪器、隐私保护

## 订阅链接

| 名称 | GitHub 订阅链接 | GitHub 加速订阅链接 |
| :-- | :-- | :-- |
| AdGuard Home 规则 | [订阅](https://raw.githubusercontent.com/existyay/Ads-block/refs/heads/main/Rules/adblock_auto.txt) | [订阅](https://raw.gitmirror.com/existyay/Ads-block/refs/heads/main/Rules/adblock_auto.txt)

## ⭐ 核心特性

### 🎯 强力拦截能力
- ✅ **25+ 顶级规则源** - 整合全球最优质的广告拦截规则
- ✅ **100万+ 拦截规则** - 覆盖各类广告、跟踪器、恶意网站
- ✅ **多平台覆盖** - PC端 + 移动端 + 全设备
- ✅ **中英文双语** - 中文网站 + 国际网站全面覆盖

### 🛡️ 全面保护
- ✅ **域名拦截** (`||domain.com^`) - DNS 级别拦截广告域名
- ✅ **元素隐藏** (`domain.com##selector`) - 隐藏页面广告元素
- ✅ **扩展 CSS** (`domain.com#?#selector`) - 高级选择器（`:has()`, `:has-text()` 等）
- ✅ **JavaScript 注入** (`domain.com#$#script`) - 阻止广告脚本执行
- ✅ **Scriptlet 注入** (`domain.com#%#//scriptlet`) - 预定义脚本片段
- ✅ **弹窗拦截** (`$popup`, `$document`) - 移动端弹窗广告克星
- ✅ **隐私保护** - 阻止跟踪器、数据收集、Windows 遥测

### 🚀 高级功能
- ✅ **智能重定向** (`$redirect=`) - 将广告请求重定向到空资源
- ✅ **参数清理** (`$removeparam=`) - 移除 URL 跟踪参数
- ✅ **CSP 修改** (`$csp=`) - 修改内容安全策略
- ✅ **完整修饰符** - `$important`, `$third-party`, `$script`, `$image` 等

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

## 📊 覆盖范围

### 🌐 网站类型
- ✅ 视频网站（优酷、爱奇艺、腾讯视频、YouTube、Netflix 等）
- ✅ 新闻网站（新浪、网易、搜狐、今日头条等）
- ✅ 社交媒体（微博、知乎、贴吧、Facebook、Twitter 等）
- ✅ 电商平台（淘宝、京东、拼多多、Amazon 等）
- ✅ 搜索引擎（百度、Google、Bing 等）
- ✅ 工具网站（CSDN、GitHub、Stack Overflow 等）

### 📱 移动端优化
- ✅ 手机浏览器内广告
- ✅ APP 内嵌广告
- ✅ 弹窗广告
- ✅ 应用下载提示
- ✅ 悬浮广告
- ✅ 全屏广告

### 💻 PC端覆盖
- ✅ 网页横幅广告
- ✅ 视频前贴片广告
- ✅ 侧边栏广告
- ✅ 弹窗广告
- ✅ 底部悬浮广告
- ✅ 文章内嵌广告

### 🔒 隐私保护
- ✅ 阻止网页跟踪器
- ✅ 阻止数据收集
- ✅ 阻止指纹识别
- ✅ 阻止 Windows 遥测
- ✅ 移除 URL 跟踪参数

## 使用说明

### 在 AdGuard Home 中使用

1. 在 AdGuard Home 管理界面进入「过滤器」>「DNS 封锁清单」
2. 添加自定义过滤器
3. 粘贴上方的订阅链接
4. 保存并更新

### 规则类型说明

本规则集包含 AdGuard Home 支持的所有类型广告拦截规则：

**1. JavaScript / Scriptlet 注入**
- 格式：`domain.com#$#script` 或 `domain.com#%#//scriptlet`
- 功能：注入 JavaScript 代码或预定义脚本片段
- 示例：`example.com#$#document.getElementById('ad').remove();`
- 用途：修改页面行为、移除动态加载的广告等

**2. 扩展 CSS 选择器**
- 格式：`domain.com#?#selector`
- 功能：使用高级 CSS 选择器
- 支持：`:has()`, `:has-text()`, `:matches-css()`, `:xpath()` 等
- 示例：`example.com#?#div:has(> .ad-banner)`

**3. 元素隐藏规则**
- 格式：`domain.com##selector` 或 `##selector`
- 功能：隐藏网页中的广告元素
- 示例：`12306.cn##li.menu-item:nth-of-type(3) > .menu-hd`
- 来源：NoAppDownload、Ad-J 等

**4. 弹窗拦截规则**
- 格式：`||domain.com^$popup` 或 `||domain.com^$document`
- 功能：拦截弹窗窗口和整页广告
- 适用：手机浏览器、应用内弹窗
- 来源：EasyList、乘风规则等

**5. 域名拦截规则**
- 格式：`||domain.com^`
- 功能：DNS 级别拦截广告域名
- 来源：anti-AD、adblockdns、ad-wars 等

**6. 高级修饰符**
- `$redirect=` - 重定向请求
- `$removeparam=` - 移除 URL 参数
- `$csp=` - 修改内容安全策略
- `$important` - 提高规则优先级

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=existyay/Ads-block&type=Date)](https://star-history.com/#existyay/Ads-block&Date)

---

**注意**: 本规则集包含 AdGuard Home 的完整高级语法，包括 JavaScript 注入、Scriptlet、扩展 CSS 等。同时也兼容 uBlock Origin 和 AdGuard 浏览器扩展。
