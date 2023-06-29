import json
import re
import time
import sys

USERNAME = ""
PASSWORD = ""
WAIT = 600  # 循环执行等待时间

check_url = "http://192.168.101.201/"
login_url = f"http://192.168.101.201:801/eportal/portal/login?callback=dr1003&login_method=1&user_account={USERNAME}&user_password={PASSWORD}&wlan_user_ip=0.0.0.0&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.1&terminal_type=1&lang=zh-cn&v=8569&lang=zh"


headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36',
    'Referer': 'http://192.168.101.201/'
}

def main():
    import requests
    with open("login.log", "a+") as f:
        f.write("[*] 当前时间: {}\n".format(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())))
        req = requests.get(url=check_url)
        if req.text.find("上网登录页") != -1:
            f.write("[!] 未登录, 自动登录中....\n")
            info = requests.get(url=login_url, headers=headers).text
            info = json.loads(re.findall("dr1003\((.*)\);", info)[0])
            if info['result'] != 1:
                f.write("[!] 登录失败, 错误信息: {}\n".format(info['msg']))
            else:
                f.write("[+] 登录成功\n")
        else:
            f.write("[*] 已登录\n")
        f.write("========= Done. =========\n")
        f.close()

if __name__ == '__main__':
    if len(sys.argv) > 1:
        LOOP_OFF = True
    else:
        LOOP_OFF = False

    try:
        print("===== OUC-WIFI/OUC-AUTO 自动登录脚本 =====")
        if USERNAME != "" and PASSWORD != "":
            print("[*] 开始执行... ")
            print(f"[+] 当前循环执行等待时间为{WAIT}s, 执行日志见当前目录下的login.log文件")
            while True:
                main()
                if LOOP_OFF:
                    break
                time.sleep(WAIT)
        else:
            print("[!] 请先配置用户名及密码")
    except ModuleNotFoundError as e:
        print("[!] 请先执行 pip3 install requests")
    except KeyboardInterrupt as e:
        print("\n[-] 停止执行...")
    except Exception as e:
        print(e)

