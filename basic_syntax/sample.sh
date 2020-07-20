#!/bin/bash

### Current Directory
SCRIPT_DIR=$(cd $(dirname $0); pwd)
echo "SCRIPT_DIR: ${SCRIPT_DIR}"


### DateTime
DATETIME_1=`date +%Y%m%d%H%M%S`           # 20200720160345
DATETIME_2=`date +%Y-%m-%d`               # 2020-07-20
DATETIME_3=`date "+%Y-%m-%d %H:%M:%S"`    # 2020-07-20 16:03:45


### 実行スクリプトのファイル名を取得・切り取り
SCRIPT_NAME=$(basename $0)
echo  "SCRIPT_NAME_1: ${SCRIPT_NAME}"      # sample.sh
echo  "SCRIPT_NAME_2: ${SCRIPT_NAME%.*}"   # sample
echo  "SCRIPT_NAME_3: ${SCRIPT_NAME##*.}"  # sh


### 標準出力・エラー出力をログファイルにリダイレクトする
LOG_FILE=${SCRIPT_DIR}/${SCRIPT_NAME%.*}.log
ls sample.sh  >> ${LOG_FILE} 2>&1
ls aaaaaa.sh  >> ${LOG_FILE} 2>&1


### 配列
a=(2 4 6)
echo $a # 2
echo ${a[0]} # 2
echo ${a[1]} # 4
echo ${a[@]} # 2 4 6
echo ${#a[@]} # 3
d=(`date`)
echo ${d[3]} # 18:14:54


### if ディレクトリ有無
if [ -d "${SCRIPT_DIR}/log" ]; then        # ディレクトリがあるときは処理
    echo "${SCRIPT_DIR}/log exists."
elif [ ! -d "${SCRIPT_DIR}/log" ]; then    # ディレクトリがないときは処理
    mkdir ${SCRIPT_DIR}/log
else
    exit
fi


### if ファイル有無
if [ -f "${SCRIPT_DIR}/sample.txt" ]; then       # ファイルがあるときは処理
    echo "${SCRIPT_DIR}/sample.txt exists."
elif [ ! -f "${SCRIPT_DIR}/sample.txt" ]; then   # ファイルがないときは処理
    touch ${SCRIPT_DIR}/sample.txt
else
    exit
fi


### if ファイル or ディレクトリの有無
if [ -e "${SCRIPT_DIR}/sample.txt" ]; then        # ファイル or ディレクトリがあるときは処理
    echo "${SCRIPT_DIR}/sample.txt exists."
elif [ ! -e "${SCRIPT_DIR}/sample.txt" ]; then    # ファイル or ディレクトリがないときは処理
    echo "${SCRIPT_DIR}/sample.txt exists not exists."
else
    exit
fi


### if ファイルがあり、かつ空でない
if [ -s "${SCRIPT_DIR}/sample.txt" ]; then        # ファイルがあり、中身が空でないときは処理
    echo "${SCRIPT_DIR}/sample.txt is not empty."
    rm -f ${SCRIPT_DIR}/sample.txt
    touch "${SCRIPT_DIR}/sample.txt"
elif [ ! -s "${SCRIPT_DIR}/sample.txt" ]; then    # ファイルがない、またはファイルがあるが中身が空のときは処理
    echo "${SCRIPT_DIR}/sample.txt is empty."
    echo "aaaa" >> ${SCRIPT_DIR}/sample.txt
else
    exit
fi


### if 数値の比較
count=5
if [ ${count} -gt 5 ]; then                  # より大きい
     echo "${count} は 5 より大きいです。"
else
     echo "${count} は 5 以下です。"
fi
if [ ${count} -ge 5 ]; then                  # 以上
     echo "${count} は 5 以上です。"
else
     echo "${count} は 5 より小さいです。"
fi
if [ ${count} -eq 5 ]; then                  # イコール
    echo "${count} は 5 です。"
else
    echo "${count} は 5 ではありません。"
fi
if [ ${count} -ne 5 ]; then                  # not イコール
    echo "${count} は 5 ではありません。"
else
    echo "${count} は 5 です。"
fi
if [ ${count} -lt 5 ]; then                  # より小さい
     echo "${count} は 5 より小さいです。"
else
     echo "${count} は 5 以上です。"
fi
if [ ${count} -le 5 ]; then                  # 以下
     echo "${count} は 5 以下です。"
else
     echo "${count} は 5 より大きいです。"
fi


### if 文字列の比較
VAR_1=abc
VAR_2=""
VAR_3=123
if [ -n "$VAR_1" ]; then             # 文字列の長さが0以上であれば真
    echo "VAR_1 is not empty."
fi
if [ -z "$VAR_2" ]; then             # 文字列の長さが0以上でなければ真
    echo "VAR_2 is empty."
fi
if [ "$VAR_1" = "abc" ]; then        # 文字列の一致
    echo "VAR_2 = abc"
fi
if [ "`echo "${VAR_3}" | grep -e "abc" -e "123"`" ]; then    # 文字列を含む or 条件
    echo "VAR_3 contain abc or 123."
fi


### read
echo -n "ENDPOINT: "
read ENDPOINT
echo "ENDPOINT: $ENDPOINT"


### 正規表現による入力チェック
VAR_1=abc123!
VAR_2=5
VAR_3=abXZ
VAR_4=abXZ5678
VAR_5=a_b.@1-2
VAR_6=" ab 1   5 "
VAR_7="ab 1 - ./ @ ?_ 5\! "
[[ $VAR_1 =~ bc ]] && echo "VAR_1"               # [[ xxx =~ xxx ]] 正規表現マッチング 
[[ $VAR_1 =~ [0-9] ]] && echo "VAR_1"            # 数字を含む
[[ $VAR_1 =~ ^bc ]] && echo "VAR_1"              # ^ は先頭を表現
[[ $VAR_2 =~ ^[0-9]$ ]] && echo "VAR_2"          # $ は末尾を表現
[[ $VAR_3 =~ ^[a-zA-Z]+$ ]] && echo "VAR_3"      # + は直前の文字列が1回以上
[[ $VAR_4 =~ ^[0-9a-zA-Z]+$ ]] && echo "VAR_4"   # 英数字のみ
[[ $VAR_5 =~ ^[0-9a-zA-Z._-@]+$ ]] && echo "VAR_5"  # 英数字 . _ - @ のみ
[[ $VAR_6 =~ ^([[:alnum:][:blank:]])+$ ]] && echo "VAR_6"  # 英数字 スペース・タブ のみ
[[ $VAR_7 =~ ^([[:alnum:][:blank:]]|[-./_?\\!@])+$ ]] && echo "VAR_7"  # 英数字 スペース・タブ - _ . @ ! ? \ / のみ
# \ エスケープ
# [[:alnum:]]	英数字。[0-9A-Za-z]と同じ。
# [[:alpha:]]	英字。[A-Za-z]と同じ。
# [[:digit:]]	数字。[0-9]と同じ。
# [[:lower:]]	英字の小文字。[a-z]と同じ。
# [[:upper:]]	英字の大文字。[A-Z]と同じ。
# [[:blank:]]	スペースとタブ
# [[:punct:]]	記号 ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
# [[:xdigit:]]	16進数。[0-9A-Fa-f]と同じ。
if [[ "$VAR_1" =~ ^([[:alnum:][:blank:]]|[-./_?\\!@])+$ ]]; then
    echo "variable check ok"
fi


### function
function echo_msg() {
    # 引数を変数に代入
    msg=$1
    # 処理を記述
    echo $msg
}
echo_msg "thank you."  # thank you.


### case
function push_message() {
    # 引数を変数に代入
    var=$1
    fcn=$2
    msg=$3
    # 処理を記述
    case "$var" in
        "1" ) 
            echo "${var}: ${fcn} ${msg}"
        ;;

        "2" ) 
            echo "${var}: ${fcn}"
        ;;

        "3" ) 
            echo "${var}: ${msg}"
        ;;
    esac
}
push_message 1 "test" "sample"   # 1: test sample
push_message 2 "test" "sample"   # 2: test
push_message 3 "test" "sample"   # 3: sample


### while []
i=0
while [ $i -lt 10 ]   # TRUE なら do ~ done を繰り返す
do
    i=$(expr $i + 1)
    echo $i
done


### while read line
echo "bbbb" >> ${SCRIPT_DIR}/sample.txt
echo "cccc" >> ${SCRIPT_DIR}/sample.txt
while read line
do
    echo $line
done < ${SCRIPT_DIR}/sample.txt


### while: 無限ループ
i=0
while :    # 常に0(正常終了)を返すので、無限ループになる
do
    i=`expr $i + 1`
    if [ $i -eq 3 ]; then   # 3 は echo されない
        continue
    fi
    if [ $i -gt 5 ]; then
        break
    fi  
    echo $i
done


### for
d=(`date`)
for i in ${d[@]}
do
    echo $i
done

