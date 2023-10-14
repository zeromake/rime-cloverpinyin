#!/usr/bin/env bash
set -e

SHELLDIR="$(dirname $0)"
PYTHON="poetry run python"
DICT_DIR="clover.dict"
RIME_DEPLOYER="rime_deployer"
OPENCC_EXEC="opencc"
OPENCC_SHARE=""

RIME_USER_DIR="/usr/share/rime-data"
HOST_OS=linux
if [ "$(uname)" == "Darwin" ];then
  HOST_OS="osx"
  RIME_USER_DIR="~/AppData/Roaming/Rime"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ];then
  HOST_OS="linux"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ];then
  HOST_OS="windows"
elif [ "$(expr substr $(uname -s) 1 10)" == "Windows_NT" ];then
  HOST_OS="windows"
fi

if [ "$HOST_OS" == "windows" ]; then
  RIME_USER_DIR="~/AppData/Roaming/Rime"
  RIME_DEPLOYER=""
  OPENCC_SHARE="D:/Scoop/Program/opencc/share/opencc/"
  OPENCC_EXEC="D:/Scoop/Program/opencc/bin/opencc.exe"
fi
if [ "$HOST_OS" == "osx" ];then
  command -v rime_deployer > /dev/null 2>&1 || export PATH="$PATH:/Library/Input Methods/Squirrel.app/Contents/MacOS/"
fi

minfreq="${1:-100}"

mkdir -p "$SHELLDIR/cache"
cd "$SHELLDIR/cache"

# 生成符号列表
mkdir -p opencc
(
  cd opencc
  $PYTHON ../../scripts/rime-symbols-gen.py
  cd ..
)

# 生成符号词汇
cat ../rime-emoji/opencc/*.txt opencc/*.txt | $OPENCC_EXEC -c "${OPENCC_SHARE}t2s.json" | uniq > symbols.txt

# 开始生成词典
ln -sf "../rime-essay/essay.txt" .
# ln -sf "../chinese-dictionary-3.6million/词典360万（个人整理）.txt" .
ln -sf "../rime-pinyin-simp/pinyin_simp.dict.yaml" .
$PYTHON ../scripts/clover-dict-gen.py --minfreq="$minfreq"
while read -r file; do
  echo "转换 $file"
  $PYTHON ../scripts/thuocl2rime.py "$file"
done < <(find ../THUOCL/data -type f -name 'THUOCL_*.txt')
cp ../src/sogou_new_words.dict.yaml .
$PYTHON ../scripts/scel.py --id=4 --dest="sogou_new_words.dict.yaml"
WORDS="15117 75228 80764"
for id in $WORDS; do
  echo -e "name: sogou_new_words_$id\nversion: \"1\"\nsort: by_weight\n\n..." > sogou_new_words.$id.dict.yaml
  $PYTHON ../scripts/scel.py --id=$id --dest="sogou_new_words.$id.dict.yaml"
done

# 生成 data 目录
mkdir -p ../data
mkdir -p ../data/$DICT_DIR
cp ../src/clover.*.yaml ../data
cp clover.*.yaml THUOCL_*.yaml sogou_new_words.dict.yaml sogou_new_words.*.dict.yaml ../data/$DICT_DIR/

for id in $WORDS; do
  echo "  - clover.dict/sogou_new_words.$id" >> ../data/clover.dict.yaml
done

# 生成 opencc 目录
cd ../data
mkdir -p opencc
$PYTHON ../scripts/copyrime-symbols-normal.py ../rime-emoji/opencc opencc
$PYTHON ../scripts/copyrime-symbols-normal.py ../cache/opencc opencc

if [ "$RIME_DEPLOYER" != "" ]; then
  echo "开始构建部署二进制"
  # osx 报错 error building config: clover.schema 尝试安装 rime-install prelude
  "$RIME_DEPLOYER" --compile clover.schema.yaml . $RIME_USER_DIR
fi
rm -rf build/*.txt || true
