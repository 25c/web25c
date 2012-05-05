/* Button
 *
 * The code that is run on the publisher's page which draws the button.
 * drawn in this way:
 *     <script src="http://25c.com/assets/button.js?uuid={user id}"></script>
 **/
;(function() {
  var scriptSource = (function() {
      var scripts = document.getElementsByTagName('script'),
          script = scripts[scripts.length - 1];
      if (script.getAttribute.length !== undefined) {
          return script.getAttribute('src')
      }
      return script.getAttribute('src', 2)
  }());

  // TODO(duane): make this more secure so javascript can't be entered into the url
  var uid = scriptSource.split('uid=')[1];
  document.write('<iframe width="60" height="60" frameborder="0" border="0" scrolling="auto" src="http://localhost:3000/button/' + uid + '" style="vertical-align: middle; display: inline-block; *display: inline; *zoom: 1;"></iframe>');
}());