gulp-static-website
===============================

静的サイト制作用の汎用gulpタスクテンプレートです。

## インストール
```bash
mkdir yourProject
cd yourProject
git clone git@github.com:takumi0125/gulp-static-website.git .
cd gulp
npm install
```
<a href="http://sass-lang.com/" target="_blank">Sass/SCSS</a>, <a href="http://compass-style.org/" target="_blank">Compass</a>がインストールされていない場合はインストールしてください。

## 概要

基本構造は  
<a href="https://github.com/takumi0125/static-website-basic-src" target="_blank">takumi0125/static-website-basic-src</a>  
を使用しています。


`gulp` コマンドで `gulp/src/` の中身がタスクで処理され、ディレクトリ構造を保ちつつ `htdocs/` に展開されます。ただし、「 _ (アンダースコア) 」で始まるファイルやディレクトリはコンパイル・コピーの対象外です。スプライト用のソース画像を格納するディレクトリや、Sassで@importするファイルは「 _ (アンダースコア) 」をつけておけば、 `htdocs/` に展開されることはありません。

`gulp watcher` コマンドでローカルサーバが立ち上がります。実行中は
```
http://localhost:50000/
```
で展開後のページが確認できます。


### 主要タスク

```
gulp
```
`gulp/src/` の中身を各種タスクで処理し `htdocs/` に展開します。`gulp init` は実行されません。

```
gulp init
```
`bower.json` で定義されているJSライブラリをインストール(後述)します。開発開始時に実行して下さい。

```
gulp watcher
```
ディレクトリを監視し、変更が会った場合適宜タスクを実行します。また、ローカルサーバを立ち上げます。


### 個別タスク

```
gulp html
```
Jade のコンパイルを実行し、 `htdocs/` に展開します。また、拡張子が .html のファイルは `htdocs/` 以下にコピーされます。

```
gulp css
```
Sass/SCSS (+Compass) のコンパイルを実行し <a href="https://github.com/sindresorhus/gulp-autoprefixer" target="_blank">gulp-autoprefixer</a> を実行後、 `htdocs/` 以下に展開されます。また、拡張子が .css のファイルは gulp-autoprefixer を実行後、 `htdocs/` 以下にコピーされます。

```
gulp js
```
CoffeeScript コンパイル後に `htdocs/` 以下に展開します。また、拡張子が .js のファイルは <a href="https://github.com/spenceralger/gulp-jshint" target="_blank">gulp-jshint</a> 実行後に `htdocs/` 以下にコピーされます。

```
gulp json
```
<a href="https://github.com/rogeriopvl/gulp-jsonlint" target="_blank">gulp-jsonlint</a> 実行後、 `htdocs/` 以下にコピーされます。

```
gulp img
```
<a href="https://github.com/twolfson/gulp.spritesmith" target="_blank">gulp-spritesmith</a> を使用してスプライト画像を生成します。生成されたスプライト画像と SCSS ファイルが `src/` 以下に展開されます。

また、 <a href="https://github.com/wearefractal/gulp-concat" target="_blank">gulp-concat</a> を使用する場合は適宜タスクを追加してください。


その他個別タスクは `gulpfile.coffee` をご参照ください。


## スプライト生成タスク

スプライト画像を生成する場合は、スプライト画像生成タスクを追加する
```
createSpritesTask
```
を使用してください。使用方法は `gulpfile.coffee` の66行目以降に記載されています。呼び出す場合は conf, task が定義された後に呼び出します。サンプルでは260行目で呼び出しています。



## bower

`bower.json` に設定を記述することにより、`gulp init` コマンドで `src/common/js/lib/` に JS ライブラリが自動で配置されます。

```js
{
  "name": "project libraries",
  "version": "0.0.0",
  "authors": "",
  "license": "MIT",
  "private": true,
  "ignore": [
    "**/.*",
    "node_modules",
    "bower_components",
    "test",
    "tests"
  ],
  "devDependencies": {
    "jquery": "1",
    "jquery.easing": "~1.3.1",
    "gsap": "~1.13.1",
    "EaselJS": "*",
    "PreloadJS": "*",
    "underscore": "~1.7.0",
    "swfobject": "*"
  },
  "overrides": {
    "jquery": {
      "main": [
        "dist/jquery.min.js"
      ]
    },
    "jquery.easing": {
      "main": [
        "js/jquery.easing.min.js"
      ]
    },
    "gsap": {
      "main": [
        "src/minified/TweenMax.min.js"
      ]
    },
    "underscore": {
      "main": [
        "underscore-min.js"
      ]
    }
  }
}

```

テンプレートでは、 overrides を指定して minify されたファイルがインストールされるようになっています。ライブラリが不要であれば devDependencies から削除してください。
