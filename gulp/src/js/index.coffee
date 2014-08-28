sample = window.sample || {}

class sample.Main
  $window: null
  $loading: null

  constructor: ->
    Main.instance = @
    @$window = $ window
    @$loding = $ '#loading'
 

$ ->
  window.sample = sample
  new sample.Main()
