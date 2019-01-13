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
    filedict = {}           # 文件分类表，有多少中类型资源，每种类型有多少个
    timeOrder = {}          # 文件创建时间排序表 os.path.getctime(path)
    sizeOrder = {}          # 文件大小排序表  os.path.getsize(filepath)
    notRepeatmd5List = {}   # 存储文件md5值 key:md5 value:path
    oldtonewPath = {}       # 新旧路径对应表 key: oldpath ,value : newpath
    allFiles = 0            # 记录文件数
    typeNum = {}            # 存储文件类型和相应的数量
    # 将内容记录到文件中
    def recordToFile(self):
        comFun.RecordToJsonFile(comFun.DICTFILE, self.filedict)

        comFun.RecordToJsonFile(comFun.SIZEFILE, self.sizeOrder)

        comFun.RecordToJsonFile(comFun.MD5OLD_NEW, self.notRepeatmd5List)
        # mp3 对应的编号是  2 , 类型 2 下 有429个文件
        comFun.RecordToJsonFile(comFun.FILETYPENUM, self.typeNum)  #

    # 初始化文件表
    def initFileDict(self , refresh = False):
        refresh = True
        if not refresh and self.hasRecordFile():
            return
        else:
            self.initDict()
            self.judgeFileCopySucceed()

    # 初始化文件字典
    def initDict(self):
        fileList = []
        comFun.initPathFiles(comFun.FILEPATH, fileList)
        for pathbylist in fileList:
            abspath = pathbylist
            if not os.path.isabs(abspath):
                abspath = os.path.abspath(pathbylist)
            if re.search(r".svn" , abspath) :
                continue
            abspath = comFun.turnBias(abspath)
            if not self.addToDict(abspath):    # 重复文件不进行后续操作
                continue
            pathbylist = comFun.turnBias(pathbylist)
            fileSize = os.path.getsize(pathbylist)
            self.sizeOrder[pathbylist] =  fileSize  # 文件大小
            self.timeOrder[pathbylist] = os.path.getctime(pathbylist) # 创建时间
        # print(json.dumps(self.filedict, ensure_ascii=False, encoding="utf -8", indent=4))
        print "Total File Num : " + str(self.allFiles)
        self.copyFile()
        self.sortFileSize()
        self.recordToFile()
        # print(json.dumps(self.typeNum, ensure_ascii=False, encoding="utf -8", indent=4))

    # 判断记录文件的情况
    def hasRecordFile(self):
        if os.path.isfile(comFun.DICTFILE):
            file_stream = open(comFun.DICTFILE , "r")
            if comFun.is_json(file_stream.read()):
                # print json_stream.tell()
                file_stream.seek(0, 0)
                self.filedict = json.load(file_stream)
                file_stream.close()
                # print "open : " + json.dumps(self.json_res, ensure_ascii=False, encoding="utf-8", indent=4)
                return True
            else:
                file_stream.close()
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
        for md5Code , md5_old_new in self.notRepeatmd5List.iteritems():
            copynum += 1
            # 这里要生成唯一性的名称，后面需要用名称来与md5值生成对应关系，因为在合成plist后，只有名称保存在其中
            newpath = self.getNewFileName(md5_old_new["old"])
            shutil.copyfile(md5_old_new["old"], newpath)
            md5_old_new["new"] = newpath

    # 获取新文件名称
    def getNewFileName(self , filepath):
        _, filetype = os.path.splitext(filepath)
        if not filetype or cmp(".csb" , filetype) == 0:   # 没有类型的文件不修改文件名
            return comFun.COPYPATH + "/" + os.path.basename(filepath)
        if not filetype in self.typeNum:
            self.typeNum[filetype] = len(self.typeNum)
            self.typeNum[self.typeNum[filetype]] = 1
        else:
            self.typeNum[self.typeNum[filetype]] += 1
        # 10 表示由工具修改过的图片,中间两位是文件类型码,后面三位为图片index。
        return comFun.COPYPATH + "/" + "10" + \
               str("%02d" % self.typeNum[filetype]) + \
               str("%03d" % self.typeNum[self.typeNum[filetype]]) + filetype

    # 判断文件复制情况是否出现偏差
    def judgeFileCopySucceed(self):
        repeatNum = 0
        for _,value in self.notRepeatmd5List.iteritems():
            if "repeat" in value:
                repeatNum += len(value["repeat"])
        if repeatNum + len(self.notRepeatmd5List) == self.allFiles:
            print "copy file succeed  repeatNum: " + str(repeatNum)
        else:
            print " copy file failed repeatNum: " + str(repeatNum) + " newfilenum : " \
                  + str(len(self.notRepeatmd5List)) + " allNum : " + str(self.allFiles)

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
        self.allFiles += 1
        if md5 in self.notRepeatmd5List:
            if not "repeat" in self.notRepeatmd5List[md5]:
                oldList = []
                self.notRepeatmd5List[md5]["repeat"] = oldList
                oldList.append(filepath)
            else:
                self.notRepeatmd5List[md5]["repeat"].append(filepath)
            return False
        md5_old_new = {}
        md5_old_new["old"] = filepath
        self.notRepeatmd5List[md5] = md5_old_new   # 由一个md5值对应所有曾出现过的文件
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
