# coding:utf-8

import sys
import io
import os
import time
import re
import string
import subprocess

sys.path.append(os.getcwd() + "/class/core")
import mw

app_debug = False
if mw.isAppleSystem():
    app_debug = True


# python3 plugins/fastdfs/index.py start 6.09

def getPluginName():
    return 'fastdfs'


def getPluginDir():
    return mw.getPluginDir() + '/' + getPluginName()


def getServerDir():
    return mw.getServerDir() + '/' + getPluginName()


def getInitDFile():
    if app_debug:
        return '/tmp/' + getPluginName()
    return '/etc/init.d/' + getPluginName()


def getConfTpl():
    path = getPluginDir() + "/conf/fastdfs.conf"
    return path


def getConf():
    path = getServerDir() + "/conf/storage.conf"
    return path


def getInitDTpl():
    path = getPluginDir() + "/init.d/" + getPluginName() + ".tpl"
    return path


def getArgs():
    args = sys.argv[2:]
    tmp = {}
    args_len = len(args)

    if args_len == 1:
        t = args[0].strip('{').strip('}')
        t = t.split(':')
        tmp[t[0]] = t[1]
    elif args_len > 1:
        for i in range(len(args)):
            t = args[i].split(':')
            tmp[t[0]] = t[1]
    return tmp


def checkArgs(data, ck=[]):
    for i in range(len(ck)):
        if not ck[i] in data:
            return (False, mw.returnJson(False, '参数:(' + ck[i] + ')没有!'))
    return (True, mw.returnJson(True, 'ok'))


def configTpl():
    path = getPluginDir() + '/tpl'
    pathFile = os.listdir(path)
    tmp = []
    for one in pathFile:
        file = path + '/' + one
        tmp.append(file)
    return mw.getJson(tmp)


def readConfigTpl():
    args = getArgs()
    data = checkArgs(args, ['file'])
    if not data[0]:
        return data[1]

    content = mw.readFile(args['file'])
    content = contentReplace(content)
    return mw.returnJson(True, 'ok', content)


def contentReplace(content):
    service_path = mw.getServerDir()
    content = content.replace('{$ROOT_PATH}', mw.getRootDir())
    content = content.replace('{$SERVER_PATH}', service_path)
    content = content.replace(
        '{$SERVER_APP}', service_path + '/' + getPluginName())

    content = content.replace('{$STORAGED_DIR}', getFtDir())
    content = content.replace('{$DEFAULT_IP}', mw.getHostAddr())

    return content


def status():
    data = mw.execShell(
        "ps -ef|grep fdfs |grep -v grep | grep -v python | awk '{print $2}'")
    if data[0] == '':
        return 'stop'
    return 'start'


def getFtDir():
    return '/www/fastdfs'


def getConfNameList():
    return ['client.conf', 'storage.conf', 'storage_ids.conf', 'tracker.conf']


def getServiceName():
    return ['fdfs_storaged', 'fdfs_trackerd']


def initDreplace():
    storage_dir = getFtDir() + '/store1'
    if not os.path.exists(storage_dir):
        mw.execShell('mkdir -p ' + storage_dir)

    # log_dir = getServerDir() + '/logs'
    # if os.path.exists(log_dir):
    #     mw.execShell('mkdir -p ' + log_dir)

    conf_dir = getServerDir() + '/conf'
    if not os.path.exists(conf_dir):
        mw.execShell('mkdir -p ' + conf_dir)

    install_ok = getServerDir() + '/install.pl'
    if not os.path.exists(install_ok):
        conf_list = getConfNameList()
        for cl in conf_list:
            pcfg = getServerDir() + '/conf/' + cl
            pcfg_tpl = getPluginDir() + '/conf/' + cl
            content = mw.readFile(pcfg_tpl)
            content = contentReplace(content)
            mw.writeFile(pcfg, content)

        conf_service_list = ['fdfs_trackerd.service', 'fdfs_storaged.service']
        for cl_ll in conf_service_list:
            pser_tpl = getPluginDir() + '/init.d/' + cl_ll
            pser = mw.systemdCfgDir() + '/' + cl_ll
            content = mw.readFile(pser_tpl)
            content = contentReplace(content)
            # print(pser)
            mw.writeFile(pser, content)
        mw.execShell('systemctl daemon-reload')
        # mw.writeFile(install_ok, 'ok')
    return ''


def ftOp(method):
    if mw.isAppleSystem():
        return 'fail'

    initDreplace()

    services = getServiceName()
    for s in services:
        cmd = 'systemctl ' + method + ' ' + s
        data = mw.execShell(cmd)
        if data[1] != '':
            return 'fail'

    return 'ok'


def start():
    return ftOp('start')


def stop():
    return ftOp('stop')


def restart():
    return ftOp('restart')


def reload():
    return ftOp('reload')


def initdStatus():
    if mw.isAppleSystem():
        return "Apple Computer does not support"

    services = getServiceName()
    for s in services:
        shell_cmd = 'systemctl status ' + s + ' | grep loaded | grep "enabled;"'
        data = mw.execShell(shell_cmd)
        if data[0] == '':
            return 'fail'
    return 'ok'


def initdInstall():
    if mw.isAppleSystem():
        return "Apple Computer does not support"

    services = getServiceName()
    for s in services:
        mw.execShell('systemctl enable ' + s)
    return 'ok'


def initdUinstall():
    if mw.isAppleSystem():
        return "Apple Computer does not support"

    services = getServiceName()
    for s in services:
        mw.execShell('systemctl disable ' + s)
    return 'ok'


def runLog():
    path = getConf()
    content = mw.readFile(path)
    rep = 'base_path\s*=\s*(.*)'
    tmp = re.search(rep, content)
    log = tmp.groups()[0] + "/logs/storaged.log"
    return log


def ftEdit():
    conf_list = getConfNameList()
    rdata = []
    cpath = getServerDir() + "/conf"
    for x in conf_list:
        tmp = {}
        tmp['name'] = x
        tmp['path'] = cpath + '/' + x
        rdata.append(tmp)
    return mw.returnJson(True, 'ok', rdata)


if __name__ == "__main__":
    func = sys.argv[1]
    if func == 'status':
        print(status())
    elif func == 'start':
        print(start())
    elif func == 'stop':
        print(stop())
    elif func == 'restart':
        print(restart())
    elif func == 'reload':
        print(reload())
    elif func == 'initd_status':
        print(initdStatus())
    elif func == 'initd_install':
        print(initdInstall())
    elif func == 'initd_uninstall':
        print(initdUinstall())
    elif func == 'conf':
        print(getConf())
    elif func == 'config_tpl':
        print(configTpl())
    elif func == 'read_config_tpl':
        print(readConfigTpl())
    elif func == 'run_log':
        print(runLog())
    elif func == 'ft_edit':
        print(ftEdit())
    else:
        print('error')
