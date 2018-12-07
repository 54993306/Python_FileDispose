
# -*- coding: UTF-8 -*-

import os
import json
import re

import comFun
import totalResDict
import jsonFileRes
import fileChange

t = totalResDict.gameres()
t.initFileDict()

jc= jsonFileRes.jsonHasRes(t.filedict)
jc.initRecordFile()

cg = fileChange.replaceImage()
# cg.replaceFile(jc.jsonPaths)

newJsonFile = "./newJson/rp_1lay_test.json"
def streamDispose(newJsonFile):
    json_stream = open(newJsonFile, "r+")
    # json_stream.seek(0,0)             # 定位到文件流某个位置
    # json_stream.tell()                # 输出当前文件流位置
    # json_stream.flush()               #
    # print(type(json.loads("[1,2,3,4,5]")))   #将字符串转换为数据对象( List or Dict )

    if not json_stream:
        assert (False)
    jsondict = json.load(json_stream)
    for k_1 , v_1 in jsondict.iterkeys():   #对一级路径的资源做判断 textures、texturesPng、widgetTree
        # print k_1
        if cmp(k_1 , "textures"):   #里面存在的资源一定是plist文件
            for res in v_1:
                comFun.getFileMd5(res)

    # print json.dumps( jsondict , ensure_ascii=False ,  encoding= "utf-8" , indent=4)
    json_stream.close()
# streamDispose(newJsonFile)