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
	if [ ! -d ${serverPath}/source/fastdfs/libfastcommon ];then
		cd ${serverPath}/source/fastdfs
		git clone https://github.com/happyfish100/libfastcommon
	fi

	if [ ! -d /usr/include/fastcommon ];then
		cd ${serverPath}/source/fastdfs/libfastcommon
		./make.sh && ./make.sh install
	fi
}


Install_App_libserverframe()
{
	if [ ! -d ${serverPath}/source/fastdfs/libserverframe ];then
		cd ${serverPath}/source/fastdfs
		git clone https://github.com/happyfish100/libserverframe
	fi

	if [ ! -d /usr/include/sf ];then
		cd ${serverPath}/source/fastdfs/sf
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

	Install_App_libfastcommon

	# wget -O /www/server/source/fastdfs/fastdfs-V6.09.tar.gz https://github.com/happyfish100/fastdfs/archive/refs/tags/V6.09.tar.gz
	if [ ! -f ${APP_DIR}/fastdfs-${VERSION}.tar.gz ];then
		if [ $sysName == 'Darwin' ]; then
			wget -O ${APP_DIR}/fastdfs-V${VERSION}.tar.gz https://github.com/happyfish100/fastdfs/archive/refs/tags/V${VERSION}.tar.gz
		else
			curl -sSLo ${APP_DIR}/fastdfs-V${VERSION}.tar.gz https://github.com/happyfish100/fastdfs/archive/refs/tags/V${VERSION}.tar.gz
		fi
	fi

	if [ ! -d ${APP_DIR}/fastdfs-${VERSION} ];then
		cd ${APP_DIR} && tar -zxvf fastdfs-V${VERSION}.tar.gz
	fi

	if [ ! -d  /etc/fdfs ];then
		cd ${APP_DIR}/fastdfs-${VERSION} && ./make.sh && ./make.sh install
	fi
	echo $VERSION > $serverPath/fastdfs/version.pl
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
