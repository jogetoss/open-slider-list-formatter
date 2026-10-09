<script>
(function(){
  // "Open In: Top window" support. The slider markup for this list is
  // rendered as an inert JSON string (a <script type="application/json">,
  // see OpenSliderListFormatter.topSliderHolder()) instead of into the
  // page, and only installed on first use - into the top window when this page is framed
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

  // Parses the markup in the target window's document and adds it there.
  // The scripts are re-created by that document, so they run as the target
  // window's own code: the slider keeps working after this frame reloads,
  // navigates or is removed.
  function install(win, html) {
    var doc = win.document;
    var parser = doc.createElement('template');
    parser.innerHTML = html;
    var nodes = doc.importNode(parser.content, true);
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
      var holder = document.getElementById(templateId);
      if (!holder) {
        return true;
      }
      install(win, JSON.parse(holder.textContent));
    }

    if (typeof win.openSlider === 'function') {
      win.openSlider(absoluteUrl, title);
      return false;
    }
    return true;
  };
})();
</script>
