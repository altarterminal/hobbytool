#!/bin/sh
set -eu

######################################################################
# 設定
######################################################################

print_usage_and_exit () {
  cat <<-USAGE 1>&2
	Usage   : ${0##*/} [カード名Prefix] [カードトップURL]
	Options :

	ミリシタDB（https://imas.gamedbs.jp/mlth）における
	カードPrefix名とカードPrefixURLを取得する。
	USAGE
  exit 1
}

######################################################################
# パラメータ
######################################################################

opr=''
opt_p=''

i=1
for arg in ${1+"$@"}
do
  case "$arg" in
    -h|--help|--version) print_usage_and_exit ;;
    -p*)                 opt_p=${arg#-p}      ;;
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

# Prefixが空でないことを判定
if [ -z "$opt_p" ]; then
  echo "${0##*/}: card prefix must be specified" 1>&2
  exit 21
fi

# URLか簡易的に判定
if ! printf "%s\n" "$opr" | grep -q '^http'; then
  echo "${0##*/}: URL must be specified" 1>&2
  exit 22
fi

# webページ取得コマンドの存在を判定
if   type curl >/dev/null 2>&1; then
  wcmd="curl -sS -f -L"
elif type wget >/dev/null 2>&1; then
  wcmd="wget -q -O -"
else
  echo "${0##*/}: wget or curl is needed" 1>&2
  exit 23
fi

# パラメータを決定
cprefix=$opt_p
curl=$opr

######################################################################
# 本体処理
######################################################################

# カードのページの取得
$wcmd "$curl"                                                        |

#カードの情報の一覧を取得
gawk '
  $0 ~ /カード情報/ {
    getline
    while ($0  ~ /<section .*>/) { getline; }
    while ($0 !~ /<\/section>/ ) { print $0; getline; }
  }
'                                                                    |

# SSRの衣装画像を弾くためのフィルター
sed -n '/^ *<article class="tc"/,/^ *<\/article>/p'                  |

# カードURL記載部分を抽出
grep '<a href'                                                       |
sed 's!^.*<a href="\([^"]*\)".*title="\([^"]*\)".*$!\1 \2!'          |

# 無名のカードに名前をつける
awk -v cprefix=$cprefix '
 NF == 2 { print $1, cprefix, $2; }
 NF != 2 { print $0;              }
'                                                                    |

# カード名の空白はアンダースコアに置換
gawk '
{
  # URLとカード名（の先頭）を出力
  printf "%s %s", $1, $2;

  # カード名の残り部分を連結
  for (i = 3; i <= NF; i++) { printf "_%s", $i; }
  print "";
}'                                                                   |

# 出力の体裁を整理
awk '{ print $2, $1; }'
