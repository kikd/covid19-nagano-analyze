# COVID-19 Nagano Analysis
[![Run MATLAB Script on GitHub-Hosted Runner](https://github.com/kikd/covid19-nagano-analyze/actions/workflows/matlab.yml/badge.svg)](https://github.com/kikd/covid19-nagano-analyze/actions/workflows/matlab.yml)
## About
長野県が公開している新型コロナウイルスのオープンデータを取得、分析を行い、 JSON ファイル、 MAT ファイルを出力する MATLAB スクリプトです。
オープンデータをもとに次のデータを計算します。

### 新規陽性者数関連データ
* 公表日ベースの陽性者数  
  毎日発表されている陽性者の数です。  
  7 日間移動平均も合わせて計算しています
* 10 万人当たりの陽性者数  
  新規陽性者数の7日間移動平均をもとに、10万人当たりの陽性者数を計算します。  
  計算で使用する人口は、2021/04/01時点の 2024073 人を用いています。  
* 簡易版実効再生産数  
  東洋経済オンラインで公開されている数式をもとに演算しています。  
* 年代別新規陽性者数  
  日ごとの新規陽性者数を年代別に分類しています。

### 検査実施状況関連データ
* 検査実施件数の 7 日間移動平均
* 検査陽性者数の 7 日間移動平均
* 陽性率
  次の数式で計算しています。  
  (検査陽性者数の 7 日間移動平均) / (検査実施件数の 7 日間移動平均)

## How To Run
次のコマンドをコマンドウィンドウで実行します
1. script フォルダをパスに追加します  
  `addpath("scripts");`
2. datawrangle.m を実行します  
  `run datawrangle`
