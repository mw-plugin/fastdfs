#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

curPath=`pwd`
rootPath=$(dirname "$curPath")
rootPath=$(dirname "$rootPath")
serverPath=$(dirname "$rootPath")
sysName=`uname`

install_tmp=${rootPath}/tmp/mw_install.pl

bash ${rootPath}/scripts/getos.sh
OSNAME=`cat ${rootPath}/data/osname.pl`
OSNAME_ID=`cat /etc/*-release | grep VERSION_ID | awk -F = '{print $2}' | awk -F "\"" '{print $2}'`



Install_App_libfastcommon()
{
	if [ ! -d ${serverPath}/source/fa/libfastcommon ];then
		git clone https://github.com/happyfish100/libfastcommon
	fi

	if [ ! -d /usr/include/fastcommon ];then
		cd ${serverPath}/libfastcommon
		./make.sh && ./make.sh install
	fi
}


VERSION=6.09
Install_App()
{

	echo '正在安装脚本文件...' > $install_tmp
	mkdir -p $serverPath/fastdfs
	APP_DIR=${serverPath}/source/fastdfs

	mkdir -p $APP_DIR
	
	if [ ! -f ${APP_DIR}/fastdfs-${VERSION}.tar.gz ];then
		if [ $sysName == 'Darwin' ]; then
			wget -O ${APP_DIR}/fastdfs-V${VERSION}.tar.gz https://github.com/happyfish100/fastdfs/archive/refs/tags/V${VERSION}.tar.gz
		else
			curl -sSLo ${APP_DIR}/fastdfs-V${VERSION}.tar.gz https://github.com/happyfish100/fastdfs/archive/refs/tags/V${VERSION}.tar.gz
		fi
	fi

	if [ ! -f ${APP_DIR}/fastdfs-${VERSION}.tar.gz ];then
		curl -sSLo ${APP_DIR}/fastdfs-V${VERSION}.tar.gz https://gitee.com/fastdfs100/fastdfs/archive/refs/tags/V${VERSION}.tar.gz
	fi

	cd ${APP_DIR} && tar -zxvf fastdfs-V${VERSION}.tar.gz


	echo $MIN_VERSION > $serverPath/fastdfs/version.pl
	echo 'install fastdfs' > $install_tmp
}

Uninstall_App()
{
	# if [ -f $serverPath/fastdfs/initd/fastdfs ];then
	# 	$serverPath/fastdfs/initd/fastdfs stop
	# fi

	rm -rf $serverPath/fastdfs
	echo "uninstall fastdfs" > $install_tmp
}

action=$1
if [ "${1}" == 'install' ];then
	Install_App
else
	Uninstall_App
fi
