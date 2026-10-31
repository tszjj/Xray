# 介绍

最好用的 Xray 一键安装脚本 & 管理脚本

# 本分支说明

- 仓库：https://github.com/tszjj/Xray
- 上游：fork 自 https://github.com/233boy/xray ，脚本逻辑与上游保持一致，遵循原作者的 GPL-3.0 许可
- 本分支改动：
  1. 脚本内的仓库相关链接（安装、更新、反馈问题、关于）全部指向本分支仓库 `tszjj/Xray`
  2. 新增 **VLESS-XHTTP-REALITY** 协议，同时启用 REALITY 与 XHTTP，无需域名与证书
- 一键安装：

```bash
bash -c "$(wget -qO- https://raw.githubusercontent.com/tszjj/Xray/main/install.sh)"
```

> 若脚本更新（`xray U`）失败，请检查本仓库的 GitHub Actions 是否正常运行，脚本的 code.zip 由 Actions 自动构建并发布。

# 特点

- 快速安装
- 无敌好用
- 零学习成本
- 自动化 TLS
- 简化所有流程
- 屏蔽 BT
- 屏蔽中国 IP
- 使用 API 操作
- 兼容 Xray 命令
- 强大的快捷参数
- 支持所有常用协议
- 一键添加 VLESS-REALITY (默认)
- 一键添加 VLESS-XHTTP-REALITY (REALITY + XHTTP 同时启用)
- 一键添加 Shadowsocks 2022
- 一键添加 VMess-(TCP/mKCP)
- 一键添加 VMess-(WS/gRPC)-TLS
- 一键添加 VLESS-(WS/gRPC/XHTTP)-TLS
- 一键添加 Trojan-(WS/gRPC)-TLS
- 一键添加 VMess-(TCP/mKCP) 动态端口
- 一键启用 BBR
- 一键更改伪装网站
- 一键更改 (端口/UUID/密码/域名/路径/加密方式/SNI/动态端口/等...)
- 还有更多...

# 设计理念

设计理念为：**高效率，超快速，极易用**

脚本基于作者的自身使用需求，以 **多配置同时运行** 为核心设计

并且专门优化了，添加、更改、查看、删除、这四项常用功能

你只需要一条命令即可完成 添加、更改、查看、删除、等操作

例如，添加一个配置仅需不到 1 秒！瞬间完成添加！其他操作亦是如此！

脚本的参数非常高效率并且超级易用，请掌握参数的使用

# 文档

上游文档（协议参数与用法基本通用）：https://233boy.com/xray/xray-script/

# VLESS-XHTTP-REALITY（本分支新增）

把 **REALITY** 与 **XHTTP** 组合到同一个入站：用 XHTTP 承载 VLESS 流量，再由 REALITY 伪装 TLS 握手，
因此既保留了 REALITY 免域名、免证书、抗主动探测的优势，又具备 XHTTP 的分流与抗 QoS 特性。

添加（端口 / UUID / 路径 / SNI 都可选，缺省自动生成）：

```bash
xray add xr                      # 全自动：随机端口、随机 UUID、随机路径、随机 SNI
xray add xr 443                  # 指定端口
xray add xr 443 <uuid>           # 指定端口与 UUID
xray add xr 443 <uuid> /path     # 再指定路径
xray add xr 443 <uuid> /path www.amazon.com   # 再指定 SNI (伪装目标站点)
# 别名: xr / rx / xhttp-reality / reality-xhttp
```

查看、分享与修改：

```bash
xray info 443        # 也可直接 xray i 交互选择
xray url  443        # 输出 vless:// 分享链接
xray qr   443        # 输出二维码
xray path 443 /new-path       # 改路径
xray sni  443 www.ebay.com    # 改 SNI（同时作为 HTTP Host）
xray key  443 auto            # 重新生成 REALITY 密钥对
xray port 443 8443            # 改端口
```

生成的入站结构（关键部分）：

```json
"streamSettings": {
  "network": "xhttp",
  "security": "reality",
  "realitySettings": { "dest": "www.amazon.com:443", "serverNames": ["www.amazon.com", ""], "privateKey": "...", "shortIds": [""] },
  "xhttpSettings": { "host": "www.amazon.com", "path": "/<uuid>" }
}
```

说明：
- XHTTP + REALITY 下 `flow` 必须为空，脚本已自动处理（不再写入 `xtls-rprx-vision`）
- 该组合不需要域名，也不依赖 Caddy 自动申请证书，端口建议直接使用 443
- `no-auto-tls` 同样适用于该协议（本来就不需要证书）

# 帮助

使用：`xray help`

```
Xray script v1.37 by 233boy
Usage: xray [options]... [args]...

基本:
   v, version                                      显示当前版本
   ip                                              返回当前主机的 IP
   pbk                                             同等于 xray x25519
   get-port                                        返回一个可用的端口
   ss2022                                          返回一个可用于 Shadowsocks 2022 的密码

一般:
   a, add [protocol] [args... | auto]              添加配置
      add xr [port] [uuid] [/path] [sni]           添加 VLESS-XHTTP-REALITY 配置 (本分支)
   c, change [name] [option] [args... | auto]      更改配置
   d, del [name]                                   删除配置**
   i, info [name]                                  查看配置
   qr [name]                                       二维码信息
   url [name]                                      URL 信息
   log                                             查看日志
   logerr                                          查看错误日志

更改:
   dp, dynamicport [name] [start | auto] [end]     更改动态端口
   full [name] [...]                               更改多个参数
   id [name] [uuid | auto]                         更改 UUID
   host [name] [domain]                            更改域名
   port [name] [port | auto]                       更改端口
   path [name] [path | auto]                       更改路径
   passwd [name] [password | auto]                 更改密码
   key [name] [Private key | atuo] [Public key]    更改密钥
   type [name] [type | auto]                       更改伪装类型
   method [name] [method | auto]                   更改加密方式
   sni [name] [ ip | domain]                       更改 serverName
   seed [name] [seed | auto]                       更改 mKCP seed
   new [name] [...]                                更改协议
   web [name] [domain]                             更改伪装网站

进阶:
   dns [...]                                       设置 DNS
   dd, ddel [name...]                              删除多个配置**
   fix [name]                                      修复一个配置
   fix-all                                         修复全部配置
   fix-caddyfile                                   修复 Caddyfile
   fix-config.json                                 修复 config.json

管理:
   un, uninstall                                   卸载
   u, update [core | sh | dat | caddy] [ver]       更新
   U, update.sh                                    更新脚本
   s, status                                       运行状态
   start, stop, restart [caddy]                    启动, 停止, 重启
   t, test                                         测试运行
   reinstall                                       重装脚本

测试:
   client [name]                                   显示用于客户端 JSON, 仅供参考
   debug [name]                                    显示一些 debug 信息, 仅供参考
   gen [...]                                       同等于 add, 但只显示 JSON 内容, 不创建文件, 测试使用
   genc [name]                                     显示用于客户端部分 JSON, 仅供参考
   no-auto-tls [...]                               同等于 add, 但禁止自动配置 TLS, 可用于 *TLS 相关协议
   xapi [...]                                      同等于 xray api, 但 API 后端使用当前运行的 Xray 服务

其他:
   bbr                                             启用 BBR, 如果支持
   bin [...]                                       运行 Xray 命令, 例如: xray bin help
   api, x25519, tls, run, uuid  [...]              兼容 Xray 命令
   h, help                                         显示此帮助界面

谨慎使用 del, ddel, 此选项会直接删除配置; 无需确认
反馈问题) https://github.com/tszjj/Xray/issues
文档(doc) https://233boy.com/xray/xray-script/
```