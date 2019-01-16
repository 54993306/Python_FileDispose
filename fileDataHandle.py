
# -*- coding: UTF-8 -*-

import os
import json
import re
import comFun
import copy
import collections
# 对数据的处理抽象对象
class fileDataHandle:
    def __init__(self):
        if not os.path.isfile(comFun.MD5OLD_NEW):
            assert(False)
        self.data = comFun.GetDataByFile(comFun.MD5OLD_NEW)

    def getFileDatas(self):
        return self.data

    # 根据文件路径获取md5值
    def getFileMd5(self , filepath):
        if not filepath:
            print(" getFileMd5 : path is null" )
            return
        for md5code , datas in self.data.iteritems():
            if cmp(filepath , datas["old"]) == 0:
                return md5code
            if cmp(filepath , datas["new"]) == 0:
                return md5code
            if "repeat" in datas:
                for path in datas["repeat"]:
                    if cmp(filepath , path) == 0:
                        return md5code
        print "can't find path md5 : " + filepath
        return ""

    # 根据md5值获取新路径名称
    def getNewPathByMd5Code(self , md5code):
        if md5code in self.data:
            return self.data[md5code]["new"]
        else:
            return ""

    # 根据md5值获取老路径
    def getOldPathByMd5Code(self , md5code):    # 老路径用于同一急速
        if md5code in self.data:
            return self.data[md5code]["old"]
        else:
            return ""

    # 根据其他路径获取老路径信息
    def getOldPathBypath(self , filepath):
        for md5code, datas in self.data.iteritems():
            if cmp(filepath, datas["old"]) == 0:
                return filepath
            if cmp(filepath, datas["new"]) == 0:
                return datas["old"]
            if "repeat" in datas:
                for path in datas["repeat"]:
                    if cmp(filepath, path) == 0:
                        return datas["old"]
        print(" can't find old path " + filepath)
        return ""

    # 根据老路径获取新路径
    def getNewPathByOldPath(self , filepath):
        for md5code, datas in self.data.iteritems():
            if cmp(filepath, datas["old"]) == 0:
                return datas["new"]
            if "repeat" in datas:
                for path in datas["repeat"]:
                    if cmp(filepath, path) == 0:
                        return datas["new"]
        return ""

    # 根据md5值，获取数据信息
    def getDatasByMd5(self , md5code):
        if md5code in self.data:
            return self.data[md5code]
        else:
            return

    # 根据老路径获取数据信息
    def getDatasByOldPath(self , filepath):
        for md5code, datas in self.data.iteritems():
            if cmp(filepath, datas["old"]) == 0:
                return datas
            if "repeat" in datas:
                for path in datas["repeat"]:
                    if cmp(filepath, path) == 0:
                        return datas
        return

    # 根据新路径获取数据信息
    def getDatasByNewPath(self , filepath):
        for md5code, datas in self.data.iteritems():
            if cmp(filepath, datas["new"]) == 0:
                return datas
        return

    # 根据类型数据刷新数据集
    def refreshTypeDataToFile(self , data):
        for filetype , resList in data.iteritems():
            for fileDict in resList:
                if fileDict["md5"] in self.data:
                    self.data[fileDict["md5"]]["tPath"] = fileDict["path"]
                else:
                    print fileDict["path"]
                    assert(False)
        # print json.dumps(self.data, ensure_ascii=False, encoding="utf-8", indent=4)
        comFun.RecordToJsonFile(comFun.MD5OLD_NEW, self.data)

    def getTPathByMd5Code(self , md5code):
        if md5code in self.data:
            if "tPath" in self.data[md5code]:
                return self.data[md5code]["tPath"]
            return ""
        else:
            return ""

    # 根据文件基础名称获取文件信息
    def getResInfoByBaseName(self , basename):
        for md5code, datas in self.data.iteritems():
            if cmp(basename, os.path.basename(datas["new"])) == 0:
                resInfo = collections.OrderedDict()
                resInfo["md5"] = md5code
                resInfo["new"] = datas["new"]
                resInfo["old"] = datas["old"]
                return resInfo
        return ""

    # 根据新路径获取文件信息
    def getResInfoByNewPath(self , filepath):
        for md5code, datas in self.data.iteritems():
            if cmp(filepath, datas["new"]) == 0:
                resInfo = collections.OrderedDict()
                resInfo["md5"] = md5code
                resInfo["new"] = datas["new"]
                resInfo["old"] = datas["old"]
                return resInfo
        return ""