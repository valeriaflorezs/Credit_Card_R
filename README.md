# Credit_Card_R

Libro interactivo (R bookdown) con el análisis exploratorio del dataset *Default of Credit Card Clients* (UCI).

## Compilar

```r
install.packages(c("bookdown", "tidyverse", "readxl", "plotly", "htmltools",
                   "htmlwidgets", "jsonlite", "e1071", "knitr", "skimr"))
bookdown::render_book("index.Rmd", "bookdown::gitbook")
```

El resultado queda en `docs/` (abrir `docs/index.html`).
