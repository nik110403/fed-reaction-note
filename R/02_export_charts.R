# Chart.js HTML widgets + PNG figures from output/data/note_export.rds.
# Follows the argentina-monetary-deepdive widget-factory pattern exactly: standalone
# <figure> HTML, Chart.js 4.4.1 lazy-loaded from jsDelivr behind a shared
# window.__chartjs promise, theme via MutationObserver on <html> class list
# ('is-light'), stat cards, HTML legend with data-k swatches, source footer.
# One generic JS renderer is parameterized per figure by a serialized spec.
# Also writes paste-ready *.embed.md files (```html-embed fenced) per widget.

source("R/config.R")

df <- readRDS(file.path(DIR_DATA, "note_export.rds"))

KICKER <- "Market Note &middot; Fed Reaction &middot; 2026"
SITE   <- "https://nikkhosravipour.com"

# ---- generic JS renderer (JS uses single quotes only; R string is double-quoted)
JS_TEMPLATE <- "
<script>
(function () {
  window.__chartjs = window.__chartjs || new Promise(function(resolve) {
    if (window.Chart) return resolve();
    var s = document.createElement('script');
    s.src = 'https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.js';
    s.onload = resolve;
    document.head.appendChild(s);
  });
  var canvas = document.getElementById('__ID__');
  if (!canvas) return;
  var SPEC = __SPEC__;
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
</script>"

# ---- HTML shell (single-quoted R strings; no literal apostrophes) ---------------
stat_card <- function(label, value) {
  paste0('<div style="background:var(--bg-soft);border:1px solid var(--border);',
         'border-radius:6px;padding:8px 12px;"><div style="font-size:0.68rem;',
         'color:var(--muted);text-transform:uppercase;letter-spacing:.05em;',
         'margin-bottom:2px;">', label, '</div><div style="font-size:1.05rem;',
         'font-weight:600;color:var(--text);">', value, '</div></div>')
}

legend_item <- function(key, label) {
  paste0('<span style="display:inline-flex;align-items:center;gap:6px;',
         'font-size:11px;color:var(--muted);"><span data-k="', key,
         '" style="display:inline-block;width:10px;height:10px;',
         'border-radius:2px;background:#888;flex-shrink:0;"></span>',
         label, '</span>')
}

widget <- function(stem, id, title, subtitle, stats, legend, height, source_html,
                    spec, aria) {
  spec_json <- jsonlite::toJSON(spec, auto_unbox = TRUE, na = "null", digits = 4)
  stats_html <- if (length(stats)) {
    paste0('<div style="display:grid;grid-template-columns:repeat(',
           length(stats), ',1fr);gap:8px;margin-bottom:12px;">',
           paste0(mapply(stat_card, names(stats), unlist(stats)), collapse = ""),
           '</div>')
  } else ""
  legend_html <- if (length(legend)) {
    paste0('<div style="display:flex;flex-wrap:wrap;gap:16px;margin-bottom:12px;">',
           paste0(mapply(legend_item, names(legend), unlist(legend)),
                  collapse = ""), '</div>')
  } else ""
  js <- sub("__ID__", id, JS_TEMPLATE, fixed = TRUE)
  js <- sub("__SPEC__", spec_json, js, fixed = TRUE)
  html <- paste0(
    '<figure class="chart-embed" style="margin:0; font-family:var(--font-body);">\n',
    '<p style="margin:0 0 3px;font-size:10px;letter-spacing:0.13em;',
    'text-transform:uppercase;color:var(--muted);">', KICKER, '</p>\n',
    '<p style="margin:0 0 3px;font-size:18px;font-weight:500;color:var(--text);',
    'line-height:1.3;">', title, '</p>\n',
    '<p style="margin:0 0 18px;font-size:12px;color:var(--muted);">', subtitle,
    '</p>\n', stats_html, legend_html,
    '<div style="position:relative; width:100%; height:', height, 'px;">\n',
    '<canvas id="', id, '" role="img" aria-label="', aria, '"></canvas>\n</div>\n',
    '<div style="margin-top:14px;padding-top:10px;border-top:1px solid ',
    'var(--border);display:flex;justify-content:space-between;font-size:10px;',
    'color:var(--muted);letter-spacing:0.02em;"><span>Source: ', source_html,
    ' Author&#8217;s calculations.</span><a href="', SITE,
    '" target="_blank" rel="noopener" style="color:inherit;',
    'text-decoration:underline;">nikkhosravipour.com</a></div>\n</figure>',
    js)
  writeLines(html, file.path(DIR_WIDGETS, paste0(stem, ".html")))
  writeLines(c("```html-embed", html, "```"),
             file.path(DIR_WIDGETS, paste0(stem, ".embed.md")))
  cat(sprintf("  widget -> output/widgets/%s.{html,embed.md}\n", stem))
}

# ---- spec helpers ----------------------------------------------------------------
fmt_m <- function(d) format(d, "%Y-%m")
fmt_d <- function(d) gsub("\\s+", " ", trimws(format(d, "%b %e")))
num   <- function(x) ifelse(is.finite(x), round(x, 2), NA)
last_nonna <- function(v) tail(stats::na.omit(v), 1)

series_df <- function(id) {
  x <- df[df$series == id, ]
  x[order(x$date), ]
}

FRED_SRC <- paste0('<a href="https://fred.stlouisfed.org/" target="_blank" ',
                    'rel="noopener" style="color:inherit;text-decoration:underline;">',
                    'Federal Reserve Economic Data (FRED)</a>, BLS, BEA.')

nearest_obs <- function(dates, values, target) {
  idx <- which(dates <= target)
  if (!length(idx)) return(NA_real_)
  values[max(idx)]
}

vline_idx <- function(dates, events) {
  out <- list()
  for (i in seq_len(nrow(events))) {
    idx <- which(dates >= events$date[i])
    if (!length(idx)) next
    out[[length(out) + 1]] <- list(x = idx[1] - 1, text = events$label[i])
  }
  out
}

png_fig <- function(name, expr) {
  path <- file.path(DIR_FIGURES, paste0(name, ".png"))
  grDevices::png(path, width = 1600, height = 900, res = 200, bg = "white")
  op <- par(mar = c(3.5, 3.8, 3, 1), mgp = c(2.2, 0.6, 0), tcl = -0.3, family = "sans")
  on.exit({par(op); grDevices::dev.off()}, add = TRUE)
  force(expr)
  cat(sprintf("  png -> output/figures/%s.png\n", name))
}

# ==================================================================================
# fig1 — repricing (lead chart): 2-year yield, daily, June 2026, event flags
# ==================================================================================
d1 <- series_df("DGS2")

pre_cpi        <- nearest_obs(d1$date, d1$value, as.Date("2026-06-09"))
post_fomc_peak <- max(d1$value[d1$date >= as.Date("2026-06-17")], na.rm = TRUE)
latest_close   <- tail(d1$value, 1)

widget("fig1_repricing", "frn-fig1",
       "The market-implied path, repriced print by print",
       "2-year Treasury yield, daily close, June 2026",
       list("Jun 9 close (pre-CPI)" = sprintf("%.2f%%", pre_cpi),
            "Post-FOMC peak"        = sprintf("%.2f%%", post_fomc_peak),
            "Latest close"          = sprintf("%.2f%%", latest_close)),
       list(actual = "2-year Treasury yield"),
       260, FRED_SRC,
       list(type = "line", labels = fmt_d(d1$date), xEvery = 5, ySuffix = "%",
            datasets = list(list(label = "2-year yield", key = "actual",
                                 data = num(d1$value), width = 2.2)),
            vlines = vline_idx(d1$date, EVENTS)),
       "Line chart of the 2-year Treasury yield, daily, June 2026, with CPI, FOMC, PCE, and payrolls event markers")

png_fig("fig1_repricing", {
  ylim <- range(d1$value, na.rm = TRUE)
  ylim[2] <- ylim[2] + 0.14 * diff(ylim)
  plot(d1$date, d1$value, type = "l", lwd = 2.2, col = PAL$dark,
       xlab = "", ylab = "2-year Treasury yield (%)", ylim = ylim,
       main = "The market-implied path, repriced print by print")
  mtext("2-year Treasury yield, daily close, June 2026", side = 3, line = 0.3,
        cex = 0.75, col = PAL$muted, adj = 0)
  abline(v = EVENTS$date, col = grDevices::adjustcolor(PAL$dark, 0.35), lty = 3)
  # Clamp label x so text stays fully inside the plot region (mirrors the JS
  # deco plugin's ca.left/ca.right clamping) — the NFP line sits at the right edge.
  usr <- par("usr")
  half_w <- strwidth(EVENTS$label, cex = 0.65) / 2
  pad    <- strwidth("M", cex = 0.65) * 0.4
  lab_x  <- pmin(pmax(as.numeric(EVENTS$date), usr[1] + half_w + pad),
                 usr[2] - half_w - pad)
  text(lab_x, ylim[2], labels = EVENTS$label, cex = 0.65,
       col = grDevices::adjustcolor(PAL$dark, 0.75), pos = 1, offset = 0.3)
})

# ==================================================================================
# fig2 — decomposition: headline / core / energy PCE, YoY, monthly
# ==================================================================================
d2h <- series_df("PCEPI")
d2c <- series_df("PCEPILFE")
d2e <- series_df("DNRGRG3M086SBEA")
wide2 <- Reduce(function(a, b) merge(a, b, by = "date", all = TRUE),
                 list(d2h[, c("date", "value")], d2c[, c("date", "value")],
                      d2e[, c("date", "value")]))
names(wide2) <- c("date", "headline", "core", "energy")
wide2 <- wide2[order(wide2$date), ]

max_abs_energy <- max(abs(wide2$energy), na.rm = TRUE)
use_secondary  <- max_abs_energy >= 12
cat(sprintf("  fig2: max |energy PCE YoY| = %.1f%% -> plotting on %s axis\n",
            max_abs_energy, if (use_secondary) "secondary (y1)" else "primary (same)"))

widget("fig2_decomposition", "frn-fig2",
       "Headline, core, and the energy wedge",
       "PCE price indexes, year-over-year, monthly",
       list("Headline PCE YoY" = sprintf("%.1f%%", last_nonna(wide2$headline)),
            "Core PCE YoY"     = sprintf("%.1f%%", last_nonna(wide2$core)),
            "Energy PCE YoY"   = sprintf("%.1f%%", last_nonna(wide2$energy))),
       list(actual = "Headline PCE", taylor1 = "Core PCE", dev_pos = "Energy PCE"),
       260, FRED_SRC,
       list(type = "line", labels = fmt_m(wide2$date), xEvery = 3, ySuffix = "%",
            y1 = use_secondary, y1Suffix = if (use_secondary) "%" else NULL,
            hline = 2,
            datasets = list(
              list(label = "Headline PCE", key = "actual", data = num(wide2$headline), width = 2.2),
              list(label = "Core PCE", key = "taylor1", data = num(wide2$core), width = 2),
              list(label = "Energy PCE", key = "dev_pos", data = num(wide2$energy),
                   width = 1.8, y2 = use_secondary))),
       "Line chart of headline, core, and energy PCE inflation year over year, monthly, with a 2 percent target line")

png_fig("fig2_decomposition", {
  if (use_secondary) {
    # Mirror the widget: headline + core on the left axis, energy on its own
    # right axis so the headline/core separation stays readable.
    par(mar = c(3.5, 3.8, 3, 3.4))
    ylim_l <- range(c(wide2$headline, wide2$core, 2), na.rm = TRUE)
    ylim_l <- ylim_l + c(-0.25, 0.35) * diff(ylim_l)
    plot(wide2$date, wide2$headline, type = "l", lwd = 2.2, col = PAL$dark,
         xlab = "", ylab = "Year-over-year (%)", ylim = ylim_l,
         main = "Headline, core, and the energy wedge")
    mtext("PCE price indexes, year-over-year, monthly", side = 3, line = 0.3,
          cex = 0.75, col = PAL$muted, adj = 0)
    lines(wide2$date, wide2$core, lwd = 1.8, col = PAL$blue)
    abline(h = 2, lty = 2, col = PAL$muted)
    usr <- par("usr")
    ylim_r <- range(wide2$energy, na.rm = TRUE)
    ylim_r <- ylim_r + c(-0.05, 0.05) * diff(ylim_r)
    par(new = TRUE)
    plot(wide2$date, wide2$energy, type = "l", lwd = 1.6, col = PAL$orange,
         axes = FALSE, xlab = "", ylab = "",
         xlim = as.Date(usr[1:2], origin = "1970-01-01"), xaxs = "i",
         ylim = ylim_r)
    axis(4, cex.axis = 0.65, col.axis = PAL$orange, col = PAL$orange)
    mtext("Energy PCE YoY (%)", side = 4, line = 2.0, cex = 0.65, col = PAL$orange)
    legend("topleft", c("Headline PCE", "Core PCE", "Energy PCE (right)", "2% target"),
           col = c(PAL$dark, PAL$blue, PAL$orange, PAL$muted), lty = c(1, 1, 1, 2),
           lwd = c(2.2, 1.8, 1.6, 1), bty = "n", cex = 0.7)
  } else {
    ylim <- range(c(wide2$headline, wide2$core, wide2$energy), na.rm = TRUE)
    plot(wide2$date, wide2$headline, type = "l", lwd = 2.2, col = PAL$dark,
         xlab = "", ylab = "Year-over-year (%)", ylim = ylim,
         main = "Headline, core, and the energy wedge")
    mtext("PCE price indexes, year-over-year, monthly", side = 3, line = 0.3,
          cex = 0.75, col = PAL$muted, adj = 0)
    lines(wide2$date, wide2$core, lwd = 1.8, col = PAL$blue)
    lines(wide2$date, wide2$energy, lwd = 1.6, col = PAL$orange)
    abline(h = 2, lty = 2, col = PAL$muted)
    legend("topleft", c("Headline PCE", "Core PCE", "Energy PCE", "2% target"),
           col = c(PAL$dark, PAL$blue, PAL$orange, PAL$muted), lty = c(1, 1, 1, 2),
           lwd = c(2.2, 1.8, 1.6, 1), bty = "n", cex = 0.7)
  }
})

# ==================================================================================
# fig3 — collision: payroll monthly change (bars) + 3-mo avg (line) + AHE YoY (line, y1)
# ==================================================================================
d3p <- series_df("PAYEMS")
d3a <- series_df("CES0500000003")
wide3 <- merge(d3p[, c("date", "value")], d3a[, c("date", "value")], by = "date", all = TRUE)
names(wide3) <- c("date", "payems", "ahe")
wide3 <- wide3[order(wide3$date), ]
wide3 <- wide3[wide3$date <= as.Date("2026-06-01"), ]
wide3$ma3 <- zoo::rollmean(wide3$payems, k = 3, fill = NA, align = "right")

june_val   <- wide3$payems[wide3$date == as.Date("2026-06-01")]
ma3_latest <- last_nonna(wide3$ma3)
ahe_latest <- last_nonna(wide3$ahe)

widget("fig3_collision", "frn-fig3",
       "Hiring stalls while pay accelerates",
       "Nonfarm payroll monthly change (bars, 3-month average) and average hourly earnings growth",
       list("June payroll change (cons. +57K)" = sprintf("%+.0fK", june_val),
            "3-month average"                  = sprintf("%+.0fK", ma3_latest),
            "Latest AHE YoY"                    = sprintf("%.1f%%", ahe_latest)),
       list(dev_neg = "Monthly change", actual = "3-month average", dev_pos = "AHE YoY (right)"),
       260, FRED_SRC,
       list(type = "bar", labels = fmt_m(wide3$date), xEvery = 3, ySuffix = "K",
            y1 = TRUE, y1Suffix = "%",
            datasets = list(
              list(label = "Monthly change", key = "dev_neg", data = num(wide3$payems), width = 0),
              list(label = "3-month average", key = "actual", type = "line",
                   data = num(wide3$ma3), width = 2.2),
              list(label = "AHE YoY", key = "dev_pos", type = "line",
                   data = num(wide3$ahe), width = 1.8, y2 = TRUE))),
       "Combination chart of monthly nonfarm payroll change as bars, three month average as a line, and average hourly earnings year over year growth on the right axis")

png_fig("fig3_collision", {
  par(mar = c(3.5, 3.8, 3, 3.4))  # room for the labeled right axis
  ylim_p <- range(wide3$payems, na.rm = TRUE)
  ylim_p <- ylim_p + c(-0.1, 0.15) * diff(ylim_p)
  bp <- barplot(wide3$payems, col = grDevices::adjustcolor(PAL$blue, 0.75), border = NA,
                ylim = ylim_p, xlab = "", ylab = "Monthly change (thousands)",
                main = "Hiring stalls while pay accelerates", names.arg = rep("", nrow(wide3)))
  xlim_bp <- par("usr")[1:2]
  mtext("Nonfarm payroll monthly change (bars, 3-month average) and average hourly earnings growth",
        side = 3, line = 0.3, cex = 0.6, col = PAL$muted, adj = 0)
  lines(bp, wide3$ma3, lwd = 2.2, col = PAL$dark)
  abline(h = 0, col = "black", lwd = 0.8)
  tick_idx <- seq(1, length(bp), by = 3)
  axis(1, at = bp[tick_idx], labels = fmt_m(wide3$date)[tick_idx], cex.axis = 0.6, las = 2)
  # xaxs = "i" reproduces the barplot's usr exactly (default "r" would re-expand
  # the captured limits by 4% and shift the AHE line off the bar midpoints).
  ylim_r <- range(wide3$ahe, na.rm = TRUE)
  ylim_r <- ylim_r + c(-0.15, 0.15) * diff(ylim_r)
  par(new = TRUE)
  plot(bp, wide3$ahe, type = "l", lwd = 1.8, col = PAL$orange, axes = FALSE,
       xlab = "", ylab = "", xlim = xlim_bp, xaxs = "i", ylim = ylim_r)
  axis(4, cex.axis = 0.65, col.axis = PAL$orange, col = PAL$orange)
  mtext("AHE YoY (%)", side = 4, line = 2.0, cex = 0.65, col = PAL$orange)
  legend("topleft", c("Monthly change", "3-month average", "AHE YoY (right)"),
         col = c(PAL$blue, PAL$dark, PAL$orange), lty = c(NA, 1, 1), lwd = c(NA, 2.2, 1.8),
         pch = c(15, NA, NA), bty = "n", cex = 0.65)
})

message("02_export_charts.R done.")
