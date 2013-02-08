/**
 * Copyright (c) 2008 Tom Deater (http://www.tomdeater.com)
 * Licensed under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
jQuery.onFontResize=(function(a){a(document).ready(function(){var c=a("<iframe />").attr("id","frame-onFontResize"+Date.parse(new Date)).addClass("div-onfontresize").css({width:"100em",height:"10px",position:"absolute",borderWidth:0,top:"-5000px",left:"-5000px"}).appendTo("body");
if(a.browser.msie){c.bind("resize",function(){a.onFontResize.trigger(c[0].offsetWidth/100);});}else{var b=c[0].contentWindow||c[0].contentDocument||c[0].document;
b=b.document||b;b.open();b.write('<script>window.onload = function(){var em = parent.jQuery(".div-onfontresize")[0];window.onresize = function(){if(parent.jQuery.onFontResize){parent.jQuery.onFontResize.trigger(em.offsetWidth / 100);}}};<\/script>');
b.close();}});return{trigger:function(b){a(document).trigger("fontresize",[b]);}};})(jQuery);

/**
* HTML5 placeholder polyfill
*
* code: https://github.com/ginader/HTML5-placeholder-polyfill
* please report issues at: https://github.com/ginader/HTML5-placeholder-polyfill/issues
*
* Copyright (c) 2012 Dirk Ginader (ginader.de)
* Dual licensed under the MIT and GPL licenses:
* http://www.opensource.org/licenses/mit-license.php
* http://www.gnu.org/licenses/gpl.html
*
* Version: Version: 2.0.3
*/
(function(e){var a=false,h;function b(k,l){if(k.val()===""){k.data("placeholder").removeClass(l.hideClass);}else{k.data("placeholder").addClass(l.hideClass);
}}function f(k,l){k.data("placeholder").addClass(l.hideClass);}function g(m,l){var k=l.is("textarea");m.css({width:l.innerWidth()-(k?20:4),height:l.innerHeight()-6,lineHeight:l.css("line-height"),whiteSpace:k?"normal":"nowrap",overflow:"hidden"}).offset(l.offset());
}function c(k,l){var k=k,m=k.val();(function n(){h=requestAnimationFrame(n);if(k.val()!=m){f(k,l);j();i(k,l);}})();}function i(k,l){var k=k,m=k.val();(function n(){h=requestAnimationFrame(n);
b(k,l);})();}function j(){cancelAnimationFrame(h);}function d(k){if(a&&window.console&&window.console.log){window.console.log(k);}}e.fn.placeHolder=function(m){d("init placeHolder");
var n=this;var k=e(this).length;this.options=e.extend({className:"placeholder",visibleToScreenreaders:true,visibleToScreenreadersHideClass:"placeholder-hide-except-screenreader",visibleToNoneHideClass:"placeholder-hide",hideOnFocus:false,removeLabelClass:"visuallyhidden",hiddenOverrideClass:"visuallyhidden-with-placeholder",forceHiddenOverride:true,forceApply:false,autoInit:true},m);
this.options.hideClass=this.options.visibleToScreenreaders?this.options.visibleToScreenreadersHideClass:this.options.visibleToNoneHideClass;return e(this).each(function(p){var l=e(this),t=l.attr("placeholder"),u=l.attr("id"),o,s,q,r;
o=l.closest("label");l.removeAttr("placeholder");if(!o.length&&!u){d("the input element with the placeholder needs an id!");return;}o=o.length?o:e('label[for="'+u+'"]').first();
if(!o.length){d("the input element with the placeholder needs a label!");return;}r=e(o).find(".placeholder");if(r.length){g(r,l);return l;}if(o.hasClass(n.options.removeLabelClass)){o.removeClass(n.options.removeLabelClass).addClass(n.options.hiddenOverrideClass);
}s=e('<span class="'+n.options.className+'">'+t+"</span>").appendTo(o);q=(s.width()>l.width());if(q){s.attr("title",t);}g(s,l);l.data("placeholder",s);
s.data("input",s);s.click(function(){e(this).data("input").focus();});l.focusin(function(){if(!n.options.hideOnFocus&&window.requestAnimationFrame){c(l,n.options);
}else{f(l,n.options);}});l.focusout(function(){b(e(this),n.options);if(!n.options.hideOnFocus&&window.cancelAnimationFrame){j();}});b(l,n.options);e(document).bind("fontresize resize",function(){g(s,l);
});if(e.event.special.resize){e("textarea").bind("resize",function(v){g(s,l);});}else{e("textarea").css("resize","none");}if(p>=k-1){e.attrHooks.placeholder={get:function(v){if(v.nodeName.toLowerCase()=="input"||v.nodeName.toLowerCase()=="textarea"){if(e(v).data("placeholder")){return e(e(v).data("placeholder")).text();
}else{return e(v)[0].placeholder;}}else{return undefined;}},set:function(v,w){return e(e(v).data("placeholder")).text(w);}};}});};e(function(){var k=window.placeHolderConfig||{};
if(k.autoInit===false){d("placeholder:abort because autoInit is off");return;}if("placeholder" in e("<input>")[0]&&!k.forceApply){d("placeholder:abort because browser has native support");
return;}e("input[placeholder], textarea[placeholder]").placeHolder(k);});})(jQuery);