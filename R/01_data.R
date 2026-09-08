# FRED pulls -> one tidy long CSV (date, series, value) + RDS.
# Series and transforms: see README.md FRED series table.

source("R/config.R")

ARCHIVE_DIR <- file.path(PROJECT_ROOT, "data-raw", "fred", FRED_VINTAGE)
if (!dir.exists(ARCHIVE_DIR)) dir.create(ARCHIVE_DIR, recursive = TRUE)
archived_series <- character(0)

pull <- function(series_id, start, end, units = "lin") {
  raw <- fredr::fredr_series_observations(
    series_id          = series_id,
    observation_start  = start,
    observation_end    = end,
    units              = units,
    realtime_start     = FRED_VINTAGE,
    realtime_end       = FRED_VINTAGE
  )
  write.csv(raw, file.path(ARCHIVE_DIR, paste0(series_id, ".csv")), row.names = FALSE)
  archived_series[[length(archived_series) + 1]] <<- series_id
  raw |>
    dplyr::select(date, value) |>
    dplyr::filter(!is.na(value))
}

# ── fig1: 2-year Treasury yield, daily levels ──────────────────────────────────
dgs2 <- pull("DGS2", DGS2_START, DGS2_END) |>
  dplyr::mutate(series = "DGS2")

# FRED mirrors the H.15 release with a one-business-day (holiday-extended) lag.
# Backfill any missing recent days from the primary source: the Treasury daily
# par yield curve ("2 Yr" column), which DGS2 reproduces.
treasury_url <- paste0(
  "https://home.treasury.gov/resource-center/data-chart-center/interest-rates/",
  "daily-treasury-rates.csv/2026/all",
  "?type=daily_treasury_yield_curve&field_tdr_date_value=2026&page&_format=csv"
)
tsy <- tryCatch(read.csv(treasury_url, check.names = FALSE), error = function(e) NULL)
if (!is.null(tsy) && "2 Yr" %in% names(tsy)) {
  extra <- data.frame(
    date  = as.Date(tsy$Date, format = "%m/%d/%Y"),
    value = as.numeric(tsy[["2 Yr"]])
  ) |>
    dplyr::filter(date > max(dgs2$date), date <= DGS2_END, !is.na(value)) |>
    dplyr::mutate(series = "DGS2")
  if (nrow(extra) > 0) {
    cat(sprintf("  DGS2: %d day(s) backfilled from Treasury par yield curve (%s)\n",
                nrow(extra), paste(extra$date, collapse = ", ")))
    dgs2 <- dplyr::bind_rows(dgs2, extra) |> dplyr::arrange(date)
  }
}

# ── fig2: PCE decomposition, year-over-year ────────────────────────────────────
pcepi <- pull("PCEPI", MONTHLY_START, MONTHLY_END, units = "pc1") |>
  dplyr::mutate(series = "PCEPI")
pcepilfe <- pull("PCEPILFE", MONTHLY_START, MONTHLY_END, units = "pc1") |>
  dplyr::mutate(series = "PCEPILFE")
energy <- pull("DNRGRG3M086SBEA", MONTHLY_START, MONTHLY_END, units = "pc1") |>
  dplyr::mutate(series = "DNRGRG3M086SBEA")

# ── fig3: payrolls (first difference) + average hourly earnings YoY ───────────
# Pull one extra month so the first difference is defined at MONTHLY_START.
payems <- pull("PAYEMS", MONTHLY_START %m-% months(1), MONTHLY_END, units = "lin") |>
  dplyr::arrange(date) |>
  dplyr::mutate(value = value - dplyr::lag(value)) |>
  dplyr::filter(date >= MONTHLY_START, !is.na(value)) |>
  dplyr::mutate(series = "PAYEMS")

ahe <- pull("CES0500000003", MONTHLY_START, MONTHLY_END, units = "pc1") |>
  dplyr::mutate(series = "CES0500000003")

writeLines(
  c(paste("FRED_VINTAGE:", FRED_VINTAGE),
    paste("Pulled:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
    "Series:", archived_series),
  file.path(ARCHIVE_DIR, "VINTAGE.txt")
)

# ── merge, save ─────────────────────────────────────────────────────────────
df <- dplyr::bind_rows(dgs2, pcepi, pcepilfe, energy, payems, ahe) |>
  dplyr::select(date, series, value) |>
  dplyr::arrange(series, date)

write.csv(df, file.path(DIR_DATA, "note_export.csv"), row.names = FALSE)
saveRDS(df, file.path(DIR_DATA, "note_export.rds"))

cat(sprintf("  csv -> output/data/note_export.csv (%d rows, %d series)\n",
            nrow(df), dplyr::n_distinct(df$series)))
message("01_data.R done.")
