$ ->
  $('body.points.index').each ->
    $body = $(this)
    
    $body.on 'ajax:before', 'a', (event) ->
      $a = $(this)
      $a.hide()
      $a.after '<div class="loader"></div>'
        
    $body.on 'ajax:error', 'a', (event, xhr, status, error) ->
      $a = $(this)
      $a.next('.loader').remove()
      $a.show()
      alert xhr.responseText
      
    $body.on 'ajax:success', 'a.payment-show-more', (event, data, status, xhr) ->
      $tr = $(this).closest('tr')
      $prevtr = $tr.prev()
      $tr.remove()
      $prevtr.after(data)
