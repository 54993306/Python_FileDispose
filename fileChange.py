# -*- coding: UTF-8 -*-

import os
import json
import re

import comFun

# json修改小图 jsonfilename
outputPath = "./newJson/"
import shutil
class replaceImage:
    def replaceFile(self):
        if not os.path.exists(outputPath):
            os.mkdir(outputPath , 0o777)        # 创建输出路径
        for jsonPath in jc.jsonPaths:
            if not os.path.isfile(jsonPath):
                assert(False)
            if not re.search(r".json" , jsonPath):
                assert(False)
            print jsonPath
            _ , filename = os.path.split(jsonPath)
            newFilePath = outputPath + filename
            if os.path.isfile(newFilePath):
                print("file exists : " + newFilePath)
                continue  # 文件已经存在
            shutil.copyfile(jsonPath , newFilePath)
            if not os.path.isabs(newFilePath):
                newFilePath = os.path.abspath(newFilePath)
            if not os.path.isfile(newFilePath):
                assert(False)
            print(newFilePath)
            json_stream = open(newFilePath , "r+")
            self.streamDispose(json_stream)

    def streamDispose(self , fileStream):
        if not fileStream:
            assert(False)
        jsondict = json.load(fileStream)
        print json.dumps( jsondict , ensure_ascii=False ,  encoding= "utf -8" , indent=4)

# rep = replaceImage()
# rep.replaceFile()