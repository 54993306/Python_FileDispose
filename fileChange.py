# -*- coding: UTF-8 -*-

import os
import json
import re
import types
import collections
import comFun
import copy
from PIL import Image

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
    resNum = 0

    # 根据老图的路径，获取新图所在位置,老路径对应的新图的大图路径和plist文件信息
    def initNewPathDict(self):
        allFileMD5 = open(comFun.ALLFILES , "r")
        self.allFileMD5 = json.load(allFileMD5)

        newFileMD5 = open(comFun.NEWMD5 , "r")
        self.newFileMD5 = json.load(newFileMD5)

        plistMd5 = open(comFun.PLISTMD5 , "r")
        self.plistMd5 = json.load(plistMd5)

    # 记录替换结果数据
    def recordResult(self):
        changeRecord = open(comFun.CHANGERESULT , "w+")
        changeRecord.write(json.dumps(self.changeRecord, ensure_ascii=False, encoding="utf -8", indent=4))
        changeRecord.close()

    # 做新旧资源替换
    def replaceFile(self):
        self.initNewPathDict()
        jsonPaths = ["D:\Svn_2d\UI_Shu\Json/hall.json"]
        if not os.path.exists(outputPath):
            os.mkdir(outputPath , 0o777)        # 创建输出路径
        for jsonPath in jsonPaths:
            if not os.path.isfile(jsonPath):
                assert(False)
            if not re.search(r".json" , jsonPath):
                assert(False)
            _ , filename = os.path.split(jsonPath)
            newFilePath = outputPath +filename
            shutil.copyfile(jsonPath , newFilePath)
            if not os.path.isabs(newFilePath):
                newFilePath = os.path.abspath(newFilePath)
            if not os.path.isfile(newFilePath):
                assert(False)
            self.streamDispose(newFilePath)
        self.recordResult()

    # 文件处理
    def streamDispose(self , newJsonFile):
        json_stream = open(newJsonFile, "r+")
        if not json_stream:
            assert (False)
        jsondict = json.load(json_stream, object_pairs_hook=collections.OrderedDict )
        outPutFile = "./newJson/1output.json"
        resDict = {}
        self.changeRecord[newJsonFile] = resDict                        # 只是复制了一个引用
        self.searchNodeTree(jsondict.get("widgetTree"), resDict)
        str_strean = open(outPutFile, "w+")
        # json.dump(jsondict, str_strean)
        str_strean.write(json.dumps(jsondict, encoding="utf -8", indent=4))
        str_strean.close()
        json_stream.close()

    # 遍历节点树
    def searchNodeTree(self, parent , pResDict):
        if not parent:
            return
        self.searchOptions(parent, pResDict)
        children = parent.get("children")
        if children:
            self.searchChildren(children , pResDict)

    # 对子节点树进行遍历
    def searchChildren(self , childrens , pResDict):
        for child in childrens:
            self.searchOptions(child, pResDict)
            if child.get("children"):
                self.searchChildren(child.get("children"), pResDict)

    def searchOptions(self, pNode , pResDict):
        if pNode.has_key("options"):
            tDictList = []
            self.searchForKey(pNode["options"], "resourceType" , tDictList)
            if not tDictList:
                # print "not have resourceType tag:" + str(pNode["options"]["tag"])  # 输出对应节点的tag，用于手动验证
                return
            # rjust(right)右对齐， ljust(left)左对齐
            # print("Node tag : " + str(pNode["options"]["tag"]).ljust(6) + " resNum :" + str(len(tDictList)))
            # 输出每个需要修改的类型的tag是否有重复部分
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
        for tDict in pDictList:
            if not tDict["resourceType"] and tDict["path"]:
                pResDict["old"] = copy.deepcopy(tDict)
                newFileDict = self.getNewResInfo(tDict["path"])
                if type(newFileDict)is types.DictType:
                    tDict["path"] = newFileDict["newpath"]  # 直接改动生效
                    tDict["plistFile"] = newFileDict["plist"]
                    tDict["resourceType"] = 1
                else:
                    tDict["path"] = newFileDict
                    tDict["resourceType"] = 0
                    tDict["plistFile"] = ""
                pResDict["new"] = copy.deepcopy(tDict)
        # resDict 用于记录新增 plist 文件

    def getNewResInfo(self , path):
        if not path:
            return ""
        path = r"D:\Svn_2d\S_GD_Heji\res/hall/" + path
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
                newFileName = os.path.basename(newFileName)
            else:
                if max(Image.open(path).size) >= comFun.PNG_MAX_SIZE:
                    print "max size path : " + path
                else:
                    print "can't found plist file : " + path + "  md5:" + filemd5
                return newFileName    # 只是改了名字没有合并大图的图，只是修改了文件的路径

            newFileDict = {}
            newFileDict["newpath"] = newFileName
            newFileDict["plist"] = plistpath
            newFileDict["oldpath"] = path
            # print json.dumps(newFileDict, ensure_ascii=False, encoding="utf -8", indent=4)
            return newFileDict
        else:
            print "can't find file :" + path
