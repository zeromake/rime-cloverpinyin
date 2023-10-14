# rime-symbols

## 简介

本项目为 opencc 的配置文件，功能是将中文转换为符号，如“平方”转换为 ² ，以此来实现输入法快速输入特殊符号。是为[🍀️四叶草简体拼音](https://github.com/fkxxyz/rime-cloverpinyin)而设计的。

## 安装

推荐直接使用[🍀️四叶草简体拼音](https://github.com/fkxxyz/rime-cloverpinyin)，自带该功能。

如果想要别的输入法带此功能，则按照下列步骤做：

确保自己机器上有 python 和 opencc

然后如下执行

```shell
./rime-symbols-gen
```

再将生成的所有文件复制到 rime 的目录的 opencc 子目录下（不存在就创建一个）

下面以 fcitx-rime 的用户配置文件为例

```shell
mkdir -p ~/.config/fcitx/rime/opencc
cp symbol_* ~/.config/fcitx/rime/opencc
```

然后给给自己的输入法打上 patch：

```yaml
patch:
  switches/@next:
    name: symbol_support
    reset: 1
    states: [ "无符", "符" ]
  'engine/filters/@before 0':
    simplifier@symbol_support
  symbol_support:
    opencc_config: symbol.json
    option_name: symbol_support
    tips: all
```

然后重新部署即可

# libscel

## 搜狗细胞词库（.scel）转换工具

### 简介

该项目参考 [scel2txt](https://github.com/lewang0/scel2txt ) ，在此表示感谢

### 用法

#### 直接输出至文本

```shell
scel.py [file] [dest]
```

输出的 dest 格式为 "词语\t拼音\t优先级"

参数详解:

- file	搜狗细胞词库文件，格式为 .scel 如果不指定则会自动从官网获取“网络流行新词【官方推荐】.scel”
- dest	输出的文件，如果不指定则会输出到标准输出

#### 当成库使用

从文件读取

```python
import scel
s = scel.scel()
s.load('网络流行新词【官方推荐】.scel')
print(s.title)
print(s.category)
print(s.description)
print(s.samples)
print("一共有 %d 个词汇" % len(s.word_list))
print("第一个词是 %s" % str(s.word_list[0]))
print("一共有 %d 个被删除的词汇" % len(s.del_words))
```

从官网获取流行词汇

```python
import scel
s = scel.scel()
data = scel.getInternetPopularNewWords()
s.loads(data)
print(s.title)
print(s.category)
print(s.description)
print(s.samples)
print("一共有 %d 个词汇" % len(s.word_list))
print("第一个词是 %s" % str(s.word_list[0]))
print("一共有 %d 个被删除的词汇" % len(s.del_words))
```

