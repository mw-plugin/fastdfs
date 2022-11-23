#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

curPath=`pwd`
rootPath=$(dirname "$curPath")
rootPath=$(dirname "$rootPath")
serverPath=$(dirname "$rootPath")
install_tmp=${rootPath}/tmp/mw_install.pl

action=$1
type=$2

if [ "${2}" == "" ];then
	echo '缺少安装脚本...' > $install_tmp
	exit 0
fi 

if [ ! -d $curPath/versions/$2 ];then
	echo '缺少安装脚本2...' > $install_tmp
	exit 0
fi

if [ "${action}" == "uninstall" ];then

	serDir=/usr/lib/systemd/system
	if [ ! -d $serDir ];then
		serDir=/lib/systemd/system
	fi

	if [ ! -d $serDir ];then
		echo "pass"
	else
		systemctl stop fdfs_storaged
	  	systemctl stop fdfs_trackerd
	  	rm -rf $serDir/fdfs_storaged.service
	  	rm -rf $serDir/fdfs_trackerd.service
	  	systemctl daemon-reload
	fi
fi

sh -x $curPath/versions/$2/install.sh $1

if [ "${action}" == "install" ] && [ -d $serverPath/fastdfs ];then
	#初始化 
	cd ${rootPath} && python3 ${rootPath}/plugins/fastdfs/index.py start ${type}
	cd ${rootPath} && python3 ${rootPath}/plugins/fastdfs/index.py initd_install ${type}
fi
