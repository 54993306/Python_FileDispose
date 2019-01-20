
# -*- coding: UTF-8 -*-

import re
import os
import json
import comFun
import copy
import collections
import sys
reload(sys)
sys.setdefaultencoding('utf8')
import fileDataHandle as FD

class codeRes:
    absPathChild = ["games", "hall", "package_res","res"]
    FILEPATH = r"D:/Svn_2d/S_GD_Heji/res/"
    resTypes = ['\\.png', '\\.ExportJson', '\\.plist', '\\.json',
                '\\.fnt', '\\.TTF', '\\.jpg', '\\.mp3', '\\.ogg']  # csb类资源不做匹配修改处理
    handleType = ['.png', '.fnt', '.TTF' , ".plist"]
    changeResult = []  # 对数组合字符串做分别判断

    def __init__(self):  # 构造函数
        self.plistMd5 = copy.deepcopy(comFun.GetDataByFile(comFun.PLISTMD5))

        self.FileData = FD.fileDataHandle()

        self.outInfo = collections.OrderedDict()

        self.excuteReplace()

    # 输出并写入日志文件
    def printOutInfo(self, instr):
        if not instr:
            return
        if isinstance(instr, str) or isinstance(instr, unicode):
            print instr
            if "msgList" in self.currInfo:
                msgList = self.currInfo.get("msgList")
                msgList.append(instr)
            else:
                msgList = []
                self.currInfo["msgList"] = msgList
                msgList.append(instr)
        elif isinstance(instr, list):
            self.currInfo["matchList"] = instr
        else:
            print(type(instr))
            assert (False)

    # 记录输出信息到文件
    def recordInfoListToFile(self, listName, info, tagInfo=None):
        InfoList = []
        if listName in self.currInfo:
            InfoList = self.currInfo[listName]
        else:
            self.currInfo[listName] = InfoList
        if tagInfo:
            InfoList.append("%s >>> %s" % (info.ljust(50), tagInfo))
        else:
            InfoList.append(info)

    # 记录改变的内容
    def recordChange(self, oldstr, newstr , md5code):
        # 记录每一次实际改动
        if "ChangeRecord" in self.currInfo:
            self.currInfo["ChangeRecord"].append("%s >>> %s" % (oldstr.ljust(50), newstr))
        else:
            ChangeRecord = []
            self.currInfo["ChangeRecord"] = ChangeRecord
            ChangeRecord.append("%s >>> %s" % (oldstr.ljust(50), newstr))
        # 记录每一次有效改动
        FileDict = collections.OrderedDict()
        FileDict["new"] = newstr
        FileDict["old"] = oldstr
        if "ValidChange" in self.currInfo:
            self.currInfo["ValidChange"][md5code] = FileDict
        else:
            ValidChange = collections.OrderedDict()
            self.currInfo["ValidChange"] = ValidChange
            ValidChange[md5code] = FileDict

    # 记录当前修改所使用的Plist,可以拓展记录每个png对应的Plist文件
    def recordPlist(self, md5code):
        if "PlistList" in self.currInfo:
            if md5code in self.currInfo["PlistList"]:
                return
            self.currInfo["PlistList"][md5code] =self.plistMd5.get(md5code)
        else:
            PlistList = collections.OrderedDict()
            self.currInfo["PlistList"] = PlistList
            PlistList[md5code] = self.plistMd5.get(md5code)

    def recordNoDiposeType(self , oldstr, newstr , md5code ):
        FileDict = collections.OrderedDict()
        FileDict["new"] = newstr
        FileDict["old"] = oldstr
        if "NoDiposeType" in self.currInfo:
            self.currInfo["NoDiposeType"][md5code] = FileDict
        else:
            ValidChange = collections.OrderedDict()
            self.currInfo["NoDiposeType"] = ValidChange
            ValidChange[md5code] = FileDict

    # 记录在Lua中使用但是Res路径中不存在的内容
    def recordNotFindRes(self, path):
        if "NotFount" in self.currInfo:
            self.currInfo["NotFount"].append(path)
        else:
            NotFount = []
            self.currInfo["NotFount"] = NotFount
            NotFount.append(path)

    # 记录在Lua中使用但是Res路径中不存在的内容
    def recordUnMatch(self, path):
        if "unMatch" in self.currInfo:
            self.currInfo["unMatch"].append(path)
        else:
            unMatch = []
            self.currInfo["unMatch"] = unMatch
            unMatch.append(path)

    # 不需要做修改的条件
    def isContinue(self , path):
        if not re.search(r".lua", path):
            return True
        if re.search("app/framework/|/app/luaqrcode/|/src/cocos", path):
            return True

    # 执行替换操作
    def excuteReplace(self):
        lusPaths = []
        comFun.initPathFiles(comFun.SEARLUAPATJ, lusPaths)
        # lusPaths = [r"D:\Svn_2d\S_GD_Heji\src\app\hall\main/HallMain.lua"]
        for filepath in lusPaths:
            if not os.path.isabs(filepath):
                filepath = os.path.abspath(filepath)
            if self.isContinue(filepath):
                continue
            filepath = comFun.turnBias(filepath)
            print "\n ===============>>>>> " + filepath
            stream = open(filepath, "r")
            self.currInfo = collections.OrderedDict()
            self.handleFilePath = filepath  # 对日志的记录提供了很大的遍历，大胆使用语言特性
            self.outInfo[filepath] = self.currInfo
            self.handleStream(stream)
        self.tidyChangeInfo()

    # 整理要记录的数据
    def tidyChangeInfo(self):
        emptys = []
        for path , changeInfo in self.outInfo.iteritems():
            if not changeInfo:
                emptys.append(path)
        for path in emptys:
            del self.outInfo[path]
        self.outInfo["emptys"] = emptys
        comFun.RecordToJsonFile(comFun.CODERESMESSAGE, self.outInfo)

    # 开始处理文件流
    def handleStream(self, stream):
        resList = []
        content = []
        for lineNum, line in enumerate(stream):
            for resType in self.resTypes:  # 对于不处理的类型，在这个位置就可以进行过滤掉
                pattern = re.compile(r"[\"](?P<Pattern>[^:\"]+?" + resType + r")[\"]")  # 找到包含资源的行，所有的资源都会被修改路径，统一进行管理
                serchList = pattern.findall(line)  # 对于一行中，包含多个类型的情况
                if serchList:
                    resList.extend(serchList)  # 含有resType且匹配成功的部分
                    line = pattern.sub(self.replacePattern, line)  # 可能对一行内容进行多次替换，一行中有多个restype的情况
                else:
                    if re.search(resType, line):  # 包含有资源类型的字段,但是匹配不成功
                        self.recordUnMatch(line + " >>> " + resType)
            content.append(line)
        self.printOutInfo(resList)
        self.createNewFile(content)

    # 创建替换内容后的文件
    def createNewFile(self, content):
        # dir = re.sub("D:/Svn_2d/S_GD_Heji/src/" , "" , self.handleFilePath)
        # dir = "./newLua/" + os.path.dirname(dir)
        # if not os.path.isdir(dir):  # 不修改lua文件的路径
        #     os.makedirs(dir, 0o777)
        # basename = os.path.basename(self.handleFilePath)
        # stream = open(dir + "/" + basename, "w+")
        dir = re.sub(comFun.SEARLUAPATJ , comFun.NEWLUAPATH , self.handleFilePath)
        print dir
        if not os.path.isfile(dir):         # 对文件做覆盖处理
            os.makedirs(os.path.dirname(dir), 0o777)
        stream = open(dir, "w+")
        for line in content:
            stream.write(str(line))
        stream.close()

    # 对路径做判断处理
    def replacePattern(self, match):  # match是表达式匹配到的内容
        matchStr = match.group("Pattern")
        filepath = self.formatPath(matchStr)
        if not filepath:
            self.recordInfoListToFile("NoChange", matchStr)  # 无法改动的部分
            return "\"" + matchStr + "\""
        newPath , md5code = self.getResNewPath(filepath)
        newPath = re.sub(comFun.OUTPUTTARGET , "" , newPath)
        if newPath:
            self.recordChange(matchStr, newPath , md5code)
            return "\"" + newPath + "\""  # 给新路径添加引号
        else:
            self.printOutInfo("Error match : " + filepath)
            return "\"" + matchStr + "\""

    # 格式化匹配到的内容,将匹配的内容转换为全路径
    def formatPath(self, matchStr):
        paths = matchStr.split("/")[0]
        if cmp("res" , paths) == 0:
            matchStr = re.sub("res/", "", matchStr)
            paths = matchStr.split("/")[0]
        if not paths in self.absPathChild:  # 判断路径是否为根路径内容
            self.printOutInfo("not abs path can't change :" + matchStr)
            return
        filepath = self.FILEPATH + matchStr
        if not os.path.isabs(filepath):
            filepath = os.path.abspath(filepath)
        filepath = comFun.turnBias(filepath)
        if not os.path.isfile(filepath):  # 横版代码在竖版中没有图
            self.recordNotFindRes(filepath)
            return
        return filepath

    # 根据老路径取得新路径 oldpath = D:/Svn_2d/S_GD_Heji/res/hall/font/fangzhengcuyuan.TTF
    def getResNewPath(self, oldpath):
        md5code = self.FileData.getFileMd5(oldpath)
        newFileName = self.FileData.getNewPathByOldPath(oldpath)
        newFileName = re.sub(comFun.OUTPUTTARGET, "", newFileName)
        _, filetype = os.path.splitext(newFileName)
        if not filetype in self.handleType:
            self.recordNoDiposeType(oldpath , newFileName , md5code)
            return newFileName , md5code
        if md5code in self.plistMd5:
            self.recordPlist(md5code)
            return "#" + os.path.basename(newFileName) , md5code # 要使用精灵帧的形式进行处理
        else:
            if self.FileData.getTPathByMd5Code(md5code):  # 包括大图，fnt，和手动设置为不进行打包的聂内容集合
                return self.FileData.getTPathByMd5Code(md5code) , md5code
            self.printOutInfo("can't found plist file : " + oldpath + "  md5:" + md5code + " newPath :" + newFileName)
            return newFileName , md5code # 只是改了名字没有合并大图的图，只是修改了文件的路径