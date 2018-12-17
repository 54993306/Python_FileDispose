
# -*- coding: UTF-8 -*-

# 小图合成大图

import comFun
import os
import json
from PIL import Image

class packageImage:
    def __init__(self , pResDict):
        if not pResDict:
            assert(False)
        self.ResDict = pResDict
    packageList = {}
    sortRefList = {}

    def sortReference(self):
        ref_stream = open(comFun.ReferenceFIle,"r")
        refDict = json.load(ref_stream)
        for md5 , dic1 in refDict.iteritems():
            if len(dic1["RefList"]) and dic1["FilePath"]:
                self.sortRefList[dic1["FilePath"]] = len(dic1["RefList"])
            else:
                print "refresh is : " + str(len(dic1["RefList"])) + "path: " + dic1["FilePath"]
        self.sortRefList = sorted(self.sortRefList.items(), key=lambda refNum: refNum[1] , reverse = True)
        print json.dumps(self.sortRefList, ensure_ascii=False, encoding="utf-8", indent=4)

    # def countPackagImage(self):

        # 通过分析打印数据，当引用计数大于2时，可以作为第一批的加载数据处理。

        # print len(refDict)

    # 将引用计数最高，且合成后大小是1024的合成为一张图


    # 根据老路径直接获取新路径的信息，获取新路径中的名称和对应的plist文件。