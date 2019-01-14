
# -*- coding: UTF-8 -*-

# 小图合成大图

import comFun
import os
import json
import shutil
import re
import copy
import collections
import fileDataHandle as FD
from PIL import Image
import xml.etree.ElementTree as ET

# 图片合并的规则是相对负责的,出现图片的情况很多，包括在代码中使用和一张图被多个文件使用的情况

class packageImage:
    plistInfo = collections.OrderedDict()      # 合图后的plist包含的图片信息。
    plistMd5 = collections.OrderedDict()       # 图片md5值对应存储的plist文件
    lowRefPath = collections.OrderedDict()     # 引用计数低的路径
    newResPath = collections.OrderedDict()     # 结构化存储文件被整理后的路径信息
    outPutFolder = collections.OrderedDict()   # 生成的文件夹
    moveRecord = collections.OrderedDict()     # 记录被使用的文件
    packageInfo = collections.OrderedDict()    # 存储合成plist的res信息
    unPackRepeat = collections.OrderedDict()   # 未打包和重复移动的文件
    unPackRepeat["repeat"] = []

    # 将数据都记录到文件中
    def recordData(self):
        comFun.RecordToJsonFile(comFun.PLISTINFO , self.plistInfo)

        comFun.RecordToJsonFile(comFun.PLISTMD5, self.plistMd5)

        comFun.RecordToJsonFile(comFun.TYPEPATHS, self.newResPath)    # 新路径新增到文件信息记录中
        self.fileData.refreshTypeDataToFile(self.newResPath)

        comFun.RecordToJsonFile(comFun.UNPACKREPEATRES, self.unPackRepeat)

        comFun.RecordToJsonFile(comFun.MOVERECORD, self.moveRecord)

    def tidyRes(self):
        self.fileData = FD.fileDataHandle()
        self.clearDir()
        self.tidyForeRes()  # 文件被移动一次后第二次合成时，会报错，文件已经被移走了
        self.tidyModuleRes()
        self.packageRes()
        self.initNewImageInfo()
        self.initPlistMd5()
        self.recordData()
        self.copyOutPutFile()
        self.copyMoveRes()

    # 清理文件夹
    def clearDir(self):
        if os.path.isdir(comFun.PACKAGESOURCE):
            shutil.rmtree(comFun.PACKAGESOURCE)
        if os.path.isdir(comFun.PACKAGEOUTPUT):
            shutil.rmtree(comFun.PACKAGEOUTPUT)
        os.mkdir(comFun.PACKAGEOUTPUT, 0o777)
        os.mkdir(comFun.PACKAGESOURCE, 0o777)

    # 对资源进行打包操作
    def packageRes(self):
        for outPutName , SourcePath in self.packageInfo.iteritems():
            # 将模块下的内容打包输出到指定目录下
            self.singlePackageTexture(comFun.PNG_MAX_SIZE, outPutName, SourcePath)

    # 根据引用计数，执行打包工具脚本合成大图,试用版软件可以实现切图无水印
    def tidyForeRes(self):
        SOURCE_FOLDER = comFun.PACKAGESOURCE + "foreload"   # 存储引用计数较高的资源
        if not os.path.isdir(SOURCE_FOLDER):
            os.mkdir(SOURCE_FOLDER, 0o777)
        refDict = copy.deepcopy(comFun.GetDataByFile(comFun.REFERENCEFILE))
        for MD5code , fileinfo in refDict.iteritems():
            _, filetype = os.path.splitext(fileinfo["new"])
            if cmp(filetype, ".png") != 0:
                self.handleOtherRes(fileinfo["new"])
                continue
            if fileinfo["total"] > 2:  # 将引用计数最高，且合成后大小是1024的合成为一张图, 2产生自对引用次数的分析
                # 根据md5值，找到相应的新路径的位置，打包大图使用新路径的打包大图，新路径的图已经修改过名字
                self.moveResToPath(fileinfo["new"] , SOURCE_FOLDER)
            else:
                self.lowRefPath[fileinfo["Path"]] = fileinfo["new"]
        self.packageInfo["foreload"] = comFun.PACKAGESOURCE + "foreload"

    # 将模块中，引用计数较低的按模块进行打包
    def tidyModuleRes(self):
        collatingJsonRes = copy.deepcopy(comFun.GetDataByFile(comFun.COLLATINGJSON))
        for jsonpath , resDict in collatingJsonRes.iteritems():   # json对应一个模块，对模块进行遍历
            # 如果模块只有少量一两张图的情况如何处理？
            # 考虑将内容少的模块统一合成一张图进行预加载
            moduleName = os.path.basename(jsonpath)
            moduleName = moduleName.split(".")[0]            # 以点号切割字符串返回一个切割的结果列表
            modulePath = comFun.PACKAGESOURCE + moduleName
            if not os.path.isdir(modulePath):
                os.mkdir(modulePath, 0o777)
            for md5code , respath in resDict.iteritems():
                if respath["curr"] in self.lowRefPath:
                    self.moveResToPath( self.lowRefPath.get(respath["curr"]) , modulePath)  # 将图片移动到打包的路径下
                # else:
                    # print "not found file in lowRefList : " + respath
            if not self.judgeResNum(modulePath):            # 将模块中只有少量图片的模块集中
                os.removedirs(modulePath)                   # 将空的文件夹都删掉
                continue
            self.packageInfo[moduleName] = modulePath
        self.packageInfo["common"] = comFun.PACKAGESOURCE + "common"

    # 对文件夹中的图片做一个判断处理，当低于3张时不进行直接合图处理。移动到某个位置后，一起合并起来组成通用图统一预加载
    def judgeResNum(self , modulePath):
        SourcePath = comFun.PACKAGESOURCE + "common"
        if not os.path.isdir(SourcePath):
            os.mkdir(SourcePath, 0o777)
        folderFiles = []  # 存储所有的json文件
        comFun.initPathFiles(modulePath, folderFiles)
        if not len(folderFiles):
            return False
        if len(folderFiles) < comFun.UNPACKAGENUM:
            for resPath in folderFiles:
                resPath = comFun.turnBias(resPath)
                md5code = self.moveRecord[resPath]["md5"]
                if md5code in self.unPackRepeat:   # 已经被移动过一次，则移动回原来的位置去，避免图片重复出现
                    print "repeat :" + resPath
                    self.moveResToPath(resPath, comFun.COPYPATH, True)
                else:
                    self.moveResToPath(resPath, SourcePath, True)  # 达不到打包条件的图片会统一存放到这个位置，没有进行进一步的处理
                    self.unPackRepeat[self.moveRecord[resPath]["md5"]] = SourcePath + "/" + os.path.basename(resPath)
                # 要做进一步的处理，出现的一个情况是一个文件可能被多个(具体为2个，2个以上会另外打包)json使用 1000497.png 就是其中的情况之一
            return False
        return True

    # 将图片移动到打包路径
    def moveResToPath(self , resPath , sourcePath , coerce = False):  # 默认采用拷贝模式
        if self.isRepeatCopy(resPath):
            return
        if min(Image.open(resPath).size) >= comFun.PNG_MAX_RES:
            # print "max size path : " + resPath   # 大图也是其他资源的一种
            self.handleOtherRes(resPath)
        else:
            basename = os.path.basename(resPath)
            if os.path.isfile(resPath):
                # print "cur : " + resPath + " Tag : " + sourcePath + "\\" + filename
                if coerce:
                    shutil.move(resPath, sourcePath + "\\" + basename)          # 不是移动无法删除文件夹
                else:
                    shutil.copyfile(resPath, sourcePath + "\\" + basename)          # 剪切的方式进行文件移动打包
                    self.recordMovePath(resPath, sourcePath + "\\" + basename)
            else:
                print "package Lost file :" + resPath

    # 判断当前路径是否已经被拷贝过
    def isRepeatCopy(self , resPath):
        for tPath , fileInfo in self.moveRecord.iteritems():
            if cmp(fileInfo["new"] , resPath) == 0:  # 图片已经被移走
                if "repeat" in self.unPackRepeat:
                    self.unPackRepeat["repeat"].append(resPath)
                else:
                    repeat = []
                    repeat.append(resPath)
                    self.unPackRepeat["repeat"] = repeat
                return resPath
        return
    # 对png以外的其他资源做处理
    def handleOtherRes(self , pResPath):
        if not os.path.isfile(pResPath):
            return
        _, filetype = os.path.splitext(pResPath)
        outPutPath = "res_" + filetype.split(".")[1]
        if not os.path.isdir(outPutPath):
            os.mkdir(outPutPath, 0o777)
        if not outPutPath in self.outPutFolder:
            self.outPutFolder[outPutPath] = True
        command = self.fntdiapose(pResPath , outPutPath) # 移动与fnt对应的图片
        tPath = comFun.OUTPUTTARGET + outPutPath + "/" + os.path.basename(pResPath)
        # print "cur : " + pResPath + " Tag : " + tPath
        shutil.copyfile(pResPath , tPath)
        if command:
            pNewResPath = re.sub("D:/Python_FileDispose", ".", tPath)   # 修改目标路径的文件，而不是本地文件
            print command + pNewResPath
            # "wsl sed -i s/new/ccc/g ./file.txt"
            os.system(command + pNewResPath)
        self.recordMovePath(pResPath, tPath)
        self.initNewPathRes(pResPath , tPath , outPutPath)

    # 对fnt类文件处理，找到相应的png文件
    def fntdiapose(self , pNewResPath , outPutPath ):
        _, filetype = os.path.splitext(pNewResPath)
        if cmp(filetype, ".fnt") == 0:  # 针对fnt类文件进行特殊处理
            baseName = os.path.basename(pNewResPath)
            oldpath = self.fileData.getOldPathBypath(pNewResPath)
            pResPath = re.sub(r".fnt", r".png", oldpath)
            newPath = self.fileData.getNewPathByOldPath(pResPath)
            if not newPath:
                print "new ： " + pNewResPath + " old :" + oldpath or ""
                assert(False)
            tPath = comFun.OUTPUTTARGET + outPutPath + "/" + baseName.split(".")[0] + ".png"
            shutil.copyfile(newPath, tPath)
            self.recordMovePath(newPath, tPath)
            return "wsl sed -i s/" +  os.path.basename(pResPath) + "/" +  os.path.basename(tPath) + "/g "

    # 初始化分类后文件位置信息
    def initNewPathRes(self , oldPath , newPath , outPutPath):
        # print "res move: " + oldPath.ljust(58) + ">>> " + newPath
        resInfo = collections.OrderedDict()
        resInfo["md5"] = self.fileData.getFileMd5(oldPath)
        resInfo["path"] = newPath
        if outPutPath in self.newResPath:
            resList = self.newResPath.get(outPutPath)
            resList.append(resInfo)
        else:
            resList = []
            self.newResPath[outPutPath] = resList
            resList.append(resInfo)

    # 调用打包工具打包图片
    def callPackageTexture(self , PNG_MAX_SIZE , outFileName , SOURCE_FOLDER):
        TEXTURE_PACK_PATH = r"C:\Program Files\CodeAndWeb\TexturePacker\bin"
        PACKAGE_TYPE = r"--multipack"
        PLIST_PATH = comFun.PACKAGEOUTPUT + outFileName +"{n}.plist"
        PNG_PATH = comFun.PACKAGEOUTPUT + outFileName +"{n}.png"
        PACKAGE_COMMOND = "TexturePacker.exe %s --data %s --sheet %s --max-size %d %s" % \
                          (PACKAGE_TYPE, PLIST_PATH, PNG_PATH, PNG_MAX_SIZE, SOURCE_FOLDER)
        CURRPATH = os.getcwd()
        os.chdir(TEXTURE_PACK_PATH)
        os.system(PACKAGE_COMMOND)
        os.chdir(CURRPATH)

    # 使用老版本的TexturePackage进行文件打包处理，将一些超出的大图进行手动删除处理，自动的同时加入一些手动操作，兼容cocosstudio
    def singlePackageTexture(self, PNG_MAX_SIZE , outFileName , SOURCE_FOLDER):
        TEXTURE_PACK_PATH = r"C:\Program Files (x86)\TexturePacker\bin"
        PLIST_PATH = comFun.PACKAGEOUTPUT + outFileName + ".plist"
        PNG_PATH = comFun.PACKAGEOUTPUT + outFileName + ".png"
        PACKAGE_COMMOND = "TexturePacker.exe --data %s --sheet %s --max-size %d %s" % \
                          (PLIST_PATH, PNG_PATH, PNG_MAX_SIZE, SOURCE_FOLDER)
        CURRPATH = os.getcwd()
        os.chdir(TEXTURE_PACK_PATH)
        os.system(PACKAGE_COMMOND)
        os.chdir(CURRPATH)

    # 读取输出路径中的plist文件获取大图中的资源信息
    def initNewImageInfo(self):
        folderFiles = []  # 存储所有的json文件
        comFun.initPathFiles(comFun.PACKAGEOUTPUT, folderFiles)
        for plistPath in folderFiles:
            if not os.path.isabs(plistPath):
                plistPath = os.path.abspath(plistPath)
            plistPath = comFun.turnBias(plistPath)
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
        pngList = collections.OrderedDict()
        self.plistInfo[plistPath] = pngList
        for ele in pElements:
            if re.search(r".png", ele.text):
                pngList[ele.text] = self.fileData.getResInfoByBaseName(ele.text)


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
        for md5 , filepath in self.fileData.getFileDatas().iteritems():
            filename = os.path.basename(filepath["new"])
            for plistpath , pnglist in self.plistInfo.iteritems():
                for pngName in pnglist:
                    if cmp(filename , pngName) == 0:
                        self.plistMd5[md5] = plistpath                  # 文件md5值对应所存储的plist文件
        # print(json.dumps(self.plistMd5, ensure_ascii=False, encoding="utf -8", indent=4))

    # 拷贝输出的plist文件到指定目录
    def copyOutPutFile(self):
        folderFiles = []  # 存储所有的json文件
        comFun.initPathFiles(comFun.PACKAGEOUTPUT, folderFiles)
        self.copyFilesToPath(folderFiles, comFun.TARGETPATH + "1newplist/")

    # 将被移动的大图和其他资源拷贝到应用目录
    def copyMoveRes(self):
        for folderpath in self.outPutFolder.iterkeys():
            folderFiles = []  # 存储所有的json文件
            comFun.initPathFiles(folderpath, folderFiles)
            self.copyFilesToPath(folderFiles , comFun.TARGETPATH + folderpath)

    # 将文件列表复制到指定目录
    def copyFilesToPath(self , files , path):
        if not os.path.isdir(path):
            os.mkdir(path, 0o777)
        else:
            os.chmod(path, 0o777)       # 当cocosstudio在运行时会提示权限不足
        for filepath in files:
            if not os.path.isabs(filepath):
                filepath = os.path.abspath(filepath)
            if not os.path.isfile(filepath):
                print(" not found file " + filepath)
                assert (False)
            shutil.copyfile(filepath, path + "/" + os.path.basename(filepath))

    # 记录移动的文件信息
    def recordMovePath(self , path ,tPath):
        tPath = comFun.turnBias(tPath)
        self.moveRecord[tPath] = self.fileData.getResInfoByNewPath(path)