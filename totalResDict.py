# -*- coding: UTF-8 -*-

import os
import json
import hashlib
import re
import time

import comFun
#读取路径下的所有资源文件分类后写入到文件中
# filepath = "./res"
# filepath = "D:/Python_FileDispose/res"
filepath = r"D:\Svn_2d\S_GD_Heji\res"

class totalRes:
    totalfile = open("files.txt" , "w+")
    totalfile.close()
    fileList = []
    comFun.initPathFiles(filepath , fileList)

    filedict = {}   # 文件分类表，有多少中类型资源，每种类型有多少个
    timeOrder = {}  # 文件创建时间排序表 os.path.getctime(path)
    sizeOrder = {}  # 文件大小排序表  os.path.getsize(filepath)
    md5List = {}    # 存储文件md5值 key:md5 value:path
    repeatList = [] #
    def initFileDict(self):
        for pathbylist in self.fileList:
            abspath = pathbylist
            if not os.path.isabs(abspath):
                abspath = os.path.abspath(pathbylist)
            singlepath , filetype = os.path.splitext(abspath)   # 分离文件名和后缀
            if re.search(r".svn" , abspath) :
                continue
            if not self.addToDict(abspath):    # 重复文件不进行后续操作
                continue
            fileSize = os.path.getsize(pathbylist)
            self.sizeOrder[pathbylist] =  fileSize  # 文件大小
            self.timeOrder[pathbylist] = os.path.getctime(pathbylist) # 创建时间
        # print(json.dumps(self.filedict, ensure_ascii=False, encoding="utf -8", indent=4))
        self.sortFileSize()
        # self.formatFileCTime()  # 创建时间都是在"Tue Nov 06 16:11:46 2018" 根据日期来处理失去意义

    def addToDict(self, filepath):
        md5 = self.getFileMd5(filepath)
        if not md5:
            return False

        _, filetype = os.path.splitext(filepath)  # 分离文件名和后缀
        typedict = {}
        if filetype in self.filedict:
            typedict = self.filedict.get(filetype)
        else:
            self.filedict[filetype] = typedict

        pathdict = {}
        pathdict["md5"] = md5
        pathdict["size"] = os.path.getsize(filepath)
        typedict[filepath] = pathdict
        return True

    def getFileMd5(self , filepath):
        md5 = comFun.getFileMd5(filepath)
        if md5 in self.md5List:
            print "Repeat File Path : " + filepath
            self.repeatList.append(filepath)
            return False
        self.md5List[md5] = filepath
        return md5

    def sortFileSize(self):
        self.sizeOrder = sorted(self.sizeOrder.items() , key = lambda fileSize:fileSize[1] , reverse = True)
        print type(self.sizeOrder)
        print(json.dumps(self.sizeOrder, ensure_ascii=False, encoding="utf -8", indent=4))

    def formatFileCTime(self):
        sorted(self.timeOrder.items() , key = lambda filetime:filetime[1])
        # for key,filetime in self.timeOrder.items():
        #     self.timeOrder[key] = time.asctime(time.localtime(filetime))
        print(json.dumps(self.timeOrder, ensure_ascii=False, encoding="utf -8", indent=4))
