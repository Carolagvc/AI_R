library(shiny)
library(readxl)
library(ggplot2)

archivo <- if (file.exists("Rendimientos_decada.xlsx")) {
  "Rendimientos_decada.xlsx"
} else if (file.exists("Rendimiento.xlsx")) {
  "Rendimiento.xlsx"
} else {
  stop("No se encontró Rendimientos_decada.xlsx ni Rendimiento.xlsx en la carpeta de la app.")
}

datos <- read_excel(archivo)
columnas_requeridas <- c(
  "Cultivo", "Campaña", "Sup. Sembrada", "Sup. Cosechada"
)
faltan <- setdiff(columnas_requeridas, names(datos))

if (length(faltan) > 0) {
  stop("Faltan columnas necesarias en el Excel: ", paste(faltan, collapse = ", "))
}

if (!is.numeric(datos[["Sup. Sembrada"]]) ||
    !is.numeric(datos[["Sup. Cosechada"]])) {
  stop("Las columnas 'Sup. Sembrada' y 'Sup. Cosechada' deben ser numéricas.")
}

cultivos <- sort(unique(as.character(datos$Cultivo[
  !is.na(datos$Cultivo) & nzchar(trimws(as.character(datos$Cultivo)))
])))

ui <- fluidPage(
  titlePanel("Superficie sembrada y cosechada"),
  sidebarLayout(
    sidebarPanel(
      selectInput("cultivo", "Seleccioná un cultivo:", choices = cultivos),
      helpText(
        "Las filas con valores faltantes en cultivo, campaña o superficies ",
        "se excluyen del gráfico."
      )
    ),
    mainPanel(
      plotOutput("grafico", height = "500px")
    )
  )
)

server <- function(input, output, session) {
  datos_cultivo <- reactive({
    req(input$cultivo)
    datos[!is.na(datos$Cultivo) & as.character(datos$Cultivo) == input$cultivo, ]
  })

  output$grafico <- renderPlot({
    seleccion <- datos_cultivo()
    columnas_grafico <- c(
      "Campaña", "Sup. Sembrada", "Sup. Cosechada"
    )
    completos <- complete.cases(seleccion[, columnas_grafico])
    datos_grafico <- seleccion[completos, ]

    validate(need(
      nrow(datos_grafico) > 0,
      "No hay datos completos para graficar este cultivo."
    ))

    ggplot(
      datos_grafico,
      aes(
        x = `Sup. Sembrada`,
        y = `Sup. Cosechada`,
        color = Campaña
      )
    ) +
      geom_point(alpha = 0.7, size = 2) +
      labs(
        title = paste("Cultivo:", input$cultivo),
        x = "Superficie sembrada",
        y = "Superficie cosechada",
        color = "Campaña"
      ) +
      theme_minimal()
  })
}

shinyApp(ui = ui, server = server)
