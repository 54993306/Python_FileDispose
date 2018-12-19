
# -*- coding: UTF-8 -*-

# 需要把可存在png和plist的行都进行处理，所有的资源类型都要进行处理和匹配

import comFun
import os
import re
import json

# searchJsonpath = "./oldJson"
# searchJsonpath = "./newJson"
searchJsonpath = "D:\Svn_2d\UI_Shu\Json"
jsonHavaRes = "./output/jsonres.json"
ReferenceFIle = "./output/reference.json"
NotFound = "./output/notfound.json"
realPath = r"D:\Svn_2d\S_GD_Heji\res/hall/"
class jsonRes:
    def __init__(self , resDict):
        if not resDict:
            assert (False)
        self.pResDict = resDict

    folderFiles = [] #存储所有的json文件
    comFun.initPathFiles(searchJsonpath , folderFiles)

    json_res = {}   #json文件中包含的资源map
    referenceCount = {}  # 资源引用计数统计
    notFountFile = {}   # 在json中使用但是未找到的资源文件

    def initRecordFile(self , refresh = False):
        # refresh = True
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
        self.recordFile()

    def recordFile(self):
        json_res = open(jsonHavaRes, "w+")   # 将数据写入文件中
        json_res.write(json.dumps(self.json_res, ensure_ascii=False, encoding="utf-8", indent=4))
        # json.dump(self.json_res, json_stream)
        json_res.close()

        referenceCount = open(ReferenceFIle, "w+")   # 将数据写入文件中
        referenceCount.write(json.dumps(self.referenceCount, ensure_ascii=False, encoding="utf-8", indent=4))
        referenceCount.close()

        notFountFile = open(NotFound, "w+")   # 将数据写入文件中
        notFountFile.write(json.dumps(self.notFountFile, ensure_ascii=False, encoding="utf-8", indent=4))
        notFountFile.close()

    # 资源文件在json中被引用的次数
    def initReferenceCount(self , refresh = False):  #初始化文件引用计数表
        RepeatFile = "./output/repeatfile.json"
        repeat_stream = open(RepeatFile , "r")
        repeatDict = json.load(repeat_stream)
        for jsonpath , paths in self.json_res.iteritems():
            for path in paths:
                if not os.path.isabs(path):
                    path = os.path.abspath(path)
                if not os.path.isfile(path):
                    self.addNotFoundFile(jsonpath , path)   # 在json 中使用，但是实际上不存在
                    continue
                _,fileType = os.path.splitext(path)
                if fileType in self.pResDict:
                    typeDict = self.pResDict.get(fileType)
                    md5Code = None
                    if typeDict.has_key(path):
                        fileinfo = typeDict.get(path)   #通过文件路径到总资源表中取得文件Md5值
                        md5Code = fileinfo["md5"]
                    else:
                        md5Code = comFun.getFileMd5(path)
                        if md5Code in repeatDict:
                            fileinfo = repeatDict.get(md5Code)
                            path = fileinfo["currPath"]
                        else:
                            print "type not found in dict : " + path   # 图片可能被去重删除掉了
                            assert(False)
                    if md5Code:
                        self.addReferenceNum(md5Code, jsonpath, path)
                    else:
                        print(" ERROR : Lost file md5 by " + path)
                        assert (False)
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
            referenctInfo["total"] = referenctInfo["total"] + 1
        else:
            referenctInfo = {}
            self.referenceCount[md5Code] = referenctInfo
            referenctInfo["FilePath"] = path
            referenctInfo["total"] = 1
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
                    serchObj = reType.search(line)              # 对于一行中，包含多个类型的情况是否有相应的考虑
                    # groupdict 返回以有别名的组的别名为键、以该组截获的子串为值的字典，没有别名的组不包含在内。default含义同上。
                    if serchObj:
                        # self.json_res[jsonpath].append(serchObj.group(1))  # 记录每个文件中都包含了多少的资源
                        self.json_res[jsonpath].append(realPath + serchObj.group(1))  # 记录每个文件中都包含了多少的资源
                    else:
                        print line + " regular failed "
                        assert(False)
                    break