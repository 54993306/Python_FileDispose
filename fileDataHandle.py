
# -*- coding: UTF-8 -*-

import os
import json
import re
import comFun
import copy

# 对数据的处理抽象对象
class fileDataHandle:
    def __init__(self):
        if not os.path.isfile(comFun.MD5OLD_NEW):
            assert(False)
        self.data = copy.deepcopy(comFun.GetDataByFile(comFun.MD5OLD_NEW))

    def getFileDatas(self):
        return self.data

    # 根据文件路径获取md5值
    def getFileMd5(self , filepath):
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
            if cmp(filepath, datas["new"]) == 0:
                return datas["old"]
            if "repeat" in datas:
                for path in datas["repeat"]:
                    if cmp(filepath, path) == 0:
                        return datas["old"]
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
            return {}

    # 根据老路径获取数据信息
    def getDatasByOldPath(self , filepath):
        for md5code, datas in self.data.iteritems():
            if cmp(filepath, datas["old"]) == 0:
                return datas
            if "repeat" in datas:
                for path in datas["repeat"]:
                    if cmp(filepath, path) == 0:
                        return datas
        return {}

    # 根据新路径获取数据信息
    def getDatasByNewPath(self , filepath):
        for md5code, datas in self.data.iteritems():
            if cmp(filepath, datas["new"]) == 0:
                return datas
        return {}
