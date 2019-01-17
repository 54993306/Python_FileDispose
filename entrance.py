
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
import shutil
import copy
import tidyRes
from PIL import Image
import fileDataHandle as FD

if not TEST:
    # 去重和生成文件信息
    # t = totalResDict.totalRes() #初始化所有的资源信息

    # 对json中的资源做处理
    # jc= jsonFileRes.jsonRes()  # 初始化所有json中包含的资源信息

    # 对UI中使用的资源进行5小图合并大图
    # pcg = packageImage.packageImage()

    # 修改json文件为使用大图
    # cg = fileChange.replaceImage()

    # 初始化代码中包含的资源信息
    # cre = codeRes.codeRes()

    # 整理日志和资源
    tr = tidyRes.tidyRes()
else:
    comFun.deleteDirByStr(r".svn", r"D:\Python_FileDispose\source")
    # shutil.copytree(r"D:\Svn_2d\UI_Shu", r"D:\Python_FileDispose\source\UI_Shu")