# Funciones comunes de los capitulos portados desde el Jupyter Book.
# Cada capitulo define BASE (raiz del proyecto) y luego carga este archivo.

mostrar_tabla <- function(nb, archivo) {
  ruta <- file.path(BASE, "data", "outputs", nb, archivo)
  df <- utils::read.csv(ruta, check.names = FALSE, colClasses = "character",
                        na.strings = character(0), encoding = "UTF-8")
  knitr::kable(df, align = "l", row.names = FALSE)
}

# Formato de tablas como el de pandas (float_format "{:,.4f}"): decimales fijos y separador de miles.
formato_pandas <- function(df, d = 4) {
  out <- as.data.frame(lapply(df, function(x) formatC(x, format = "f", digits = d, big.mark = ",")),
                       check.names = FALSE, stringsAsFactors = FALSE)
  rownames(out) <- rownames(df)
  out
}

# Dibuja un grafico Plotly guardado como JSON plano (data y layout de la salida del notebook).
# Usa el Plotly que ya cargan los widgets del libro; si no esta disponible, lo pide al CDN.
mostrar_plotly_json <- function(archivo, nb = "00_eda") {
  ruta <- file.path(BASE, "figures", nb, archivo)
  json <- paste(readLines(ruta, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  id   <- paste0("pj_", gsub("[^A-Za-z0-9]", "_", archivo))
  js <- paste0(
    "(function(){var fig=", json, ";var el=document.getElementById('", id, "');",
    "el.style.height=((fig.layout&&fig.layout.height)||450)+'px';",
    "if(fig.layout){fig.layout.autosize=true;delete fig.layout.width;}",
    "function dibujar(){Plotly.newPlot(el,fig.data,fig.layout,fig.config);}",
    "if(typeof Plotly!=='undefined'){dibujar();}else{var s=document.createElement('script');",
    "s.src='https://cdn.plot.ly/plotly-2.35.2.min.js';s.onload=dibujar;document.head.appendChild(s);}})();")
  htmltools::tagList(
    htmltools::tags$div(id = id, class = "plotly-json", style = "width:100%;max-width:950px;"),
    htmltools::tags$script(htmltools::HTML(js))
  )
}
