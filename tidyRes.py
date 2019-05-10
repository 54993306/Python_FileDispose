
# -*- coding: UTF-8 -*-

# 将被使用了的资源从real_res中取出来

import comFun
import os
import re
import shutil
import json
import collections
import fileDataHandle as FD

class tidyRes:

    def __init__(self):
        self.tidyInfo = collections.OrderedDict()  # 存储整理相关的信息

        self.PackagePath = comFun.MOVETOCODEPATH + "res_package/"
        comFun.createNewDir(self.PackagePath)

    def moveCsb(self):
        jsonPaths = []
        comFun.initPathFiles(comFun.SEARCHJSONPATH, jsonPaths)
        for jsonPath in jsonPaths:
            if not re.search(r".json", jsonPath):
                continue
            print "<string>" + os.path.basename(jsonPath) + "</string>"
        comFun.moveTypeFileToTarget( comFun.UIPROJECT + r"/Export", ".csb" , comFun.REALPATH)

    # 移动UI类所使用资源至UI工程和代码工程
    def moveUIRes(self):
        UIChange = comFun.GetDataByFile(comFun.CHANGERESULT)
        JsonValidResList = []
        for jsonPath , ChangeList in UIChange.iteritems():
            for index , ChangeInfo in ChangeList.iteritems():
                if not ChangeInfo["new"]["plistFile"] and not ChangeInfo["new"]["path"]:
                    print(" ERROR " + jsonPath + " Not have Change")
                    continue
                newPath = ""
                if ChangeInfo["new"]["plistFile"]:
                    newPath = ChangeInfo["new"]["plistFile"]
                elif ChangeInfo["new"]["path"]:
                    newPath = ChangeInfo["new"]["path"]
                if not newPath in JsonValidResList:
                    JsonValidResList.append(newPath)
                # 将文件拷贝到代码工程
                self.copyFileToPath(comFun.OUTPUTTARGET + newPath, comFun.REALPATH + newPath)
                # 将文件拷贝到UI工程
                self.copyFileToPath(comFun.OUTPUTTARGET + newPath, comFun.TARGETPATH + newPath)
        self.tidyInfo["JsonChange"] = JsonValidResList

    def moveCodeRes(self):
        CodeChange = comFun.GetDataByFile(comFun.CODERESMESSAGE)
        LuaValidResList = []
        for luaPath , ChangeInfos in CodeChange.iteritems():  # 代码中对每个json文件中使用的资源有过一个去重处理 dict key
            if not "ValidChange" in ChangeInfos:
                continue
            for md5code , ChangeInfo in ChangeInfos["ValidChange"].iteritems():
                if not ChangeInfo["new"] in LuaValidResList:
                    LuaValidResList.append("Channel/" + ChangeInfo["new"])
                self.copyFileToPath(comFun.OUTPUTTARGET + ChangeInfo["new"], comFun.REALPATH + ChangeInfo["new"])
            # if not "PlistList" in ChangeInfos:
            #     continue
            # for md5code , PListPath in ChangeInfos["PlistList"].iteritems():
            #     self.copyFileToPath(PListPath, self.PackagePath + "/" + os.path.basename(PListPath))
        self.tidyInfo["CodeChange"] = LuaValidResList
        print(json.dumps(LuaValidResList, ensure_ascii=False, encoding="utf -8", indent=4))
        comFun.RecordToJsonFile(comFun.TIDYRECORD, self.tidyInfo)

    # 拷贝文件到新路径
    def copyFileToPath(self , oldPath , newPath):
        if not os.path.isabs(oldPath):
            oldPath = os.path.abspath(oldPath)
        oldPath = comFun.turnBias(oldPath)
        dir = os.path.dirname(newPath)          # 创建文件路径
        if not os.path.isdir(dir):
            os.makedirs(dir, 0o777)
        if os.path.isfile(oldPath):
            if os.path.isfile(newPath):
                # print "new path is exist"
                return
            else:
                newPath = comFun.turnBias(newPath)
                shutil.copyfile(oldPath , newPath)
                self.otherTypeDispose(oldPath , newPath)
                self.recordMove(oldPath , newPath)
        else:
            print "not find file : " + oldPath
            return

    def otherTypeDispose(self , oldPath , newPath):
        basePath,resType = os.path.splitext(oldPath)
        if not resType:
            return
        elif cmp(resType, ".fnt") == 0 or cmp(resType, ".plist") == 0:
            basePath = basePath + ".png"
            newPath = os.path.dirname(newPath) + "/" + os.path.basename(basePath)
            print "otherTypeDispose ：" + basePath + " >>> " + newPath
            self.copyFileToPath(basePath , newPath)
        elif cmp(resType, ".png") == 0:
            return
        else:
            print "special type : " + oldPath    # 将没有处理的类型输出看看是什么

    def recordMove(self, oldPath , newPath):
        oldPath = re.sub(comFun.turnBias(comFun.OUTPUTTARGET), "Channel/", oldPath)
        newPath = re.sub(comFun.turnBias(comFun.MOVETOCODEPATH), "CodePath/", newPath)
        if "MoveRecord" in self.tidyInfo:
            self.tidyInfo["MoveRecord"][oldPath] = newPath
        else:
            MoveRecord = {}
            self.tidyInfo["MoveRecord"] = MoveRecord
            MoveRecord[oldPath] = newPath
    # 找到代码中所有使用的资源，判断哪些csb是没有在json中被使用的，对应的UIJson文件是否有图片是可以删除掉的。
    # 引用了不存在的csb NotFount、NoChange 数组可以解决,代码中引用了不存在的资源都需要做处理
    # 遍历所有的csb，如果不存在于被改动的部分，表示在代码中没有使用，一旦使用了，随着路径的移动会发生改动
    # 多余的csb没有被人引用，只需要比对，被复制过去的部分，和原来的之间的差异，就可以知道每种资源的多余情况

    # 多余的资源，比对被复制过去的实际使用csb得出多余的。
    # 使用了不存在的，分析NotFound和NotChange即可得出。

    # 在代码中和在Json中使用了Plist文件的情况。 最主要的问题就是，名称被修改了之后，是否会发生无法使用的情况
    # 还没有做过实验和分析。