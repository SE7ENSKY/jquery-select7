###
@name jquery-select7
@version 0.0.7
@author Se7enSky studio <info@se7ensky.com>
###
###! jquery-select7 0.0.7 http://github.com/Se7enSky/jquery-select7 ###

plugin = ($) ->
	
	"use strict"

	trim = (s) ->
		s.replace(///^\s*///, '').replace(///\s*$///, '')
	readOptionsFromSelect = (el) ->
		(for option in $(el).find("option")
			title: trim $(option).text()
			value: $(option).attr("value") or trim $(option).text()
		)
	readSelectedIndexFromSelect = (el) ->
		selectVal = $(el).val()
		for option, i in $(el).find("option")
			optionVal = $(option).attr("value") or trim $(option).text()
			return i if optionVal is selectVal
		return 0

	class Select7
		# defaults:
		# 	v: 1

		constructor: (@el, config) ->
			@$el = $ @el
			@$select7 = null
			@$drop = null
			# @config = $.extend {}, @defaults, config
			@options = readOptionsFromSelect @el
			@selectedIndex = 0
			@selected = null
			@opened = no
			@pwnSelect()

		pwnSelect: ->
			@$el.hide()

			select7Markup = """
				<div class="select7">
					<div class="select7__current">
						<span data-role="value" class="select7__current-value" data-value=""></span><span class="select7__caret"></span>
					</div>
				</div>
			"""
			@$select7 = $ select7Markup
			
			@$el.data "updateCurrentFn", => @updateCurrent()
			@$el.on "change", @$el.data "updateCurrentFn"
			@updateCurrent()
			
			@$select7.find(".select7__current").click => @toggle()

			@$el.before @$select7
		updateCurrent: ->
			@selectedIndex = readSelectedIndexFromSelect @el
			@selected = @options[@selectedIndex]
			@$select7.find("[data-role='value']").attr("data-value", @selected.value).text @selected.title
		
		open: ->
			return if @opened
			@$drop = $ """<ul class="select7__drop"></ul>"""
			for option, i in @options
				continue if i is @selectedIndex
				$option = $ """<li class="select7__option" data-i="#{i}"></li>"""
				$option.text option.title
				@$drop.append $option
			@$drop.on "click", ".select7__option", (e) =>
				{i} = $(e.target).data()
				option = @options[i]
				@$el.val(option.value).trigger("change")
				@close()
			@$select7.append @$drop
			@$select7.addClass "select7_open"
			@opened = yes
			setTimeout =>
				@$drop.click (e) -> e.stopPropagation()
				@$drop.data "closeFn", => @close()
				$("body").on "click", @$drop.data "closeFn"
			, 1
		close: ->
			return unless @opened
			@$select7.removeClass "select7_open"
			$("body").off "click", @$drop.data "closeFn"
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
