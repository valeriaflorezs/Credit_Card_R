# =============================================================================
# eda_widgets.R
# Equivalente en R de `src/eda_widgets.py`:
#   - Paleta navy/gold y estilo Plotly personalizado (ng_theme)
#   - show_with_interpretation(): gráfico Plotly + tarjeta de interpretación
#     con dos modos ("Interpretación Básica" / "Interpretación Técnica") que
#     cambia junto con el menú desplegable de la figura.
#
# Todo corre en el navegador (HTML + JS), así que funciona en R Markdown
# (html_document), Quarto, Jupyter Book con salida HTML, etc.
#
# Uso:
#   source("../R/eda_widgets.R")
#   show_with_interpretation(fig, basic_text, tech_text)
#
#   * Gráfico simple:           basic_text / tech_text = un solo string.
#   * Gráfico con dropdown:     basic_text / tech_text = vectores (o listas)
#                               NOMBRADOS con las mismas etiquetas que los
#                               botones del menú de Plotly (label = nombre).
# =============================================================================

suppressPackageStartupMessages({
  library(plotly)
  library(htmltools)
  library(htmlwidgets)
  library(jsonlite)
})

# ---- Paleta ------------------------------------------------------------------
DEEP_NAVY <- "#0C1A41"
NAVY      <- "#1B3071"
PALE_GOLD <- "#E8C871"
WARM_GOLD <- "#C9930C"
CREAM     <- "#F9F0DE"

NG_COLORWAY  <- c(DEEP_NAVY, WARM_GOLD, NAVY, PALE_GOLD, "#7A8AA8")
DIVERGING_NG <- list(c(0, NAVY), c(0.5, CREAM), c(1, WARM_GOLD))  # para heatmaps (plotly colorscale)
.NG_GRID     <- "#EBF0F8"  # color de rejilla de la plantilla "plotly_white"

# ---- Estilo Plotly (equivalente a pio.templates["navy_gold"]) ----------------
# Fondo del lienzo blanco, área de trazado CREAM, tipografía Arial en DEEP_NAVY
# y ciclo de colores navy/gold. `axes` permite extender la rejilla a ejes
# secundarios (p. ej. c("xaxis","yaxis","xaxis2","yaxis2") en subplots).
ng_theme <- function(p, axes = c("xaxis", "yaxis")) {
  p <- plotly::layout(
    p,
    paper_bgcolor = "white",
    plot_bgcolor  = CREAM,
    font          = list(color = DEEP_NAVY, family = "Arial"),
    colorway      = NG_COLORWAY
  )
  for (ax in axes) {
    args <- list(p)
    args[[ax]] <- list(gridcolor = .NG_GRID, zerolinecolor = .NG_GRID, linecolor = .NG_GRID)
    p <- do.call(plotly::layout, args)
  }
  plotly::config(p, displaylogo = FALSE)
}

# ---- Utilidades internas -------------------------------------------------------
.ewid_env <- new.env(parent = emptyenv())
.ewid_env$n <- 0L

.ewid_next_uid <- function() {
  .ewid_env$n <- .ewid_env$n + 1L
  sprintf("ewid_%04d", .ewid_env$n)
}

# Acepta un string, un vector nombrado o una lista nombrada y los unifica.
.ewid_normalize <- function(basic_text, tech_text) {
  b <- unlist(basic_text)
  t <- unlist(tech_text)
  if (is.null(names(b)) || is.null(names(t))) {
    if (length(b) != 1L || length(t) != 1L) {
      stop("Para varias columnas, basic_text y tech_text deben ser vectores/listas NOMBRADOS ",
           "(nombre = etiqueta del botón del menú desplegable).", call. = FALSE)
    }
    return(list(
      keys   = "__single__",
      single = TRUE,
      texts  = list(`__single__` = list(basica = as.character(b), tecnica = as.character(t)))
    ))
  }
  keys  <- names(b)
  texts <- lapply(keys, function(k) {
    list(basica  = as.character(b[[k]]),
         tecnica = if (k %in% names(t)) as.character(t[[k]]) else "")
  })
  names(texts) <- keys
  list(keys = keys, single = FALSE, texts = texts)
}

# ---- Función principal ---------------------------------------------------------
#' Renderiza juntos un gráfico Plotly y su tarjeta de interpretación.
#'
#' @param plot_obj      Objeto plotly (htmlwidget).
#' @param basic_text    Texto de la interpretación básica (string, o vector
#'                      nombrado por etiqueta de botón si hay dropdown).
#' @param tech_text     Texto de la interpretación técnica (mismo formato).
#' @param default_mode  "basica" (por defecto) o "tecnica".
#' @return Un `tagList` navegable; en un chunk de R Markdown se renderiza
#'         automáticamente (dentro de bucles/funciones, envolver con print()).
show_with_interpretation <- function(plot_obj, basic_text, tech_text,
                                     default_mode = c("basica", "tecnica")) {
  default_mode <- match.arg(default_mode)
  norm <- .ewid_normalize(basic_text, tech_text)
  uid  <- .ewid_next_uid()

  # El gráfico necesita un id fijo para que el JS pueda engancharse a sus eventos
  plot_obj$elementId <- paste0(uid, "_plot")

  btn_style <- sprintf(
    "border:1px solid %s;padding:4px 14px;cursor:pointer;font-family:Arial;font-size:13px;",
    DEEP_NAVY
  )

  card <- tags$div(
    style = sprintf(paste0(
      "max-width:850px;margin-top:6px;padding:12px 16px;background:%s;",
      "color:%s;border-left:5px solid %s;font-family:Arial;"
    ), CREAM, DEEP_NAVY, WARM_GOLD),
    tags$div(
      style = "margin-bottom:8px;",
      tags$button(id = paste0(uid, "_b_basica"), type = "button",
                  style = paste0(btn_style, "border-radius:4px 0 0 4px;"),
                  "Interpretación Básica"),
      tags$button(id = paste0(uid, "_b_tecnica"), type = "button",
                  style = paste0(btn_style, "border-radius:0 4px 4px 0;margin-left:-1px;"),
                  "Interpretación Técnica"),
      tags$span(id = paste0(uid, "_col"), style = "margin-left:12px;font-weight:bold;")
    ),
    tags$div(id = paste0(uid, "_txt"), style = "font-size:14px;line-height:1.5;")
  )

  texts_json <- as.character(jsonlite::toJSON(norm$texts, auto_unbox = TRUE))
  texts_json <- gsub("</", "<\\/", texts_json, fixed = TRUE)  # evita cerrar el <script>

  js <- paste0("
(function() {
  var texts  = ", texts_json, ";
  var single = ", tolower(as.character(norm$single)), ";
  var uid    = ", toJSON(uid, auto_unbox = TRUE), ";
  var state  = {col: ", toJSON(norm$keys[1], auto_unbox = TRUE), ", mode: ", toJSON(default_mode, auto_unbox = TRUE), "};
  var NAVY = '", DEEP_NAVY, "', CREAM = '", CREAM, "';

  function render() {
    var t = (texts[state.col] || {})[state.mode] || '';
    document.getElementById(uid + '_txt').textContent = t;
    document.getElementById(uid + '_col').textContent = single ? '' : state.col;
    ['basica', 'tecnica'].forEach(function(m) {
      var b = document.getElementById(uid + '_b_' + m);
      var on = (m === state.mode);
      b.style.background = on ? NAVY : CREAM;
      b.style.color = on ? 'white' : NAVY;
    });
  }

  ['basica', 'tecnica'].forEach(function(m) {
    document.getElementById(uid + '_b_' + m).onclick = function() { state.mode = m; render(); };
  });

  // El menú desplegable de Plotly avisa con 'plotly_buttonclicked'
  var tries = 0;
  var timer = setInterval(function() {
    var plot = document.getElementById(uid + '_plot');
    tries++;
    if (plot && typeof plot.on === 'function') {
      clearInterval(timer);
      plot.on('plotly_buttonclicked', function(ev) {
        if (ev && ev.button && Object.prototype.hasOwnProperty.call(texts, ev.button.label)) {
          state.col = ev.button.label;
          render();
        }
      });
    } else if (tries > 100) {
      clearInterval(timer);
    }
  }, 100);

  render();
})();
")

  htmltools::browsable(
    tags$div(id = paste0(uid, "_wrap"), plot_obj, card, tags$script(HTML(js)))
  )
}
