<script type="text/javascript">
(function(){
  // DataListAction has no hook to attach a custom onclick to the <a> it
  // generates, so instead we delegate: every link this action instance
  // renders carries the stable "link_<id>" class DataListDecorator always
  // adds for row actions, and we intercept clicks on that class here.
  var cls = '${linkClass?js_string}';

  window.__osSliderTriggersInit = window.__osSliderTriggersInit || {};
  if (window.__osSliderTriggersInit[cls]) return;
  window.__osSliderTriggersInit[cls] = true;

  document.addEventListener('click', function(e){
    // Respect a cancelled confirm() dialog (framework-generated onclick
    // returning false triggers an automatic preventDefault() before this
    // bubbles up to us).
    if (e.defaultPrevented) return;

    var trigger = e.target.closest('a.' + cls);
    if (!trigger) return;

    var href = trigger.getAttribute('href');
    if (!href) return;

    e.preventDefault();
    e.stopPropagation();

    var title = (trigger.textContent || '').trim() || 'Open';
    if (typeof window.openSlider === 'function') {
      window.openSlider(href, title);
    }
  });
})();
</script>
