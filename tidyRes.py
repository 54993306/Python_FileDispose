
# -*- coding: UTF-8 -*-

# 将被使用了的资源从real_res中取出来

import comFun
import os
import re
import shutil
import json
import collections
import fileDataHandle as FD

class tidyRes:

    def __init__(self):
        self.FileData = comFun.GetDataByFile(comFun.MD5OLD_NEW)
        self.UIChange = comFun.GetDataByFile(comFun.CHANGERESULT)
        self.CodeChange = comFun.GetDataByFile(comFun.CODERESMESSAGE)
        self.tidyInfo = collections.OrderedDict()

        self.tidy()

    # 实际移动的文件和原去重后的文件想比较，得出的差异就是每种资源多余的文件差异。
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
        for luaPath , ChangeInfos in self.CodeChange.iteritems():  # 代码中对每个json文件中使用的资源有过一个去重处理 dict key
            if not "ValidChange" in ChangeInfos:
                continue
            for md5code , ChangeInfo in ChangeInfos["ValidChange"].iteritems():
                if re.search(comFun.RESFOLDER + "/[\w]*?.png" , ChangeInfo["new"]):
                    if not ChangeInfo["new"] in LuaValidResList:
                        LuaValidResList.append(ChangeInfo["new"])
                    shutil.copyfile(ChangeInfo["new"], CopyToPath + "/" + os.path.basename(ChangeInfo["new"]))

        ValidResList = {}
        ValidResList["JsonChange"] = JsonValidResList
        ValidResList["CodeChange"] = LuaValidResList
        print(json.dumps(ValidResList, ensure_ascii=False, encoding="utf -8", indent=4))
        comFun.RecordToJsonFile(comFun.TIDYRECORD, ValidResList)


    # 找到代码中所有使用的资源，判断哪些csb是没有在json中被使用的，对应的UIJson文件是否有图片是可以删除掉的。
    # 引用了不存在的csb NotFount、NoChange 数组可以解决,代码中引用了不存在的资源都需要做处理
    # 遍历所有的csb，如果不存在于被改动的部分，表示在代码中没有使用，一旦使用了，随着路径的移动会发生改动
    # 多余的csb没有被人引用，只需要比对，被复制过去的部分，和原来的之间的差异，就可以知道每种资源的多余情况

    # 多余的资源，比对被复制过去的实际使用csb得出多余的。
    # 使用了不存在的，分析NotFound和NotChange即可得出。

    # 在代码中和在Json中使用了Plist文件的情况。 最主要的问题就是，名称被修改了之后，是否会发生无法使用的情况
    # 还没有做过实验和分析。