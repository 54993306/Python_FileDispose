
# -*- coding: UTF-8 -*-

import os
import json
import re

import comFun
import totalResDict
import jsonFileRes
import fileChange

t = totalResDict.gameres()
t.initFileDict()

jc= jsonFileRes.jsonHasRes()
jc.iniJsonFileList(t.filedict)

cg = fileChange.replaceImage()
cg.replaceFile(jc.jsonPaths)