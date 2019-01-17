
# -*- coding: UTF-8 -*-

# 需要把可存在png和plist的行都进行处理，所有的资源类型都要进行处理和匹配

import comFun
import os
import re
import json
import copy
import collections
import fileDataHandle as FData

class jsonRes:
    def __init__(self):
        if not os.path.isfile(comFun.DICTFILE):
            print "can't found file " + comFun.DICTFILE
            assert(False)
        self.pResDict = comFun.GetDataByFile(comFun.DICTFILE)

        self.FileData = FData.fileDataHandle()

        self.initRecordFile()  # 程序执行开始

    folderFiles = [] #存储所有的json文件
    comFun.initPathFiles(comFun.SEARCHJSONPATH , folderFiles)

    json_res = collections.OrderedDict()           #json文件中包含的资源map
    collatingJson = collections.OrderedDict()      # 整理后的json数据
    referenceCount = collections.OrderedDict()     # 资源引用计数统计
    notFountFile = collections.OrderedDict()       # 在json中使用但是未找到的资源文件

    def recordFile(self):
        comFun.RecordToJsonFile(comFun.JSONHAVARES, self.json_res)

        comFun.RecordToJsonFile(comFun.COLLATINGJSON, self.collatingJson)

        comFun.RecordToJsonFile(comFun.REFERENCEFILE, self.referenceCount)

        comFun.RecordToJsonFile(comFun.NOTFOUND, self.notFountFile)

    def initRecordFile(self , refresh = False):
        refresh = True
        if not refresh and os.path.isfile(comFun.JSONHAVARES):
            if not self.json_res:
                json_stream = open(comFun.JSONHAVARES , "r")
                if comFun.is_json(json_stream.read()):
                    # print json_stream.tell()
                    json_stream.seek(0,0)
                    self.json_res = json.load(json_stream, object_pairs_hook=collections.OrderedDict)
                    json_stream.close()
                    # print "open : " + json.dumps(self.json_res, ensure_ascii=False, encoding="utf-8", indent=4)
                else:
                    json_stream.close()
                    os.remove(comFun.JSONHAVARES)
                    print "record file has error remove file paht : " + comFun.JSONHAVARES
        else:
            self.iniJsonFileList()
        self.initReferenceCount() # 可以跟json_res一起执行，但是耦合逻辑太多，拆出来逻辑清楚，但是性能消耗
        self.recordFile()

    # 资源文件在json中被引用的次数，json中包含的资源，被引用的次数
    def initReferenceCount(self , refresh = False):  #初始化文件引用计数表
        for jsonpath , paths in self.json_res.iteritems():
            for path in paths:
                if not os.path.isfile(path):
                    self.addNotFoundFile(jsonpath , path)   # 在json 中使用，但是实际上不存在
                    continue
                md5Code = self.FileData.getFileMd5(path)
                path = self.FileData.getOldPathBypath(path)
                if not md5Code:
                    print "type not found in dict : " + path
                    assert (False)
                self.recordJsonRes(jsonpath , path)
                self.addReferenceNum(md5Code, jsonpath, path)
        # print "referenceCount : " + json.dumps(self.referenceCount, ensure_ascii=False, encoding="utf-8", indent=4)
        # print "notFountFile : " + json.dumps(self.notFountFile, ensure_ascii=False, encoding="utf-8", indent=4)

    # 记录每个json文件中对应的资源信息
    def recordJsonRes(self , jsonpath, path):        # 在json中使用的路径，要进行保存
        md5Code = self.FileData.getFileMd5(path)
        if not jsonpath in self.collatingJson:
            jsonResList = collections.OrderedDict()
            self.collatingJson[jsonpath] = jsonResList
        if not md5Code in self.collatingJson[jsonpath]:  # 没有被记录过的文件，有可能存在两个文件名称不同但是md5相同的情况出现
            newPath = self.FileData.getNewPathByOldPath(path)
            fileinfo = collections.OrderedDict()
            self.collatingJson[jsonpath][md5Code] = fileinfo
            fileinfo["curr"] = path
            fileinfo["new"] = newPath
        else:
            if "repeat" in self.collatingJson[jsonpath][md5Code]:
                self.collatingJson[jsonpath][md5Code]["repeat"].append(path)
            else:
                repeat = []
                self.collatingJson[jsonpath][md5Code]["repeat"] = repeat
                repeat.append(path)


    # 文件添加一次引用
    def addReferenceNum(self,md5Code , jsonpath = "" ,path = ""):
        if md5Code in self.referenceCount:
            referenceInfo = self.referenceCount.get(md5Code)
            RefList = referenceInfo["RefList"]
            if jsonpath in RefList:
                RefList[jsonpath] = RefList[jsonpath] + 1   # 在同一个 json 文件中被引用的次数
            else:
                RefList[jsonpath] = 1
                referenceInfo["total"] = referenceInfo["total"] + 1
        else:
            referenceInfo = collections.OrderedDict()
            self.referenceCount[md5Code] = referenceInfo
            referenceInfo["Path"] = path
            referenceInfo["new"] = self.FileData.getNewPathByMd5Code(md5Code)
            referenceInfo["total"] = 1
            RefList = collections.OrderedDict()
            referenceInfo["RefList"] = RefList
            RefList[jsonpath] = 1

    # 文件在json中存在，在文件夹中没找到相应资源
    def addNotFoundFile(self , jsonPath , path):
        # print "not found file : " + path + " [ in ] : " + jsonPath
        if jsonPath in self.notFountFile:    # 判断dict中是否包含某个key的方法不能采用取值的模式来判断,会报keyerror
            self.notFountFile[jsonPath].append(path)
        else:
            filePaths = []
            self.notFountFile[jsonPath] = filePaths
            filePaths.append(path)

    # 遍历json文件找到，所使用的资源
    def iniJsonFileList(self):
        for jsonpath in self.folderFiles:
            _ , fileType = os.path.splitext(jsonpath)
            if cmp(fileType , ".json") != 0:
                continue
            if not os.path.isabs(jsonpath):
                jsonpath = os.path.abspath(jsonpath)
            jsonpath = comFun.turnBias(jsonpath)
            if not os.path.isfile(jsonpath):
                assert(False)
            self.json_res[jsonpath] = []
            # print("Json has res : " + jsonpath)
            self.cmpJsonResType(jsonpath)
        # print "init : " + json.dumps(self.json_res, ensure_ascii=False, encoding="utf-8", indent=4)

    # 找到json文件中包含的资源行
    def cmpJsonResType(self , jsonpath):
        file_stream = open(jsonpath, "rb")
        printLineNum = 0
        for line in file_stream.readlines():
            # if printLineNum == 2:
            #     print "------------------------------------------"
            # if printLineNum > 0:
            #     printLineNum -= 1
            #     line = re.sub(r"\s|\r|\n", "", line)
            #     if not re.search(r"plistFile|resourceType" , line):    # path、plistFile、resourceType
            #         print line + jsonpath
            # 结论 if not textures then texturesPng = []
            if re.search(r":\\" , line):
                line = re.sub(r"\s|\r|\n", "", line)
                # print "Local Image Line : " + line + "by: " + jsonpath
                continue
            for resType in self.pResDict.iterkeys():  # 从json文件中，找到所有包含资源文件的行
                # print resType
                resType = str.replace(str(resType), ".", "\.")  # 把点号也匹配上,字符串替换
                if re.search(resType, line):
                    line = re.sub(r"\s|\r|\n", "", line)
                    # print line
                    printLineNum = 2
                    reType = re.compile(r"\"([^:]+" + resType + r")\"")   # ：不是特殊字符跟字母一样 , ()不是特殊字符串
                    serchObj = reType.search(line)
                    # groupdict 返回以有别名的组的别名为键、以该组截获的子串为值的字典，没有别名的组不包含在内。default含义同上。
                    if serchObj:
                        realPath = comFun.REALPATH + serchObj.group(1)
                        if not os.path.isabs(realPath):
                            realPath = os.path.abspath(realPath)
                        realPath = comFun.turnBias(realPath)
                        self.json_res[jsonpath].append(realPath)  # 记录每个文件中都包含了多少的资源
                    else:
                        print line + " regular failed "
                        assert(False)
                    break