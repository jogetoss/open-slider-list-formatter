<div class="slider-container <#if multiTabEnabled?? && multiTabEnabled>os-slider</#if>" id="slider">
    <div class="slider-handle os-resize-handle" id="osResizeHandle">
        <span class="os-resize-grip" aria-hidden="true">⋮⋮</span>
        </div>
    <#if multiTabEnabled?? && multiTabEnabled>
    <div class="os-dock" id="osDock">
        <div class="os-tab-list" id="osTabList"></div>

        <div class="os-controls">
            <button type="button" class="os-btn" id="osMinBtn" title="Minimize"><span>_</span></button>
            <button type="button" class="os-btn" id="osCloseBtn" title="Close"><span>×</span></button>
            </div>
        </div>

    <div class="os-content" id="osContent">
        <div class="os-loading" id="osLoading">
            <div class="os-spinner"></div>
            Loading...
            </div>
        </div>
    <#else>
    <div class="slider-content"></div>
    </#if>
    </div>

<#if multiTabEnabled?? && multiTabEnabled>
<div class="os-min-indicator" id="osMinIndicator" title="Restore">
    <div class="os-min-text">Tabs</div>
    <div class="os-min-count" id="osTabCount">0</div>
    </div>
</#if>

<style>
    .slider-container {
        position: fixed;
        top: 0;
        right: -100%; /* Initially off-screen */
        width: ${width!};
        height: 100%;
        background-color: #fff;
        box-shadow: -2px 0 5px rgba(0, 0, 0, 0.5);
        transition: right 0.3s ease-in-out;
        overflow-y: auto; /* Enable vertical scrolling if content exceeds height */
        overscroll-behavior: contain; /* Don't chain scroll to the page underneath once this has no more room to scroll */
        z-index: 9999;
        resize: horizontal;

    }

    .slider-content {
        padding: 0 10px;
        height: 100%; /* Take full height of slider container */
        box-sizing: border-box; /* Ensure padding is included in height calculation */

    }

    .slider-container.open {
        right: 0;

    }

    #slider.os-slider{
        position: fixed;
        top: 0;
        right: -100%;
        width: ${width!'50%'};
        height: 100%;
        background: #fff;
        box-shadow: -2px 0 10px rgba(0,0,0,.35);
        transition: right .25s ease-in-out;
        z-index: 9999;

        display: flex;
        flex-direction: column;
        overflow: hidden;
        overscroll-behavior: contain;
        min-width: 300px;
        max-width: 90%;

    }

    #slider.os-slider.open{ right: 0;
    }
    #slider.os-slider.minimized{ right: -100%;
    }

    #slider .os-resize-handle{
        position: absolute;
        left: 0;
        top: 0;
        width: 12px;
        height: 100%;
        cursor: col-resize;
        z-index: 10001;
        background: transparent;

    }

    #slider .os-resize-handle::after{
        content:"";
        position:absolute;
        left:0;
        top:50%;
        transform:translateY(-50%);
        width:12px;
        height:90px;
        border-radius:10px;
        background:#dad7d7;
        border:1px solid #2d2e2e59;

    }

    #slider .os-resize-grip{
        position:absolute;
        left:3px;
        top:50%;
        transform:translateY(-50%);
        color:#1c1b1b;
        font-size:14px;
        line-height:10px;
        letter-spacing:-2px;
        writing-mode: vertical-rl;
        text-orientation: upright;
        pointer-events:none;
        user-select:none;
        z-index:1;

    }

    #slider.os-resizing iframe{
        pointer-events: none !important;

    }

    #slider.os-slider .os-dock{
        flex: 0 0 auto;
        position: sticky;
        top: 0;
        z-index: 10;

        display:flex;
        align-items:center;
        gap: 10px;
        height: ${dockHeight};
        padding: ${dockPadding};
        background: ${dockBackground};
        border-bottom: #ffffff26;
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);

    }

    #slider.os-slider .os-tab-list{
        display:flex;
        flex:1;
        overflow-x:auto;
        gap: ${tabListGap};
        padding: ${tabListPadding};

    }

    #slider.os-slider .os-tab-list::-webkit-scrollbar{ height: 4px;
    }
    #slider.os-slider .os-tab-list::-webkit-scrollbar-thumb{ background: rgba(255,255,255,.25); border-radius: 2px;
    }

    #slider.os-slider .os-tab{
        background: ${tabBackground};
        border: 1px solid rgba(255,255,255,.18);
        color: ${tabTextColor};
        padding: ${tabPadding};
        border-radius: ${borderRadius};
        cursor: pointer;
        white-space: nowrap;
        font-size: ${fontSize};
        font-weight: ${fontWeight};
        display:flex;
        align-items:center;
        gap: ${tabListGap};
        user-select:none;
        min-width: ${tabMinWidth};
        max-width: ${tabMaxWidth};

    }

    #slider.os-slider .os-tab:hover{
        background: rgba(255,255,255,.18);
        transform: translateY(-1px);

    }

    #slider.os-slider .os-tab.active{
        background: ${tabActiveBackground};
        border-color: rgba(255,255,255,.25);

    }

    #slider.os-slider .os-tab-close{
        opacity: ${tabCloseButtonOpacity};
        font-size: 16px;
        line-height: 1;
        padding: 0 2px;
        border-radius: 6px;

    }

    #slider.os-slider .os-tab:hover .os-tab-close{ opacity: .95;
    }
    #slider.os-slider .os-tab-close:hover{ background: rgba(255,255,255,.18);
    }

    #slider.os-slider .os-controls{
        display:flex;
        gap: ${controlsGap};
        align-items:center;

    }

    #slider.os-slider .os-btn{
        background: ${buttonBackground};
        border: 1px solid rgba(255,255,255,.18);
        color: rgba(255,255,255,.92);
        width: ${controlButtonSize};
        height: ${controlButtonSize};
        border-radius: 12px;
        cursor: pointer;
        font-size: ${fontSize};
        font-weight: bold;

    }

    #slider.os-slider .os-btn:hover{
        background: ${buttonHoverBackground};
        transform: scale(1.05);

    }

    #slider.os-slider .os-content{
        flex: 1 1 auto;
        overflow: hidden;
        position: relative;
        background: #fff;

    }

    #slider.os-slider .os-content iframe{
        width: 100%;
        height: 100%;
        border: none;
        display: none;

    }

    #slider.os-slider .os-loading{
        display:flex;
        align-items:center;
        justify-content:center;
        gap: 14px;
        height: 180px;
        color: #666;
        font-size: 15px;
        flex-direction: column;

    }

    #slider.os-slider .os-spinner{
        width: 46px;
        height: 46px;
        border: 4px solid #f1f1f1;
        border-top: 4px solid rgba(0,123,255,.9);
        border-radius: 50%;
        animation: osSpin 1s linear infinite;

    }

    @keyframes osSpin{
        0%{ transform: rotate(0deg);
        }
        100%{ transform: rotate(360deg);
        }

    }

    .os-min-indicator{
        position: fixed;
        top: 50%;
        right: 0;
        transform: translateY(-50%);
        background: ${dockBackground};
        color: rgba(255,255,255,.92);
        padding: 12px 8px;
        border-top-left-radius: 12px;
        border-bottom-left-radius: 12px;
        cursor: pointer;
        z-index: 10000;
        display: none;
        box-shadow: -4px 0 18px rgba(0,0,0,.35);
        writing-mode: vertical-rl;
        text-orientation: mixed;
        min-height: 120px;
        align-items:center;
        justify-content:center;
        gap: 10px;
        border: 2px solid rgba(255,255,255,.10);
        border-right: none;

    }

    #slider.os-slider.minimized + #osMinIndicator{ display: flex;
    }

    .os-min-text{ font-size: 11px; opacity: .9; letter-spacing: 1px; text-transform: uppercase;
    }
    .os-min-count{
        background: rgba(0,123,255,.95);
        border-radius: 50%;
        width: 24px;
        height: 24px;
        display:flex;
        align-items:center;
        justify-content:center;
        font-size: 12px;
        font-weight: bold;
        border: 2px solid rgba(255,255,255,.18);

    }
    </style>

<script>
(function(){
  // Clicks and key presses inside an iframe never reach this document, so
  // with the slider open over a page of same-origin iframes (e.g.
  // dashboard portlets) a click inside one wouldn't count as "outside the
  // slider". This returns a function that also attaches the given
  // handler (capture phase, like the document-level one) to the document
  // of every same-origin iframe on the page, nested ones included, except
  // the slider's own content. Call it whenever the slider opens: frames
  // added since are picked up, and a frame that navigates gets the
  // handler again on load. Cross-origin frames can't be reached and are
  // skipped. Defined once per window, shared by both scripts below.
  if (typeof window.osSliderFrameListener !== 'function') {
    window.osSliderFrameListener = function(slider, type, handler) {
      var key = '__osSlider_' + type + '_' + Math.random().toString(36).slice(2);

      function frameDocument(frame) {
        try {
          return frame.contentDocument;
        } catch (e) {
          return null;
        }
      }

      function attachToFrames(doc, depth) {
        if (!doc || depth > 3) return;
        Array.prototype.forEach.call(doc.querySelectorAll('iframe'), function(frame){
          if (slider.contains(frame)) return;
          if (!frame[key]) {
            frame[key] = true;
            frame.addEventListener('load', function(){
              attach(frameDocument(frame), depth + 1);
            });
          }
          attach(frameDocument(frame), depth + 1);
        });
      }

      function attach(doc, depth) {
        if (!doc) return;
        if (!doc[key]) {
          doc[key] = true;
          doc.addEventListener(type, handler, true);
        }
        attachToFrames(doc, depth);
      }

      return function() {
        attachToFrames(document, 0);
      };
    };
  }

  // This template can be injected more than once per page (a Kanban page
  // renders the formatter once per list row and again per card, a
  // Planner page keeps several views of the list in the DOM, and a
  // long-lived single-page-app session carries JS state across
  // client-side navigations), so several #slider elements can share
  // this id. Each run of this script therefore claims the first #slider
  // no other run has claimed yet, and does EVERYTHING - element lookups,
  // listeners, the openSlider() closure - against that one element.
  //
  // Two things this must not do:
  // - Guard with a window-global flag: a stale "already initialized"
  //   from an earlier render would skip a brand new #slider entirely,
  //   leaving window.openSlider bound to a dead element.
  // - Look anything up document-wide ("#slider .slider-content"): that
  //   resolves to whichever copy is first in tree order, not
  //   necessarily this run's, so openSlider() would put the iframe into
  //   one copy's content while opening a different, empty copy (a
  //   blank panel).
  var slider = Array.prototype.find.call(
      document.querySelectorAll('[id="slider"]'),
      function(el){ return !el.__osSliderInitialized; });
  if (!slider) return;
  slider.__osSliderInitialized = true;

  // This slider's own minimize indicator is its next sibling in the
  // markup; grab it before anything is moved.
  var minIndicator = slider.nextElementSibling;
  if (!minIndicator || minIndicator.id !== 'osMinIndicator') {
    minIndicator = null;
  }

  // Re-parent the slider (and its minimize indicator) to <body>. The formatter
  // emits this markup inline inside the datalist's row/cell, and staying there
  // means clicks on our controls bubble through row/cell click handlers the
  // underlying list/kanban view attaches (e.g. inline-edit auto-save), which
  // can fire unrelated form submissions. Moving it to <body> also avoids
  // "position: fixed" being broken by a transformed ancestor. The indicator
  // goes right after the slider so the "#slider.minimized + #osMinIndicator"
  // sibling selector keeps matching.
  if (slider.parentNode !== document.body) {
    document.body.appendChild(slider);
    if (minIndicator) {
      document.body.appendChild(minIndicator);
    }
  }

  var sliderContent = slider.querySelector('.slider-content');
  var handle = slider.querySelector('.slider-handle');

  var isResizing = false;
  var startX = 0;
  var startWidth = 0;

  if (handle){
    handle.addEventListener('pointerdown', startResize);
  }
  document.addEventListener('pointermove', onResize);
  document.addEventListener('pointerup', stopResize);
  document.addEventListener('pointerleave', stopResize);

  function startResize(e) {
    isResizing = true;
    startX = e.clientX;
    // offsetWidth, not clientWidth: clientWidth leaves out a classic
    // scrollbar's width, so the panel would jump narrower by that much
    // as soon as a drag starts.
    startWidth = slider.offsetWidth;

    if (handle && handle.setPointerCapture) {
      handle.setPointerCapture(e.pointerId);
    }

    slider.classList.add('os-resizing');

    e.preventDefault();
  }

  function onResize(e) {
    if (!isResizing) return;
    const currentX = e.clientX;
    const deltaX = currentX - startX;
    slider.style.width = (startWidth - deltaX) + 'px';
  }

  function stopResize(e) {
    if (!isResizing) return;
    isResizing = false;

    try {
      if (handle && handle.releasePointerCapture) {
        handle.releasePointerCapture(e.pointerId);
      }
    } catch(err) {}

    slider.classList.remove('os-resizing');
  }
  function closePanel() {
    if (sliderContent) sliderContent.innerHTML = '';
    slider.classList.remove('open');
    slider.classList.remove('minimized');
  }

  // Only single-mode markup has a .slider-content to load into. In
  // multi-tab markup the multi-tab script below owns openSlider/
  // closeSlider; claiming them here too would just leave whichever of
  // the two scripts happened to run last in charge of them.
  if (sliderContent) {
    window.openSlider = function(url) {
      closePanel();

      var iframe = document.createElement('iframe');
      iframe.src = url;
      iframe.style.width = '100%';
      iframe.style.height = '100%';
      iframe.style.border = 'none';
      // An iframe is inline by default, which leaves a baseline gap
      // under it inside .slider-content; that gap makes #slider overflow
      // by a few pixels and grow a scrollbar of its own next to the
      // iframe's (a double scrollbar).
      iframe.style.display = 'block';

      sliderContent.appendChild(iframe);
      slider.classList.add('open');
      listenInFrames();
    };

    window.closeSlider = closePanel;
  }

  document.addEventListener('DOMContentLoaded', closePanel);

    // Click outside to close. Capture phase (matching the multi-tab dock's
    // own outside-click handler below) so this runs and reads "open"
    // BEFORE a trigger link's own onclick (e.g. openSliderTrigger, an
    // attribute-based AT_TARGET-phase handler) has a chance to open the
    // slider on this very click - otherwise a trigger without the
    // "no-close" class immediately closes the panel it just opened.
  function closeOnOutsideClick(e) {
    if (slider.classList.contains('os-slider')) return;

    if (slider.classList.contains('open') &&
        !slider.contains(e.target) &&
        !(e.target.closest && e.target.closest('.no-close'))) {
      closePanel();
    }
  }
  document.addEventListener('click', closeOnOutsideClick, true);
  // ...and inside the page's iframes, see osSliderFrameListener above
  var listenInFrames = window.osSliderFrameListener(slider, 'click', closeOnOutsideClick);
})();
    </script>


<#if multiTabEnabled?? && multiTabEnabled>
<script type="text/javascript">
(function(){
  // Claim this run's own multi-tab #slider and scope every lookup to it,
  // for the same reasons as the base script above (several #slider
  // copies can share one id, and document-wide id lookups only ever
  // return the first).
  var slider = Array.prototype.find.call(
      document.querySelectorAll('[id="slider"]'),
      function(el){ return el.querySelector('.os-dock') && !el.__osSliderMultiTabInitialized; });
  if (!slider) return;
  slider.__osSliderMultiTabInitialized = true;

  // The base script has already moved this slider and its indicator to
  // <body> together, so the indicator is still its next sibling.
  var minIndicator = slider.nextElementSibling;
  if (!minIndicator || minIndicator.id !== 'osMinIndicator') {
    minIndicator = null;
  }

  var tabList = slider.querySelector('#osTabList');
  var contentDiv = slider.querySelector('#osContent');
  var loadingDiv = slider.querySelector('#osLoading');
  var tabCount = minIndicator ? minIndicator.querySelector('#osTabCount') : null;

  var minBtn = slider.querySelector('#osMinBtn');
  var closeBtn = slider.querySelector('#osCloseBtn');

  var tabs = []; 
  var activeId = null;

  function safeId(url){ return url; }

  function updateCount(){
    if (tabCount) tabCount.textContent = tabs.length;
  }

  function showLoading(){
    if (loadingDiv) loadingDiv.style.display = 'flex';
  }
  function hideLoading(){
    if (loadingDiv) loadingDiv.style.display = 'none';
  }

  function ensureOpen(){
    slider.classList.add('open');
    slider.classList.remove('minimized');
    listenInFrames();
  }

  function renderTabs(){
    if (!tabList) return;
    tabList.innerHTML = '';

    tabs.forEach(function(t){
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'os-tab' + (t.id === activeId ? ' active' : '');
      btn.addEventListener('click', function(e){
        e.preventDefault(); e.stopPropagation();
        setActive(t.id);
      });

      var title = document.createElement('span');
      title.textContent = t.title || 'Tab';
      title.style.overflow = 'hidden';
      title.style.textOverflow = 'ellipsis';

      var x = document.createElement('span');
      x.className = 'os-tab-close';
      x.innerHTML = '×';
      x.addEventListener('click', function(e){
        e.preventDefault(); e.stopPropagation();
        closeTab(t.id);
      });

      btn.appendChild(title);
      btn.appendChild(x);
      tabList.appendChild(btn);
    });
  }

  function getIframe(tabId){
    return contentDiv.querySelector('iframe[data-tab-id="' + tabId.replace(/"/g,'\\"') + '"]');
  }

  function hideAllIframes(){
    var iframes = contentDiv.querySelectorAll('iframe');
    iframes.forEach(function(f){ f.style.display = 'none'; });
  }

  function loadTab(tab){
    if (!contentDiv) return;

    var existing = getIframe(tab.id);
    if (existing){
      hideAllIframes();
      existing.style.display = 'block';
      hideLoading();
      return;
    }

    showLoading();
    hideAllIframes();

    var iframe = document.createElement('iframe');
    iframe.setAttribute('data-tab-id', tab.id);
    iframe.src = tab.url;
    iframe.style.display = 'none';

    iframe.onload = function(){
      hideLoading();
      iframe.style.display = 'block';
    };
    iframe.onerror = function(){
      if (loadingDiv){
        loadingDiv.innerHTML = '<div style="color:red;">Error loading content</div>';
        loadingDiv.style.display = 'flex';
      }
    };

    contentDiv.appendChild(iframe);
  }

  function setActive(tabId){
    var tab = tabs.find(function(t){ return t.id === tabId; });
    if (!tab) return;

    activeId = tabId;
    renderTabs();
    loadTab(tab);
  }

  function addOrFocus(url, title){
    if (!url) return;

    var id = safeId(url);
    var existing = tabs.find(function(t){ return t.id === id; });

    if (existing){
      existing.title = title || existing.title;
      setActive(existing.id);
    } else {
      var tab = { id: id, url: url, title: title || ('Page ' + (tabs.length + 1)) };
      tabs.push(tab);
      renderTabs();
      setActive(tab.id);
      updateCount();
    }

    ensureOpen();
  }

  function closeTab(tabId){
    var idx = tabs.findIndex(function(t){ return t.id === tabId; });
    if (idx < 0) return;

    var iframe = getIframe(tabId);
    if (iframe) iframe.remove();

    tabs.splice(idx, 1);

    if (activeId === tabId){
      if (tabs.length > 0){
        var newIdx = idx >= tabs.length ? tabs.length - 1 : idx;
        activeId = tabs[newIdx].id;
        renderTabs();
        loadTab(tabs[newIdx]);
      } else {
        closeSlider();
        return;
      }
    } else {
      renderTabs();
    }

    updateCount();
  }

  function closeSlider(){
    slider.classList.remove('open', 'minimized');

    tabs = [];
    activeId = null;
    updateCount();

    if (tabList) tabList.innerHTML = '';

    if (contentDiv){
      var iframes = contentDiv.querySelectorAll('iframe');
      iframes.forEach(function(f){ f.remove(); });
    }

    if (loadingDiv){
      loadingDiv.style.display = 'flex';
      loadingDiv.innerHTML = '<div class="os-spinner"></div>Loading...';
    }
  }

  function minimize(){
    if (!slider.classList.contains('open')) return;
    slider.classList.add('minimized');
    updateCount();
  }

  function restore(){
    if (tabs.length === 0) return;
    slider.classList.remove('minimized');
    slider.classList.add('open');
    listenInFrames();
  }

  window.openSlider = function(url, tabName){
    addOrFocus(url, tabName || '');
  };

  window.closeSlider = closeSlider;
  window.minimizeSlider = minimize;
  window.restoreSlider = restore;
  window.closeSliderTab = closeTab;

  minBtn && minBtn.addEventListener('click', function(e){
    e.preventDefault(); e.stopPropagation();
    if (slider.classList.contains('minimized')) restore();
    else minimize();
  });

  closeBtn && closeBtn.addEventListener('click', function(e){
    e.preventDefault(); e.stopPropagation();
    closeSlider();
  });

  minIndicator && minIndicator.addEventListener('click', function(e){
    e.preventDefault(); e.stopPropagation();
    restore();
  });

  function minimizeOnOutsideClick(e){
    if (!slider.classList.contains('open') || slider.classList.contains('minimized')) return;

    var isInside = slider.contains(e.target);
    var isIndicator = minIndicator && minIndicator.contains(e.target);

    if (e.target.closest && e.target.closest('.no-close')) return;

    if (!isInside && !isIndicator){
      minimize();
    }
  }

  function onKeydown(e){
    if (e.key === 'Escape' && slider.classList.contains('open')) {
      minimize();
    }
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'w' && slider.classList.contains('open')) {
      e.preventDefault();
      closeSlider();
    }
  }

  document.addEventListener('click', minimizeOnOutsideClick, true);
  document.addEventListener('keydown', onKeydown);
  // ...and inside the page's iframes, see osSliderFrameListener
  var listenForClicksInFrames = window.osSliderFrameListener(slider, 'click', minimizeOnOutsideClick);
  var listenForKeysInFrames = window.osSliderFrameListener(slider, 'keydown', onKeydown);
  function listenInFrames(){
    listenForClicksInFrames();
    listenForKeysInFrames();
  }

  (function initResizePersist(){
    var savedWidth = localStorage.getItem('openSliderWidth');
    if (savedWidth) slider.style.width = savedWidth;

    // We reuse the original resize handlers; just save width on pointerup.
    document.addEventListener('pointerup', function(){
      try { localStorage.setItem('openSliderWidth', slider.style.width); } catch(e){}
    });
    document.addEventListener('pointercancel', function(){
      try { localStorage.setItem('openSliderWidth', slider.style.width); } catch(e){}
    });
  })();

  closeSlider();
})();
    </script>
</#if>
