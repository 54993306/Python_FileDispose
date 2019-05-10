
# -*- coding: UTF-8 -*-
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
import copy
import tidyRes as TR
from PIL import Image
import fileDataHandle as FD

# TEST = False
TEST = True
#
if __name__ == "__main__":
    if TEST:
        print ""
        # comFun.svnExport(r"D:\Svn_2d\CoCoStuio\vertical\hall", r"D:\Svn_2d\CoCoStuio\vertical\package_hall")
        def moveCsb():
            jsonPaths = []
            comFun.initPathFiles("D:\\Svn_2d\\CoCoStuio\\vertical\\hall\\Json", jsonPaths)
            for jsonPath in jsonPaths:
                if not re.search(r".json", jsonPath):
                    continue
                print "<string>" + os.path.basename(jsonPath) + "</string>"
        moveCsb()
    else:
        print ""
        # 整理日志和资源
        TidyRes = TR.tidyRes()

        # 文件去重、拷贝、分类、修改特殊文件内容(fnt、plist)
        totalResDict.totalRes() #初始化所有的资源信息

        # 对json中的资源做处理
        # jsonFileRes.jsonRes()  # 初始化所有json中包含的资源信息

        # 对UI中使用的资源进行5小图合并大图
        # packageImage.packageImage()

        # 修改json文件为使用大图
        # fileChange.replaceImage()

        # 移动UI类所使用资源至UI工程和代码工程
        # TidyRes.moveUIRes()

        #打开Cocostudio导出所有文件成功后，执行CSB文件移动
        # TidyRes.moveCsb()

        # 初始化代码中包含的资源信息
        # codeRes.codeRes()

        # 移动代码中所使用资源至代码工程
        # TidyRes.moveCodeRes()