
# -*- coding: UTF-8 -*-

import os
import json
import re


import comFun
import totalResDict
import jsonFileRes

jsonfilename = "1lay_test.json"

t = totalResDict.gameres()
t.initFileDict()
# print(json.dumps(t.filedict, ensure_ascii=False, encoding="utf -8", indent=4))


jc= jsonFileRes.jsonHasRes()
jc.iniJsonFileList(t.filedict)