# -*- coding: UTF-8 -*-

import os
import json
import hashlib
# 通过子进程执行shell命令
# subprocess.run('kill  %s' % ' '.join(pids), shell=True)
# 就可以杀掉进程 111 和 22

BigFileSie = 1024 * 100   #100k以上即认为是大文件

UNPACKAGENUM = 3

FileMd5Dict = {}   #用于记录文件的路径和md5值,避免同一路径多次生成
FILEPATH = r"D:\Svn_2d\S_GD_Heji\res"
COPYPATH = r"./real_res"
DICTFILE = "./output/filedict.json"
SIZEFILE = "./output/filesize.json"
MD5FILE = "./output/notRepeatFilemd5.json"
REPEATFILE = "./output/repeatfile.json"
ALLFILES = "./output/allfile.json"
NEWMD5 = "./output/newmd5.json"

# json UI 文件
SEARCHJSONPATH = "D:\Svn_2d\UI_Shu\Json"            # 只是竖版的大厅部分json
REALPATH = r"D:\Svn_2d\S_GD_Heji\res/hall/"         # 资源的具体位置和json的位置相关
JSONHAVARES = "./output/jsonres.json"
REFERENCEFILE = "./output/reference.json"
NOTFOUND = "./output/notfound.json"
REPEATFILE = "./output/repeatfile.json"

# 代码文件
CODEFOLDER = r"D:\Svn_2d\S_GD_Heji\src\app"
GAMECODEFOLDER = r"D:\Svn_2d\S_GD_Heji\src\package_src"
CODERESFILE = r"./output/coderesline.json"
CODEUNREGULARFILE = r"./output/codeUnregularline.json"
CODECSB = r"./output/codecsb.json"

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