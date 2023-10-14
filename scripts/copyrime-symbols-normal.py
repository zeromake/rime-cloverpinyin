#!/usr/bin/env python
#-*- encoding:utf-8 -*-

import os
import sys
import shutil
import opencc
t2s = opencc.OpenCC('t2s.json')

def copy_normal(input, output):
    items = {}
    with open(input, "rb") as input_f:
        for line in input_f:
            line = line.decode("utf-8")
            i = line.index(" ")
            prefix = line[:i]
            suffix = line[i+1:-1]
            [name, name_t] = prefix.split("\t")
            # 如果出现相同尝试把第一个词语转为简体
            if name == name_t:
                name = t2s.convert(name_t)
            # 写入简体
            names = [name]
            # 繁体
            if name != name_t:
                names.append(name_t)
            for name in names:
                ss = set(suffix.split(" "))
                if name in items:
                    items[name].union(ss)
                else:
                    items[name] = ss
    with open(output, "wb") as output_f:
        keys = list(items.keys())
        keys.sort()
        for name in keys:
            suffixs = items[name]
            output_f.write(("{}\t{} {}\n".format(name, name, " ".join(list(suffixs)))).encode("utf-8"))

def main():
    input_dir = sys.argv[1]
    output_dir = sys.argv[2]
    for item in os.listdir(input_dir):
        item_path = os.path.join(input_dir, item)
        output_path = os.path.join(output_dir, item)
        if not item.endswith(".txt"):
            shutil.copyfile(item_path, output_path)
            continue
        print("copy_normal {} {}".format(item_path, output_path))
        copy_normal(item_path, output_path)

if __name__ == '__main__':
    exit(main())