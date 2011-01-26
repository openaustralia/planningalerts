/*
 * searchField - jQuery plugin to display and remove
 * a default value in a searchvalue on blur/focus
 *
 * Copyright (c) 2008 Jï¿½Ã¶rn Zaefferer
 *
 * $Id$
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *
 */

/**
 * Clear the help text in a search field (either in the value or title attribute)
 * when focused, and restore it on blur if nothing was entered. If the value is
 * blank but there is a title attribute, the title will be moved to the initial value.
 *
 * @example $('#quicksearch').searchField();
 * @before <input id="quicksearch" title="Enter search here" name="quicksearch" />
 * @result <input id="quicksearch" value="Enter search here" name="quicksearch" />
 *
 * @name searchField
 * @type jQuery
 * @cat Plugins/SearchField
 */
jQuery.fn.searchField = function(mark){
	return this.each(function() {
		var mark = mark || this.title;

		if (!mark)
			return;

		var target = this;
		var original = $(this);
		if (this.type == "password") {
			target = $("<input />")
				.insertBefore(this)
				.css("display", $(this).css("display"))
				.attr("size", this.size)
				.attr("title", this.title)
				.attr("class", this.className)
				.addClass("watermark")[0];
			if (!this.value) {
				$(this).hide();
			} else {
				$(target).hide();
			}
		}

		if(!target.value || mark == this.value) {
			$(target).addClass("watermark");
		}

		// setup initial value
		if (!this.value || target != this) {
			target.value = mark;
		}

		$(target).focus(function() {
				if (target != original[0]) {
				$(this).hide();
				original.show().focus();
			} else if (this.value == mark) {
				this.value = '';
				$(this).removeClass("watermark");
			}
		});
		$(this).blur(function() {
			if (!this.value.length) {
				if (target != original[0]) {
					$(target).show();
					original.hide();
				} else {
					this.value = mark;
					$(this).addClass("watermark")
				}
			}
		});

		// make sure that when the form is submitted, the watermark is
		// replaced with the empty string, which is usually the expected behavior.
       $(this).parents("form:first").submit(function(){
           if ($(target).hasClass("watermark")) {
               $(target).attr("value", "");
               $(target).removeClass("watermark");
           }
       });
	});
};