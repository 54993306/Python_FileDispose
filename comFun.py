# -*- coding: UTF-8 -*-

import os
import json
import hashlib
import copy
import re
# 通过子进程执行shell命令
# subprocess.run('kill  %s' % ' '.join(pids), shell=True)
# 就可以杀掉进程 111 和 22

BigFileSie = 1024 * 100   #100k以上即认为是大文件

PNG_MAX_SIZE = 1024  # 输出的图片大小,大多数平台支持的大小

UNPACKAGENUM = 3

# 将对数据的存储和处理，抽象到一个专门的类中去进行操作。通过统一的接口去调用个各类的产出都存储到同一个通用类中。

FILEPATH = "D:\\Svn_2d\\S_GD_Heji\\res\\"
COPYPATH = r"real_res"
DICTFILE = "./output/filedict.json"
SIZEFILE = "./output/filesize.json"
MD5OLD_NEW = "./output/notRepeatFilemd5.json"       # 包含新旧两种文件的信息和数据
REPEATFILE = "./output/repeatfile.json"
ALLFILES = "./output/allfile.json"                  # 存储game目录下的res的信息
NEWMD5 = "./output/newmd5.json"
FILETYPENUM = "./output/fileTypeNum.json"           # 存储文件类型和对应的文件数量

# json UI 文件
SEARCHJSONPATH = "D:\Svn_2d\UI_Shu\Json"            # 只是竖版的大厅部分json
REALPATH = r"D:\Svn_2d\S_GD_Heji\res/hall/"         # 资源的具体位置和json的位置相关
JSONHAVARES = "./output/jsonres.json"
COLLATINGJSON = "./output/collatingjsonres.json"    # 整理之后的json资源
REFERENCEFILE = "./output/reference.json"
NOTFOUND = "./output/notfound.json"
REPEATFILE = "./output/repeatfile.json"

# 代码文件
CODEFOLDER = r"D:\Svn_2d\S_GD_Heji\src\app"
GAMECODEFOLDER = r"D:\Svn_2d\S_GD_Heji\src\package_src"
CODERESFILE = r"./output/coderesline.json"
CODEUNREGULARFILE = r"./output/codeUnregularline.json"
CODECSB = r"./output/codecsb.json"

# package
PLISTINFO = "./output/plistInfo.json"  # 合图后的plist包含的图片信息。
SORTREFLIST = "./output/sortRefList.json"  # key:path , value:reference
PLISTMD5 = "./output/plistMd5.json"  # 图片md5值对应存储的plist文件
TARGETPATH = r"D:\Svn_2d\UI_Shu\Resources/"  # 实际输出路径
OUTPUTTARGET = r"D:\Python_FileDispose/"
TYPEPATHS = "./output/resTypePaths.json"  # 文件分类后对应的新路径和md5值，对不进行大图合成的资源进行分类存放
TYPENEWPATH = "./output/typeNewPaths.json"

#
CHANGERESULT = r"./output/changefile.json"
PLISTMD5 = "./output/plistMd5.json"  # 图片md5值对应存储的plist文件

# code res
CODERESMESSAGE = "./CodeOutPut/code_res_Message.json"
CODELINERES = "./CodeOutPut/resLine.json"

# 为优化打包结构，一些图片，手动选择不用打包
UNPACKAGERES = {}
UNPACKAGERES["lastUpdateAD"] = True

SPECIALTYPE = [".fnt"]

def RecordToJsonFile(path , data):
    file_stream = open(path, "w+")
    file_stream.write(json.dumps(data, ensure_ascii=False, encoding="utf -8", indent=4))
    file_stream.close()

def GetDataByFile(path):
    data = {}
    if not os.path.isfile(path):
        return data
    stream = open(path, "r")
    data = json.load(stream)
    stream.close()
    return data


def initPathFiles(filepath , list):
    if os.path.isdir(filepath):
        for ccfile in os.listdir(filepath):
            if os.path.isdir(filepath + "/" + ccfile):
                # print(filepath + "/" + ccfile + "----- 3")
                initPathFiles(filepath + "/" + ccfile , list)
            else:
                # print(filepath + "/" + ccfile + "-----2")
                # list.append(filepath + "/" + ccfile + "\n") # 写入到列表中，不需要加换行符，从列表中写入文件才需要加入换行符
                list.append(filepath + "/" + ccfile ) # 写入到列表中，不需要加换行符，从列表中写入文件才需要加入换行符
    else:
        print(filepath + "-----1")
        list.append(filepath)

def Test2(rootDir):
    for lists in os.listdir(rootDir):
        path = os.path.join(rootDir, lists)   #将root路径链接到子目录上
        print path
        if os.path.isdir(path):
            Test2(path)
# Test2(filefilepath)
FileMd5Dict = {}   #用于记录文件的路径和md5值,避免同一路径多次生成
def getFileMd5( path ):
    if FileMd5Dict.has_key(path):
        return FileMd5Dict.get(path)

    if os.path.isfile(path):
        filesize = os.path.getsize(path)
        if filesize > BigFileSie:   # 大文件获取md5值的方法
            # print("BigFile :" + path + " size = " + str(filesize))
            return bigFileMd5(path)
        else:
            return smallFileMd5(path)
    else:
        print(" path error : " + path)

def bigFileMd5(path):
    md5_obj = hashlib.md5()
    f_stream = open(path, "rb")
    while True:
        cut_stream = f_stream.read(8069)
        if not cut_stream:
            break
        md5_obj.update(cut_stream)
    hask_code = md5_obj.hexdigest()
    f_stream.close()
    md5_code = str(hask_code).lower()
    FileMd5Dict[path] = md5_code
    return md5_code

def smallFileMd5(path):
    md5_obj = hashlib.md5()
    f_stream = open(path , "rb")
    md5_obj.update(f_stream.read())
    hash_code = md5_obj.hexdigest()
    f_stream.close()
    md5_code = str(hash_code).lower()
    FileMd5Dict[path] = md5_code
    return md5_code

# 判断字符串内容是否为合法json格式内容
def is_json(myjson):
    try:
        json.loads(myjson)
    except ValueError:
        return False
    return True

# 将所有的斜杠转换为正斜杠
def turnBias(str):
    str = re.sub(r"[/]+" , r"\\" , str)
    return re.sub(r"[\\]+" , "/" , str)