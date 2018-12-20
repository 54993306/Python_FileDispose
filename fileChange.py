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
    allFileMD5 = {}
    newFileMD5 = {}
    plistMd5 = {}

    # 根据老图的路径，获取新图所在位置,老路径对应的新图的大图路径和plist文件信息
    def initNewPathDict(self):
        ALLFILES = "./output/allfile.json"
        allFileMD5 = open(ALLFILES , "r")
        self.allFileMD5 = json.load(allFileMD5)

        NEWMD5 = "./output/newmd5.json"
        newFileMD5 = open(NEWMD5 , "r")
        self.newFileMD5 = json.load(newFileMD5)

        PLISTMD5 = "./output/plistMd5.json"  # 图片md5值对应存储的plist文件
        plistMd5 = open(PLISTMD5 , "r")
        self.plistMd5 = json.load(plistMd5)
    # 做新旧资源替换
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

    # 文件处理
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

    def searchOptions(self, pNode , pResDict):
        if pNode.has_key("options"):
            tDictList = []
            self.searchForKey(pNode["options"], "resourceType" , tDictList)
            self.changeResPath(tDictList, pResDict)
        else:
            print "child un has options"
            assert (False)

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
                newFileDict = self.getNewResInfo(tDict["path"])
                if type(newFileDict)is types.DictType:
                    tDict["path"] = newFileDict["name"]  # 直接改动生效
                    tDict["resourceType"] = 1
                    tDict["plistFile"] = newFileDict["plist"]
                else:
                    tDict["path"] = newFileDict
                    tDict["resourceType"] = 0
                    tDict["plistFile"] = ""
                pResDict["new"] = copy.deepcopy(tDict)
        # resDict 用于记录新增 plist 文件

    def getNewResInfo(self , path):
        if not os.path.isabs(path):
            path = os.path.abspath(path)
        if os.path.isfile(path):
            filemd5 = None
            if path in self.allFileMD5:
                filemd5 = self.allFileMD5.get(path)
            else:
                print "can't found md5 : " + path
                assert(False)

            newFileName = None
            if filemd5 in self.newFileMD5:
                newFileName = self.newFileMD5.get(filemd5)
            else:
                print "can't found new file name : " + path + " md5 : " + filemd5
                return

            plistpath = None
            if filemd5 in self.plistMd5:
                plistpath = self.plistMd5.get(filemd5)
            else:
                print "can't found plist file : " + path + " md5: " + filemd5
                return newFileName    # 只是改了名字没有合并大图的图，只是修改了文件的路径

            newFileDict = {}
            newFileDict["name"] = newFileName
            newFileDict["plist"] = plistpath
            return newFileDict
        else:
            print "can't find file :" + path
