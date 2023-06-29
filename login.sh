#!/bin/bash

# 配置用户名及密码
username=""
password=""
logfile=./login.log
sleep_time=600   # 循环执行等待时间，单位秒


# 解析参数
while getopts "i:u:p:t:l:v:" arg
do
    case $arg in
        i)
            echo "[+] Interface: $OPTARG"
            interface=$OPTARG
            ;;
        u)
            echo "[+] Username: $OPTARG"
            username=$OPTARG
            ;;
        p)
            echo "[+] Password: $OPTARG"
            password=$OPTARG
            ;;
        t)
            echo "[+] Login type: $OPTARG"
            login_type=$OPTARG
            ;;
        l)
            echo "[+] Enable loop"
            loop=1
            ;;
        v)
            echo "[+] Enable verbose log"
            verbose=1
            ;;
        ?)
            echo "[!] Unkonw argument"
            exit 1
            ;;
    esac
done

# $login_type 默认为1，普通情况登录
if [[ -z $login_type ]]; then
    login_type=1
fi

# 判断参数是否为空
if [ -z $interface ] || [ -z $username ] || [ -z $password ]; then
    echo "usage: $0 -i <interface> [-u <username>] [-p <password>] [-t <login_type>] [-l enable] [-v enable]"
    echo "  -i <interface>     network interface"
    echo "  -u <username>      login username"
    echo "  -p <password>      login password"
    echo "  -t <login_type>    login type, 1: Normal, 2: ServerRoom [default: 1]"
    echo "  -l enable          enable loop execution (default disable)"
    echo "  -v enable          enable log (default disable)"
    echo "note: 可以在当前脚本文件中配置用户名及密码"
    exit 1
fi

if [[ $login_type -eq 1 ]]; then
    # 普通情况登录
    login_url="http://192.168.101.201/"
else
    # 机房登录
    login_url="http://yxrz.ouc.edu.cn/"
fi 

# 检测是否存在 iconv 命令, 如果不存在返回 1
function check_iconv() {
    iconv --help >/dev/null 2>&1
    return $?
}

# 登录
function execute_login() {
    echo "[+] 开始登录..."   
    if [[ $login_type -eq 1 ]]; then
        # 普通情况登录
        login_url="http://192.168.101.201:801/eportal/portal/login?callback=dr1003&login_method=1&user_account=$username&user_password=$password&wlan_user_ip=0.0.0.0&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.1&terminal_type=1&lang=zh-cn&v=8569&lang=zh"
    else
        # 机房登录
        login_url="http://yxrz.ouc.edu.cn/drcom/login?callback=dr1003&DDDDD=$username&upass=$password&0MKKey=123456&R1=0&R2=&R3=0&R6=0&para=00&v6ip=&R7=0&terminal_type=1&lang=zh-cn&jsVersion=4.1&v=938&lang=zh"
    fi
    login_result=`curl --interface $interface -s -L $login_url`
    if [[ $verbose -eq 1 ]]; then
        echo "[+] 登录返回结果: $login_result" >> $logfile
    fi
    if [[ $login_result =~ '"result":1' ]]; then
        echo "[+] 登录成功"
    else
        echo "[!] 登录失败"
    fi
}

# 检查登录函数
function check_login() {
    echo "当前时间：$(date)"
    if [[ $verbose -eq 1 ]]; then
        date >> $logfile
        echo "usage username/password: $username/$password" >> $logfile
    fi

    # 检查是否已经登录
    if [[ check_iconv -eq 0 ]]; then 
        check_result=`curl --interface $interface -s -L $login_url  | iconv -f gb2312`

        # 判断是否包含子串"注销页"
        if [[ $check_result =~ "注销页" ]]; then
            echo "[*] 已登录"
            if [[ $verbose -eq 1 ]]; then
                echo "[*] 已登录" >> $logfile
            fi
        else
            echo "[!] 未登录"
            execute_login
        fi
    else 
        execute_login
    fi 
    
    if [[ $verbose -eq 1 ]]; then
        echo "======= Done. =======" >> $logfile
    fi
}

if [[ $loop -eq 1 ]]; then
    while true
    do
        check_login
        sleep $sleep_time
    done
else
    check_login
fi