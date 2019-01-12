# -*- coding: UTF-8 -*-

import os
import json
import hashlib
import copy
import re
# 通过子进程执行shell命令
# subprocess.run('kill  %s' % ' '.join(pids), shell=True)
# 就可以杀掉进程 111 和 22

BigFileSie      = 1024 * 100   #100k以上即认为是大文件
PNG_MAX_SIZE    = 1024          # 输出的图片大小,大多数平台支持的大小
PNG_MAX_RES     = 512           # 判断是否为大尺寸资源
UNPACKAGENUM    = 3

# 将对数据的存储和处理，抽象到一个专门的类中去进行操作。通过统一的接口去调用个各类的产出都存储到同一个通用类中。

FILEPATH        = "D:/Svn_2d/S_GD_Heji/res/"
COPYPATH        = "D:/Python_FileDispose/real_res"
TARGETPATH      = "D:/Svn_2d/UI_Shu/Resources/"  # 实际输出路径
OUTPUTTARGET    = "D:/Python_FileDispose/"
OUTPUTPATH      = "D:/Python_FileDispose/newJson/"

PACKAGESOURCE   = "D:/Python_FileDispose/packagesource/"
PACKAGEOUTPUT   = "D:/Python_FileDispose/packageimage/"

# json UI 文件
SEARCHJSONPATH  = "D:/Svn_2d/UI_Shu/Json"            # 只是竖版的大厅部分json
REALPATH        = "D:/Svn_2d/S_GD_Heji/res/hall/"         # 资源的具体位置和json的位置相关

# 1 totalResDict
DICTFILE        = "./output/1_FileDict.json"
SIZEFILE        = "./output/1_FileSize.json"
MD5OLD_NEW      = "./output/1_NewFilesInfo.json"             # 包含新旧两种文件的信息和数据
FILETYPENUM     = "./output/1_FileTypeNum.json"             # 存储文件类型和对应的文件数量
REPEATFILE      = "./output/1_RepeatFile.json"
ALLFILES        = "./output/1_Allfile.json"                    # 存储game目录下的res的信息
NEWMD5          = "./output/1_NewMd5.json"

# 2 JsonFileRes 其他的非大厅部分的json，它拼接的路径就不是res/hall了
JSONHAVARES     = "./output/2_JsonRes.json"
COLLATINGJSON   = "./output/2_CollatingJsonRes.json"    # 整理之后的json资源
REFERENCEFILE   = "./output/2_Reference.json"
NOTFOUND        = "./output/2_NotFound.json"

# 3 packageImage
PLISTINFO       = "./output/3_PlistInfo.json"  # 合图后的plist包含的图片信息。
PLISTMD5        = "./output/3_PlistMd5.json"  # 图片md5值对应存储的plist文件
TYPEPATHS       = "./output/3_ResTypePaths.json"  # 文件分类后对应的新路径和md5值，对不进行大图合成的资源进行分类存放
TYPENEWPATH     = "./output/3_TypeNewPaths.json"
MOVERECORD      = "./output/3_MoveRecord.json"  # 记录被使用了的资源

# 4 fileChange
CHANGERESULT    = "./output/4_ChangeFile.json"

# 5 code res
CODERESMESSAGE      = "./CodeOutPut/code_res_Message.json"
CODELINERES         = "./CodeOutPut/resLine.json"
CODEFOLDER          = "D:/Svn_2d/S_GD_Heji/src/app"
GAMECODEFOLDER      = "D:/Svn_2d/S_GD_Heji/src/package_src"
CODERESFILE         = "./output/coderesline.json"
CODEUNREGULARFILE   = "./output/codeUnregularline.json"
CODECSB             = "./output/codecsb.json"

# 为优化打包结构，一些图片，手动选择不用打包
UNPACKAGERES = {}
UNPACKAGERES["lastUpdateAD"] = True

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