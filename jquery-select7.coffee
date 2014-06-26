###
@name jquery-select7
@version 0.2.12
@author Se7enSky studio <info@se7ensky.com>
###
###! jquery-select7 0.2.12 http://github.com/Se7enSky/jquery-select7 ###

plugin = ($) ->
	
	"use strict"

	trim = (s) ->
		s.replace(///^\s*///, '').replace(///\s*$///, '')
	readOptionsFromSelect = (el) ->
		if placeholderText = $(el).attr "placeholder"
			$(el).find("option:first").prop("disabled", yes).attr("data-is-placeholder", yes).text placeholderText
		(for option in $(el).find("option")
			data = $(option).data()
			data.title = trim $(option).text()
			data.value = $(option).attr("value") or trim $(option).text()
			data.disabled = yes if $(option).attr "disabled"
			data.class = $(option).attr "class"
			data
		)
	readSelectedIndexFromSelect = (el) ->
		selectVal = $(el).val()
		for option, i in $(el).find("option")
			optionVal = $(option).attr("value") or trim $(option).text()
			return i if optionVal is selectVal
		return 0

	class Select7
		defaults:
			nativeDropdown: off

		constructor: (@el, config) ->
			@$el = $ @el
			@$select7 = null
			@$drop = null
			@config = $.extend {}, @defaults, config
			@config.nativeDropdown = on if @$el.is ".select7_native_dropdown"
			@options = readOptionsFromSelect @el
			@selectedIndex = 0
			@selected = null
			@opened = no
			@pwnSelect()

		pwnSelect: ->
			@$el.hide() unless @config.nativeDropdown

			classes = @$el.attr("class").split(" ")
			classes.splice classes.indexOf("select7"), 1
			classes.push "select7_noopts" if @options.length < 2

			select7Markup = """
				<div class="select7 #{classes.join ' '}">
					<div class="select7__current">
						<span data-role="value" class="select7__current-value" data-value=""></span><span class="select7__caret"></span>
					</div>
				</div>
			"""
			@$select7 = $ select7Markup
			
			@$el.data "updateCurrentFn", => @updateCurrent()
			@$el.on "change", @$el.data "updateCurrentFn"
			@updateCurrent()
			
			unless @config.nativeDropdown
				@$select7.find(".select7__current").click => @toggle()

			@$el.after @$select7
			if @config.nativeDropdown
				@$el.css
					position: "absolute"
					transformOrigin: "top left"
					zIndex: 1
					opacity: 0
					margin: 0
					padding: 0
				v = ($el, k) -> parseFloat $el.css(k).replace("px", "")
				w = ($el) -> v($el, "width") + v($el, "padding-left") + v($el, "padding-right") + v($el, "border-left-width") + v($el, "border-right-width")
				h = ($el) -> v($el, "height") + v($el, "padding-top") + v($el, "padding-bottom") + v($el, "border-top-width") + v($el, "border-bottom-width")
				@$el.css
					transform: "scaleX(#{ w(@$select7) / w(@$el) }) scaleY(#{ h(@$select7) / h(@$el) })"
		updateCurrent: ->
			@selectedIndex = readSelectedIndexFromSelect @el
			@selected = @options[@selectedIndex]
			$value = @$select7.find("[data-role='value']")
			$value.attr "data-value", if @selected.isPlaceholder then "" else @selected.value
			$value.toggleClass "select7__placeholder", !!@selected.isPlaceholder
			$value.text @selected.title
			$value.find(".select7__icon").remove()
			$value.prepend """<span class="select7__icon"><img src="#{@selected.icon}"></span>""" if @selected.icon
		
		open: ->
			return if @opened
			return if @options.length < 2
			@$drop = $ """<ul class="select7__drop"></ul>"""
			@$drop = $ """<div class="select7__drop"></div>"""
			$dropList = $ """<ul class="select7__drop-list"></ul>"""
			@$drop.append $dropList
			for option, i in @options
				continue if option.isPlaceholder
				continue if i is @selectedIndex
				$option = $ """<li class="select7__option #{option.class}" data-i="#{i}"></li>"""
				$option.text option.title
				$option.addClass "select7__option_disabled" if option.disabled
				$option.prepend """<span class="select7__icon"><img src="#{option.icon}"></span>""" if option.icon
				$dropList.append $option
			@$drop.on "click", ".select7__option", (e) =>
				$el = if $(e.target).is(".select7__option") then $(e.target) else $(e.target).closest(".select7__option")
				{i} = $el.data()
				option = @options[i]
				return if option.disabled
				@$el.val(option.value).trigger("change")
				@close()
			@$select7.append @$drop
			@$select7.addClass "select7_open"
			@opened = yes
			$("body").trigger "select7Opened"
			setTimeout =>
				@$drop.click (e) -> e.stopPropagation()
				@$drop.data "closeFn", => @close()
				$("body").on "click select7Opened", @$drop.data "closeFn"
			, 1
		close: ->
			return unless @opened
			@$select7.removeClass "select7_open"
			$("body").off "click select7Opened", @$drop.data "closeFn"
			@$drop.remove()
			@$drop = null
			@opened = no
		toggle: ->
			if @opened then @close() else @open()

		destroy: ->
			close() if @opened
			@$select7.remove()
			@$el.off "change", @$el.data "updateCurrentFn"
			@$el.data "updateCurrentFn", null
			@$el.data "select7", null
			@$el.show()

	$.fn.select7 = (method, args...) ->
		@each ->
			select7 = $(@).data 'select7'
			unless select7
				select7 = new Select7 @, if typeof method is 'object' then option else {}
				$(@).data 'select7', select7
			
			select7[method].apply select7, args if typeof method is 'string'

# UMD
if typeof define is 'function' and define.amd # AMD
	define(['jquery'], plugin)
else # browser globals
	plugin(jQuery)
