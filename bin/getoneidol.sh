#!/bin/sh
set -u

######################################################################
# 設定
######################################################################

print_usage_and_exit () {
  cat <<-USAGE 1>&2
	Usage   : ${0##*/} [アイドルURL]
	Options :

	ミリシタDB（https://imas.gamedbs.jp/mlth）における
	アイドルURLのページに存在するカードPrefix名とカードPrefixURLの一覧を取得する。
	USAGE
  exit 1
}

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

# URLか簡易的に判定
if ! printf "%s\n" "$opr" | grep -q '^http'; then
  echo "${0##*/}: URL must be specified" 1>&2
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

# パラメータを決定
iurl=$opr

######################################################################
# 本体処理
######################################################################

# アイドルのページの取得
$wcmd "$iurl"                                                        |

# アイドルのページからカードの名前とページを取得
gawk '
  $0 ~ /カード一覧/ {
    getline
    while ($0  ~ /<ul .*>/) { getline;          }
    while ($0 !~ /<\/ul>/ ) { print $0; getline }
  }
'                                                                    |

# 必要部分を絞りこむ
sed 's!^.*<a href="\([^"]*\)".*<br>\(.*\)</a>.*$!\1 \2!'             |

# カード名が空列の場合はダミーのカード名をつける
gawk '
NF != 1 { print; }
NF == 1 {
  iurl = $1;

  # md5sumコマンドでハッシュ値を取得
  cmd = "echo " $0 " | md5sum";
  cmd | getline; chash = substr($1,1,10); 
  close(cmd);

  print iurl, "no-title_" chash;
}'                                                                   |

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
