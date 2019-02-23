
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
        self.tidyInfo["Channel"] = comFun.OUTPUTTARGET
        self.tidyInfo["CodePath"] = comFun.MOVETOCODEPATH
        self.UIChange = comFun.GetDataByFile(comFun.CHANGERESULT)
        self.CodeChange = comFun.GetDataByFile(comFun.CODERESMESSAGE)

        self.UIResPath = comFun.TARGETPATH + comFun.RESFOLDER
        comFun.createNewDir(self.UIResPath)

        self.CodeResPath = comFun.MOVETOCODEPATH + comFun.RESFOLDER
        comFun.createNewDir(self.CodeResPath)

        self.PackagePath = comFun.MOVETOCODEPATH + comFun.RESPACKAGE
        comFun.createNewDir(self.PackagePath)
        # self.moveCsb()   # 需要手动操作

        self.tidy()

    def moveCsb(self):
        jsonPaths = []
        comFun.initPathFiles(comFun.SEARCHJSONPATH, jsonPaths)
        for jsonPath in jsonPaths:
            if not re.search(r".json", jsonPath):
                continue
            print "<string>" + os.path.basename(jsonPath) + "</string>"

        comFun.moveTypeFileToTarget( comFun.UIPROJECT + r"/Export", ".csb" , comFun.REALPATH)

    # 实际移动的文件和原去重后的文件想比较，得出的差异就是每种资源多余的文件差异。
    def tidy(self):
        self.tidyInfo["JsonChange"] = self.moveUIRes()
        self.tidyInfo["CodeChange"] = self.moveCodeRes()
        print(json.dumps(self.tidyInfo, ensure_ascii=False, encoding="utf -8", indent=4))
        comFun.RecordToJsonFile(comFun.TIDYRECORD, self.tidyInfo)

    def moveUIRes(self):
        JsonValidResList = []
        for jsonPath , ChangeList in self.UIChange.iteritems():
            for index , ChangeInfo in ChangeList.iteritems():
                if not "new" in ChangeInfo:
                    continue
                if ChangeInfo["new"]["plistFile"]:
                    newPath = comFun.OUTPUTTARGET + ChangeInfo["new"]["plistFile"]
                    if not newPath in JsonValidResList:
                        JsonValidResList.append(newPath)
                    self.copyFileToPath(newPath, self.CodeResPath + "/" + os.path.basename(newPath))
                elif ChangeInfo["new"]["path"]:
                    newPath = comFun.OUTPUTTARGET + ChangeInfo["new"]["path"]
                    if not newPath in JsonValidResList:
                        JsonValidResList.append(newPath)
                    # shutil.copyfile(newPath , self.UIResPath + "/" + os.path.basename(newPath))   # 在打包的时候已经做了移动处理
                    self.copyFileToPath(newPath, self.CodeResPath + "/" + os.path.basename(newPath))

        return JsonValidResList

    def moveCodeRes(self):
        LuaValidResList = []
        for luaPath , ChangeInfos in self.CodeChange.iteritems():  # 代码中对每个json文件中使用的资源有过一个去重处理 dict key
            if not "ValidChange" in ChangeInfos:
                continue
            for md5code , ChangeInfo in ChangeInfos["ValidChange"].iteritems():
                if re.search(comFun.RESFOLDER + "/[\w]*?.(png|mp3)" , ChangeInfo["new"]):  # 这个类型判断也是不应该存在的。代码路径就是实际路径，不应该有这些东西
                    newPath = comFun.OUTPUTTARGET + ChangeInfo["new"]
                    if not newPath in LuaValidResList:
                        LuaValidResList.append("Channel/" + ChangeInfo["new"])
                    self.copyFileToPath(newPath, self.CodeResPath + "/" + os.path.basename(newPath))
            if not "PlistList" in ChangeInfos:
                continue
            for md5code , PListPath in ChangeInfos["PlistList"].iteritems():
                self.copyFileToPath(PListPath, self.PackagePath + "/" + os.path.basename(PListPath))
        return LuaValidResList

    # 拷贝文件到新路径
    def copyFileToPath(self , oldPath , newPath):
        if not os.path.isabs(oldPath):
            oldPath = os.path.abspath(oldPath)
        oldPath = comFun.turnBias(oldPath)
        dir = os.path.dirname(oldPath)          # 创建文件路径
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