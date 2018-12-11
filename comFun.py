# -*- coding: UTF-8 -*-

import os
import json
import hashlib
# 通过子进程执行shell命令
# subprocess.run('kill  %s' % ' '.join(pids), shell=True)
# 就可以杀掉进程 111 和 22

FileMd5Dict = {}   #用于记录文件的路径和md5值

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
        if filesize > 1024 * 10:   # 大文件获取md5值的方法
            print("BigFile :" + path)
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