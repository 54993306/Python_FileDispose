
# -*- coding: UTF-8 -*-

import comFun
import re
import os
import json


codeFolder = r"D:\Svn_2d\S_GD_Heji\src\app"
gameCodeFolder = r"D:\Svn_2d\S_GD_Heji\src\package_src"
codeResFile = r"./output/coderesline.json"
codeUnregularFile = r"./output/codeUnregularline.json"
class codeRes:
    def __init__(self , pResDict):
        if not pResDict:
            assert(False)
        self.mResDict = pResDict
    fileList = []
    comFun.initPathFiles(codeFolder , fileList)
    comFun.initPathFiles(gameCodeFolder , fileList)

    codeResLine = {}
    unInRegular = {}
    csbList = []
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
                    if re.search(resType, line):
                        pattern = re.compile(r"[\"]([^:\"]+" + resType + r")[\"]")    #找到包含资源的行，所有的资源都会被修改路径，统一进行管理
                        serchObj = pattern.search(line)
                        if serchObj:
                            serc2 = re.search(r"[\"]([^:\"]+" + r".csb" + r")[\"]", line)
                            if serc2:
                                self.csbList.append(serc2.group(1))
                            self.codeResLine[filepath].append(serchObj.group(1))  # 记录每个文件中都包含了多少的资源
                        else:
                            # print " regular failed ===>>>  " + line + "lineNumn : " + str(lineNum)
                            self.unInRegular[filepath].append(line)
                            # assert (False)
                        break
        self.recordToFile()
        print json.dumps(self.csbList, ensure_ascii=False, encoding="utf-8", indent=4)

    def recordToFile(self):
        codeResLine = open(codeResFile, "w+")   # 将数据写入文件中
        codeResLine.write(json.dumps(self.codeResLine, ensure_ascii=False, encoding="utf-8", indent=4))
        codeResLine.close()

        unInRegular = open(codeUnregularFile, "w+")   # 将数据写入文件中
        unInRegular.write(json.dumps(self.unInRegular, ensure_ascii=False, encoding="utf-8", indent=4))
        unInRegular.close()
