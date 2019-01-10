
# -*- coding: UTF-8 -*-
TEST = False
# TEST = True
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
import shutil
from PIL import Image

if not TEST:
    referenceRes = {}    #文件引用计数表

    # t = totalResDict.totalRes() #初始化所有的资源信息
    # t.initFileDict()

    # jc= jsonFileRes.jsonRes()  # 初始化所有json中包含的资源信息
    # jc.initRecordFile()

    # 小图合并大图
    pcg = packageImage.packageImage()
    pcg.packageRes()

    # 修改json文件为使用大图
    # cg = fileChange.replaceImage()
    # cg.replaceFile()

    # 初始化代码中包含的资源信息
    # cre = codeRes.codeRes()
    # cre.initResList()
else:
    class TestClass:
        absPathChild = ["games", "hall", "package_res"]
        FILEPATH = r"D:\Svn_2d\S_GD_Heji\res/"
        resTypes = ['\\.png', '\\.ExportJson', '\\.plist', '\\.json',
                    '\\.fnt', '\\.TTF', '\\.jpg', '\\.mp3', '\\.ogg',
                    '\\.csb']
        # resTypes = ['.png', '.ExportJson', '.plist', '.json',
        #             '.fnt', '.TTF', '.jpg', '.mp3', '.ogg',
        #             '.csb']
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
                if "msgList" in self.outInfo[self.handleFilePath]:
                    msgList = self.outInfo[self.handleFilePath].get("msgList")
                    msgList.append(instr)
                else:
                    msgList = []
                    self.outInfo[self.handleFilePath]["msgList"] = msgList
                    msgList.append(instr)
            elif isinstance(instr , list):
                self.outInfo[self.handleFilePath]["matchList"] = instr
            else:
                print(type(instr))
                assert(False)

        # 记录输出信息到文件
        def recordInfoListToFile(self , listName ,info , tagInfo = None):
            InfoList = None
            if listName in self.outInfo[self.handleFilePath]:
                InfoList = self.outInfo[self.handleFilePath][listName]
            else:
                InfoList = []
                self.outInfo[self.handleFilePath][listName] = InfoList
            if tagInfo:
                InfoList.append("%s >>> %s" % (info.ljust(50), tagInfo))
            else:
                InfoList.append(info)

        # 记录改变的内容
        def recordChange(self , oldstr , newstr):
            ChangeList = None
            if "ChangeList" in self.outInfo[self.handleFilePath]:
                ChangeList = self.outInfo[self.handleFilePath]["ChangeList"]
            else:
                ChangeList = []
                self.outInfo[self.handleFilePath]["ChangeList"] = ChangeList
            ChangeList.append("%s >>> %s" % (oldstr.ljust(50) , newstr))

        # 记录所使用的Plist,可以拓展记录每个png对应的Plist文件
        def recordPlist(self , plist):
            PlistList = None
            if "PlistList" in self.outInfo[self.handleFilePath]:
                PlistList = self.outInfo[self.handleFilePath]["PlistList"]
            else:
                PlistList = []
                self.outInfo[self.handleFilePath]["PlistList"] = PlistList
            PlistList.append(plist)

        # 记录在Lua中使用但是Res路径中不存在的内容
        def recordNotFindRes(self , path):
            NotFount = None
            if "NotFount" in self.outInfo[self.handleFilePath]:
                NotFount = self.outInfo[self.handleFilePath]["NotFount"]
            else:
                NotFount = []
                self.outInfo[self.handleFilePath]["NotFount"] = NotFount
            NotFount.append(path)

        # 执行替换操作
        def excuteReplace(self):
            pathstr = ["./oldJson/HallMain.lua"]
            for filepath in pathstr:
                stream = open(filepath, "r")
                self.handleFilePath = filepath      # 对日志的记录提供了很大的遍历，大胆使用语言特性
                self.outInfo[filepath] = {}
                self.handleStream(stream)

        # 开始处理文件流
        def handleStream(self,stream):
            resList = []
            content = []
            unMatch = []
            for lineNum, line in enumerate(stream):
                for resType in self.resTypes:               # 对于不处理的类型，在这个位置就可以进行过滤掉
                    pattern = re.compile(r"[\"](?P<Pattern>[^:\"]+?" + resType + r")[\"]")  # 找到包含资源的行，所有的资源都会被修改路径，统一进行管理
                    serchList = pattern.findall(line)  # 对于一行中，包含多个类型的情况
                    if serchList:
                        resList.extend(serchList)                        # 含有resType且匹配成功的部分
                        line = pattern.sub(self.replacePattern , line)   # 可能对一行内容进行多次替换，一行中有多个restype的情况
                    else:
                        if re.search(resType, line):  # 包含有资源类型的字段,但是匹配不成功
                            unMatch.append(line + " >>> " + resType)
                content.append(line)
            self.outInfo[stream.name]["unMatch"] = unMatch
            if resList:
                # print json.dumps(resList, ensure_ascii=False, encoding="utf -8", indent=4)
                self.coderesline[stream.name] = resList
                self.printOutInfo(resList)
            self.createNewFile(content)

        # 创建替换内容后的文件
        def createNewFile(self , content):
            dir = "./newLua/" + os.path.dirname(self.handleFilePath)
            if not os.path.isdir(dir):
                os.makedirs(dir , 0o777)
            basename = os.path.basename(self.handleFilePath)
            stream = open(dir + "/" + basename , "w+")
            for line in content:
                stream.write(str(line))
            stream.close()

        # 对路径做判断处理
        def replacePattern(self,match):   # match是表达式匹配到的内容
            matchStr = match.group("Pattern")
            filepath = self.formatPath(matchStr)
            if not filepath:
                self.recordInfoListToFile("NoChange" , matchStr)
                return "\"" + matchStr + "\""
            newPath = self.getResNewPath(filepath)
            if newPath:
                self.recordChange(matchStr , newPath)
                self.printOutInfo( "new path :" + newPath)
                return "\"" + newPath + "\""   # 给新路径添加引号
            else:
                self.printOutInfo("Error match : " + matchStr)
                return match.group("Pattern")

        # 格式化匹配到的内容
        def formatPath(self , matchStr):
            paths = matchStr.split("/")[0]
            if not paths in self.absPathChild:  # 判断路径是否为根路径内容
                self.printOutInfo("not abs path can't change :" + matchStr)
                return
            filepath = self.FILEPATH + matchStr
            if not os.path.isabs(filepath):
                filepath = os.path.abspath(filepath)
            if not os.path.isfile(filepath):  # 横版代码在竖版中没有图
                self.recordNotFindRes(filepath)
                self.printOutInfo("can't find in game res :" + filepath)  # 在游戏中不存在该图片
                return
            return filepath

        # 根据老路径取得新路径
        def getResNewPath(self , oldpath):
            filemd5 = self.allResData[oldpath]
            newFileName = self.getNewFilePath(filemd5)
            _,filetype = os.path.splitext(newFileName)
            if not filetype in self.handleType:
                self.printOutInfo( "not handle type " + newFileName )
                return newFileName
            if filemd5 in self.plistMd5:
                self.recordPlist(self.plistMd5.get(filemd5))
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
                assert(False)

        # 根据md5值获取文件新路径
        def getNewFilePath(self, filemd5):
            newFileName = None
            if filemd5 in self.newFileMD5:
                newFileName = self.newFileMD5.get(filemd5)
            else:
                self.printOutInfo( "can't found new file md5 : " + filemd5 )
            return newFileName

    # TestClass().excuteReplace()