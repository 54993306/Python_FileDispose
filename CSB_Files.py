
# -*- coding: UTF-8 -*-
# import shutil
import os
import json
import hashlib

class CSB_Files:
    def __init__(self,path):
        __Path = path
    __Count = 0 #统计文件数量 两个下划线的为
# 单下划线是protected变量，双下划线是私有变量，私有变量 在外部可以通过self.__Count 进行访问
    publicCount = 0 # 类的公开变量
    def count(self):
        print "1111"

# csbfiles = CSB_Files("aaa")
# print "Employee.__doc__:", csbfiles.__doc__
# print "Employee.__module__:", csbfiles.__module__
# print "Employee.__dict__:", csbfiles.__dict__

# 读取行内容
# txt = open("test.txt")
# line = txt.readlines()
# for lines in line:
#     print lines

# 通过子进程执行shell命令
# subprocess.run('kill  %s' % ' '.join(pids), shell=True)
# 就可以杀掉进程 111 和 22

# filepath = "D:/Python_FileDispose/res"
filepath = "./res"
jsonfilename = "lay_test.json"

def initPathFiles(filepath , list):
    if os.path.isdir(filepath):
        for ccfile in os.listdir(filepath):
            if os.path.isdir(filepath + "/" + ccfile):
                print(filepath + "/" + ccfile + "----- 3")
                initPathFiles(filepath + "/" + ccfile , list)
            else:
                print(filepath + "/" + ccfile + "-----2")
                list.append(filepath + "/" + ccfile + "\n")
    else:
        print(filepath + "-----1")
        list.append(filepath + "\n")

def Test2(rootDir):
    for lists in os.listdir(rootDir):
        path = os.path.join(rootDir, lists)   #将root路径链接到子目录上
        print path
        if os.path.isdir(path):
            Test2(path)
# Test2(filefilepath)

#读取路径下的所有资源文件分类后写入到文件中
class gameres:
    file = open("files.txt" , "w+")
    # def __init__(self):
    fileList = []
    initPathFiles(filepath , fileList)

    filedict = {}
    for pathbylist in fileList:
        print(pathbylist)
        abspath = pathbylist
        if not os.path.isabs(abspath):
            abspath = os.path.abspath(pathbylist)
        if os.path.isabs(abspath):                  #可以直接输出
            print("2222222222222222222")
        print(abspath)
        # print abspath.replace("\\" , "/")   # 不管用
        # abspath = repr(abspath)[1:-1]     # repr 不行
        # abspath = eval("""%s""" % str(abspath))   # eval(r"%s" % abspath) 不行，r+abspath不行
        print(os.path.exists(abspath))
        print(os.path.isfile(abspath))
        # print(os.path.exists(r"D:\Python_FileDispose\res\111.txt"))
        # print(os.path.exists(r"D:\Python_FileDispose\res\fqqq\222.png"))
        # print(os.path.exists(r"D:\Python_FileDispose\res\fccc\333.txt"))

        if os.path.exists(abspath) and os.path.isfile(abspath):
            singlepath  = os.path.splitext(abspath)
            print(singlepath)


    # file.write("".join(fileList))
    file.close()

    # jsonfile = open(jsonfilename   , "r+")
    # jsondict = json.load(jsonfile)
    # print json.dumps( jsondict , ensure_ascii=False ,  encoding= "utf -8" , indent=4)


    # if isinstance(jsondict , dict):
        # print( jsondict.get("fileNameData", "666"))   #遍历所有的容器，找到key值为fileNameData的地方