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

class totalRes:
    fileList = []
    comFun.initPathFiles(comFun.FILEPATH , fileList)

    filedict = {}           # 文件分类表，有多少中类型资源，每种类型有多少个
    timeOrder = {}          # 文件创建时间排序表 os.path.getctime(path)
    sizeOrder = {}          # 文件大小排序表  os.path.getsize(filepath)
    notRepeatmd5List = {}   # 存储文件md5值 key:md5 value:path
    repeatList = {}         # 存储重复图片的相关信息
    newFileMd5 = {}         # 新文件的md5
    oldtonewPath = {}       # 新旧路径对应表 key: oldpath ,value : newpath
    allFiles = {}           # 存储所有文件和文件对应md5值 未去重，避免多次生成文件md5值
    # 将内容记录到文件中
    def recordToFile(self):
        filedict = open(comFun.DICTFILE , "w+")
        filedict.write(json.dumps(self.filedict, ensure_ascii=False, encoding="utf -8", indent=4))
        filedict.close()

        sizeOrder = open(comFun.SIZEFILE , "w+")
        sizeOrder.write(json.dumps(self.sizeOrder, ensure_ascii=False, encoding="utf -8", indent=4))
        sizeOrder.close()

        md5List = open(comFun.MD5FILE , "w+")
        md5List.write(json.dumps(self.notRepeatmd5List, ensure_ascii=False, encoding="utf -8", indent=4))
        md5List.close()

        repeatList = open(comFun.REPEATFILE , "w+")
        repeatList.write(json.dumps(self.repeatList, ensure_ascii=False, encoding="utf -8", indent=4))
        repeatList.close()

        allFiles = open(comFun.ALLFILES , "w+")
        allFiles.write(json.dumps(self.allFiles, ensure_ascii=False, encoding="utf -8", indent=4))
        allFiles.close()


        newFileMd5 = open(comFun.NEWMD5 , "w+")
        newFileMd5.write(json.dumps(self.newFileMd5, ensure_ascii=False, encoding="utf -8", indent=4))
        newFileMd5.close()

    # 初始化文件表
    def initFileDict(self , refresh = False):
        refresh = True
        if self.hasRecordFile() and not refresh:
            return
        else:
            self.initDict()
            self.judgeFileCopySucceed()

    # 初始化文件字典
    def initDict(self):
        for pathbylist in self.fileList:
            abspath = pathbylist
            if not os.path.isabs(abspath):
                abspath = os.path.abspath(pathbylist)
            if re.search(r".svn" , abspath) :
                continue
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

    # 判断记录文件的情况
    def hasRecordFile(self):
        if os.path.isfile(comFun.DICTFILE):
            file_stream = open(comFun.DICTFILE , "r")
            if comFun.is_json(file_stream.read()):
                # print json_stream.tell()
                file_stream.seek(0, 0)
                self.filedict = json.load(file_stream)
                # print "open : " + json.dumps(self.json_res, ensure_ascii=False, encoding="utf-8", indent=4)
                return True
            else:
                json_stream.close()
                os.remove(comFun.DICTFILE)
                print "record file has error remove file paht : " + comFun.DICTFILE
        return False

    # 复制文件
    def copyFile(self):
        if os.path.isdir(comFun.COPYPATH):
            shutil.rmtree(comFun.COPYPATH)
        time.sleep(3)                # 大规模的文件操作，需要做延时处理
        os.mkdir(comFun.COPYPATH, 0o777)
        copynum = 0
        for md5Code , filepath in self.notRepeatmd5List.iteritems():
            _, filename = os.path.split(filepath)
            copynum += 1
            # 这里要生成唯一性的名称，后面需要用名称来与md5值生成对应关系，因为在合成plist后，只有名称保存在其中
            newpath = comFun.COPYPATH + "/" + filename
            if os.path.isfile(comFun.COPYPATH + "/" + filename):   # 判断是否已经存在同名文件
                newpath = comFun.COPYPATH + "/" + str(copynum) + "_" + filename
                shutil.copyfile(filepath, newpath)
                self.newFileMd5[md5Code] = newpath
            else:
                shutil.copyfile(filepath, newpath)
                self.newFileMd5[md5Code] = newpath
        if len(self.newFileMd5) == len(self.notRepeatmd5List):
            print "File Num : " + str(len(self.notRepeatmd5List))

    # 判断文件复制情况是否出现偏差
    def judgeFileCopySucceed(self):
        repeatNum = 0
        for _,value in self.repeatList.iteritems():
            repeatNum += len(value["oldpath"])
        if repeatNum + len(self.newFileMd5) == len(self.allFiles):
            print "copy file succeed  repeatNum: " + str(repeatNum)
        else:
            print " copy file failed repeatNum: " + str(repeatNum) + " newfilenum : " \
                  + str(len(self.newFileMd5)) + " allNum : " + str(len(self.allFiles))

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
        self.allFiles[filepath] = md5           # 存储所有文件和对应的md5值
        if md5 in self.notRepeatmd5List:
            if md5 in self.repeatList:
                self.repeatList[md5]["oldpath"].append(filepath)
            else:
                repeatDict = {}
                self.repeatList[md5] = repeatDict
                repeatDict["currPath"] =  self.notRepeatmd5List[md5]
                oldpaths = []
                repeatDict["oldpath"] = oldpaths
                oldpaths.append(filepath)
            # print "Repeat File Path : " + filepath
            return False
        self.notRepeatmd5List[md5] = filepath
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
