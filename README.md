# Fed Reaction Note

Replication repository for the market note [*Calibrated to the Headline: Two Prints and the
Path That Moved Between Them*](https://nikkhosravipour.com/post/calibrated-to-the-headline).

R pulls daily and monthly macro series from FRED and produces Chart.js widgets and static
PNG figures tracing how the 2-year Treasury yield repriced across the June 2026 CPI, FOMC,
PCE, and payrolls prints, and how the inflation and labor-market data underneath that
repricing evolved.

## Data vintage

FRED revises `PCEPI`, `PCEPILFE`, `DNRGRG3M086SBEA`, `PAYEMS`, and `CES0500000003` with
each release and subsequent benchmark revisions. Results reproduce exactly against the
vintage retrieved for the published note. The DGS2 window is locked to 2026-06-01 through
2026-07-03 in `R/config.R` (`DGS2_START`, `DGS2_END`); the monthly series run from
2024-01-01 through whatever FRED reports as latest at pull time (`MONTHLY_START`,
`MONTHLY_END`).

`R/config.R` also pins a `FRED_VINTAGE` (realtime-as-of date) passed as
`realtime_start`/`realtime_end` on every FRED pull, with the raw response archived under
`data-raw/fred/<FRED_VINTAGE>/`. The published figures predate this pin — they reflect
whatever FRED reported at publication time, not `FRED_VINTAGE`. Re-running `R/01_data.R`
reproduces the FRED state as of `FRED_VINTAGE`, which will diverge from the published
numbers as FRED revises these series.

## Requirements

- R (≥ 4.0); packages: `fredr`, `dplyr`, `zoo`, `lubridate`, `jsonlite`
- A free FRED API key — https://fredaccount.stlouisfed.org/apikeys

## Setup

```bash
cp .Renviron.example .Renviron   # edit and paste your FRED_API_KEY
```

R loads `.Renviron` from the project root automatically.

## Run

```bash
Rscript run_all.R
```

Run from the repo root; `run_all.R` errors if called from a subdirectory. It prints a
key-numbers block (latest PCE/payroll/AHE readings, DGS2 closes around each event) for use
in prose.

## FRED series

| Series ID | Figure | Transformation |
|---|---|---|
| `DGS2` | fig1 | Levels, daily, 2026-06-01 to 2026-07-03 |
| `PCEPI` | fig2 | Year-over-year % (`pc1`), monthly |
| `PCEPILFE` | fig2 | Year-over-year % (`pc1`), monthly |
| `DNRGRG3M086SBEA` | fig2 | Year-over-year % (`pc1`), monthly |
| `PAYEMS` | fig3 | Monthly first difference, thousands |
| `CES0500000003` | fig3 | Year-over-year % (`pc1`), monthly |

DGS2 has no weekend/holiday observations; the fig1 x-axis is built from observed trading
days only, and each event flag (CPI, FOMC, PCE, NFP) is mapped to the nearest observed date
at or after the event date.

## Layout

| Script | Role |
|---|---|
| `R/config.R` | Packages, FRED key, output paths, sample windows, event dates |
| `R/01_data.R` | FRED pulls → `output/data/note_export.{csv,rds}` (tidy: date, series, value) |
| `R/02_export_charts.R` | Chart.js widgets (`output/widgets/*.html`, `*.embed.md`) + PNG figures (`output/figures/*.png`) |
| `run_all.R` | Orchestrates 01 → 02, prints the key-numbers block |

## Embedding

Widgets follow the personal.site embed contract (Chart.js 4.4.1 from jsDelivr only, no
hardcoded nonce, no inline `on*=` attributes, theme via `is-light` class on `<html>`). Paste
the `*.embed.md` contents (already fenced in ` ```html-embed `) directly into a post's
markdown body. The `*.html` files are the same fragment unfenced, for local preview.

## License

Code, text and figures: CC-BY-4.0 (see `LICENSE`). Source data is public, served by
[FRED](https://fred.stlouisfed.org/) and subject to its terms; the archived raw pulls under
`data-raw/fred/` are redistributed on that basis.
