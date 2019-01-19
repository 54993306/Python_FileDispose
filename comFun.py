# -*- coding: UTF-8 -*-

import os
import json
import hashlib
import copy
import re
import shutil
import stat
import collections


BigFileSie              = 1024 * 100                                #100k以上即认为是大文件
PNG_MAX_SIZE            = 1024                                      # 输出的图片大小,大多数平台支持的大小
PNG_MAX_RES             = 512                                       # 判断是否为大尺寸资源
UNPACKAGENUM            = 3

FILEPATH                = "D:/Svn_2d/S_GD_Heji/res/"                # 获取游戏中的资源位置，并进行去重和重命名处理
COPYPATH                = "D:/Python_FileDispose/real_res"          # 改名去重后的资源存储路径
OUTPUTTARGET            = "D:/Python_FileDispose/"

PACKAGESOURCE           = "D:/Python_FileDispose/packageRes/"       # 需要进行打包的文件夹和资源
PACKAGEOUTPUT           = "D:/Python_FileDispose/packagePList/"     # 打包成Plist后的存储理解

RESFOLDER               = "real_res"

##################################################################################################################

EXCUTE_INDEX            = 1                                         # 0 对应demo，1对应TEST，3对应Project

SEARCHJSONPATH          = "D:/Svn_2d/UI_Shu/Json"                               # 获取JsonUI文件的路径，只是竖版的大厅部分json
TARGETPATH              = "D:/Svn_2d/UI_Shu/Resources/"                         # 打包资源后输出路径
OUTPUTPATH              = "D:/Python_FileDispose/newJson/"                      # 修改后的Json存储路径
NEWLUAPATH              = "D:/Python_FileDispose/newLua/app"                    # 修改后的Lua存储路径
MOVETOCODEPATH          = "D:/Python_FileDispose/source/S_GD_Heji/res/hall/"    # 资源在代码中的路径
SEARLUAPATJ             = "D:/Svn_2d/S_GD_Heji/src/app"                         # 获取Lua文件的路径，只是大厅的Lua文件

if EXCUTE_INDEX == 1:
    SEARLUAPATJ         = "D:/Svn_2d/S_GD_Heji/src/app"                      # 获取Lua文件的路径，只是大厅的Lua文件
    TARGETPATH          = "D:/Python_FileDispose/source/UI_Shu/Resources/"   # 打包资源后输出路径
    OUTPUTPATH          = "D:/Python_FileDispose/source/UI_Shu/Json/"        # 修改后的Json存储路径
    NEWLUAPATH          = "D:/Python_FileDispose/source/S_GD_Heji/src/app"   # 修改后的Lua存储路径
    # SEARLUAPATJ         = NEWLUAPATH
    MOVETOCODEPATH      = "D:/Python_FileDispose/source/S_GD_Heji/res/hall/" # 资源在代码中的路径
    SEARCHJSONPATH      = "D:/Svn_2d/CoCoStuio/vertical/hall/Json"           # 整理后的Ui工程
elif EXCUTE_INDEX == 2:
    TARGETPATH          = "D:/Svn_2d/CoCoStuio/vertical/hal_packres/Resources/"   # 打包资源后输出路径
    OUTPUTPATH          = "D:/Svn_2d/CoCoStuio/vertical/hal_packres/Json/"        # 修改后的Json存储路径
    NEWLUAPATH          = "D:/Python_FileDispose/source/S_GD_Heji/src/app"        # 修改后的Lua存储路径
    MOVETOCODEPATH      = "D:/Python_FileDispose/source/S_GD_Heji/res/hall/"      # 资源在代码中的路径
    SEARCHJSONPATH      = "D:/Svn_2d/CoCoStuio/vertical/hall/Json"                # Ui工程中json文件的路径

##################################################################################################################

# json UI 文件
REALPATH                = "D:/Svn_2d/S_GD_Heji/res/hall/"           # 资源的具体位置和json的位置相关

# 1 totalResDict
DICTFILE                = "./output/1_FileDict.json"
SIZEFILE                = "./output/1_FileSize.json"
MD5OLD_NEW              = "./output/1_NewFilesInfo.json"             # 包含新旧两种文件的信息和数据
FILETYPENUM             = "./output/1_FileTypeNum.json"              # 存储文件类型和对应的文件数量
NEWMD5                  = "./output/1_NewMd5.json"

# 2 JsonFileRes 其他的非大厅部分的json，它拼接的路径就不是res/hall了
JSONHAVARES             = "./output/2_JsonRes.json"
COLLATINGJSON           = "./output/2_CollatingJsonRes.json"            # 整理之后的json资源
REFERENCEFILE           = "./output/2_Reference.json"
NOTFOUND                = "./output/2_NotFound.json"

# 3 packageImage
PLISTINFO               = "./output/3_PlistInfo.json"                   # 合图后的plist包含的图片信息。
PLISTMD5                = "./output/3_PlistMd5.json"                    # 图片md5值对应存储的plist文件
TYPEPATHS               = "./output/3_ResTypePaths.json"                # 分类后对应的新路径和md5值，对不进行大图合成的资源进行分类存放
UNPACKREPEATRES         = "./output/3_UnPackRepeatRes.json"
MOVERECORD              = "./output/3_MoveRecord.json"                  # 记录被使用了的资源

# 4 fileChange
CHANGERESULT            = "./output/4_UIChange.json"

# 5 code res
CODERESMESSAGE          = "./output/5_CodeChange.json"
CODEFOLDER              = "D:/Svn_2d/S_GD_Heji/src/app"
GAMECODEFOLDER          = "D:/Svn_2d/S_GD_Heji/src/package_src"

# 6 tidy
TIDYRECORD              = "./output/6_Tidy.json"

def RecordToJsonFile(path , data):
    file_stream = open(path, "w+")
    file_stream.write(json.dumps(data, ensure_ascii=False, encoding="utf -8", indent=4))
    file_stream.close()

def GetDataByFile(path):
    if not os.path.isfile(path):
        return
    stream = open(path, "r")
    data = json.load(stream, object_pairs_hook=collections.OrderedDict)
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

def Test2(rootDir):
    for lists in os.listdir(rootDir):
        path = os.path.join(rootDir, lists)   #将root路径链接到子目录上
        print path
        if os.path.isdir(path):
            Test2(path)
# Test2(filefilepath)
FileMd5Dict = collections.OrderedDict()   #用于记录文件的路径和md5值,避免同一路径多次生成
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
        cut_stream = f_stream.read(8069)  # 8069 来自网上的参考值
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

# 根据匹配str内容,递归删除路径下的文件
def deleteFileBystr(str , pPath):
    paths = []
    initPathFiles(pPath , paths)
    for path in paths:
        if re.search(str , path):
            print path
            os.chmod(path, 0o777);
            # os.remove(path)
            # shutil.rmtree(path)

# 递归删除文件夹
def removeDir(dirPath):
    if not os.path.isdir(dirPath):
        return
    files = os.listdir(dirPath)
    try:
        for file in files:
            filePath = os.path.join(dirPath,file)
            if os.path.isfile(filePath):
                os.chmod(filePath, 0o777)
                os.remove(filePath)
            elif os.path.isdir(filePath):
                removeDir(filePath)
        os.chmod(dirPath, 0o777)
        os.rmdir(dirPath)
    except Exception,e:
        print e

# 删除目录下包含str内容的路径和文件
def deleteDirByStr(str , paths):
    if not os.path.isdir(paths):
        print paths + " is not dir"
        return
    if not os.path.isabs(paths):
        os.path.abspath(paths)
    for path in os.listdir(paths):
        nPath = os.path.join(paths, path)
        # nPath = paths + "/" + path
        if os.path.isdir(nPath):
            if re.search(str , nPath):
                print nPath
                removeDir(nPath)
            else:
                deleteDirByStr(str,nPath)
        elif re.search(str , nPath):
            print nPath
            os.chmod(nPath, 0o777);
            os.remove(nPath)

# 从 sourcepath 移动 包含type的文件到dirPath,是否保留原有的路径结构
def moveTypeFileToTarget(sourcePath , type , dirPath):
    if not os.path.isdir(sourcePath) or not os.path.isdir(dirPath):
        print "moveTypeFileToTarget is not dir"
        return
    files = []  # 存储所有的json文件
    initPathFiles(sourcePath, files)
    for path in files:
        if not os.path.isabs(path):
            path = os.path.abspath(path)
        path = turnBias(path)
        if not re.search(type,path):
            continue
        shutil.copyfile(path , dirPath + "/" + os.path.basename(path))




# 复制文件夹到指定文件夹，目标文件夹必须是不存在的路径
# comFun.deleteDirByStr(r".svn", r"D:\Python_FileDispose\source\project")
# shutil.copytree(r"D:\Svn_2d\S_GD_Heji", r"D:\Python_FileDispose\source\project")

# 通过sed修改文件内容
# os.system("wsl sed -i s/old_str/new_str/g ./file.txt")
# os.system("wsl sed -i s/new_str/old_str/g ./file.txt")

# 将数据加入到文件中
# comFun.addDataToFile("./aaa.txt" , 77122 , "22221")
def addDataToFile(path , key , data , newFile = False):
    if newFile or not os.path.isfile(path):
        stream = open(path , "w+")
    else:
        stream = open(path, "a+")
    if is_json(stream.read()):
        stream.seek(0, 0)
        fileData = json.load(stream, object_pairs_hook=collections.OrderedDict)
    else:
        fileData = collections.OrderedDict()
    stream.truncate(len(stream.read()))  # 清理文件内容
    if stream.mode == "a+":
        stream.seek(0, 2)  # 必须从文件末尾开始处理，否则 a+模式报错
    fileData[str(key)] = data
    stream.write(json.dumps(fileData, ensure_ascii=False, encoding="utf -8", indent=4))
    stream.close()
