// Generated by CoffeeScript 1.6.3
/*
@name jquery-select7
@version 0.2.9
@author Se7enSky studio <info@se7ensky.com>
*/


/*! jquery-select7 0.2.9 http://github.com/Se7enSky/jquery-select7*/


(function() {
  var plugin,
    __slice = [].slice;

  plugin = function($) {
    "use strict";
    var Select7, readOptionsFromSelect, readSelectedIndexFromSelect, trim;
    trim = function(s) {
      return s.replace(/^\s*/, '').replace(/\s*$/, '');
    };
    readOptionsFromSelect = function(el) {
      var data, option, placeholderText, _i, _len, _ref, _results;
      if (placeholderText = $(el).attr("placeholder")) {
        $(el).find("option:first").prop("disabled", true).attr("data-is-placeholder", true).text(placeholderText);
      }
      _ref = $(el).find("option");
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        option = _ref[_i];
        data = $(option).data();
        data.title = trim($(option).text());
        data.value = $(option).attr("value") || trim($(option).text());
        if ($(option).attr("disabled")) {
          data.disabled = true;
        }
        _results.push(data);
      }
      return _results;
    };
    readSelectedIndexFromSelect = function(el) {
      var i, option, optionVal, selectVal, _i, _len, _ref;
      selectVal = $(el).val();
      _ref = $(el).find("option");
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        option = _ref[i];
        optionVal = $(option).attr("value") || trim($(option).text());
        if (optionVal === selectVal) {
          return i;
        }
      }
      return 0;
    };
    Select7 = (function() {
      Select7.prototype.defaults = {
        nativeDropdown: false
      };

      function Select7(el, config) {
        this.el = el;
        this.$el = $(this.el);
        this.$select7 = null;
        this.$drop = null;
        this.config = $.extend({}, this.defaults, config);
        if (this.$el.is(".select7_native_dropdown")) {
          this.config.nativeDropdown = true;
        }
        this.options = readOptionsFromSelect(this.el);
        this.selectedIndex = 0;
        this.selected = null;
        this.opened = false;
        this.pwnSelect();
      }

      Select7.prototype.pwnSelect = function() {
        var classes, select7Markup,
          _this = this;
        this.$el.hide();
        classes = this.$el.attr("class").split(" ");
        classes.splice(classes.indexOf("select7"), 1);
        if (this.options.length < 2) {
          classes.push("select7_noopts");
        }
        select7Markup = "<div class=\"select7 " + classes + "\">\n	<div class=\"select7__current\">\n		<span data-role=\"value\" class=\"select7__current-value\" data-value=\"\"></span><span class=\"select7__caret\"></span>\n	</div>\n</div>";
        this.$select7 = $(select7Markup);
        this.$el.data("updateCurrentFn", function() {
          return _this.updateCurrent();
        });
        this.$el.on("change", this.$el.data("updateCurrentFn"));
        this.updateCurrent();
        this.$select7.find(".select7__current").click(function() {
          return _this.toggle();
        });
        return this.$el.before(this.$select7);
      };

      Select7.prototype.updateCurrent = function() {
        var $value;
        this.selectedIndex = readSelectedIndexFromSelect(this.el);
        this.selected = this.options[this.selectedIndex];
        $value = this.$select7.find("[data-role='value']");
        $value.attr("data-value", this.selected.isPlaceholder ? "" : this.selected.value);
        $value.toggleClass("select7__placeholder", !!this.selected.isPlaceholder);
        $value.text(this.selected.title);
        $value.find(".select7__icon").remove();
        if (this.selected.icon) {
          return $value.prepend("<span class=\"select7__icon\"><img src=\"" + this.selected.icon + "\"></span>");
        }
      };

      Select7.prototype.open = function() {
        var $option, i, option, _i, _len, _ref,
          _this = this;
        if (this.config.nativeDropdown) {
          this.$el.css({
            width: 0,
            height: 0,
            position: "absolute",
            marginLeft: "-" + (this.$select7.width()) + "px"
          }).show();
          setTimeout(function() {
            var e;
            e = document.createEvent('MouseEvents');
            e.initMouseEvent('mousedown', true, true, window);
            return _this.el.dispatchEvent(e);
          }, 1);
          return;
        }
        if (this.opened) {
          return;
        }
        if (this.options.length < 2) {
          return;
        }
        this.$drop = $("<ul class=\"select7__drop\"></ul>");
        _ref = this.options;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          option = _ref[i];
          if (option.isPlaceholder) {
            continue;
          }
          if (i === this.selectedIndex) {
            continue;
          }
          $option = $("<li class=\"select7__option\" data-i=\"" + i + "\"></li>");
          $option.text(option.title);
          if (option.disabled) {
            $option.addClass("select7__option_disabled");
          }
          if (option.icon) {
            $option.prepend("<span class=\"select7__icon\"><img src=\"" + option.icon + "\"></span>");
          }
          this.$drop.append($option);
        }
        this.$drop.on("click", ".select7__option", function(e) {
          var $el;
          $el = $(e.target).is(".select7__option") ? $(e.target) : $(e.target).closest(".select7__option");
          i = $el.data().i;
          option = _this.options[i];
          if (option.disabled) {
            return;
          }
          _this.$el.val(option.value).trigger("change");
          return _this.close();
        });
        this.$select7.append(this.$drop);
        this.$select7.addClass("select7_open");
        this.opened = true;
        return setTimeout(function() {
          _this.$drop.click(function(e) {
            return e.stopPropagation();
          });
          _this.$drop.data("closeFn", function() {
            return _this.close();
          });
          return $("body").on("click", _this.$drop.data("closeFn"));
        }, 1);
      };

      Select7.prototype.close = function() {
        if (!this.opened) {
          return;
        }
        this.$select7.removeClass("select7_open");
        $("body").off("click", this.$drop.data("closeFn"));
        this.$drop.remove();
        this.$drop = null;
        return this.opened = false;
      };

      Select7.prototype.toggle = function() {
        if (this.opened) {
          return this.close();
        } else {
          return this.open();
        }
      };

      Select7.prototype.destroy = function() {
        if (this.opened) {
          close();
        }
        this.$select7.remove();
        this.$el.off("change", this.$el.data("updateCurrentFn"));
        this.$el.data("updateCurrentFn", null);
        this.$el.data("select7", null);
        return this.$el.show();
      };

      return Select7;

    })();
    return $.fn.select7 = function() {
      var args, method;
      method = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return this.each(function() {
        var select7;
        select7 = $(this).data('select7');
        if (!select7) {
          select7 = new Select7(this, typeof method === 'object' ? option : {});
          $(this).data('select7', select7);
        }
        if (typeof method === 'string') {
          return select7[method].apply(select7, args);
        }
      });
    };
  };

  if (typeof define === 'function' && define.amd) {
    define(['jquery'], plugin);
  } else {
    plugin(jQuery);
  }

}).call(this);
