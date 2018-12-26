
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
    fileList = []
    comFun.initPathFiles(comFun.CODEFOLDER , fileList)
    comFun.initPathFiles(comFun.GAMECODEFOLDER , fileList)

    codeResLine = {}
    unInRegular = {}
    csbList = []            # 记录在代码中使用的csb的文件

    # 记录匹配数据
    def recordToFile(self):
        codeResLine = open(comFun.CODERESFILE, "w+")   # 将数据写入文件中
        codeResLine.write(json.dumps(self.codeResLine, ensure_ascii=False, encoding="utf-8", indent=4))
        codeResLine.close()

        unInRegular = open(comFun.CODEUNREGULARFILE, "w+")   # 将数据写入文件中
        unInRegular.write(json.dumps(self.unInRegular, ensure_ascii=False, encoding="utf-8", indent=4))
        unInRegular.close()
    # 对于plist类的文件，判断相应的png图片是否存在多张，匹配png文件的名称如果跟plist相同则不进行删除处理。

    def initResList(self):
        for filepath in self.fileList:
            if re.search(r".svn" , filepath):
                continue
            if not os.path.isfile(filepath):
                continue
            if not os.path.isabs(filepath):
                filepath = os.path.abspath(filepath)
            stream = open(filepath , "r")
            self.codeResLine[filepath] = []
            self.unInRegular[filepath] = []
            for lineNum,line in enumerate(stream):
                line = re.sub(r"\s|\r|\n", "", line)
                for resType in self.mResDict.iterkeys():
                    resType = str.replace(str(resType), ".", "\.")
                    if re.search(resType, line):                                      #包含有资源类型的字段
                        pattern = re.compile(r"[\"]([^:\"]+" + resType + r")[\"]")    #找到包含资源的行，所有的资源都会被修改路径，统一进行管理
                        serchList = pattern.findall(line)                             # 对于一行中，包含多个类型的情况
                        if serchList:
                            self.codeResLine[filepath].extend(serchList)            # 记录每个文件中都包含了多少的资源
                        else:
                            # print " regular failed ===>>>  " + line + "lineNumn : " + str(lineNum)
                            self.unInRegular[filepath].append(line)
                            # assert (False)
                        break
            # 删除空行的列表
            if not self.codeResLine[filepath]:
                del self.codeResLine[filepath]
            if not self.unInRegular[filepath]:
                del self.unInRegular[filepath]
        self.recordToFile()