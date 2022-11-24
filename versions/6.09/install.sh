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
		cd ${serverPath}/source/fastdfs/libserverframe
		./make.sh && ./make.sh install
	fi
}

serDir=/usr/lib/systemd/system
if [ ! -d $serDir ];then
	serDir=/lib/systemd/system
fi


VERSION=6.09
Install_App()
{

	# Uninstall_App

	echo '正在安装脚本文件...' > $install_tmp
	APP_DIR=${serverPath}/source/fastdfs

	mkdir -p $serverPath/fastdfs
	mkdir -p $APP_DIR

	Install_App_libfastcommon
	Install_App_libserverframe

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

	if [ ! -d /etc/fdfs ];then
		cd ${APP_DIR}/fastdfs-${VERSION} && ./make.sh && ./make.sh install
		echo 'install fastdfs' > $install_tmp
	else 
		echo "fastdfs already install"
	fi

	if [ ! -f /etc/fdfs/http.conf ];then
		cp -rf ${APP_DIR}/fastdfs-${VERSION}/conf/http.conf /etc/fdfs/http.conf
	fi

	echo $VERSION > $serverPath/fastdfs/version.pl

	# rm -rf ${APP_DIR}/fastdfs-${VERSION}
	# rm -rf ${APP_DIR}/fastdfs-V${VERSION}.tar.gz
}

Uninstall_App()
{
	if [ -f $serDir/fdfs_storaged.service ];then
		systemctl stop fdfs_storaged
		rm -rf $serDir/fdfs_storaged.service
	fi

	if [ -f $serDir/fdfs_trackerd.service ];then
		systemctl stop fdfs_trackerd
		rm -rf $serDir/fdfs_trackerd.service
	fi

	rm -rf /usr/include/fastcommon
	rm -rf /usr/include/sf
	rm -rf $serverPath/fastdfs
	echo "uninstall fastdfs" > $install_tmp
}

action=$1
if [ "${1}" == 'install' ];then
	Install_App
else
	Uninstall_App
fi
