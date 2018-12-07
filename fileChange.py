# -*- coding: UTF-8 -*-

import os
import json
import re

import comFun

# json修改小图 jsonfilename
outputPath = "./newJson/"
import shutil
class replaceImage:
    def replaceFile(self , jsonPaths):
        if not os.path.exists(outputPath):
            os.mkdir(outputPath , 0o777)        # 创建输出路径
        for jsonPath in jsonPaths:
            if not os.path.isfile(jsonPath):
                assert(False)
            if not re.search(r".json" , jsonPath):
                assert(False)
            _ , filename = os.path.split(jsonPath)
            newFilePath = outputPath + "rp_" +filename
            shutil.copyfile(jsonPath , newFilePath)
            if not os.path.isabs(newFilePath):
                newFilePath = os.path.abspath(newFilePath)
            if not os.path.isfile(newFilePath):
                assert(False)
            print(newFilePath)
            self.streamDispose(newFilePath)

    def streamDispose(self , newJsonFile):
        json_stream = open(newJsonFile, "r+")
        # json_stream.seek(0,0)             # 定位到文件流某个位置
        # json_stream.tell()                # 输出当前文件流位置
        # json_stream.flush()               #
        # print(type(json.loads("[1,2,3,4,5]")))   #将字符串转换为数据对象( List or Dict )

        if not json_stream:
            assert(False)
        jsondict = json.load(json_stream)
        for keyL1 in jsondict.iterkeys():
            print keyL1
        # print json.dumps( jsondict , ensure_ascii=False ,  encoding= "utf-8" , indent=4)
        json_stream.close()

