$ ->
  $('#sign-in').on 'click', 'a.login, a.register, a.forgot-password', ->
    a = $(this)
    sign_in = a.closest('#sign-in')
    selected = a.attr('class')
    sign_in.find('.email-form').hide()
    sign_in.find('#' + selected).show()
    return false
    
  $('#sign-in').on 'click', 'a.use-email', ->
    $(this).closest('p').hide().next().show()
    return false
    
  $('#sign-in').on 'ajax:success', '#forgot-password form', (event, data, status, xhr) ->
    alert = $(this).find('.alert')
    alert.attr('class', 'alert alert-' + data['result'])
    alert.html(data['message'])
    alert.show()
    