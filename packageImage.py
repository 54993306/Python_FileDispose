
# -*- coding: UTF-8 -*-

# 小图合成大图

import comFun
import os
import json
import shutil
import re
from PIL import Image
import xml.etree.ElementTree as ET

PNG_MAX_SIZE = 1024  # 输出的图片大小,大多数平台支持的大小
PACKAGESOURCE = r"D:\Python_FileDispose\packagesource\\"
COMMONSOURCE = r"D:\Python_FileDispose\packagesource\\lowcommon"
PACKAGEOUTPUT = r"D:\\Python_FileDispose\\packageimage\\"
class packageImage:
    plistInfo = {}      # 合图后的plist包含的图片信息。
    sortRefList = {}    # key:path , value:reference
    plistMd5 = {}       # 图片md5值对应存储的plist文件
    lowRefPath = {}  # 引用计数低的路径

    # 将数据都记录到文件中
    def recordData(self):
        comFun.RecordToJsonFile(comFun.PLISTINFO , self.plistInfo)

        comFun.RecordToJsonFile(comFun.SORTREFLIST, self.sortRefList)

        comFun.RecordToJsonFile(comFun.PLISTMD5, self.plistMd5)

    def packageRes(self):
        self.sortReference()
        # self.countPackagImage()  # 文件被移动一次后第二次合成时，会报错，文件已经被移走了
        # self.modulePackageImage()
        self.initNewImageInfo()
        self.initPlistMd5()
        self.recordData()
        self.copyOutPutFile()

    # 对引用计数进行排序处理，分析需要进行预加载的图片要满足的引用计数最低值是多少
    def sortReference(self):
        ref_stream = open(comFun.REFERENCEFILE,"r")         #以json中的文件引用计数为基础对图片进行打包处理
        refDict = json.load(ref_stream)
        for md5 , dic1 in refDict.iteritems():
            if len(dic1["RefList"]) and dic1["FilePath"]:
                fileinfo = {}
                self.sortRefList[dic1["FilePath"]] = fileinfo
                fileinfo["refNum"] = len(dic1["RefList"])
                fileinfo["md5"] = md5
            else:
                print "refresh is : " + str(len(dic1["RefList"])) + "path: " + dic1["FilePath"]
        # self.sortRefList = sorted(self.sortRefList.items(), key=lambda refNum: refNum[1] , reverse = True)
        # print json.dumps(self.sortRefList, ensure_ascii=False, encoding="utf-8", indent=4)
        ref_stream.close()

    # 根据引用计数，执行打包工具脚本合成大图,试用版软件可以实现切图无水印
    def countPackagImage(self):
        SOURCE_FOLDER = PACKAGESOURCE + "foreload"
        if not os.path.isdir(SOURCE_FOLDER):
            os.mkdir(SOURCE_FOLDER, 0o777)
        newFile_stream = open(comFun.NEWMD5 , "r")
        newFileDict = json.load(newFile_stream)
        for tPath , fileinfo in self.sortRefList.iteritems():
            _, filetype = os.path.splitext(tPath)
            if cmp(filetype, ".png") != 0:
                print "not image file: " + tPath
                continue
            newpath = newFileDict[fileinfo["md5"]]  # 根据老路径直接获取新路径的信息
            if not os.path.isabs(newpath):
                newpath = os.path.abspath(newpath)
            if fileinfo["refNum"] > 2:  # 将引用计数最高，且合成后大小是1024的合成为一张图
                # 根据md5值，找到相应的新路径的位置，打包大图使用新路径的打包大图，新路径的图已经修改过名字
                self.moveResToPath(newpath , SOURCE_FOLDER)
            else:
                self.lowRefPath[tPath] = newpath
        self.callPackageTexture(PNG_MAX_SIZE , "foreload" , SOURCE_FOLDER)
        newFile_stream.close()

    # 将模块中，引用计数较低的按模块进行打包
    def modulePackageImage(self):
        jsonres_stream = open(comFun.JSONHAVARES , "r")
        jsonresDict = json.load(jsonres_stream)
        for jsonpath , resList in jsonresDict.iteritems():   # 对模块进行遍历
            # 如果模块只有少量一两张图的情况如何处理？
            # 考虑将内容少的模块统一合成一张图进行预加载
            moduleName = os.path.basename(jsonpath)
            moduleName = moduleName.split(".")[0]            # 以点号切割字符串返回一个切割的结果列表
            modulePath = PACKAGESOURCE + moduleName
            if not os.path.isdir(modulePath):
                os.mkdir(modulePath, 0o777)
            for respath in resList:
                if respath in self.lowRefPath:
                    self.moveResToPath( self.lowRefPath.get(respath) , modulePath)  # 将图片移动到打包的路径下
                else:
                    print "not found file in lowRefList : " + respath
            if not self.judgeResNum(modulePath):            # 将模块中只有少量图片的模块集中
                os.removedirs(modulePath)                   # 将空的文件夹都删掉
                continue
            self.callPackageTexture(PNG_MAX_SIZE, moduleName , modulePath) # 将模块下的内容打包输出到指定目录下
        self.callPackageTexture(PNG_MAX_SIZE, "common", COMMONSOURCE)   # 对模块中的集中图片进行打包

    # 对文件夹中的图片做一个判断处理，当低于3张时不进行直接合图处理。移动到某个位置后，一起合并起来组成通用图统一预加载
    def judgeResNum(self , modulePath):
        if not os.path.isdir(COMMONSOURCE):
            os.mkdir(COMMONSOURCE, 0o777)
        folderFiles = []  # 存储所有的json文件
        comFun.initPathFiles(modulePath, folderFiles)
        if not len(folderFiles):
            return False
        if len(folderFiles) < comFun.UNPACKAGENUM:
            for resPath in folderFiles:
                self.moveResToPath(resPath, COMMONSOURCE)
            return False
        return True

    # 将图片移动到打包路径
    def moveResToPath(self , resPath , sourcePath):
        if not os.path.isfile(resPath):
            return
        if max(Image.open(resPath).size) >= PNG_MAX_SIZE:
            print "max size path : " + resPath
        else:
            filename = os.path.basename(resPath)
            if os.path.isfile(resPath):
                shutil.move(resPath, sourcePath + "\\" + filename)
            else:
                print "package Lost file :" + resPath

    # 调用打包工具打包图片
    def callPackageTexture(self , PNG_MAX_SIZE , outFileName , SOURCE_FOLDER):
        TEXTURE_PACK_PATH = r"C:\Program Files\CodeAndWeb\TexturePacker\bin"
        PACKAGE_TYPE = r"--multipack"
        PLIST_PATH = PACKAGEOUTPUT + outFileName +"{n}.plist"
        PNG_PATH = PACKAGEOUTPUT + outFileName +"{n}.png"
        PACKAGE_COMMOND = "TexturePacker.exe %s --data %s --sheet %s --max-size %d %s" % \
                          (PACKAGE_TYPE, PLIST_PATH, PNG_PATH, PNG_MAX_SIZE, SOURCE_FOLDER)
        CURRPATH = os.getcwd()
        os.chdir(TEXTURE_PACK_PATH)
        os.system(PACKAGE_COMMOND)
        os.chdir(CURRPATH)

    # 读取输出路径中的plist文件获取大图中的资源信息
    def initNewImageInfo(self):
        folderFiles = []  # 存储所有的json文件
        comFun.initPathFiles(PACKAGEOUTPUT, folderFiles)
        for plistPath in folderFiles:
            if not os.path.isabs(plistPath):
                plistPath = os.path.abspath(plistPath)
            if not os.path.isfile(plistPath):
                print(" not found file " + plistPath)
                assert(False)
            _,filetype = os.path.splitext(plistPath)
            if cmp(filetype , r".plist") != 0:
                continue
            tree = ET.parse(plistPath)
            root = tree.getroot()
            elements = self.getListElement(root)
            self.initPlistInfo(elements , plistPath)

    # 读取plist中的png字段
    def initPlistInfo(self , pElements , plistPath):
        pngList = []
        self.plistInfo[plistPath] = pngList
        for ele in pElements:
            if re.search(r".png", ele.text):
                pngList.append(ele.text)


    # 找到包含图片名称的dict并返回，因文件结构原因，只好这样去找。
    def getListElement(self, pElement):
        for tr in pElement:
            for tr2 in tr:  # frames.dict.metadata.dict
                if tr2.tag == "dict":
                    for tr3 in tr2:
                        _, isPng = os.path.splitext(tr3.text)
                        if cmp(isPng, r".png") == 0:
                            return tr2

    # 初始化md5对应的文件所在的plist文件
    def initPlistMd5(self):
        if not os.path.isabs(comFun.NEWMD5):
            comFun.NEWMD5 = os.path.abspath(comFun.NEWMD5)
        newFile_stream = open(comFun.NEWMD5 , "r")
        newFileDict = json.load(newFile_stream)
        for md5 , filepath in newFileDict.iteritems():
            filename = os.path.basename(filepath)
            for plistpath , pnglist in self.plistInfo.iteritems():
                for pngName in pnglist:
                    if cmp(filename , pngName) == 0:
                        plistpath = os.path.abspath(plistpath)
                        plistpath = re.sub(PACKAGEOUTPUT, "1newplist/", plistpath)
                        self.plistMd5[md5] = plistpath                  # 文件md5值对应所存储的plist文件
        # print(json.dumps(self.plistMd5, ensure_ascii=False, encoding="utf -8", indent=4))

    def copyOutPutFile(self):
        folderFiles = []  # 存储所有的json文件
        comFun.initPathFiles(PACKAGEOUTPUT, folderFiles)
        for filepath in folderFiles:
            if not os.path.isabs(filepath):
                filepath = os.path.abspath(filepath)
            if not os.path.isfile(filepath):
                print(" not found file " + filepath)
                assert (False)
            shutil.copyfile(filepath, r"D:\Svn_2d\UI_Shu\Resources\1newplist/" + os.path.basename(filepath))
        #