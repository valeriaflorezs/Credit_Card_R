# Riesgo de Incumplimiento en Tarjetas de Crédito (Libro en R bookdown)

**Libro interactivo con el análisis exploratorio y la comparación de modelos para predecir el incumplimiento de pago de clientes de tarjetas de crédito.**

---

## Ver el libro en vivo

[![Ver libro](https://img.shields.io/badge/Ver%20Libro-Online-brightgreen?style=for-the-badge&logo=r)](https://valeriaflorezs.github.io/Credit_Card_R/)

**[Accede al libro aquí](https://valeriaflorezs.github.io/Credit_Card_R/)**

El proyecto también cuenta con un tablero interactivo: [dash-credit-kv.onrender.com](https://dash-credit-kv.onrender.com/introduccion).

---

## Descripción del Proyecto

Anticipar qué clientes de tarjeta de crédito dejarán de pagar es uno de los problemas más relevantes de la gestión de riesgo crediticio. Una entidad que concede cupos altos a clientes que luego incumplen deteriora su cartera, y una que restringe el crédito en exceso pierde ingresos. Además, métricas como el *accuracy* pueden ocultar que el modelo no detecta a los clientes realmente en riesgo.

El proyecto usa el conjunto *Default of Credit Card Clients* (30,000 clientes de un banco de Taiwán, 2005) y desarrolla el flujo completo: ETL, análisis exploratorio, modelo base de regresión logística y comparación sistemática de 112 configuraciones de modelos. Este repositorio contiene el libro en R bookdown con la portada, el marco del proyecto y el EDA interactivo con gráficos Plotly.

El libro incluye:
- Portada con el resumen del proyecto y sus autoras.
- Marco del proyecto: introducción, planteamiento del problema, hipótesis, objetivos, marco teórico y metodología.
- Análisis Exploratorio de Datos (EDA) con gráficos interactivos y su interpretación en versión básica y técnica.
- Pruebas estadísticas (Mann-Whitney, t de Welch, chi-cuadrado) y análisis de multicolinealidad (correlación y VIF).

---

## Dataset

El dataset utilizado es [Default of Credit Card Clients](https://archive.ics.uci.edu/dataset/350/default+of+credit+card+clients) del repositorio UCI Machine Learning.

> **Nota:** el archivo `default_of_credit_card_clients.xls` ya está incluido en el repositorio, en `data/raw/`. No es necesario descargarlo para ejecutar el libro.

---

## Estructura del Proyecto

```
Credit_Card_R/
├── Credit_Card_R.Rproj      # Proyecto de RStudio (abrir este archivo)
├── index.Rmd                # Portada y resumen del proyecto
├── 01_marco.Rmd             # Introducción, problema, objetivos y metodología
├── _bookdown.yml            # Orden de los capítulos y carpeta de salida
├── _output.yml              # Formato y estilo del libro
├── style.css                # Estilos personalizados
├── R/
│   └── eda_widgets.R        # Paleta y funciones para los gráficos interactivos
├── notebooks/
│   └── 00_eda.Rmd           # Capítulo del análisis exploratorio
├── data/
│   └── raw/
│       └── default_of_credit_card_clients.xls
└── docs/                    # Libro compilado (HTML), publicado en GitHub Pages
```

---

## Cómo ejecutar el proyecto en local

### Requisitos

- [R](https://cran.r-project.org/) (versión 4.x o superior).
- [RStudio](https://posit.co/download/rstudio-desktop/).
- [Git](https://git-scm.com/) (solo si vas a clonar el repositorio).

No necesitas instalar Pandoc por separado, porque viene incluido con RStudio. En Windows tampoco necesitas Rtools, ya que los paquetes se instalan ya compilados.

**1. Clonar el repositorio**

```bash
git clone https://github.com/valeriaflorezs/Credit_Card_R.git
cd Credit_Card_R
```

**2. Abrir el proyecto en RStudio**

Haz doble clic en `Credit_Card_R.Rproj`, o desde RStudio ve a *File > Open Project* y selecciónalo. Así RStudio usa la carpeta del proyecto como directorio de trabajo.

**3. Instalar las dependencias**

En la consola de RStudio ejecuta lo siguiente. La primera vez puede tardar varios minutos:

```r
options(timeout = 600)
install.packages(c("bookdown", "tidyverse", "readxl", "plotly", "htmltools",
                   "htmlwidgets", "jsonlite", "e1071", "knitr", "skimr"))
```

**4. Compilar el libro**

```r
bookdown::render_book("index.Rmd", "bookdown::gitbook")
```

También puedes usar el botón *Build > Build Book* del panel superior derecho de RStudio.

**5. Abrir el libro en el navegador**

El resultado se genera en la carpeta `docs/`. Abre el archivo `docs/index.html` con tu navegador, o ejecuta en la consola de R:

```r
browseURL("docs/index.html")
```

### Ejecutar solo el capítulo del EDA

Para trabajar un capítulo sin compilar todo el libro, abre `notebooks/00_eda.Rmd` y usa el botón *Knit*. El notebook detecta automáticamente si se ejecuta desde la raíz del proyecto o desde su propia carpeta.

---

## Solución de problemas

- **Falla la descarga de un paquete por tiempo de espera:** aumenta el límite con `options(timeout = 600)` y vuelve a ejecutar `install.packages(...)`. Retoma lo que falte.
- **Windows bloquea un archivo `.dll` al cargar un paquete ("Una directiva de Control de aplicaciones bloqueó este archivo"):** el equipo tiene una política de control de aplicaciones, como Smart App Control, que bloquea paquetes sin firma. Si el equipo es institucional, solicita a TI una excepción para la carpeta de paquetes de R y para la instalación de R.
- **No encuentra `R/eda_widgets.R` o el archivo de datos:** verifica que abriste el proyecto con `Credit_Card_R.Rproj` y que estás en la raíz del repositorio (`getwd()`).
- **El libro no refleja tus cambios:** vuelve a ejecutar `bookdown::render_book(...)`. Si borraste archivos, elimina antes la carpeta `_bookdown_files/`.

---

## Equipo

Este proyecto fue desarrollado por:

- **Katherin Barrera**, Universidad del Norte
- **Valeria Florez**, Universidad del Norte, [GitHub](https://github.com/valeriaflorezs)
