<script>
(function(){
  // "Open In: Top window" support. The slider markup for this list is
  // rendered into an inert <template> instead of the page, and only
  // installed on first use - into the top window when this page is framed
  // by a same-origin page (e.g. a dashboard portlet), otherwise into this
  // page itself. Defined once per page; every list using "Top window"
  // shares it.
  if (typeof window.osOpenSliderTop === 'function') return;

  function targetWindow() {
    try {
      var top = window.top;
      if (top !== window && top.location.origin === window.location.origin && top.document.body) {
        return top;
      }
    } catch (e) {
      // cross-origin or sandboxed parent: open in this frame
    }
    return window;
  }

  // Copies the template's markup into the target window's document. The
  // scripts are re-created by that document rather than moved, so they run
  // as the target window's own code: the slider keeps working after this
  // frame reloads, navigates or is removed.
  function install(win, tpl) {
    var doc = win.document;
    var nodes = doc.importNode(tpl.content, true);
    var scripts = Array.prototype.slice.call(nodes.querySelectorAll('script'));
    scripts.forEach(function(s){ s.parentNode.removeChild(s); });

    doc.body.appendChild(nodes);
    scripts.forEach(function(s){
      var el = doc.createElement('script');
      if (s.type) {
        el.type = s.type;
      }
      el.text = s.textContent;
      doc.body.appendChild(el);
    });
  }

  window.osOpenSliderTop = function(url, title, templateId) {
    // relative to this frame, which the target window may not share
    var absoluteUrl = new URL(url, document.baseURI).href;
    var win = targetWindow();

    // Reuse a slider the target window already has (its own list's, or one
    // installed by an earlier click from any frame).
    if (typeof win.openSlider !== 'function') {
      var tpl = document.getElementById(templateId);
      if (!tpl) {
        return true;
      }
      install(win, tpl);
    }

    if (typeof win.openSlider === 'function') {
      win.openSlider(absoluteUrl, title);
      return false;
    }
    return true;
  };
})();
</script>
