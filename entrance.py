
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

    # t = totalResDict.totalRes() #初始化所有的资源信息
    # t.initFileDict()

    # jc= jsonFileRes.jsonRes(t.filedict)  # 初始化所有json中包含的资源信息
    # jc.initRecordFile()

    # 初始化代码中包含的资源信息


    # cg = fileChange.replaceImage()
    # cg.replaceFile(jc.jsonPaths)
else:
    import types
    import collections
    # 找到指定key值所在的dict
    def searchForKey(pDict , key , pDictList):
        tDict = pDict
        for k , v in tDict.items():
            if cmp(key , k) == 0:
                pDictList.append(tDict)
            else:
                # if type(v) is types.DictType:    # 有序的dict不是常规的dict
                if type(v) is collections.OrderedDict:
                    ttDict =  searchForKey(v , key , pDictList)
                    if ttDict:
                        pDictList.append(ttDict)

    # 修改后，如果使用到了新的plist文件中的资源，要在textures中添加plist文件
    def changeResPath(pDictList , pResDict):
        if not pDictList:
            print "dict list null"
            return
        for tDict in pDictList:
            if not tDict["resourceType"]:
                print tDict
                tDict["path"] = "btn_buxia.png" # 直接改动生效
                tDict["resourceType"] = 1
                tDict["plistFile"] = "abbb/test.plist"
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
        searchOptions(parent, pResDict)
        children = parent.get("children")
        if children:
            for child in children:
                searchOptions(child , pResDict)
                if child.get("children"):
                    searchNodeTree(child, pResDict)

    newJsonFile = "./newJson/1lay_test.json"
    outPutFile = "./newJson/1output.json"
    def streamDispose():
        json_stream = open(newJsonFile , "r+")
        if not json_stream:
            assert (False)
        # print json_stream.read()
        # json_stream.seek(0,0)
        jsondict = json.load(json_stream ,object_pairs_hook=collections.OrderedDict)
        # jsondict = json.loads(json_stream.read())
        textures = jsondict.get("textures")
        if textures:
            print("textures has value")
        else:
            print("textures is null")

        # 遍历节点数
        resDict = {}
        searchNodeTree(jsondict.get("widgetTree") , resDict)
        # print json.dumps( jsondict , ensure_ascii=False ,  encoding= "utf-8" , indent=4)
        str_strean = open(outPutFile, "w+")
        # str_strean.write(json.dumps(jsondict , encoding= "utf-8" , indent=4))
        json.dump(jsondict,str_strean)
        str_strean.close()

        json_stream.close()
    streamDispose()


