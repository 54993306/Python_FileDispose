
# -*- coding: UTF-8 -*-

import comFun
import re
import os
import json

class codeRes:
    def __init__(self):
        if not os.path.isfile(comFun.DICTFILE):
            print "can't found file " + comFun.DICTFILE
            assert(False)
        filedict = open(comFun.DICTFILE, "r")
        self.mResDict = json.load(filedict)

        self.resTypes = []
        for resType in self.mResDict.iterkeys():
            if not resType in self.resTypes:
                resType = str.replace(str(resType), ".", "\.")
                # 可以在这里过滤掉不进行处理的类型
                self.resTypes.append(resType)
        print self.resTypes

    codeResLine = {}
    unInRegular = {}
    csbList = []            # 记录在代码中使用的csb的文件

    # 记录匹配数据
    def recordToFile(self):
        if self.codeResLine:
            comFun.RecordToJsonFile(comFun.CODERESFILE, self.codeResLine)

        if self.unInRegular:
            unInRegular = open(comFun.CODEUNREGULARFILE, "w+")   # 将数据写入文件中
            unInRegular.write(json.dumps(self.unInRegular, ensure_ascii=False, encoding="utf-8", indent=4))
            unInRegular.close()
        # 对于plist类的文件，判断相应的png图片是否存在多张，匹配png文件的名称如果跟plist相同则不进行删除处理。

    # 初始化
    def initResList(self):
        self.findResByCodeFiles()
        # self.collatingCodeResList()
        self.recordToFile()

    # 从代码文件列表中查找资源引用内容
    def findResByCodeFiles(self):
        fileList = []
        comFun.initPathFiles(comFun.CODEFOLDER, fileList)
        comFun.initPathFiles(comFun.GAMECODEFOLDER, fileList)
        for filepath in fileList:
            if re.search(r".svn" , filepath):
                continue
            if not os.path.isfile(filepath):
                continue
            if not os.path.isabs(filepath):
                filepath = os.path.abspath(filepath)
            self.codeResLine[filepath] = []
            self.unInRegular[filepath] = []
            self.findResByPath(filepath)
            # 删除空行的列表
            if not self.codeResLine[filepath]:
                del self.codeResLine[filepath]
            if not self.unInRegular[filepath]:
                del self.unInRegular[filepath]

    # 根据路径搜索文件中的内容
    def findResByPath(self , pFilePath):
        stream = open(pFilePath, "r")
        for lineNum, line in enumerate(stream):
            line = re.sub(r"\s|\r|\n", "", line)
            for resType in self.resTypes:
                if re.search(resType, line):  # 包含有资源类型的字段
                    pattern = re.compile(r"[\"]([^:\"]+" + resType + r")[\"]")  # 找到包含资源的行，所有的资源都会被修改路径，统一进行管理
                    serchList = pattern.findall(line)  # 对于一行中，包含多个类型的情况
                    if serchList:
                        self.codeResLine[pFilePath].extend(serchList)  # 记录每个文件中都包含了多少的资源
                    else:
                        # print " regular failed ===>>>  " + line + "lineNumn : " + str(lineNum)
                        self.unInRegular[pFilePath].append(line)
                    break