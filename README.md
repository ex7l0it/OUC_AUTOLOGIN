
# OUC 校园网自动登录脚本

## bash 脚本

### 支持功能

1. 使用指定网卡登录
2. 支持普通情况登录及机房服务器网络登录
3. 日志记录
4. 循环定时登录

### 使用方法

```shell
usage: login.sh -i <interface> [-u <username>] [-p <password>] [-t <login_type>] [-l enable] [-v enable]
  -i <interface>     network interface
  -u <username>      login username
  -p <password>      login password
  -t <login_type>    login type, 1: Normal, 2: ServerRoom [default: 1]
  -l enable          enable loop execution (default disable)
  -v enable          enable log (default disable)
note: 可以在当前脚本文件中配置用户名及密码
```

例如:

```shell
# OUC-AUTO/OUC-WIFI/实验室有线网络 
bash ./login.sh -i en0 -u xxxxx -p xxxxx -v enable
# 机房服务器连接网络
bash ./login.sh -i eno3 -u xxxxx -p xxxxx -t 2 -l enable -v enable
```

也可配置 crontab:

```shell
*/10 * * * * /opt/auto_login/login.sh -i eno3 -t 2 -v enable
```


## Python 脚本

- 每10分钟自动尝试登录校园网
- 不能指定网卡

### 使用方法

- 打开脚本填入用户名密码
- 直接执行脚本即可 (Windows直接双击打开或命令行执行 `python3 ouc_login.py`)


## 其他

2023.06.29 校园网登录页面加上了 https，登录页面改成了 https://xha.ouc.edu.cn ，不过不影响原来的 192.168.101.201 登录