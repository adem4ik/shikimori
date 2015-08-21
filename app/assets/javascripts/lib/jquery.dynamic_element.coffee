(($) ->
  $.fn.extend dynamic_element: ->
    @each ->
      @classList.remove 'to-process'

      for processor in @attributes['data-dynamic'].value.split(',')
        switch processor
          when 'cutted_covers' then new CuttedCovers(@)
          else
            console.error "unexpected processor: #{processor}"
) jQuery
