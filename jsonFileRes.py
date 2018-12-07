
# -*- coding: UTF-8 -*-

# 需要把可存在png和plist的行都进行处理，所有的资源类型都要进行处理和匹配

import comFun
import os
import re
import json

searchJsonpath = "./oldJson"
jsonHavaRes = "jsonres.txt"
class jsonHasRes:
    def __init__(self , resDict):
        if not resDict:
            assert (False)
        self.pResDict = resDict
    json_res = {}
    folderFiles = []
    comFun.initPathFiles(searchJsonpath , folderFiles)
    rJsonRes = open(jsonHavaRes, "w+")
    def iniJsonFileList(self):
        # rJsonRes = open(jsonHavaRes, "w+")
        # rJsonRes.write(line)
        # rJsonRes.close()
        for jsonpath in self.folderFiles:
            _ , fileType = os.path.splitext(jsonpath)
            if cmp(fileType , ".json") != 0:
                continue
            if not os.path.isabs(jsonpath):
                jsonpath = os.path.abspath(jsonpath)
            if not os.path.isfile(jsonpath):
                assert(False)
            self.json_res[jsonpath] = []
            # print("Json has res : " + jsonpath)\
            self.replaceCmpResType(jsonpath)
        self.rJsonRes.close()
        # print json.dumps(self.json_res, ensure_ascii=False, encoding="utf-8", indent=4)

    def replaceCmpResType(self , jsonpath):
        file_stream = open(jsonpath, "rb")
        for line in file_stream.readlines():
            for resType in self.pResDict.iterkeys():  # 从json文件中，找到所有包含资源文件的行
                resType = str.replace(resType, ".", "\.")  # 把点号也匹配上,字符串替换
                if re.search(resType, line):
                    line = re.sub(r"\s|\r|\n", "", line)
                    # print line
                    reType = re.compile(r"\"([^:]+" + resType + r")\"")   # ：不是特殊字符跟字母一样 , ()不是特殊字符串
                    serchObj = reType.search(line)
                    print serchObj.group(1)
                    print serchObj.group()
                    if serchObj:
                        self.json_res[jsonpath].append(serchObj.group(1))  # 记录每个文件中都包含了多少的资源
                        self.rJsonRes.write(serchObj.group(1) + "\n")
                    else:
                        print line + " regular failed "
                        assert(False)
                    break