
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
from PIL import Image
import fileDataHandle as FD

if not TEST:
    referenceRes = {}    #文件引用计数表

    t = totalResDict.totalRes() #初始化所有的资源信息
    t.initFileDict()

    # jc= jsonFileRes.jsonRes()  # 初始化所有json中包含的资源信息
    # jc.initRecordFile()

    # 小图合并大图
    # pcg = packageImage.packageImage()
    # pcg.tidyRes()
    #
    # 修改json文件为使用大图
    # cg = fileChange.replaceImage()
    # cg.replaceFile()

    # 初始化代码中包含的资源信息
    # cre = codeRes.codeRes()
    # cre.excuteReplace()
else:
    print 1

