
# -*- coding: UTF-8 -*-

import comFun
import re
import os


codeFolder = r"D:\Svn_2d\S_GD_Heji\src\app"
gameCodeFolder = r"D:\Svn_2d\S_GD_Heji\src\package_src"
class codeRes:
    fileList = []
    comFun.initPathFiles(codeFolder , fileList)
    comFun.initPathFiles(gameCodeFolder , fileList)

    def initResList(self):
        for filepath in self.fileList:
            if re.search(r".svn" , filepath):
                continue
            