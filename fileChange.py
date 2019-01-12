# -*- coding: UTF-8 -*-

import os
import json
import re
import types
import collections
import comFun
import copy
import shutil
import fileDataHandle as DF

# json修改小图 jsonfilename
class replaceImage:

    def __init__(self):
        self.changeRecord = {}
        self.plistMd5 = {}
        self.resNum = 0

        plistMd5 = open(comFun.PLISTMD5, "r")
        self.plistMd5 = json.load(plistMd5)
        plistMd5.close()

        self.FileData = DF.fileDataHandle()

    # 做新旧资源替换
    def replaceFile(self):
        jsonPaths = []
        comFun.initPathFiles(comFun.SEARCHJSONPATH , jsonPaths)
        jsonPaths = ["D:\Svn_2d\UI_Shu\Json\obtain_prop_dialog.json","D:\Svn_2d\UI_Shu\Json\hall.json"]
        if not os.path.exists(comFun.OUTPUTPATH):
            os.mkdir(comFun.OUTPUTPATH , 0o777)        # 创建输出路径
        for jsonPath in jsonPaths:
            if not re.search(r".json" , jsonPath):
                continue
            if not os.path.isfile(jsonPath):
                assert(False)
            _ , filename = os.path.split(jsonPath)
            newFilePath = comFun.OUTPUTPATH + filename
            shutil.copyfile(jsonPath , newFilePath)
            self.streamDispose(newFilePath)
        # 对数据进行记录处理
        comFun.RecordToJsonFile(comFun.CHANGERESULT, self.changeRecord)

    # 文件处理
    def streamDispose(self , newJsonFile):
        json_stream = open(newJsonFile, "r")
        jsondict = json.load(json_stream, object_pairs_hook=collections.OrderedDict )
        json_stream.close()
        resDict = {}
        self.changeRecord[newJsonFile] = resDict  # 只是复制了一个引用
        self.recordDict = resDict
        self.searchNodeTree(jsondict.get("widgetTree"))
        str_strean = open(newJsonFile, "w+")
        # json.dump(jsondict, str_strean)
        str_strean.write(json.dumps(jsondict, encoding="utf -8", indent=4))
        str_strean.close()

    # 遍历节点树
    def searchNodeTree(self, parent):
        if not parent:
            return
        self.searchOptions(parent)
        children = parent.get("children")
        if children:
            self.searchChildren(children)

    # 对子节点树进行遍历
    def searchChildren(self , childrens):
        for child in childrens:
            self.searchOptions(child)
            if child.get("children"):
                self.searchChildren(child.get("children"))

    # 从options数组中找资源信息
    def searchOptions(self, pNode):
        if pNode.has_key("options"):
            tDictRes = []
            self.searchForKey(pNode["options"], "resourceType" , tDictRes)
            if tDictRes:
                # print("Node tag : " + str(pNode["options"]["tag"]).ljust(6) + " resNum :" + str(len(tDictRes)))
                # 输出每个需要修改的类型的tag是否有重复部分
                self.changeResPath(tDictRes)
            # else:
                # print "not have resourceType tag:" + str(pNode["options"]["tag"])  # 输出对应节点的tag，用于手动验证
            tDictFont = []
            self.searchForKey(pNode["options"], "fontName", tDictFont)
            self.changeFontPath(tDictFont)
        else:
            print "child un has options"
            assert (False)

    # 找到指定key值所在的dict
    def searchForKey(self, pDict , key , pDictList):
        for k , v in pDict.items():
            if cmp(key , k) == 0:
                pDictList.append(pDict)
            else:
                if type(v) is collections.OrderedDict: # 有序的dict不是常规的dict , types.DictType
                    ttDict =  self.searchForKey(v , key , pDictList)
                    if ttDict:
                        pDictList.append(ttDict)

    # 修改后，如果使用到了新的plist文件中的资源，要在textures中添加plist文件
    def changeResPath(self , pDictList):
        for tDict in pDictList:
            if not tDict["resourceType"] and tDict["path"]:
                record = {}
                self.recordDict[str(len(self.recordDict))] = record
                record["old"] = copy.deepcopy(tDict)
                newFileDict = self.getNewResInfo(tDict["path"])
                if type(newFileDict)is types.DictType:
                    tDict["path"] = newFileDict["newpath"]  # 直接改动生效
                    tDict["plistFile"] = newFileDict["plist"]
                    tDict["resourceType"] = 1
                else:
                    tDict["path"] = re.sub(comFun.OUTPUTTARGET , "" , newFileDict ) # 去除本地路径
                    tDict["resourceType"] = 0
                    tDict["plistFile"] = ""
                record["new"] = copy.deepcopy(tDict)

    # 统一字体格式
    def changeFontPath(self , pDictList):
        if not pDictList:
            return
        for tDict in pDictList:
            tDict["fontName"] = "res_TTF/1012003.TTF"

    # 根据原图片路径获取新的图片信息
    def getNewResInfo(self , path):
        path = comFun.turnBias(comFun.REALPATH + path)
        md5code = self.FileData.getFileMd5(path)
        newFileName = self.FileData.getNewPathByMd5Code(md5code) # 需要做一个去处本地路径处理

        if md5code in self.plistMd5:
            newFileDict = {}
            newFileDict["newpath"] = os.path.basename(newFileName)
            newFileDict["plist"] = self.plistMd5.get(md5code)
            newFileDict["oldpath"] = path
            # print json.dumps(newFileDict, ensure_ascii=False, encoding="utf -8", indent=4)
            return newFileDict
        else:
            if self.FileData.getTPathByMd5Code(md5code):  # 包括大图，fnt，和手动设置为不进行打包的聂内容集合
                return self.FileData.getTPathByMd5Code(md5code)
            print "can't found plist file : " + path + "  md5:" + md5code + " newPath :" + newFileName
            return newFileName