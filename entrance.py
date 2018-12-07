
# -*- coding: UTF-8 -*-

import os
import json
import re

import comFun
import totalResDict
import jsonFileRes
import fileChange

referenceRes = {}    #文件引用计数表

t = totalResDict.totalRes() #初始化所有的资源信息
t.initFileDict()

jc= jsonFileRes.jsonRes(t.filedict)  # 初始化所有json中包含的资源信息
jc.initRecordFile()

# 初始化代码中包含的资源信息

cg = fileChange.replaceImage()
# cg.replaceFile(jc.jsonPaths)

newJsonFile = "./newJson/rp_1lay_test.json"
def streamDispose(newJsonFile):
    json_stream = open(newJsonFile, "r+")
    if not json_stream:
        assert (False)
    jsondict = json.load(json_stream)
    for k_1 , v_1 in jsondict.iterkeys():   #对一级路径的资源做判断 textures、texturesPng、widgetTree
        # print k_1
        if cmp(k_1 , "textures"):   #里面存在的资源一定是plist文件
            for res in v_1:
                comFun.getFileMd5(res)

    # print json.dumps( jsondict , ensure_ascii=False ,  encoding= "utf-8" , indent=4)
    json_stream.close()
# streamDispose(newJsonFile)