#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import platform
# 模版项目svn地址
TemplateUrl = 'https://192.168.7.104/dsqpClient/pengyoukaifang/2Dmajong/common/code_template'

# 新增项目名称(用于创建时提交的消息)
ProjectName = '地方工程 by LinXC'
# 新增项目远端地址
ProjectUrl = 'https://192.168.7.104/dsqpClient/pengyoukaifang/2Dmajong/package/LandScape/HeNanQuanJi/3730/trunk'
# 新增项目本地地址
LocalPath = r'D:\Svn_2d\AutoPackage\LandScape\HeNanQuanJi\3730\trunk'
# 新增项目外链内容
PropFile = r'D:\Svn_2d\AutoPackage\LandScape\HeNanQuanJi\3730\svn_external.txt'

# svn用户设置
SvnUser = '"wangzhi"'
SvnPwd = '"#5fgrj)Uk"'
SvnAuthStr = '--username %s --password %s --no-auth-cache' % (SvnUser, SvnPwd)

def svnCheckOut(url, localPath):
    if platform.system() == "Windows":
        url = url.encode('gbk')
        os.system("svn checkout -r HEAD %s %s" % (url, localPath))
    else:
        os.system("svn checkout -r HEAD %s %s %s" % (SvnAuthStr, url, localPath))

def svnUpdate(localPath):
    if platform.system() == "Windows":
        os.system("svn update -r HEAD %s" % (localPath))
    else:
        os.system("svn update -r HEAD %s %s" % (SvnAuthStr, localPath))

def svnRevert(localFile):
    if platform.system() == "Windows":
        os.system("svn revert %s" % (localFile))
    else:
        os.system("svn revert %s %s" % (SvnAuthStr, localFile))

def svnMkbranch(url, msg):
    if platform.system() == "Windows":
        msg = msg.decode('utf-8').encode('gbk')
        os.system("svn cp %s %s -m %s" % (TemplateUrl, url, msg))
    else:
        os.system("svn cp %s %s %s -m %s" % (SvnAuthStr, TemplateUrl, url, msg))

def svnMkdir(url, msg):
    if platform.system() == "Windows":
        msg = msg.decode('utf-8').encode('gbk')
        os.system("svn mkdir %s -m %s" % (url, msg))
    else:
        os.system("svn mkdir %s %s -m %s" % (SvnAuthStr, url, msg))

def svnPorpsetFromFile(filePath, localPath):
    if platform.system() == "Windows":
        os.system('svn ps svn:externals -F %s %s' % (filePath, localPath))
    else:
        os.system('svn %s ps svn:externals -F %s %s' % (SvnAuthStr, filePath, localPath))

def svnCommit(localPath, msg):
    if platform.system() == "Windows":
        msg = msg.decode('utf-8').encode('gbk')
        os.system('svn ci %s -m %s' % (localPath, msg))
    else:
        os.system('svn %s ci %s -m %s' % (SvnAuthStr, localPath, msg))

if __name__ == "__main__":
    svnMkbranch(ProjectUrl, "[新增][新增%s工程]" % ProjectName)
    svnCheckOut(ProjectUrl, LocalPath)
    svnPorpsetFromFile(PropFile, LocalPath)
    svnCommit(LocalPath, '[新增][用命令行方式生成外链]')
    svnUpdate(LocalPath)
