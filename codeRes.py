
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
    def initResList(self , refresh = False):
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
                    if re.search(resType, line):
                        serc2 = re.search(r"[\"]([^:\"]+" + r".csb" + r")[\"]", line)
                        if serc2:
                            self.csbList.append(serc2.group(1))
                        pattern = re.compile(r"[\"]([^:\"]+" + resType + r")[\"]")    #找到包含资源的行，所有的资源都会被修改路径，统一进行管理
                        serchObj = pattern.search(line)                               # 对于一行中，包含多个类型的情况是否有相应的考虑
                        if serchObj:
                            self.codeResLine[filepath].append(serchObj.group(1))  # 记录每个文件中都包含了多少的资源
                        else:
                            # print " regular failed ===>>>  " + line + "lineNumn : " + str(lineNum)
                            self.unInRegular[filepath].append(line)
                            # assert (False)
                        break
        self.recordToFile()
        # print json.dumps(self.csbList, ensure_ascii=False, encoding="utf-8", indent=4)

    def recordToFile(self):
        codeResLine = open(comFun.CODERESFILE, "w+")   # 将数据写入文件中
        codeResLine.write(json.dumps(self.codeResLine, ensure_ascii=False, encoding="utf-8", indent=4))
        codeResLine.close()

        unInRegular = open(comFun.CODEUNREGULARFILE, "w+")   # 将数据写入文件中
        unInRegular.write(json.dumps(self.unInRegular, ensure_ascii=False, encoding="utf-8", indent=4))
        unInRegular.close()

        csbList = open(comFun.CODECSB, "w+")   # 将数据写入文件中
        csbList.write(json.dumps(self.csbList, ensure_ascii=False, encoding="utf-8", indent=4))
        csbList.close()
