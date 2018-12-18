
# -*- coding: UTF-8 -*-

# 小图合成大图

import comFun
import os
import json
from PIL import Image

class packageImage:
    packageList = {}
    sortRefList = {}  # key:path , value:reference

    def sortReference(self):
        ref_stream = open(comFun.ReferenceFIle,"r")
        refDict = json.load(ref_stream)
        for md5 , dic1 in refDict.iteritems():
            if len(dic1["RefList"]) and dic1["FilePath"]:
                self.sortRefList[dic1["FilePath"]] = len(dic1["RefList"])
            else:
                print "refresh is : " + str(len(dic1["RefList"])) + "path: " + dic1["FilePath"]
        # self.sortRefList = sorted(self.sortRefList.items(), key=lambda refNum: refNum[1] , reverse = True)
        # print json.dumps(self.sortRefList, ensure_ascii=False, encoding="utf-8", indent=4)
        self.countPackagImage()

    def countPackagImage(self):
        # shutil.move(src, dst)# 移动文件或重命名
        TEXTURE_PACK_PATH = r"C:\Program Files\CodeAndWeb\TexturePacker\bin"
        PACKAGE_TYPE = r"--multipack"
        PLIST_PATH = r"D:\Python_FileDispose\res\out{n}.plist"
        PNG_PATH = r"D:\Python_FileDispose\res\out{n}.png"
        PNG_MAX_SIZE = 1024  # 输出的图片大小
        SOURCE_FOLDER = r"D:\Python_FileDispose\real_res\111"
        fileStr = ""
        for tPath , referenceNum in self.sortRefList.iteritems():
            if referenceNum > 2:
                _,filetype = os.path.splitext(tPath)
                if cmp(filetype , ".png") != 0:
                    print tPath
                    continue
                # 根据md5值，找到相应的新路径的位置，打包大图使用新路径的打包大图，新路径的图已经修改过名字

                # print Image.open(tPath).size
                if max(Image.open(tPath).size) >= PNG_MAX_SIZE:
                    print "max size path : " + tPath
                else:
                    fileStr = fileStr + tPath + " "
        SOURCE_FOLDER = fileStr
        PACKAGE_COMMOND = "TexturePacker.exe %s --data %s --sheet %s --max-size %d %s" % \
                          (PACKAGE_TYPE, PLIST_PATH, PNG_PATH, PNG_MAX_SIZE, SOURCE_FOLDER)
        # print fileStr
        os.chdir(TEXTURE_PACK_PATH)
        os.system(PACKAGE_COMMOND)
        # os.system(r"cd C:\Program Files\CodeAndWeb\TexturePacker\bin && dir")
        # print TEXTURE_PACK_PATH + "&&" + PACKAGE_COMMOND
        # os.system("ipconfig")
        # os.system("cmd ;%s ;%s" % (TEXTURE_PACK_PATH , "TexturePacker.exe"))
        # 通过分析打印数据，当引用计数大于2时，可以作为第一批的加载数据处理。

        # print len(refDict)

    # 将引用计数最高，且合成后大小是1024的合成为一张图


    # 根据老路径直接获取新路径的信息，获取新路径中的名称和对应的plist文件。