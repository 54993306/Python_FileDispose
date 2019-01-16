
# -*- coding: UTF-8 -*-

# 将被使用了的资源从real_res中取出来

import comFun
import os
import re
import shutil
import json
import fileDataHandle as FD

class tidyRes:

    def __init__(self):
        self.UIChange = comFun.GetDataByFile(comFun.CHANGERESULT)
        self.CodeChange = comFun.GetDataByFile(comFun.CODERESMESSAGE)
        self.tidyInfo = {}


    def tidy(self):
        CopyToPath = comFun.TARGETPATH + comFun.RESFOLDER
        # if os.path.isdir(CopyToPath):
        #     comFun.removeDir(CopyToPath)
        os.chmod(comFun.TARGETPATH,0o777)
        if os.path.isdir(CopyToPath):
            shutil.rmtree(CopyToPath)
        os.mkdir(CopyToPath, 0o777)
        JsonValidResList = []
        for jsonPath , ChangeList in self.UIChange.iteritems():
            for index , ChangeInfo in ChangeList.iteritems():
                if not "new" in ChangeInfo:
                    continue
                newPath = ChangeInfo["new"]["path"]
                if re.search(comFun.RESFOLDER , newPath):
                    if not newPath in JsonValidResList:
                        JsonValidResList.append(newPath)
                    shutil.copyfile(newPath , CopyToPath + "/" + os.path.basename(newPath))

        LuaValidResList = []
        for luaPath , ChangeInfo in self.CodeChange.iteritems():  # 代码中对每个json文件中使用的资源有过一个去重处理 dict key
            if not "ChangeDict" in ChangeInfo:
                continue
            for oldPath , newPath in ChangeInfo["ChangeDict"].iteritems():
                if re.search(comFun.RESFOLDER + "/[\w]*?.png" , newPath):
                    if not newPath in LuaValidResList:
                        LuaValidResList.append(newPath)
                    shutil.copyfile(newPath, CopyToPath + "/" + os.path.basename(newPath))

        ValidResList = []
        ValidResList.extend(JsonValidResList)
        ValidResList.extend(LuaValidResList)
        print(json.dumps(ValidResList, ensure_ascii=False, encoding="utf -8", indent=4))

    # 找到代码中所有使用的资源，判断哪些csb是没有在json中被使用的，对应的UIJson文件是否有图片是可以删除掉的。
    def findUnUserCSB(self):
        csbList = []                # 所有在Lua中使用的csb
        for luaPath, ChangeInfo in self.CodeChange.iteritems():
            if not "matchList" in ChangeInfo:
                continue
            for matchStr in matchList:
                if cmp(os.path.splitext(matchStr) , ".csb") == 0:
                    csbList.append(matchStr)

        FileDict = comFun.GetDataByFile(comFun.DICTFILE)
        # for
