
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
import copy
import tidyRes
from PIL import Image
import fileDataHandle as FD

if not TEST:
    # t = totalResDict.totalRes() #初始化所有的资源信息
    # t.initFileDict()

    # 对json中的资源做处理
    # jc= jsonFileRes.jsonRes()  # 初始化所有json中包含的资源信息
    # jc.initRecordFile()

    # 对UI中使用的资源进行5小图合并大图
    pcg = packageImage.packageImage()
    pcg.tidyRes()
    #
    # 修改json文件为使用大图
    # cg = fileChange.replaceImage()
    # cg.replaceFile()

    # 初始化代码中包含的资源信息
    # cre = codeRes.codeRes()
    # cre.excuteReplace()
    #
    # tr = tidyRes.tidyRes()
    # tr.tidy()
else:
    print ""
    # comFun.addDataToFile("./aaa.txt" , 77122 , "22221")