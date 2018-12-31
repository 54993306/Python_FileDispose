
# -*- coding: UTF-8 -*-
# TEST = False
TEST = True
#
import os
import json
import re
import codeRes
import comFun
import totalResDict
import jsonFileRes
import fileChange
import packageImage
import types
from PIL import Image

if not TEST:
    referenceRes = {}    #文件引用计数表

    # t = totalResDict.totalRes() #初始化所有的资源信息
    # t.initFileDict()

    # jc= jsonFileRes.jsonRes()  # 初始化所有json中包含的资源信息
    # jc.initRecordFile()

    # 初始化代码中包含的资源信息
    cre = codeRes.codeRes()
    cre.initResList()

    # 小图合并大图
    # pcg = packageImage.packageImage()
    # pcg.packageRes()

    # 修改json文件为使用大图
    # cg = fileChange.replaceImage()
    # cg.replaceFile()
else:
    class TestClass:
        absPathChild = ["games", "hall", "package_res"]
        FILEPATH = r"D:\Svn_2d\S_GD_Heji\res/"
        resTypes = ['\\.png', '\\.ExportJson', '\\.plist', '\\.json',
                    '\\.fnt', '\\.TTF', '\\.jpg', '\\.mp3', '\\.ogg',
                    '\\.csb']
        handleType = ['.png','.fnt', '.TTF']
        changeResult = []   # 对数组合字符串做分别判断

        def __init__(self):  # 构造函数
            files_stream = open(comFun.ALLFILES, "r")   # 这些输出类文件再次读取应存储在comFun类中，或不需要去直接创建它
            self.allResData = json.load(files_stream)

            plistMd5 = open(comFun.PLISTMD5, "r")
            self.plistMd5 = json.load(plistMd5)
            plistMd5.close()

            newPaths = open(comFun.TYPENEWPATH, "r")
            self.newPaths = json.load(newPaths)
            newPaths.close()

            newFileMD5 = open(comFun.NEWMD5, "r")
            self.newFileMD5 = json.load(newFileMD5)
            newFileMD5.close()

            self.outInfo = {}
            self.coderesline = {}

        def __del__(self):  # 析构函数
            comFun.RecordToJsonFile(comFun.CODERESMESSAGE , self.outInfo)
            comFun.RecordToJsonFile(comFun.CODELINERES , self.coderesline)

        # sed 命令处理
        def sedCommand(self):
            # oldpath = os.getcwd()
            # os.chdir("D:\Python_FileDispose")
            # os.chdir(oldpath)
            # print os.getcwd()
            # os.system("cmd && wsl && sed")
            # os.system("wsl sed -i 's/ccc/new/g' ./file.txt")
            os.system("wsl sed -i 's/new/ccc/g' ./file.txt")

            stream = open("ccc.txt", "w+")
            liststr = ["1,2,3,4", "2232", "asdfasdf"]
            for line in liststr:
                stream.write(str(line) + "\n")
            # stream.writelines(liststr)
            stream.close()
            os.system("wsl cat ccc.txt")

        # 输出并写入日志文件
        def printOutInfo(self , instr):
            if isinstance(instr , str) or isinstance(instr , unicode):
                print instr
                self.currList.append(instr)
            else:
                print(type(instr))
                assert(False)

        def replacePath(self):
            pathstr = ["./oldJson/HallMain.lua"]
            for filepath in pathstr:
                str_stream = open(filepath, "r")
                self.currList = []
                self.outInfo[filepath] = self.currList
                self.handleFile(str_stream)

        def handleFile(self,str_stream):
            resList = []
            for lineNum, line in enumerate(str_stream):
                for resType in self.resTypes:
                    pattern = re.compile(r"[\"](?P<Pattern>[^:\"]*?" + resType + r")[\"]")  # 找到包含资源的行，所有的资源都会被修改路径，统一进行管理
                    serchList = pattern.findall(line)  # 对于一行中，包含多个类型的情况
                    if serchList:
                        resList.extend(serchList)
                        pattern.sub(self.replacePattern , line)
            if resList:
                # print json.dumps(resList, ensure_ascii=False, encoding="utf -8", indent=4)
                self.coderesline[str_stream.name] = resList
            self.printOutInfo(str(len(resList)))

        def getResNewPath(self , oldpath):
            if not oldpath in self.allResData:
                self.printOutInfo( "can't find old path :" + oldpath )
                return
            filemd5 = self.allResData[oldpath]
            newFileName = self.getNewFilePath(filemd5)
            _,filetype = os.path.splitext(newFileName)
            if not filetype in self.handleType:
                self.printOutInfo( "not handle type " + newFileName )
                return newFileName
            # if cmp(filetype , ".csb") == 0 or cmp(filetype , ".plist") == 0:
            #     return newFileName
            if filemd5 in self.plistMd5:
                self.printOutInfo( "file in plist :" + self.plistMd5.get(filemd5))
                return "#" + os.path.basename(newFileName)      # 要使用精灵帧的形式进行处理
            else:
                _, filetype = os.path.splitext(newFileName)
                if cmp(filetype, ".png") != 0:
                    return self.otherFileData(filemd5)
                if max(Image.open(newFileName).size) >= comFun.PNG_MAX_SIZE:
                    return self.otherFileData(filemd5)
                else:
                    basename = os.path.basename(newFileName)
                    basename = basename.split(".")[0]
                    if basename in comFun.UNPACKAGERES:  # 对尺寸较大的图但又不超过1024的图做单独处理
                        return self.otherFileData(filemd5)
                    self.printOutInfo( "can't found plist file : " + oldpath + "  md5:" + filemd5 + " newPath :" + newFileName )
                    return newFileName  # 只是改了名字没有合并大图的图，只是修改了文件的路径

        # 对fnt类的用户自定义的字体(LabelBMFont)进行处理
        def otherFileData(self, filemd5):
            if filemd5 in self.newPaths:
                # print "new big path : " + self.newPaths.get(filemd5)
                return self.newPaths.get(filemd5)
            else:
                assert (False)

        # 根据md5值获取文件新路径
        def getNewFilePath(self, filemd5):
            newFileName = None
            if filemd5 in self.newFileMD5:
                newFileName = self.newFileMD5.get(filemd5)
            else:
                self.printOutInfo( "can't found new file md5 : " + filemd5 )
            return newFileName

        # 对路径做判断处理
        def replacePattern(self,match):
            if not match:
                self.printOutInfo( "not match" )
                return ""
            matchStr = match.group("Pattern")
            paths = matchStr.split("/")[0]
            if not paths in self.absPathChild:
                self.printOutInfo( "can't change path :" + matchStr)
                return
            else:
                matchStr = self.FILEPATH + matchStr
                # print "add file path : " + matchStr
            oldmatch = matchStr
            if not os.path.isabs(matchStr):
                matchStr = os.path.abspath(matchStr)
            if not os.path.isfile(matchStr):
                self.printOutInfo( "can't find in game res :" + matchStr ) # 在游戏中不存在该图片
                return oldmatch
            newPath = self.getResNewPath(matchStr)
            if newPath:
                self.printOutInfo( "new path :" + newPath)
                return "\"" + newPath + "\""   # 给新路径添加引号
            else:
                return oldmatch

    TestClass().replacePath()
