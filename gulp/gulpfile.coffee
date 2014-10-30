gulp         = require 'gulp'
bower        = require 'main-bower-files'
clean        = require 'gulp-clean'
concat       = require 'gulp-concat'
coffee       = require 'gulp-coffee'
data         = require 'gulp-data'
filter       = require 'gulp-filter'
notify       = require 'gulp-notify'
jade         = require 'gulp-jade'
jsonlint     = require 'gulp-jsonlint'
jshint       = require 'gulp-jshint'
plumber      = require 'gulp-plumber'
autoprefixer = require 'gulp-autoprefixer'
sass         = require 'gulp-ruby-sass'
sprite       = require 'gulp.spritesmith'
webserver    = require 'gulp-webserver'

exec        = require('child_process').exec
runSequence = require 'run-sequence'

SRC_DIR = './src'
PUBLISH_DIR = '../htdocs'
BOWER_COMPONENTS = './bower_components'
DATA_JSON = "#{SRC_DIR}/_data.json"

BOWER_INSTALL_DIR_BASE = '/common' # '/common' or ''

paths =
  html: "#{SRC_DIR}/**/*.html"
  jade: "#{SRC_DIR}/**/*.jade"
  css: "#{SRC_DIR}/**/*.css"
  sass: [
     "#{SRC_DIR}/**/*.sass"
     "#{SRC_DIR}/**/*.scss"
  ]
  js: "#{SRC_DIR}/**/*.js"
  json: "#{SRC_DIR}/**/*.json"
  coffee: "#{SRC_DIR}/**/*.coffee"
  img: "#{SRC_DIR}/**/img/**"
  others: [
    "#{SRC_DIR}/**"
    "!#{SRC_DIR}/**/*.html"
    "!#{SRC_DIR}/**/*.jade"
    "!#{SRC_DIR}/**/*.css"
    "!#{SRC_DIR}/**/*.sass"
    "!#{SRC_DIR}/**/*.scss"
    "!#{SRC_DIR}/**/*.js"
    "!#{SRC_DIR}/**/*.json"
    "!#{SRC_DIR}/**/*.coffee"
    "!#{SRC_DIR}/**/img/**"
    "!#{SRC_DIR}/**/*.md"
    "!#{SRC_DIR}/**/_*"
    "!#{SRC_DIR}/**/_*/"
    "!#{SRC_DIR}/**/_*/**"
  ]


imgTask = [ 'copyImg' ]

createCopyFilesFilter = ()-> filter [ '**', '!**/_*', "!**/_*/", '!**/_*/**' ]

errorHandler = (name)-> return notify.onError name + ": <%= error %>"

createSrcArr = (name) -> [].concat paths[name], "!#{SRC_DIR}/_*", "!#{SRC_DIR}/**/_*/", "!#{SRC_DIR}/**/_*/**"

#
# spritesmith のタスクを生成
# 
# @param {string} taskName          タスクを識別するための名前 スプライトタスクが複数ある場合はユニークにする
# @param {string} outputFileName    出力されるスプライト画像 / CSS (SCSS) の名前
# @param {string} dirBase           コンテンツディレクトリのパス (SRC_DIRからの相対パス)
# @param {string} outputImgPathType CSSに記述される画像パスのタイプ (absolute | relative)
# @param {string} imgDir            dirBaseから画像ディレクトリへのパス
# @param {string} cssDir            dirBaseからCSSディレクトリへのパス
#
# #{SRC_DIR}#{dirBase}#{imgDir}/_#{outputFileName}/
# 以下にソース画像を格納せしておくと
# #{SRC_DIR}#{dirBase}#{cssDir}/_#{outputFileName}.scss と
# #{SRC_DIR}#{dirBase}#{imgDir}/#{outputFileName}.png が生成される
# かつ watch タスクの監視も追加
#
createSpritesTask = (taskName, dirBase, outputFileName = 'sprites', outputImgPathType = 'absolute', imgDir = '/img', cssDir = '/css') ->
  imgTask.push taskName
  
  srcImgFiles = "#{SRC_DIR}#{dirBase}#{imgDir}/_#{outputFileName}/*"
  gulp.task taskName, ->
    spriteObj =
      imgName: "#{outputFileName}.png"
      cssName: "_#{outputFileName}.scss"
      algorithm: 'binary-tree'
      padding: 1

    if outputImgPathType is 'absolute'
      spriteObj.imgPath = "#{dirBase}#{imgDir}/#{outputFileName}.png"

    spriteData = gulp.src srcImgFiles
    .pipe plumber errorHandler: errorHandler taskName
    .pipe sprite spriteObj
    
    spriteData.img
    .pipe gulp.dest "#{SRC_DIR}#{dirBase}#{imgDir}"
    .pipe gulp.dest "#{PUBLISH_DIR}#{dirBase}#{imgDir}"
    
    spriteData.css.pipe gulp.dest "#{SRC_DIR}#{dirBase}#{cssDir}"

  gulp.watch srcImgFiles, [ taskName ]


#############
### clean ###
#############

# clean
gulp.task 'clean', ->
  gulp.src PUBLISH_DIR
  .pipe plumber errorHandler: errorHandler 'clean'
  .pipe clean force: true


##############
### concat ###
##############

# concat
gulp.task 'concat', ->
  gulp.src "#{SRC_DIR}/__test"
  .pipe plumber errorHandler: errorHandler 'concat'
  .pipe concat 'build.js'
  .pipe gulp.dest "#{PUBLISH_DIR}/js"


############
### copy ###
############

# copyHtml
gulp.task 'copyHtml', ->
  gulp.src createSrcArr 'html'
  .pipe plumber errorHandler: errorHandler 'copyHtml'
  .pipe gulp.dest PUBLISH_DIR

# copyCss
gulp.task 'copyCss', ->
  gulp.src createSrcArr 'css'
  .pipe plumber errorHandler: errorHandler 'copyCss'
  .pipe autoprefixer()
  .pipe gulp.dest PUBLISH_DIR

# copyJs
gulp.task 'copyJs', [ 'jshint' ], ->
  gulp.src createSrcArr 'js'
  .pipe plumber errorHandler: errorHandler 'copyJs'
  .pipe gulp.dest PUBLISH_DIR

# copyJson
gulp.task 'copyJson', [ 'jsonlint' ], ->
  gulp.src createSrcArr 'json'
  .pipe plumber errorHandler: errorHandler 'copyJson'
  .pipe gulp.dest PUBLISH_DIR

# copyImg
gulp.task 'copyImg', ->
  gulp.src createSrcArr 'img'
  .pipe plumber errorHandler: errorHandler 'copyImg'
  .pipe gulp.dest PUBLISH_DIR

# copyOthers
gulp.task 'copyOthers', ->
  gulp.src createSrcArr 'others'
  .pipe plumber errorHandler: errorHandler 'copyOthers'
  .pipe gulp.dest PUBLISH_DIR


############
### html ###
############

# jade
gulp.task 'jade', ->
  gulp.src createSrcArr 'jade'
  .pipe plumber errorHandler: errorHandler 'jade'
  .pipe data -> require DATA_JSON
  .pipe jade pretty: true
  .pipe gulp.dest PUBLISH_DIR

# html
gulp.task 'html', [ 'copyHtml', 'jade' ]


###########
### css ###
###########

# sass
gulp.task 'sass', ->
  gulp.src createSrcArr 'sass'
  .pipe plumber errorHandler: errorHandler 'sass'
  .pipe sass
    unixNewlines: true
    compass: true
    sourcemap: false
    style: 'expanded'
  .pipe autoprefixer()
  .pipe gulp.dest PUBLISH_DIR


# css
gulp.task 'css', [ 'copyCss', 'sass' ]


##########
### js ###
##########

# jshint
gulp.task 'jshint', ->
  libFilter = filter [ '**', '!**/lib/**' ]
  gulp.src createSrcArr 'js'
  .pipe plumber errorHandler: errorHandler 'jshint'
  .pipe libFilter
  .pipe jshint()
  .pipe jshint.reporter()
  .pipe notify (file)-> return if file.jshint.success then false else 'jshint error'

# coffee
gulp.task 'coffee', ->
  gulp.src createSrcArr 'coffee'
  .pipe plumber errorHandler: errorHandler 'coffeelint'
  .pipe coffee()
  .pipe gulp.dest PUBLISH_DIR

# js
gulp.task 'js', [ 'copyJs', 'coffee' ]


############
### json ###
############

# jsonlint
gulp.task 'jsonlint', ->
  gulp.src createSrcArr 'json'
  .pipe plumber errorHandler: errorHandler 'jsonlint'
  .pipe jsonlint()
  .pipe jsonlint.reporter()
  .pipe notify (file)-> return if file.jsonlint.success then false else 'jsonlint error'

# json
gulp.task 'json', [ 'copyJson' ]


###########
### img ###
###########

# sprite
createSpritesTask 'spritesCommon', '/common'
createSpritesTask 'spritesIndex', ''

gulp.task 'img', imgTask


###############
### watcher ###
###############

# watcher
gulp.task 'watcher', ->
  gulp.watch paths.html, [ 'copyHtml' ]
  gulp.watch paths.jade, [ 'jade' ]
  gulp.watch paths.css, [ 'copyCss' ]
  gulp.watch paths.sass, [ 'sass' ]
  gulp.watch paths.js, [ 'copyJs' ]
  gulp.watch paths.json, [ 'copyJson' ]
  gulp.watch paths.coffee, [ 'coffee' ]
  gulp.watch paths.img, [ 'copyImg' ]
  gulp.watch paths.others, [ 'copyOthers' ]

  gulp.src PUBLISH_DIR
  .pipe webserver
    livereload: true
    port: 50000
    open: true
  .pipe notify 'start local server. http://localhost:50000/'


#############
### bower ###
#############

gulp.task 'bower', ->
  console.log 'install bower components'
  exec 'bower install', (err, stdout, stderr)->
    if err
      console.log err
    else
      console.log stdout
      
      jsFilter = filter '**/*.js'
      cssFilter = filter '**/*.css'
      gulp.src bower
        debugging: true
        includeDev: true
        paths:
          bowerDirectory: BOWER_COMPONENTS
          bowerJson: 'bower.json'
      .pipe plumber errorHandler: errorHandler
      .pipe jsFilter
      .pipe gulp.dest "#{SRC_DIR}#{BOWER_INSTALL_DIR_BASE}/js/lib"
      .pipe jsFilter.restore()
      .pipe cssFilter
      .pipe gulp.dest "#{SRC_DIR}#{BOWER_INSTALL_DIR_BASE}/css/lib"
      .pipe cssFilter.restore()
      .pipe notify 'done bower task'


############
### init ###
############

gulp.task 'init', [ 'bower' ]


###############
### default ###
###############

gulp.task 'default', [ 'clean' ], ->
  runSequence [ 'json', 'img' ], [ 'html', 'css', 'js', 'copyOthers' ], ->
    gulp.src(PUBLISH_DIR).pipe notify 'build complete'

