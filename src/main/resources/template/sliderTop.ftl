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

  // Adds a node to the target body. Joget's AJAX theme (ajaxtheme.js,
  // clearDynamicElement) deletes everything after this marker on every menu
  // navigation. A slider appended after it vanishes on the next navigation
  // while window.openSlider stays defined, so later clicks would call a
  // detached slider and do nothing. Placing it before the marker keeps it for
  // the life of the window. Without the marker (other themes, plain pages)
  // it is simply appended.
  function place(doc, node) {
    var marker = doc.getElementById('ajaxtheme_dynamic_elements_after_this');
    if (marker && marker.parentNode === doc.body) {
      doc.body.insertBefore(node, marker);
    } else {
      doc.body.appendChild(node);
    }
  }

  // Parses the markup in the target window's document and adds it there.
  // The scripts are re-created by that document, so they run as the target
  // window's own code: the slider keeps working after this frame reloads,
  // navigates or is removed. Returns { slider, open } for the slider it
  // installed, or null if the slider's script did not take over
  // window.openSlider.
  function install(win, html) {
    var doc = win.document;
    var parser = doc.createElement('template');
    parser.innerHTML = html;
    var nodes = doc.importNode(parser.content, true);
    var slider = nodes.querySelector('[id="slider"]');
    var scripts = Array.prototype.slice.call(nodes.querySelectorAll('script'));
    scripts.forEach(function(s){ s.parentNode.removeChild(s); });

    var before = win.openSlider;
    place(doc, nodes);
    scripts.forEach(function(s){
      var el = doc.createElement('script');
      if (s.type) {
        el.type = s.type;
      }
      el.text = s.textContent;
      place(doc, el);
    });

    // The slider script has just defined win.openSlider for this slider.
    // Keep that function: win.openSlider itself is shared with every slider
    // on the page, and a "Current frame" list reached later by AJAX
    // navigation redefines it for a slider of its own, which Joget then
    // deletes on the next navigation. Calling win.openSlider after that
    // opened a detached panel and nothing showed.
    if (!slider || typeof win.openSlider !== 'function' || win.openSlider === before) {
      return null;
    }
    return { slider: slider, open: win.openSlider };
  }

  window.osOpenSliderTop = function(url, title, templateId) {
    // relative to this frame, which the target window may not share
    var absoluteUrl = new URL(url, document.baseURI).href;
    var win = targetWindow();

    // Reuse the slider an earlier click from any frame installed, as long as
    // it is still in the page.
    var installed = win.osTopSlider;
    if (!installed || !installed.slider.isConnected) {
      var holder = document.getElementById(templateId);
      if (!holder) {
        return true;
      }
      installed = install(win, JSON.parse(holder.textContent));
      win.osTopSlider = installed;
    }

    if (installed) {
      installed.open(absoluteUrl, title);
      return false;
    }
    return true;
  };
})();
</script>
