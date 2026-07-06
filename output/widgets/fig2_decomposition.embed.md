```html-embed
<figure class="chart-embed" style="margin:0; font-family:var(--font-body);">
<p style="margin:0 0 3px;font-size:10px;letter-spacing:0.13em;text-transform:uppercase;color:var(--muted);">Market Note &middot; Fed Reaction &middot; 2026</p>
<p style="margin:0 0 3px;font-size:18px;font-weight:500;color:var(--text);line-height:1.3;">Headline, core, and the energy wedge</p>
<p style="margin:0 0 18px;font-size:12px;color:var(--muted);">PCE price indexes, year-over-year, monthly</p>
<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:12px;"><div style="background:var(--bg-soft);border:1px solid var(--border);border-radius:6px;padding:8px 12px;"><div style="font-size:0.68rem;color:var(--muted);text-transform:uppercase;letter-spacing:.05em;margin-bottom:2px;">Headline PCE YoY</div><div style="font-size:1.05rem;font-weight:600;color:var(--text);">4.1%</div></div><div style="background:var(--bg-soft);border:1px solid var(--border);border-radius:6px;padding:8px 12px;"><div style="font-size:0.68rem;color:var(--muted);text-transform:uppercase;letter-spacing:.05em;margin-bottom:2px;">Core PCE YoY</div><div style="font-size:1.05rem;font-weight:600;color:var(--text);">3.4%</div></div><div style="background:var(--bg-soft);border:1px solid var(--border);border-radius:6px;padding:8px 12px;"><div style="font-size:0.68rem;color:var(--muted);text-transform:uppercase;letter-spacing:.05em;margin-bottom:2px;">Energy PCE YoY</div><div style="font-size:1.05rem;font-weight:600;color:var(--text);">24.3%</div></div></div><div style="display:flex;flex-wrap:wrap;gap:16px;margin-bottom:12px;"><span style="display:inline-flex;align-items:center;gap:6px;font-size:11px;color:var(--muted);"><span data-k="actual" style="display:inline-block;width:10px;height:10px;border-radius:2px;background:#888;flex-shrink:0;"></span>Headline PCE</span><span style="display:inline-flex;align-items:center;gap:6px;font-size:11px;color:var(--muted);"><span data-k="taylor1" style="display:inline-block;width:10px;height:10px;border-radius:2px;background:#888;flex-shrink:0;"></span>Core PCE</span><span style="display:inline-flex;align-items:center;gap:6px;font-size:11px;color:var(--muted);"><span data-k="dev_pos" style="display:inline-block;width:10px;height:10px;border-radius:2px;background:#888;flex-shrink:0;"></span>Energy PCE</span></div><div style="position:relative; width:100%; height:260px;">
<canvas id="frn-fig2" role="img" aria-label="Line chart of headline, core, and energy PCE inflation year over year, monthly, with a 2 percent target line"></canvas>
</div>
<div style="margin-top:14px;padding-top:10px;border-top:1px solid var(--border);display:flex;justify-content:space-between;font-size:10px;color:var(--muted);letter-spacing:0.02em;"><span>Source: <a href="https://fred.stlouisfed.org/" target="_blank" rel="noopener" style="color:inherit;text-decoration:underline;">Federal Reserve Economic Data (FRED)</a>, BLS, BEA. Author&#8217;s calculations.</span><a href="https://nikkhosravipour.com" target="_blank" rel="noopener" style="color:inherit;text-decoration:underline;">nikkhosravipour.com</a></div>
</figure>
<script>
(function () {
  window.__chartjs = window.__chartjs || new Promise(function(resolve) {
    if (window.Chart) return resolve();
    var s = document.createElement('script');
    s.src = 'https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.js';
    s.onload = resolve;
    document.head.appendChild(s);
  });
  var canvas = document.getElementById('frn-fig2');
  if (!canvas) return;
  var SPEC = {"type":"line","labels":["2024-01","2024-02","2024-03","2024-04","2024-05","2024-06","2024-07","2024-08","2024-09","2024-10","2024-11","2024-12","2025-01","2025-02","2025-03","2025-04","2025-05","2025-06","2025-07","2025-08","2025-09","2025-10","2025-11","2025-12","2026-01","2026-02","2026-03","2026-04","2026-05"],"xEvery":3,"ySuffix":"%","y1":true,"y1Suffix":"%","hline":2,"datasets":[{"label":"Headline PCE","key":"actual","data":[2.7,2.71,2.93,2.83,2.66,2.55,2.59,2.41,2.26,2.48,2.59,2.73,2.61,2.71,2.36,2.28,2.46,2.59,2.61,2.75,2.79,2.71,2.82,2.88,2.88,2.87,3.54,3.8,4.07],"width":2.2},{"label":"Core PCE","key":"taylor1","data":[3.16,3.06,3.12,3.01,2.77,2.75,2.81,2.87,2.84,2.99,2.98,2.99,2.78,2.97,2.67,2.61,2.78,2.81,2.86,2.91,2.83,2.75,2.83,2.97,3.1,3.05,3.25,3.32,3.41],"width":2},{"label":"Energy PCE","key":"dev_pos","data":[-4.56,-2.23,1.43,1.76,3.03,0.35,0.42,-5.04,-8.1,-5.95,-4.01,-1.02,0.66,-0.56,-3.77,-4.19,-3.77,-1.26,-1.87,-0.1,2.66,2.66,4.4,2.2,-0.88,-0.23,14.44,18.29,24.26],"width":1.8,"y2":true}]};
  var scope = canvas.closest('figure');
  var chart;
  function palette() {
    var light = document.documentElement.classList.contains('is-light');
    return {
      tick:    light ? 'rgba(0,0,0,0.42)'       : 'rgba(255,255,255,0.5)',
      grid:    light ? 'rgba(0,0,0,0.06)'       : 'rgba(255,255,255,0.07)',
      yTick:   light ? 'rgba(0,0,0,0.65)'       : 'rgba(255,255,255,0.7)',
      actual:  light ? '#1C1C1A'                : '#E8E6DF',
      taylor1: light ? '#185FA5'                : '#60a5fa',
      taylor2: light ? '#1D9E75'                : '#34d399',
      dev_pos: light ? '#D85A30'                : '#f87171',
      dev_neg: light ? '#185FA5'                : '#60a5fa',
      ngdp:    light ? '#1C1C1A'                : '#E8E6DF',
      trend:   light ? '#185FA5'                : '#60a5fa',
      text:    light ? '#1C1C1A'                : '#E8E6DF',
      muted:   light ? 'rgba(0,0,0,0.50)'       : 'rgba(255,255,255,0.55)',
      vlabel:  light ? 'rgba(20,18,15,0.92)'    : 'rgba(245,243,238,0.95)',
      vplate:  light ? 'rgba(250,247,242,0.92)' : 'rgba(15,13,10,0.85)'
    };
  }
  function alpha(hex, a) {
    var n = parseInt(hex.slice(1), 16);
    return 'rgba(' + (n >> 16) + ',' + ((n >> 8) & 255) + ',' + (n & 255) +
           ',' + a + ')';
  }
  function render() {
    if (!window.Chart) return;
    var c = palette();
    scope.querySelectorAll('[data-k]').forEach(function(sw) {
      sw.style.background = c[sw.dataset.k] || '#888';
    });
    var deco = {
      id: 'deco',
      afterDraw: function(ch) {
        var ctx = ch.ctx, ca = ch.chartArea, xs = ch.scales.x;
        var vl = (SPEC.vlines || []).map(function (v) {
          return { px: xs.getPixelForValue(v.x), text: v.text };
        }).sort(function (a, b) { return a.px - b.px; });
        ctx.save();
        // dashed event lines span the plot
        ctx.strokeStyle = c.muted; ctx.lineWidth = 1; ctx.setLineDash([3, 3]);
        vl.forEach(function (v) {
          ctx.beginPath(); ctx.moveTo(v.px, ca.top); ctx.lineTo(v.px, ca.bottom); ctx.stroke();
        });
        ctx.setLineDash([]);
        // Event labels live ENTIRELY in the top gutter, never over the data.
        // Horizontal, greedily packed into rows so they never overlap each other
        // (even for clustered events), clamped to the canvas, with a thin leader
        // tying each label back to its line. Gutter reserved by padding.top below.
        ctx.font = '600 10px system-ui, sans-serif';
        ctx.textAlign = 'center'; ctx.textBaseline = 'middle';
        var rowH = 14, rowsRight = [];
        vl.forEach(function (v) {
          if (!v.text) return;
          var label = v.text.length > 16 ? v.text.slice(0, 15) + '...' : v.text;
          var w = ctx.measureText(label).width;
          var lx = Math.max(ca.left + w / 2 + 2, Math.min(v.px, ca.right - w / 2 - 2));
          var row = 0;
          while (row < rowsRight.length && rowsRight[row] > lx - w / 2 - 6) row++;
          rowsRight[row] = lx + w / 2 + 6;
          var ly = ca.top - 8 - row * rowH;
          ctx.strokeStyle = c.muted; ctx.lineWidth = 1;
          ctx.beginPath(); ctx.moveTo(v.px, ca.top); ctx.lineTo(lx, ly + 7); ctx.stroke();
          ctx.fillStyle = c.vplate; ctx.fillRect(lx - w / 2 - 3, ly - 7, w + 6, 14);
          ctx.fillStyle = c.vlabel; ctx.fillText(label, lx, ly);
        });
        ctx.restore();
        if (SPEC.hline !== undefined && SPEC.hline !== null) {
          var ys = ch.scales.y, y0 = ys.getPixelForValue(SPEC.hline);
          ctx.save(); ctx.strokeStyle = c.tick; ctx.setLineDash([4, 4]);
          ctx.beginPath(); ctx.moveTo(ca.left, y0); ctx.lineTo(ca.right, y0);
          ctx.stroke(); ctx.restore();
        }
      }
    };
    var datasets = SPEC.datasets.map(function(d) {
      var col = c[d.key] || c.actual;
      return {
        label: d.label,
        data: d.data,
        borderColor: col,
        backgroundColor: d.fillAlpha ? alpha(col, d.fillAlpha) : col,
        borderWidth: d.width !== undefined ? d.width : 2,
        borderDash: d.dash ? [5, 4] : undefined,
        pointRadius: 0,
        spanGaps: true,
        tension: 0.15,
        fill: d.fillTo !== undefined ? d.fillTo : false,
        yAxisID: d.y2 ? 'y1' : 'y',
        type: d.type || undefined
      };
    });
    var scales = {
      x: {
        border: { display: false },
        grid: { color: c.grid },
        ticks: { color: c.tick, font: { size: 10, family: 'system-ui, sans-serif' },
          maxRotation: 0, autoSkip: false,
          callback: function(val, i) {
            return i % (SPEC.xEvery || 1) === 0 ? SPEC.labels[i] : null;
          } }
      },
      y: {
        border: { display: false },
        grid: { color: c.grid },
        ticks: { color: c.yTick, font: { size: 10, family: 'system-ui, sans-serif' },
          callback: function(v) { return v + (SPEC.ySuffix || ''); } }
      }
    };
    if (SPEC.y1) {
      scales.y1 = {
        position: 'right', border: { display: false },
        grid: { drawOnChartArea: false },
        ticks: { color: c.yTick, font: { size: 10, family: 'system-ui, sans-serif' },
          callback: function(v) { return v + (SPEC.y1Suffix || ''); } }
      };
    }
    if (chart) chart.destroy();
    chart = new Chart(canvas, {
      type: SPEC.type,
      plugins: [deco],
      data: { labels: SPEC.labels, datasets: datasets },
      options: {
        responsive: true, maintainAspectRatio: false, animation: false,
        layout: { padding: { top: ((SPEC.vlines || []).some(function (v) { return v.text; })) ? (SPEC.vlabelGutter || 60) : 18, right: 16, left: 0, bottom: 4 } },
        interaction: { mode: 'index', intersect: false },
        plugins: { legend: { display: false }, title: { display: false } },
        scales: scales
      }
    });
  }
  window.__chartjs.then(function() {
    render();
    new MutationObserver(render).observe(document.documentElement,
      { attributes: true, attributeFilter: ['class'] });
  });
})();
</script>
```
