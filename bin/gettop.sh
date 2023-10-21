#!/bin/sh
set -eu

######################################################################
# 設定
######################################################################

print_usage_and_exit () {
  cat <<-USAGE 1>&2
	Usage   : ${0##*/}
	Options :

	ミリシタDB（https://imas.gamedbs.jp/mlth）の各アイドルのページのURLを取得する。
	USAGE
  exit 1
}

# ミリシタDBのトップページ
tpage='https://imas.gamedbs.jp/mlth'

######################################################################
# パラメータ
######################################################################

opr=''

i=1
for arg in ${1+"$@"}
do
  case "$arg" in
    -h|--help|--version) print_usage_and_exit ;;
    *)
      if [ $i -eq $# ] && [ -z "$opr" ]; then
        opr=$arg
      else
        echo "${0##*/}: invalid args" 1>&2
        exit 11
      fi
      ;;
  esac

  i=$((i + 1))
done

# 引数が指定されているか判定
if [ -n "$opr" ]; then
  echo "${0##*/}: invalid operand" 1>&2
  exit 21
fi

# webページ取得コマンドの存在を判定
if   type curl >/dev/null 2>&1; then
  wcmd="curl -sS -f -L"
elif type wget >/dev/null 2>&1; then
  wcmd="wget -q -O -"
else
  echo "${0##*/}: wget or curl is needed" 1>&2
  exit 22
fi

######################################################################
# 本体処理
######################################################################

# トップページの取得
$wcmd "$tpage" 2>/dev/null                                           |

# アイドルの名前とページの情報を記載した部分を抽出
awk '
  $0 ~ /アイドル一覧/ {
    getline; while ($0 !~ /<ul .*>/) { getline;          }
    getline; while ($0 !~ /<\/ul>/ ) { print $0; getline }
  }
'                                                                    |

# 必要部分を絞りこむ
sed 's!^.*\(<a href=[^>]*>\).*$!\1!'                                 |

# 名字と名前の間の空白を削除
sed 's!title="\([^ ]*\) *\([^ ]*\)"!title="\1\2"!'                   |

# URLと、アイドル名を含む文字列を抽出
sed 's!^.*"\([^"]*\)"[^"]*"\([^"]*\)".*$!\1 \2!'                     |

# 不要な文字列を削除
sed 's!詳細を表示$!!'                                                |

# 出力の体裁を整理
awk '{print $2, $1}'
