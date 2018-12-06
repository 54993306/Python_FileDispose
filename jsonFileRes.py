
# -*- coding: UTF-8 -*-

# 需要把可存在png和plist的行都进行处理，所有的资源类型都要进行处理和匹配

import comFun
import os
import re

searchJsonpath = "./newJson"   #当前目录
jsonHavaRes = "jsonres.txt"
class jsonHasRes:
    json_res = {}
    folderFiles = []
    comFun.initPathFiles(searchJsonpath , folderFiles)
    jsonPaths = []
    def iniJsonFileList(self , resDict):
        rJsonRes = open(jsonHavaRes , "w+")
        for jsonpath in self.folderFiles:
            _ , fileType = os.path.splitext(jsonpath)
            if cmp(fileType , ".json") != 0:
                continue
            # print "file : " + jsonpath
            if not os.path.isabs(jsonpath):
                jsonpath = os.path.abspath(jsonpath)
            if not os.path.isfile(jsonpath):
                assert(False)
            self.jsonPaths.append(jsonpath)
            print(jsonpath)
            file_stream = open(jsonpath , "rb")
            for line in file_stream.readlines():
                for resType in resDict.iterkeys():   # 从json文件中，找到所有包含资源文件的行
                    resType = str.replace(resType , "." , "\." )
                    # print(resType)
                    if re.search(resType , line):
                        line = str.replace(line , " " , "")
                        print resType + " : " + line
                        rJsonRes.write(line)
                        break
        # print(jsonres.read())
        rJsonRes.close()

# jc= jsonHasRes()
# jc.iniJsonFileList()