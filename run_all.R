# Entry point: FRED pull -> Chart.js widgets + PNG figures.
# Must be run from the repo root (relative "R/..." paths below).

if (!file.exists("R/config.R")) {
  stop("run_all.R must be run from the fed-reaction-note/ repo root ",
       "(R/config.R not found). cd into the repo root and re-run: Rscript run_all.R",
       call. = FALSE)
}

cat("==========================================================================\n")
cat(sprintf("Pipeline start  %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
cat("==========================================================================\n")

source("R/01_data.R")
source("R/02_export_charts.R")

cat("\n==========================================================================\n")
cat(sprintf("Pipeline end    %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
cat("==========================================================================\n")

# ── Key numbers for prose ────────────────────────────────────────────────────
latest_row <- function(s) {
  x <- df[df$series == s, ]
  x[which.max(x$date), ]
}
close_on <- function(d) {
  v <- d1$value[d1$date == as.Date(d)]
  if (length(v)) sprintf("%.2f%%", v) else "NA (no observation)"
}

cat("\n==========================================================================\n")
cat("Key numbers for prose\n")
cat("==========================================================================\n")

pce   <- latest_row("PCEPI")
core  <- latest_row("PCEPILFE")
enrg  <- latest_row("DNRGRG3M086SBEA")
pay   <- latest_row("PAYEMS")
ahe   <- latest_row("CES0500000003")
ma3   <- last_nonna(wide3$ma3)

cat(sprintf("PCE headline YoY (%s):  %.1f%%\n", format(pce$date, "%b %Y"), pce$value))
cat(sprintf("PCE core YoY (%s):      %.1f%%\n", format(core$date, "%b %Y"), core$value))
cat(sprintf("PCE energy YoY (%s):    %.1f%%\n", format(enrg$date, "%b %Y"), enrg$value))
cat(sprintf("Payroll change (%s):    %+.0fK\n", format(pay$date, "%b %Y"), pay$value))
cat(sprintf("3-month avg payroll change: %+.0fK\n", ma3))
cat(sprintf("AHE YoY (%s):           %.1f%%\n", format(ahe$date, "%b %Y"), ahe$value))

cat("\nDGS2 (2-year Treasury yield) closes:\n")
cat(sprintf("  Jun 9  (pre-CPI):   %s\n", close_on("2026-06-09")))
cat(sprintf("  Jun 10 (CPI day):   %s\n", close_on("2026-06-10")))
cat(sprintf("  Jun 17 (FOMC day):  %s\n", close_on("2026-06-17")))
cat(sprintf("  Jun 18 (post-FOMC): %s\n", close_on("2026-06-18")))
cat(sprintf("  Jun 26 (PCE day):   %s\n", close_on("2026-06-26")))
cat(sprintf("  Jul 1:              %s\n", close_on("2026-07-01")))
cat(sprintf("  Latest (%s):    %.2f%%\n", format(max(d1$date), "%Y-%m-%d"),
            d1$value[which.max(d1$date)]))
cat(sprintf("DGS2 min/max in window: %.2f%% / %.2f%%\n",
            min(d1$value, na.rm = TRUE), max(d1$value, na.rm = TRUE)))
cat("==========================================================================\n")
