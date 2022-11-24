# fastdfs

FastDFS插件

```
FastDFS是一款轻量级的开源分布式文件系统，功能包括：文件存储、文件同步、文件上传、文件下载等，解决了文件大容量存储和高性能访问问题。特别适合以文件为载体的在线服务，如图片、视频、文档服务等等.
```

## 插件安装脚本

```
cd /www/server/mdserver-web/plugins && rm -rf fastdfs && git clone https://github.com/mw-plugin/fastdfs && cd fastdfs && rm -rf .git && cd /www/server/mdserver-web/plugins/fastdfs && bash install.sh install 6.09
```

## 重新编译安装OpenResty

- 加入fastdfs-nginx-module模块

```
安装后需要修改/etc/fdfs/mod_fastdfs.conf配置
tracker_server=xxxx:22122
根据使用修改。
```

```
curl -fsSL https://raw.githubusercontent.com/mw-plugin/fastdfs-nginx-module/main/installl.sh | bash
```