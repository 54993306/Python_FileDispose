# -*- coding: UTF-8 -*-

import os
import json
import hashlib
import re
import time
import shutil
import stat
import comFun
import collections
#读取路径下的所有资源文件分类后写入到文件中

class totalRes:
    allFiles = 0                                   # 记录文件数
    filedict = collections.OrderedDict()           # 文件分类表，有多少中类型资源，每种类型有多少个
    notRepeatmd5List = collections.OrderedDict()   # 存储文件md5值 key:md5 value:path
    oldtonewPath = collections.OrderedDict()       # 新旧路径对应表 key: oldpath ,value : newpath
    typeNum = collections.OrderedDict()            # 存储文件类型和相应的数量

    def __init__(self):
        self.initFileDict()

    # 将内容记录到文件中
    def recordToFile(self):
        comFun.RecordToJsonFile(comFun.DICTFILE, self.filedict)

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
        for path in fileList:
            if not os.path.isabs(path):
                path = os.path.abspath(path)
            if re.search(r".svn" , path) :
                continue
            path = comFun.turnBias(path)
            if not self.addToDict(path):    # 重复文件不进行后续操作
                continue
        # print(json.dumps(self.filedict, ensure_ascii=False, encoding="utf -8", indent=4))
        print "Total File Num : " + str(self.allFiles)
        self.copyFile()
        self.recordToFile()
        # print(json.dumps(self.typeNum, ensure_ascii=False, encoding="utf -8", indent=4))

    # 判断记录文件的情况
    def hasRecordFile(self):
        if os.path.isfile(comFun.DICTFILE):
            file_stream = open(comFun.DICTFILE , "r")
            if comFun.is_json(file_stream.read()):
                # print json_stream.tell()
                file_stream.seek(0, 0)
                self.filedict = json.load(file_stream, object_pairs_hook=collections.OrderedDict)
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
        comFun.removeDir(comFun.COPYPATH)
        os.mkdir(comFun.COPYPATH, 0o777)
        copynum = 0
        for md5Code , fileInfo in self.notRepeatmd5List.iteritems():
            copynum += 1
            # 这里要生成唯一性的名称，后面需要用名称来与md5值生成对应关系，因为在合成plist后，只有名称保存在其中
            newpath = self.getNewFileName(fileInfo["old"])
            if os.path.isfile(newpath):                         # 重名文件会导致md5值不同，但是指向了同一个路径的文件
                path,basename =  os.path.split(newpath)
                newpath = path + "/" +str(copynum) + basename
                print(" exist file : " + newpath)   # csb 不执行重命名操作，但是有很多重名的csb，但从UI的结构上来看是不应该的
            shutil.copyfile(fileInfo["old"], newpath)
            fileInfo["new"] = newpath
            self.setNewPathByFileDict(md5Code , newpath)

    # 设置文件字典中文件的新路径
    def setNewPathByFileDict(self , md5Code , newpath):
        _, filetype = os.path.splitext(newpath)  # 分离文件名和后缀
        if not filetype:
            return
        if md5Code in self.filedict[filetype]:
            self.filedict[filetype][md5Code]["new"] = newpath
        else:
            assert(False)

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
            print "succeed  repeatNum: " + str(repeatNum) + "\ncopy file : " + str(len(self.notRepeatmd5List))
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
        typedict = collections.OrderedDict()
        if filetype in self.filedict:
            typedict = self.filedict.get(filetype)
        else:
            self.filedict[filetype] = typedict
        pathdict = collections.OrderedDict()
        pathdict["size"] = os.path.getsize(filepath)
        pathdict["old"] = filepath
        typedict[md5] = pathdict
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
        fileInfo = collections.OrderedDict()
        fileInfo["old"] = filepath
        self.notRepeatmd5List[md5] = fileInfo   # 由一个md5值对应所有曾出现过的文件
        return md5
