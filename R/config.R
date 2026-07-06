# Packages, paths, FRED key, sample-window constants.

packages <- c("fredr", "dplyr", "zoo", "lubridate", "jsonlite")
invisible(lapply(packages, function(p) {
  if (!requireNamespace(p, quietly = TRUE)) {
    stop(sprintf("Package '%s' is required but not installed. Run install.packages('%s').",
                 p, p), call. = FALSE)
  }
  library(p, character.only = TRUE)
}))
suppressMessages(library(dplyr))   # reload last so select/filter/lag win

FRED_API_KEY <- Sys.getenv("FRED_API_KEY")
if (!nzchar(FRED_API_KEY)) {
  stop("Set FRED_API_KEY in .Renviron (free key: https://fredaccount.stlouisfed.org/apikeys)",
       call. = FALSE)
}
fredr::fredr_set_key(FRED_API_KEY)

# ---- paths -------------------------------------------------------------------
PROJECT_ROOT <- getwd()
DIR_DATA     <- file.path(PROJECT_ROOT, "output/data")
DIR_WIDGETS  <- file.path(PROJECT_ROOT, "output/widgets")
DIR_FIGURES  <- file.path(PROJECT_ROOT, "output/figures")
for (d in c(DIR_DATA, DIR_WIDGETS, DIR_FIGURES)) {
  if (!dir.exists(d)) dir.create(d, recursive = TRUE)
}

# ---- sample windows -----------------------------------------------------------
DGS2_START    <- as.Date("2026-06-01")
DGS2_END      <- as.Date("2026-07-03")
MONTHLY_START <- as.Date("2024-01-01")
MONTHLY_END   <- Sys.Date()             # "latest" — FRED returns whatever exists

# ---- fig1 event flags (2-year yield repricing) ---------------------------------
EVENTS <- data.frame(
  date  = as.Date(c("2026-06-10", "2026-06-17", "2026-06-26", "2026-07-02")),
  label = c("CPI", "FOMC", "PCE", "NFP"),
  stringsAsFactors = FALSE
)

# ---- static-figure palette (mirrors JS palette light-mode hexes) --------------
PAL <- list(dark = "#1C1C1A", blue = "#185FA5", orange = "#D85A30",
            grid = "#e5e5e5", muted = "#888888")

message("config.R: packages loaded, dirs ensured, FRED key set.")
