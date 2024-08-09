### Interactive PSP Forecast Result Explorer ###

suppressPackageStartupMessages({
  library(shiny)
  library(leaflet)
  library(dplyr)
  library(readr)
})

current_forecast <- read_csv("https://github.com/BigelowLab/pspforecast/raw/master/inst/forecastdb/current_forecast.csv")

ui <- fluidPage(
    titlePanel("Experimental Maine PSP 4-10 Day Forecast"),
    mainPanel(
      verticalLayout(
        leafletOutput("current_forecast"))
    )
)

server <- function(input, output) {
    
    output$current_forecast <- renderLeaflet({
        pal <- colorNumeric(c("dimgray","gold", "orange", "red"), 0:3)
        
        leaflet() |>
            setView(lng=-68.5,lat = 44, zoom = 7) |>
            addTiles(group= "Default Background") |>
            #addProviderTiles("Esri.NatGeoWorldMap") |>
            addCircleMarkers(data=current_forecast,
                             lng = ~lon,
                             lat = ~lat,
                             popup = paste(sep= "<br>",
                                           paste("<b> Location: <b>", current_forecast$name),
                                           paste("<b> Location ID: <b>", current_forecast$location),
                                           paste("<b> Forecast Window Start Date: <b>", current_forecast$forecast_start_date),
                                           paste("<b> Forecast Window End Date: <b>", current_forecast$forecast_end_date),
                                           paste("<b> Probability of Closure-level Toxicity: <b>", current_forecast$p_3, "%", sep="")),
                             color = ~pal(predicted_class)) |>
            addLegend(position = "bottomright", 
                      title = "Predicted Toxicity Class",
                      colors = c("dimgray", "gold", "orange", "red"), 
                      labels = c("Low", "Medium", "High", "Closure-level"))
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
