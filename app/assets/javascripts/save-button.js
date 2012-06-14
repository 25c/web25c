$(document).ready(function(){
  
  // lookup dictionary for image filenames
  var imageDict = {
    large: '25c-button-large.png',
    medium: '25c-button-medium.png',
    icon: '25c-button-icon.png'
  };
  
  var updateButtonImage = function(newSize) {
    // replace button preview image if new size is valid
    if (imageDict[newSize]) {
      var newPath = '/assets/' + imageDict[newSize];
      $('#button-preview-image').attr('src', newPath).load(function() {
        $(this).show();
      });
    }
  };
  
  // initialize button preview image
  var buttonSize = $('.radio_buttons:checked').val();
  updateButtonImage(buttonSize);
  
  // when radio buttons change, update image accordingly
  $('.radio_buttons').change(function() {
    var $this = $(this);
    if ($this.attr('checked')) {
      updateButtonImage($this.val());
    }
  });
  
  // when submit happens show saving
  $('form.edit_button').submit(function() {
    $('#save-button-message').show();
  });
  
});