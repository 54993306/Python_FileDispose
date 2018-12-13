
# -*- coding: UTF-8 -*-

TEST = True
# TEST = False

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
    import types
    # 找到指定key值所在的dict
    def searchForKey(pDict , key , pDictList):
        tDict = pDict
        for k , v in tDict.items():
            if k == key:
                pDictList.append(tDict)
            else:
                if type(v) is types.DictType:
                    ttDict =  searchForKey(v , key , pDictList)
                    if ttDict:
                        pDictList.append(ttDict)

    # 修改后，如果使用到了新的plist文件中的资源，要在textures中添加plist文件
    def changeResPath(pDict , pResDict):
        if pDict:
            print(pDict)
        else:
            print "dict null"
        # resDict 用于记录新增 plist 文件

    def searchOptions(pNode , pResDict):
        if pNode.has_key("options"):
            tDictList = []
            searchForKey(pNode["options"], "resourceType" , tDictList)
            changeResPath(tDictList, pResDict)
        else:
            print "child un has options"
            assert (False)

    def searchNodeTree(parent , pResDict):
        if not parent:
            return
        print "options name 2: " + parent["options"]["name"]
        searchOptions(parent, pResDict)
        children = parent.get("children")
        if children:
            for child in children:
                print "options name 1: " + child["options"]["name"]
                searchOptions(child , pResDict)
                if child.get("children"):
                    searchNodeTree(child, pResDict)


    newJsonFile = "./newJson/1lay_test.json"
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


