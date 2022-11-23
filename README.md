# fastdfs

FastDFS插件

```
FastDFS是一款轻量级的开源分布式文件系统，功能包括：文件存储、文件同步、文件上传、文件下载等，解决了文件大容量存储和高性能访问问题。特别适合以文件为载体的在线服务，如图片、视频、文档服务等等.
```

## 安装脚本

```
cd /www/server/mdserver-web/plugins && rm -rf fastdfs && git clone https://github.com/mw-plugin/fastdfs && cd fastdfs && rm -rf .git && cd /www/server/mdserver-web/plugins/fastdfs && bash install.sh install
```