
# -*- coding: UTF-8 -*-
# import shutil
import os
import json
import hashlib

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
                # print(filepath + "/" + ccfile + "----- 3")
                initPathFiles(filepath + "/" + ccfile , list)
            else:
                # print(filepath + "/" + ccfile + "-----2")
                # list.append(filepath + "/" + ccfile + "\n") # 写入到列表中，不需要加换行符，从列表中写入文件才需要加入换行符
                list.append(filepath + "/" + ccfile ) # 写入到列表中，不需要加换行符，从列表中写入文件才需要加入换行符
    else:
        print(filepath + "-----1")
        list.append(filepath)

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
    file.close()
    fileList = []
    initPathFiles(filepath , fileList)
    # file.write("".join(fileList))   #应该遍历后逐行逐行去写，而不是一次性写入到文件中，换行符在写入文件的时候加载行尾
    # jsonfile = open(jsonfilename   , "r+")
    # jsondict = json.load(jsonfile)
    # print json.dumps( jsondict , ensure_ascii=False ,  encoding= "utf -8" , indent=4)

    filedict = {}
    def initFileDict(self):
        def fillDict(typedict , filepath):
            pathdict = {}
            typedict[filepath] = pathdict
            pathdict["md5"] = self.getFileMd5(filepath)
            # pathdict["md5"] = self.getFileMd5(filepath)
            pathdict["size"] = os.path.getsize(filepath)
            #len(dict)   #返回dict元素个数

        for pathbylist in self.fileList:
            abspath = pathbylist
            if not os.path.isabs(abspath):
                abspath = os.path.abspath(pathbylist)
            singlepath , filetype = os.path.splitext(abspath)
            if filetype in self.filedict:
                typedict = self.filedict.get(filetype)
                fillDict(typedict , abspath)
            else:
                typedict = {}
                self.filedict[filetype] = typedict
                fillDict(typedict, abspath)

    def getFileMd5( self,path ):
        if os.path.isfile(path):
            filesize = os.path.getsize(path)
            if filesize > 1024 * 10:   # 大文件获取md5值的方法
                return self.bigFileMd5(path)
            else:
                return self.smallFileMd5(path)
        else:
            print(" path error : " + path)

    def bigFileMd5(self , path):
        md5_obj = hashlib.md5()
        f_stream = open(path, "rb")
        while True:
            cut_stream = f_stream.read(8069)
            if not cut_stream:
                break
            md5_obj.update(cut_stream)
        hask_code = md5_obj.hexdigest()
        f_stream.close()
        md5_code = str(hask_code).lower()
        return md5_code

    def smallFileMd5(self , path):
        md5_obj = hashlib.md5()
        f_stream = open(path , "rb")
        md5_obj.update(f_stream.read())
        hash_code = md5_obj.hexdigest()
        f_stream.close()
        md5_code = str(hash_code).lower()
        return md5_code

t = gameres()
t.initFileDict()
print(json.dumps(t.filedict, ensure_ascii=False, encoding="utf -8", indent=4))

import re
# 需要把可存在png和plist的行都进行处理，所有的资源类型都要进行处理和匹配
jsonpaths = "./"
jsonHavaRes = "jsonres.txt"
class jsonHasRes:
    json_res = {}
    fileList = []
    initPathFiles(jsonpaths , fileList)

    def iniJsonFileList(self):
        jsonres = open(jsonHavaRes , "w+")
        for jsonpath in self.fileList:
            if not re.search(r".json" , jsonpath):
                continue
            print(jsonpath)
            if not os.path.isabs(jsonpath):
                jsonpath = os.path.abspath(jsonpath)
            if not os.path.isfile(jsonpath):
                assert(False)
            file_stream = open(jsonpath , "rb")

            for line in file_stream.readlines():
                for resType in t.filedict.iterkeys():
                    resType = str.replace(resType , "." , "\." )
                    # print(resType)
                    if re.search(resType , line):
                        line = str.replace(line , " " , "")
                        print resType + " : " + line
                        jsonres.write(line)
        # print(jsonres.read())
        jsonres.close()

jc= jsonHasRes()
jc.iniJsonFileList()