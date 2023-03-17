#!/usr/bin/env sh

execPath=`pwd`
# 接收外部传入的参数，变为数组
app=($*)

# 最后启动的应用的命令
cmd="--filter=portal"

# 计算应用的端口号
portal=443
appPort=10100
((appPort=portal+appPort))

# 记录应用对应的端口号
appName="portal:$portal,"

# 需要放置 env 文件的目录
appPackages="$execPath/packages/portal "

for i in "${app[@]}"; do
  cmd="$cmd --filter=$i"
  ((appPort++))
  appName=$appName$i:$appPort","
  appPackages=$appPackages" $execPath/packages/$i"

  # 每个子应用都有自己的端口号
  export $i=$appPort
done

# 读取配置
#envFile=`cat ${execPath}/\.env`
# 获取本机 ip
localIP=`node ${execPath}/scripts/getip.js`

# .env.local 文件内容
allApp="VUE_APP_IP=$localIP
VUE_APP_MICRO=$appName
VUE_APP_PORTAL_PORT=$portal
VUE_APP_DC_PORT=$dc
VUE_APP_AC_PORT=$ac
VUE_APP_SPA_PORT=$spa
VUE_APP_CONTROL_PORT=$control
VUE_APP_SECURITY_PORT=$security
VUE_APP_DEVICE_PORT=$device
VUE_APP_CERT_PORT=$cert"

echo -e "$allApp" > .env.local

# 执行移动 env 文件
echo $appPackages | xargs -n 1 cp -v $execPath/\.env.local

echo $appName

# 执行启动命令
echo -e "\e[43;37m pnpm $cmd run dev \e[0m"
pnpm $cmd run dev --workspace-concurrency 10
