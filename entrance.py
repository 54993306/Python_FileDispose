
# -*- coding: UTF-8 -*-
# TEST = False
TEST = True

import os
import json
import re
import codeRes
import comFun
import totalResDict
import jsonFileRes
import fileChange
import packageImage

if not TEST:
    referenceRes = {}    #文件引用计数表

    # t = totalResDict.totalRes() #初始化所有的资源信息
    # t.initFileDict()

    # jc= jsonFileRes.jsonRes()  # 初始化所有json中包含的资源信息
    # jc.initRecordFile()

    # 初始化代码中包含的资源信息
    # cre = codeRes.codeRes()
    # cre.initResList()

    # 小图合并大图
    # pcg = packageImage.packageImage()
    # pcg.packageRes()

    # 修改json文件为使用大图
    # cg = fileChange.replaceImage()
    # cg.replaceFile()
else:
    pathstr = "./oldJson/code.lua"
    str_stream = open(pathstr , "r")
    resList = []
    def replacePattern(match):
        if not match:
            return ""
        print "replacePattern : " + match.group("Pattern")
        return "ccc.png"  # 返回的内容用来替换被匹配的内容

    for lineNum, line in enumerate(str_stream):
        pattern = re.compile(r"[\"](?P<Pattern>[^:\"]*" + r".png" + r")[\"]")  # 找到包含资源的行，所有的资源都会被修改路径，统一进行管理
        # serchObj = pattern.sub(r'<---->\1</---->' , line)  # \1...\9	匹配第n个分组的内容。
        print "before : " + line
        print "after : " + pattern.sub(replacePattern , line)
        # print serchObj
        # print pattern.search(line).group("Pattern")  # 对于一行中，包含多个类型的情况是否有相应的考虑
        # serchList = pattern.findall(line)  # 对于一行中，包含多个类型的情况
        # resList.extend(serchList)
    # os.system("cmd && wsl && sed")
    oldpath = os.getcwd()
    os.chdir("D:\Python_FileDispose")
    print os.getcwd()
    TEXTURE_PACK_PATH = r"C:\Program Files (x86)\TexturePacker\bin"
    # os.system("bash;sed -i 's/new/ccc/g' ./file.txt")
    # os.popen("sed -i 's/new/ccc/g' ./file.txt")
    # os.chdir(TEXTURE_PACK_PATH)
    # os.system("TexturePacker.exe")
    # os.system("wsl sed -i 's/ccc/new/g' ./file.txt")
    os.system("wsl sed -i 's/new/ccc/g' ./file.txt")
    os.chdir(oldpath)
    print os.getcwd()
