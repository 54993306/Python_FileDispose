# -*- coding: UTF-8 -*-

import os
import json
import re
import types
import collections
import comFun
import copy

# 根据图片的引用计数合成大图成功后，对工程的json文件进行修改
# 测试修改的算法是否有效
# 合成大图后的相应匹配数据要确定
# 原来使用的是某张小图，合成大图后，应该改成什么样子才是正确的

# json修改小图 jsonfilename
outputPath = "./newJson/"
import shutil
class replaceImage:
    changeRecord = {}
    def replaceFile(self , jsonPaths):
        jsonPaths = ["./newJson/1lay_test.json"]
        if not os.path.exists(outputPath):
            os.mkdir(outputPath , 0o777)        # 创建输出路径
        for jsonPath in jsonPaths:
            if not os.path.isfile(jsonPath):
                assert(False)
            if not re.search(r".json" , jsonPath):
                assert(False)
            _ , filename = os.path.split(jsonPath)
            newFilePath = outputPath + "rp_" +filename
            shutil.copyfile(jsonPath , newFilePath)
            if not os.path.isabs(newFilePath):
                newFilePath = os.path.abspath(newFilePath)
            if not os.path.isfile(newFilePath):
                assert(False)
            print(newFilePath)
            self.streamDispose(newFilePath)


    def streamDispose(self , newJsonFile):
        json_stream = open(newJsonFile, "r+")
        if not json_stream:
            assert (False)
        # print json_stream.read()
        # json_stream.seek(0,0)
        jsondict = json.load(json_stream, object_pairs_hook=collections.OrderedDict)
        # jsondict = json.loads(json_stream.read())
        textures = jsondict.get("textures")
        if textures:
            print("textures has value")
        else:
            print("textures is null")
        outPutFile = "./newJson/1output.json"
        # 遍历节点数
        resDict = {}
        self.changeRecord[newJsonFile] = resDict  # 只是复制了一个引用
        self.searchNodeTree(jsondict.get("widgetTree"), resDict)
        # print json.dumps( jsondict , ensure_ascii=False ,  encoding= "utf-8" , indent=4)
        str_strean = open(outPutFile, "w+")
        # str_strean.write(json.dumps(jsondict , encoding= "utf-8" , indent=4))
        json.dump(jsondict, str_strean)
        str_strean.close()

        json_stream.close()

    # 找到指定key值所在的dict
    def searchForKey(self, pDict , key , pDictList):
        for k , v in pDict.items():
            if cmp(key , k) == 0:
                pDictList.append(pDict)
            else:
                # if type(v) is types.DictType:    # 有序的dict不是常规的dict
                if type(v) is collections.OrderedDict:
                    ttDict =  self.searchForKey(v , key , pDictList)
                    if ttDict:
                        pDictList.append(ttDict)

    # 修改后，如果使用到了新的plist文件中的资源，要在textures中添加plist文件
    def changeResPath(self , pDictList , pResDict):
        if not pDictList:
            print "dict list null"
            return
        for tDict in pDictList:
            if not tDict["resourceType"]:
                pResDict["old"] = copy.deepcopy(tDict)
                tDict["path"] = "btn_buxia.png" # 直接改动生效
                tDict["resourceType"] = 1
                tDict["plistFile"] = "abbb/test.plist"
                pResDict["new"] = copy.deepcopy(tDict)
        # resDict 用于记录新增 plist 文件

    def searchOptions(self, pNode , pResDict):
        if pNode.has_key("options"):
            tDictList = []
            self.searchForKey(pNode["options"], "resourceType" , tDictList)
            self.changeResPath(tDictList, pResDict)
        else:
            print "child un has options"
            assert (False)

    def searchNodeTree(self, parent , pResDict):
        if not parent:
            return
        self.searchOptions(parent, pResDict)
        children = parent.get("children")
        if children:
            for child in children:
                self.searchOptions(child , pResDict)
                if child.get("children"):
                    self.searchNodeTree(child, pResDict)

