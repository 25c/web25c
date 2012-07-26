# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require jquery_ujs
#= require bootstrap

jQuery ->
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()

	$("#sign-out").click () ->
		pathname = $(this).attr('href')
		result = FB.getLoginStatus ((response) ->
			if response.status == 'connected'
				FB.logout () ->
					window.location.pathname = pathname
			else
				window.location.pathname = pathname
		), true
		return false
		
	$(".facebook-btn").click () ->
    FB.login ((response) ->
        # handle the response
      ), {scope: 'email,publish_stream'}
    # FB.login()