# import Vue from 'vue/dist/vue.esm'

require 'pikaday'
require 'urijs'
require 'sugar'

MobileDetect = require 'mobile-detect'
window.mobile_detect = new MobileDetect(window.navigator.userAgent)

#= require sugar
#= require jquery
#= require vendor/jquery-migrate-1.3.0
#= require vendor/modernizr

#= require bowser

#= require uevent
#= require d3
#= require jQuery-Storage-API
#= require js-md5/js/md5
#= require nouislider

# imagesLoaded dependency
#= require ev-emitter
#= require imagesloaded

# magnific-popup dependency
#= require magnific-popup

# outlayer dependency
#= require desandro-matches-selector
#= require fizzy-ui-utils
#= require get-size
#= require outlayer/item
# packery dependency
#= require outlayer
#= require jquery-bridget
#= require packery/rect
#= require packery/packer
#= require packery/item
#= require packery

#= require i18n
#= require_directory ./i18n
#= require jade/runtime

#= require_tree ./vendor

#= require_self

bindings = require('helpers/bindings')

$(document).on 'page:load page:change page:restore', (e) ->
  for group in bindings[e.type]
    body_classes = if group.conditions.length && group.conditions[0][0] == '.'
      group.conditions
        .filter (v) -> v[0] == '.'
        .map (v) -> "p-#{v.slice 1} "
    else
      null

    if !group.conditions.length
      group.callback()
    else if body_classes && body_classes.length && body_classes.any((v) -> document.body.className.indexOf(v) != -1)
      group.callback()
    else if group.conditions.any((v) -> document.body.id == v)
      group.callback()
