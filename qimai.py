
# -*- coding: UTF-8 -*-
import base64
import requests
import time
import json


class QiMai(object):
    def __init__(self):
        self.string = 'a12c0fa6ab9119bc90e4ac7700796a53'

    def params_b64(self, path, params=None):
        if not params:
            t = int(time.time() * 1000) - 1515125653845
            return '@#' + path + '@#' + str(t) + '@#1'
        params_list = []
        for key in params:
            params_list.append(params[key])
        params_list.sort()
        params = ''.join(params_list)
        params_b64 = base64.b64encode(params.encode()).decode()
        t = int(time.time() * 1000) - 1515125653845
        params = params_b64 + '@#' + path + '@#' + str(t) + '@#1'
        return params

    def data_encrypt(self, data):
        # 异或运算加密
        data_list = list(data)
        for i in range(0, len(data_list)):
            data_list[i] = chr(ord(data_list[i]) ^ ord(self.string[i % len(self.string)]))
        return base64.b64encode(''.join(data_list).encode()).decode()


if __name__ == '__main__':
    params = {
        'brand': "all",
        'country': "cn",
        'date': "2018-11-17",
        'device': "iphone",
        'genre': "36",
        'page': '8',
    }
    path = '/rank/indexPlus/brand_id/0'

    Q = QiMai()
    params_b64 = Q.params_b64(path, params)
    analysis = Q.data_encrypt(params_b64)
    # string = Q.data_decrypt(analysis)

    headers = {
        "Accept": "application/json, text/plain, */*",
        "Referer": "https://www.qimai.cn/",
        "User-Agent": "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:57.0) Gecko/20100101 Firefox/59.0"
    }
    url = 'https://api.qimai.cn' + path + '?analysis=' + analysis
    r = requests.get(url, headers=headers)
    # print(json.loads(r.text))
    print(r.text)