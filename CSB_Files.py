
# -*- coding: UTF-8 -*-
import os
# import shutil

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
    print()
    file.write("".join(fileList))
    file.close()
    # print(fileList)
    #     print(os.path.join(filefilepath, fileList))
# cla = gameres()