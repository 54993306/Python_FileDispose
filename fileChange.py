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
        allFileMD5.close()

        newFileMD5 = open(comFun.NEWMD5 , "r")
        self.newFileMD5 = json.load(newFileMD5)
        newFileMD5.close()

        plistMd5 = open(comFun.PLISTMD5 , "r")
        self.plistMd5 = json.load(plistMd5)
        plistMd5.close()

        newPaths = open(comFun.TYPENEWPATH , "r")
        self.newPaths = json.load(newPaths)
        newPaths.close()


    # 记录替换结果数据
    def recordResult(self):
        changeRecord = open(comFun.CHANGERESULT , "w+")
        changeRecord.write(json.dumps(self.changeRecord, ensure_ascii=False, encoding="utf -8", indent=4))
        changeRecord.close()

    # 做新旧资源替换
    def replaceFile(self):
        self.initNewPathDict()
        jsonPaths = ["D:\Svn_2d\UI_Shu\Json/infoNode.json"]
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
        outPutFile = "./newJson/" + os.path.basename(newJsonFile)
        resDict = {}
        self.changeRecord[newJsonFile] = resDict                        # 只是复制了一个引用
        self.searchNodeTree(jsondict.get("widgetTree"), resDict)
        # print json.dumps(resDict, ensure_ascii=False, encoding="utf -8", indent=4)
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

    # 从options数组中找资源信息
    def searchOptions(self, pNode , pResDict):
        if pNode.has_key("options"):
            tDictRes = []
            self.searchForKey(pNode["options"], "resourceType" , tDictRes)
            if tDictRes:
                # rjust(right)右对齐， ljust(left)左对齐
                # print("Node tag : " + str(pNode["options"]["tag"]).ljust(6) + " resNum :" + str(len(tDictRes)))
                # 输出每个需要修改的类型的tag是否有重复部分
                self.changeResPath(tDictRes, pResDict)
            # else:
                # print "not have resourceType tag:" + str(pNode["options"]["tag"])  # 输出对应节点的tag，用于手动验证

            tDictFont = []
            self.searchForKey(pNode["options"], "fontName", tDictFont)
            if tDictFont:
                self.changeFontPath(tDictFont , pResDict)
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
                record = {}
                pResDict[str(len(pResDict))] = record
                record["old"] = copy.deepcopy(tDict)
                newFileDict = self.getNewResInfo(tDict["path"])
                if type(newFileDict)is types.DictType:
                    tDict["path"] = newFileDict["newpath"]  # 直接改动生效
                    tDict["plistFile"] = newFileDict["plist"]
                    tDict["resourceType"] = 1
                else:
                    tDict["path"] = newFileDict
                    tDict["resourceType"] = 0
                    tDict["plistFile"] = ""
                record["new"] = copy.deepcopy(tDict)
        # resDict 用于记录新增 plist 文件

    def changeFontPath(self , pDictList , pResDict):
        for tDict in pDictList:
            if tDict["fontName"]:
                # tDict["fontName"]
                # tDict["fontName"] = self.getNewFontInfo(tDict["fontName"]) # 字体还有微软雅黑类型
                tDict["fontName"] = "res_TTF/1283_fangzhengcuyuan.TTF" # 统一字体格式


    # 根据原图片路径获取新的图片信息
    def getNewResInfo(self , path):
        filemd5 = self.getFileMd5(path)
        newFileName = self.getNewFilePath(filemd5)

        plistpath = None
        if filemd5 in self.plistMd5:
            plistpath = self.plistMd5.get(filemd5)
            newFileName = os.path.basename(newFileName)
        else:
            _,filetype = os.path.splitext(newFileName)
            if cmp(filetype , ".png") != 0:
                return self.otherFileData(filemd5)
            if max(Image.open(newFileName).size) >= comFun.PNG_MAX_SIZE:
                print "max size path : " + path
                return self.otherFileData(filemd5)
            else:
                print "can't found plist file : " + path + "  md5:" + filemd5 + " newPath :" + newFileName
                return newFileName    # 只是改了名字没有合并大图的图，只是修改了文件的路径

        newFileDict = {}
        newFileDict["newpath"] = newFileName
        newFileDict["plist"] = plistpath
        newFileDict["oldpath"] = path
        # print json.dumps(newFileDict, ensure_ascii=False, encoding="utf -8", indent=4)
        return newFileDict

    # 获取文件md5值
    def getFileMd5(self , path):
        if not path:
            return ""
        path = r"D:\Svn_2d\S_GD_Heji\res/hall/" + path
        if not os.path.isabs(path):
            path = os.path.abspath(path)
        filemd5 = None
        if os.path.isfile(path):
            if path in self.allFileMD5:
                filemd5 = self.allFileMD5.get(path)
            else:
                print "can't found md5 : " + path
                assert(False)
        else:
            print "can't find file :" + path
        return filemd5

    # 根据md5值获取文件新路径
    def getNewFilePath(self , filemd5):
        newFileName = None
        if filemd5 in self.newFileMD5:
            newFileName = self.newFileMD5.get(filemd5)
        else:
            print "can't found new file name : " + path + " md5 : " + filemd5
        return newFileName

    # 对fnt类的用户自定义的字体(LabelBMFont)进行处理
    def otherFileData(self , filemd5):
        if filemd5 in self.newPaths:
            print "new big path : " + self.newPaths.get(filemd5)
            return self.newPaths.get(filemd5)
        else:
            assert(False)

    # 获取新的字体路径，实际上需要统一字体为方正粗圆
    def getNewFontInfo(self , path):
        filemd5 = self.getFileMd5(path)
        return self.otherFileData(filemd5)