# Aplicación Shiny - Rendimientos Agrícolas

Aplicación interactiva desarrollada en R para visualizar la relación entre la superficie sembrada y la superficie cosechada por campaña según cultivo, con manejo de valores faltantes.

## Requisitos y ejecución
1. Descargar `app.R` y `Rendimientos_decada.xlsx` en la misma carpeta.
2. Instalar los paquetes necesarios en R (si aún no están instalados):
   ```r
   install.packages(c("shiny", "readxl", "ggplot2", "dplyr"))
Ejecutar la aplicación desde la consola R con:
shiny::runApp()
