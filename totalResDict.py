# -*- coding: UTF-8 -*-

import os
import json
import hashlib
import re
import time
import shutil
import stat

import comFun
#读取路径下的所有资源文件分类后写入到文件中
# filepath = "./res"
# filepath = "D:/Python_FileDispose/res"
filepath = r"D:\Svn_2d\S_GD_Heji\res"
copypath = r"./real_res"

DictFile = "./output/filedict.json"
SizeFile = "./output/filesize.json"
SizeFile = "./output/filesize.json"
Md5File = "./output/md5.json"
RepeatFile = "./output/repeatfile.json"
AllFiles = "./output/allfile.json"
class totalRes:
    fileList = []
    comFun.initPathFiles(filepath , fileList)

    filedict = {}   # 文件分类表，有多少中类型资源，每种类型有多少个
    timeOrder = {}  # 文件创建时间排序表 os.path.getctime(path)
    sizeOrder = {}  # 文件大小排序表  os.path.getsize(filepath)
    md5List = {}    # 存储文件md5值 key:md5 value:path
    repeatList = {} # 存储重复图片的相关信息
    allFiles = []

    # 初始化文件表
    def initFileDict(self , refresh = False):
        # refresh = True
        if self.hasFile() and not refresh:
            return
        else:
            self.initDict()

    # 初始化文件字典(已去重)
    def initDict(self):
        for pathbylist in self.fileList:
            abspath = pathbylist
            if not os.path.isabs(abspath):
                abspath = os.path.abspath(pathbylist)
            if re.search(r".svn" , abspath) :
                continue
            self.allFiles.append(abspath)
            if not self.addToDict(abspath):    # 重复文件不进行后续操作
                continue
            fileSize = os.path.getsize(pathbylist)
            self.sizeOrder[pathbylist] =  fileSize  # 文件大小
            self.timeOrder[pathbylist] = os.path.getctime(pathbylist) # 创建时间
        # print(json.dumps(self.filedict, ensure_ascii=False, encoding="utf -8", indent=4))
        print "Total File Num : " + str(len(self.allFiles))
        self.copyFile()
        self.sortFileSize()
        self.recordToFile()

    # 将内容记录到文件中
    def recordToFile(self):
        filedict = open(DictFile , "w+")
        filedict.write(json.dumps(self.filedict, ensure_ascii=False, encoding="utf -8", indent=4))
        filedict.close()

        sizeOrder = open(SizeFile , "w+")
        sizeOrder.write(json.dumps(self.sizeOrder, ensure_ascii=False, encoding="utf -8", indent=4))
        sizeOrder.close()

        md5List = open(Md5File , "w+")
        md5List.write(json.dumps(self.md5List, ensure_ascii=False, encoding="utf -8", indent=4))
        md5List.close()

        repeatList = open(RepeatFile , "w+")
        repeatList.write(json.dumps(self.repeatList, ensure_ascii=False, encoding="utf -8", indent=4))
        repeatList.close()

        allFiles = open(AllFiles , "w+")
        allFiles.write(json.dumps(self.allFiles, ensure_ascii=False, encoding="utf -8", indent=4))
        allFiles.close()

    # 存在记录文件的情况，不重新遍历文件夹
    def hasFile(self):
        if os.path.isfile(DictFile):
            file_stream = open(DictFile , "r")
            if comFun.is_json(file_stream.read()):
                # print json_stream.tell()
                file_stream.seek(0, 0)
                self.filedict = json.load(file_stream)
                # print "open : " + json.dumps(self.json_res, ensure_ascii=False, encoding="utf-8", indent=4)
                return True
            else:
                json_stream.close()
                os.remove(DictFile)
                print "record file has error remove file paht : " + DictFile
        return False

    # 复制文件
    def copyFile(self):
        if os.path.isdir(copypath):
            shutil.rmtree(copypath)
        time.sleep(3)                # 大规模的文件操作，需要做延时处理
        os.mkdir(copypath, 0o777)
        copynum = 0
        for filepath in self.md5List.itervalues():   # 有很多的同名文件
            _, filename = os.path.split(filepath)
            copynum += 1
            if os.path.isfile(copypath + "/" + filename):   # 判断是否已经存在同名文件
                shutil.copyfile(filepath, copypath + "/" + str(copynum) + "_" + filename)
            else:
                shutil.copyfile(filepath, copypath + "/" + filename)

        if copynum == len(self.md5List):
            print "File Num : " + str(len(self.md5List))

    # 添加文件到容器中
    def addToDict(self, filepath):
        md5 = self.getFileMd5(filepath)
        if not md5:
            return False

        _, filetype = os.path.splitext(filepath)  # 分离文件名和后缀
        if not filetype:
            print "File Type is Null : " + filepath
            return False
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

    # 生成文件hash值{MD5 : {currPath:path , oldpath : [path1 ,path2 ...]}}
    def getFileMd5(self , filepath):
        md5 = comFun.getFileMd5(filepath)
        if md5 in self.md5List:
            if md5 in self.repeatList:
                self.repeatList[md5]["oldpath"].append(filepath)
            else:
                repeatDict = {}
                self.repeatList[md5] = repeatDict
                repeatDict["currPath"] =  self.md5List[md5]
                oldpaths = []
                repeatDict["oldpath"] = oldpaths
                oldpaths.append(filepath)
            # print "Repeat File Path : " + filepath
            return False
        self.md5List[md5] = filepath
        return md5

    # 对文件大小进行排序
    def sortFileSize(self):
        self.sizeOrder = sorted(self.sizeOrder.items() , key = lambda fileSize:fileSize[1] , reverse = True)
        # print type(self.sizeOrder)
        # print(json.dumps(self.sizeOrder, ensure_ascii=False, encoding="utf -8", indent=4))

    # 对文件创建时间进行排序
    def formatFileCTime(self):
        # 创建时间都是在"Tue Nov 06 16:11:46 2018" 根据日期来处理失去意义
        sorted(self.timeOrder.items() , key = lambda filetime:filetime[1])
        # for key,filetime in self.timeOrder.items():
        #     self.timeOrder[key] = time.asctime(time.localtime(filetime))
        print(json.dumps(self.timeOrder, ensure_ascii=False, encoding="utf -8", indent=4))
