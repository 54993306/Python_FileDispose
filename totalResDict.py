# -*- coding: UTF-8 -*-

import os
import json
import hashlib

import comFun
#读取路径下的所有资源文件分类后写入到文件中
filepath = "./res"
# filepath = "D:/Python_FileDispose/res"

class gameres:
    file = open("files.txt" , "w+")
    file.close()
    fileList = []
    comFun.initPathFiles(filepath , fileList)

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
            singlepath , filetype = os.path.splitext(abspath)   # 分离文件名和后缀
            if filetype in self.filedict:
                typedict = self.filedict.get(filetype)
                fillDict(typedict , abspath)
            else:
                typedict = {}
                self.filedict[filetype] = typedict
                fillDict(typedict, abspath)
        # print(json.dumps(self.filedict, ensure_ascii=False, encoding="utf -8", indent=4))

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