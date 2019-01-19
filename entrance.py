
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
    # 去重和生成文件信息
    # totalResDict.totalRes() #初始化所有的资源信息

    # 对json中的资源做处理
    # jsonFileRes.jsonRes()  # 初始化所有json中包含的资源信息

    # 对UI中使用的资源进行5小图合并大图
    # packageImage.packageImage()

    # 修改json文件为使用大图
    # fileChange.replaceImage()

    # 初始化代码中包含的资源信息
    codeRes.codeRes()

    # 整理日志和资源
    # tidyRes.tidyRes()
else:
    print ""
    comFun.deleteDirByStr(r".svn", r"D:\Svn_2d\CoCoStuio\vertical\hal_packres")
    # shutil.copytree(r"D:\Svn_2d\CoCoStuio\vertical\hall", r"D:\Python_FileDispose\source\UI_Shu")