
# -*- coding: UTF-8 -*-

# 需要把可存在png和plist的行都进行处理，所有的资源类型都要进行处理和匹配

import comFun
import os
import re
import json

# searchJsonpath = "./oldJson"
# searchJsonpath = "./newJson"
searchJsonpath = "D:\Svn_2d\UI_Shu\Json"
jsonHavaRes = "jsonres.txt"
class jsonRes:
    def __init__(self , resDict):
        if not resDict:
            assert (False)
        self.pResDict = resDict
    json_res = {}   #json文件中包含的资源map
    folderFiles = [] #存储所有的json文件
    referenceCount = {}  # 资源引用计数统计
    notFountFile = {}   # 在json中使用但是未找到的资源文件
    comFun.initPathFiles(searchJsonpath , folderFiles)

    def initRecordFile(self , refresh = False):
        refresh = True
        if os.path.isfile(jsonHavaRes) and not refresh:
            if not self.json_res:
                json_stream = open(jsonHavaRes , "r")
                if comFun.is_json(json_stream.read()):
                    # print json_stream.tell()
                    json_stream.seek(0,0)
                    self.json_res = json.load(json_stream)
                    # print "open : " + json.dumps(self.json_res, ensure_ascii=False, encoding="utf-8", indent=4)
                else:
                    json_stream.close()
                    os.remove(jsonHavaRes)
                    print "record file has error remove file paht : " + jsonHavaRes
        else:
            self.iniJsonFileList()
        self.initReferenceCount() # 可以跟json_res一起执行，但是耦合逻辑太多，拆出来逻辑清楚，但是性能消耗

    # 资源文件在json中被引用的次数
    def initReferenceCount(self , refresh = False):  #初始化文件引用计数表
        for jsonpath , paths in self.json_res.iteritems():
            for path in paths:
                if not os.path.isabs(path):
                    path = os.path.abspath(path)
                if not os.path.isfile(path):
                    self.addNotFoundFile(jsonpath , path)
                    continue
                _,fileType = os.path.splitext(path)
                if fileType in self.pResDict:
                    typeDict = self.pResDict.get(fileType)
                    if typeDict.has_key(path):
                        fileinfo = typeDict.get(path)   #通过文件路径到总资源表中取得文件Md5值
                        if fileinfo["md5"]:
                            self.addReferenceNum(fileinfo["md5"], jsonpath ,path)
                        else:
                            print(" ERROR : Lost file md5 by " + path)
                else:
                    print(path)
                    assert(False)
        # print "referenceCount : " + json.dumps(self.referenceCount, ensure_ascii=False, encoding="utf-8", indent=4)
        # print "notFountFile : " + json.dumps(self.notFountFile, ensure_ascii=False, encoding="utf-8", indent=4)

    # 文件添加一次引用
    def addReferenceNum(self,md5Code , jsonpath = "" ,path = ""):
        if md5Code in self.referenceCount:
            referenctInfo = self.referenceCount.get(md5Code)
            RefList = referenctInfo["RefList"]
            if jsonpath in RefList:
                RefList[jsonpath] = RefList[jsonpath] + 1   # 在同一个 json 文件中被引用的次数
            else:
                RefList[jsonpath] = 1
        else:
            referenctInfo = {}
            self.referenceCount[md5Code] = referenctInfo
            referenctInfo["FilePath"] = path
            RefList = {}
            referenctInfo["RefList"] = RefList
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
            if not os.path.isfile(jsonpath):
                assert(False)
            self.json_res[jsonpath] = []
            # print("Json has res : " + jsonpath)
            self.replaceCmpResType(jsonpath)
        json_stream = open(jsonHavaRes, "w+")   # 将数据写入文件中
        json.dump(self.json_res, json_stream)
        json_stream.close()
        # print "init : " + json.dumps(self.json_res, ensure_ascii=False, encoding="utf-8", indent=4)

    def replaceCmpResType(self , jsonpath):
        file_stream = open(jsonpath, "rb")
        printLineNum = 0
        for line in file_stream.readlines():
            # if printLineNum == 2:
            #     print "------------------------------------------"
            if printLineNum > 0:
                printLineNum -= 1
                line = re.sub(r"\s|\r|\n", "", line)
                if not re.search(r"plistFile|resourceType" , line):    # path、plistFile、resourceType
                    print line + jsonpath
            if re.search(r":\\|\.plist" , line):
                line = re.sub(r"\s|\r|\n", "", line)
                print "Local Image Line : " + line + "by: " + jsonpath
                continue
            for resType in self.pResDict.iterkeys():  # 从json文件中，找到所有包含资源文件的行
                resType = str.replace(resType, ".", "\.")  # 把点号也匹配上,字符串替换
                if re.search(resType, line):
                    line = re.sub(r"\s|\r|\n", "", line)
                    # print line
                    printLineNum = 2
                    reType = re.compile(r"\"([^:]+" + resType + r")\"")   # ：不是特殊字符跟字母一样 , ()不是特殊字符串
                    serchObj = reType.search(line)              # 对于一行中，包含多个类型的情况是否有相应的考虑
                    # groupdict 返回以有别名的组的别名为键、以该组截获的子串为值的字典，没有别名的组不包含在内。default含义同上。
                    if serchObj:
                        # self.json_res[jsonpath].append(serchObj.group(1))  # 记录每个文件中都包含了多少的资源
                        self.json_res[jsonpath].append(r"res/"+serchObj.group(1))  # 记录每个文件中都包含了多少的资源
                    else:
                        print line + " regular failed "
                        assert(False)
                    break