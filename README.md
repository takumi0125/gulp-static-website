gulp-template-static-website
===============================

静的 web サイト開発用 gulp スケルトン

インストール
------------

```
git clone git://github.com/takumi0125/gulp-template-static-website.git ~/.gulp-template/static-website
```

spritesmithを使用するにはgraphicsmagickをインストール


プロジェクト開始時
------------------

```
npm install
gulp init
gulp
gulp watch
```

ルール
------

* `src` ディレクトリ下のファイルを編集する。他はさわらない。
* `src` 下のディレクトリ構成は自由。
* ただし `lib` ディレクトリの中に jQuery や normalize.css 等のライブラリを格納する。
* Sass や HTML のインクルード用ファイルは必ず `_` を接頭辞とする。

License
-------

Distributed under the [Unlicense](http://unlicense.org/).
