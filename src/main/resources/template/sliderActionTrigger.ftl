<script type="text/javascript">
(function(){
  // DataListAction has no hook to attach a custom onclick to the <a> it
  // generates, so this assigns one itself, after the fact, to every link
  // this action instance renders - identified by the stable "link_<id>"
  // class DataListDecorator always adds for row actions.
  //
  // This sets a literal onclick="" ATTRIBUTE (calling a shared global
  // function, the same way Joget's own built-in target="popup" action
  // does with onclick="return dlPopupAction(this, ...)"), rather than
  // assigning the .onclick PROPERTY directly with a closure: this page's
  // table/list widget re-renders row markup shortly after load (likely
  // its responsive/draggable-columns table library), which rebuilds
  // elements from their outerHTML - carrying an onclick="" attribute
  // over, but silently dropping a property-only handler with nothing
  // behind it in the markup.
  if (typeof window.openSliderTrigger !== 'function') {
    window.openSliderTrigger = function(anchor){
      var confirmMsg = anchor.getAttribute('data-os-confirm');
      if (confirmMsg && !confirm(confirmMsg)) {
        return false;
      }

      var href = anchor.getAttribute('href');
      if (!href) return true;

      if (typeof window.openSlider === 'function') {
        var title = (anchor.textContent || '').trim() || 'Open';
        window.openSlider(href, title);
      }
      return false;
    };
  }

  var cls = '${linkClass?js_string}';
  var confirmation = '${(confirmation!"")?js_string}';

  document.querySelectorAll('a.' + cls).forEach(function(trigger){
    if (confirmation) {
      trigger.setAttribute('data-os-confirm', confirmation);
    }
    trigger.setAttribute('onclick', 'return window.openSliderTrigger(this)');
  });
})();
</script>
