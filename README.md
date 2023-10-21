# 趣味用のツール群

## ツール一覧

| ツール名             | 説明                                                                                                                     |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| gettop.sh            | [ミリシタDB](https://imas.gamedbs.jp/mlth)の各アイドルのページのURLを取得する。                                            |
| getoneidol.sh        | [ミリシタDB](https://imas.gamedbs.jp/mlth)におけるアイドルURLのページに存在するカードPrefix名とPrefixURLの一覧を取得する。 |
| getonecard.sh        | [ミリシタDB](https://imas.gamedbs.jp/mlth)におけるカードPrefix名とカードPrefixURLを取得する。                              |

## アプリ一覧
| ツール名             | 説明                                                                                                                     |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| getmillionidolimg.sh | [ミリシタDB](https://imas.gamedbs.jp/mlth)から指定のアイドルの全画像をダウンロードする。                                   |

### getmillionidolimg.sh の使い方

1. getmillionidolimg.sh をエディタで開き、先頭のヒアストリング内で列挙した行から、画像データをダウンロードしたいアイドルの行をアンコメントし、保存する。

2. 適当なディレクトリで getmillionidolimg.sh を実行する。

3. アンコメントしたアイドルの名前のディレクトリがカレントに作成され、その中に画像データがダウンロードされる。

## 事前準備

### 実行環境

- MacBook Air M2
- macOS Monterey 12.6.1
- ターミナル 2.12.7
- GNU bash 3.2.57

### 必要パッケージ

| パッケージ名      | バージョン | 補足                         |
| ----------------- | ---------- | ---------------------------- |
| GNU awk           | 5.2.0      |                              |
| GNU md5sum        | 0.9.5      |                              |
| curl              | 8.1.2      | curl または wgetが必要       |
| wget              | 1.21.4     | curl または wgetが必要       |
