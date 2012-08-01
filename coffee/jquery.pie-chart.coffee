###
Pie chart is a jquery plugin to display animated pie charts

Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.

Built on top of the jQuery library (http://jquery.com)

@source: http://github.com/rendro/easy-pie-chart/
@autor: Robert Fleischmann
@version: 1.0.0

Thanks to Philip Thrasher for the jquery plugin boilerplate for coffee script
###

(($) ->
  $.pieChart = (el, options) ->

    @el = el
    @$el = $ el
    @$el.data "pieChart", @

    @init = =>
      @options = $.extend {}, $.pieChart.defaultOptions, options

      @data = ({ value: 0, color: el.color } for el in @options.data)

      #create canvas element and set the origin to the center
      @canvas = $("<canvas width='#{@options.size}' height='#{@options.size}'></canvas>").get(0)
      @$el.append @canvas
      G_vmlCanvasManager.initElement @canvas if G_vmlCanvasManager?
      @ctx = @canvas.getContext '2d'
      @ctx.translate @options.size/2, @options.size/2

      @$el.addClass 'pieChart'
      @$el.css {
        width: @options.size
        height: @options.size
        lineHeight: "#{@options.size}px"
      }

      drawChart @options.data

    @update = (data) =>
      if @options.animate == false
        drawChart data
      else
        animateChart @data, data

    drawChart = (data) =>
      @data = data
      sum = 0
      sum += el.value for el in data

      @ctx.lineWidth = @options.lineWidth

      painted = 0
      $(data).each (idx, el) =>
        @ctx.strokeStyle = el.color
        @ctx.save()
        @ctx.rotate Math.PI * (2 * painted/sum - 0.5)
        @ctx.beginPath()
        @ctx.arc 0, 0, @options.size/2-@options.lineWidth/2, 0, Math.PI * 2 * el.value/sum, false
        @ctx.stroke()
        @ctx.restore()
        painted += el.value

    animateChart = (from, to) =>
      fps = 30
      steps = fps * @options.animate/1000
      currentStep = 0

      @options.onStart.call @
      @data = to

      clearInterval @animation if @animation

      @animation = setInterval =>
        @ctx.clearRect -@options.size/2, -@options.size/2, @options.size, @options.size
        currentData = ({color: el.color, value: easeInOutQuad currentStep, from[i].value, el.value-from[i].value, steps }for el, i in to)
        drawChart currentData

        currentStep++

        if (currentStep/steps) > 1
          clearInterval @animation
          @animation = false
          @options.onStop.call @
      , 1000/fps

    #t=time;b=beginning value;c=change in value;d=duration
    easeInOutQuad = (t, b, c, d) ->
      t /= d/2
      if ((t) < 1)
        c/2*t*t + b
      else
        -c/2 * ((--t)*(t-2) - 1) + b

    @init()

  $.pieChart.defaultOptions =
    data:            []
    size:            110
    lineWidth:       3
    animate:         false
    onStart:         $.noop
    onStop:          $.noop

  $.fn.pieChart = (options) ->
    $.each @, (i, el) ->
      $el = ($ el)

      unless $el.data 'pieChart'
        $el.data 'pieChart', new $.pieChart el, options

  undefined
)(jQuery)
