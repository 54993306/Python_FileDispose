
# -*- coding: UTF-8 -*-

# TEST = True
TEST = False

import os
import json
import re

import comFun
import totalResDict
import jsonFileRes
import fileChange

if not TEST:
    referenceRes = {}    #文件引用计数表

    t = totalResDict.totalRes() #初始化所有的资源信息
    t.initFileDict()

    jc= jsonFileRes.jsonRes(t.filedict)  # 初始化所有json中包含的资源信息
    jc.initRecordFile()

    # 初始化代码中包含的资源信息

    # cg = fileChange.replaceImage()
    # cg.replaceFile(jc.jsonPaths)
else:
    def searchNodeTree(parent , resDict):
        if not parent:
            return
        children = parent.get("children")
        # if children:

    newJsonFile = "./newJson/hall.json"
    def streamDispose(newJsonFile):
        json_stream = open(newJsonFile, "r+")
        if not json_stream:
            assert (False)
        jsondict = json.load(json_stream)
        textures = jsondict.get("textures")
        if textures:
            print("textures has value")
        else:
            print("textures is null")

        # 遍历节点数
        resDict = {}
        searchNodeTree(jsondict.get("widgetTree") , resDict)
        # print json.dumps( jsondict , ensure_ascii=False ,  encoding= "utf-8" , indent=4)

        json_stream.close()
    streamDispose(newJsonFile)


