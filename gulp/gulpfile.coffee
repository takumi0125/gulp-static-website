gulp        = require 'gulp'
bower       = require 'main-bower-files'
clean       = require 'gulp-clean'
coffee      = require 'gulp-coffee'
coffeelint  = require 'gulp-coffeelint'
data        = require 'gulp-data'
filter      = require 'gulp-filter'
notify      = require 'gulp-notify'
jade        = require 'gulp-jade'
jsonlint    = require 'gulp-jsonlint'
plumber     = require 'gulp-plumber'
sass        = require 'gulp-ruby-sass'
sprite      = require 'gulp.spritesmith'
stylus      = require 'gulp-stylus'
typescript  = require 'gulp-typescript'
uglify      = require 'gulp-uglify'
webserver   = require 'gulp-webserver'

nib         = require 'nib'
exec        = require('child_process').exec
runSequence = require 'run-sequence'

SRC_DIR = './src/'
PUBLISH_DIR = '../htdocs/'
BOWER_COMPONENTS = './bower_components/'

DATA_JSON = SRC_DIR + 'data.json'

paths =
  dataJson: DATA_JSON
  json: [
    SRC_DIR + '**/*.json'
    '!' + DATA_JSON
  ]
  jade: SRC_DIR + '**/*.jade'
  sass: [
    SRC_DIR + '**/*.sass'
    SRC_DIR + '**/*.scss'
  ]
  stylus: SRC_DIR + '**/*.styl'
  coffee: SRC_DIR + '**/*.coffee'
  typescript: SRC_DIR + '**/*.ts'
  sprite:
    index: SRC_DIR + 'img/index_sprites/*'
    common: SRC_DIR + 'common/img/common_sprites/*'

  excludeSrcs: [
    SRC_DIR + '**/*'
    '!' + SRC_DIR + '**/_*/*'
    '!' + SRC_DIR + '**/_*/'
    '!' + SRC_DIR + '**/*sprites/*'
    '!' + SRC_DIR + '**/*sprites/'
    '!' + SRC_DIR + '**/src/*'
    '!' + SRC_DIR + '**/src/'
    '!' + SRC_DIR + '**/*.json'
    '!' + DATA_JSON
    '!' + SRC_DIR + '**/*.jade'
    '!' + SRC_DIR + '**/*.sass'
    '!' + SRC_DIR + '**/*.scss'
    '!' + SRC_DIR + '**/*.styl'
    '!' + SRC_DIR + '**/*.coffee'
    '!' + SRC_DIR + '**/*.ts'
  ]
  

errorHandler = (name)-> return notify.onError name + ": <%= error %>"


#############
### clean ###
#############

# clean
gulp.task 'clean', ->
  gulp.src PUBLISH_DIR
  .pipe plumber errorHandler: errorHandler 'clean'
  .pipe clean force: true


############
### copy ###
############

# copyExcludeSrcs
gulp.task 'copyExcludeSrcs', ->
  gulp.src paths.excludeSrcs
  .pipe plumber errorHandler: errorHandler 'copyExcludeSrcs'
  .pipe gulp.dest PUBLISH_DIR


###########
### css ###
###########

# sass
gulp.task 'sass', ->
  gulp.src paths.sass
  .pipe plumber errorHandler: errorHandler 'sass'
  .pipe sass
    unixNewlines: true
    compass: true
  .pipe gulp.dest PUBLISH_DIR

# stylus
gulp.task 'stylus', ->
  gulp.src paths.stylus
  .pipe plumber errorHandler: errorHandler 'stylus'
  .pipe stylus use: [ nib() ]
  .pipe gulp.dest PUBLISH_DIR

# spriteIndex
gulp.task 'spriteIndex', ->
  spriteData = gulp.src paths.sprite.index
  .pipe plumber errorHandler: errorHandler 'spriteIndex'
  .pipe sprite(
    imgName: 'index_sprites.png'
    cssName: '_index_sprites.scss'
    padding: 1
    imgPath: '../' + paths.sprite.index
  )
  
  spriteData.img
  .pipe gulp.dest SRC_DIR + 'img/'
  .pipe gulp.dest PUBLISH_DIR + 'img/'
  
  spriteData.css.pipe gulp.dest SRC_DIR + 'css/'

# spriteCommon
gulp.task 'spriteCommon', ->
  spriteData = gulp.src paths.sprite.common
  .pipe plumber errorHandler: errorHandler 'spriteCommon'
  .pipe sprite(
    imgName: 'common_sprites.png'
    cssName: '_common_sprites.scss'
    padding: 1
    imgPath: '../' + paths.sprite.common
  )
  
  spriteData.img
  .pipe gulp.dest SRC_DIR + 'common/img/'
  .pipe gulp.dest PUBLISH_DIR + 'common/img/'
  
  spriteData.css.pipe gulp.dest SRC_DIR + 'common/css/'


##########
### js ###
##########

# coffee
gulp.task 'coffee', ->
  gulp.src paths.coffee
  .pipe plumber errorHandler: errorHandler 'coffee'
  .pipe coffee()
  .pipe gulp.dest PUBLISH_DIR

# typescript
gulp.task 'typescript', ->
  gulp.src paths.typescript
  .pipe plumber errorHandler: errorHandler 'typescript'
  .pipe typescript()
  .pipe gulp.dest PUBLISH_DIR


############
### json ###
############

# dataJson
gulp.task 'dataJson', ->
  gulp.src DATA_JSON
  .pipe plumber errorHandler: errorHandler 'dataJson'
  .pipe jsonlint()

# all json
gulp.task 'json', ->
  gulp.src paths.json
  .pipe plumber errorHandler: errorHandler 'json'
  .pipe jsonlint()
  .pipe gulp.dest PUBLISH_DIR


############
### html ###
############

# jade
gulp.task 'jade', ->
  gulp.src paths.jade
  .pipe data -> require SRC_DIR + 'data.json'
  .pipe plumber errorHandler: errorHandler 'jade'
  .pipe jade()
  .pipe gulp.dest PUBLISH_DIR


#############
### watch ###
#############

# watch
gulp.task 'watch', ->
  gulp.watch paths.json, [ 'json' ]
  gulp.watch paths.dataJson, [ 'jade' ]
  gulp.watch paths.jade, [ 'jade' ]
  gulp.watch paths.sass, [ 'sass' ]
  gulp.watch paths.stylus, [ 'stylus' ]
  gulp.watch paths.coffee, [ 'coffee' ]
  gulp.watch paths.typescript, [ 'typescript' ]
  gulp.watch paths.sprite.index, [ 'spriteIndex' ]
  gulp.watch paths.sprite.common, [ 'spriteCommon' ]
  gulp.watch paths.excludeSrcs, [ 'copyExcludeSrcs' ]

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
      .pipe plumber errorHandler: errorHandler
      .pipe jsFilter
      .pipe gulp.dest SRC_DIR + 'js/lib/'
      .pipe jsFilter.restore()
      .pipe cssFilter
      .pipe gulp.dest SRC_DIR + 'css/lib/'
      
      gulp.src BOWER_COMPONENTS
      .pipe plumber errorHandler: errorHandler
      .pipe clean force: true
      .pipe notify 'complete bower task'


############
### init ###
############

gulp.task 'init', [ 'bower' ]


###############
### default ###
###############

gulp.task 'default', [ 'clean' ], ->
  runSequence [ 'dataJson', 'spriteIndex', 'spriteCommon' ], [ 'json', 'jade', 'sass', 'stylus', 'coffee', 'typescript' ], 'copyExcludeSrcs', ->
    gulp.src(PUBLISH_DIR).pipe notify 'build complete'

