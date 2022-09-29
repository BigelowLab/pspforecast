

library(shiny)
library(leaflet)

library(dplyr)
library(plotly)

library(pspforecast)


### Data for shiny app ##

psp <- pspdata::read_psp_data()

predictions21 <- read_forecast(season="2021")
results21 <- add_forecast_results(predictions21, psp) |>
    mutate(season_week = as.numeric(format(as.Date(date), format="%W"))-14, #need to define number of weeks to offset - different starting week for each season
           season = 2021) |>
    relocate(predicted_class, .after=prob_3)

predictions22 <- read_forecast(season="2022")
results22 <- add_forecast_results(predictions22, psp) |>
    mutate(season_week = as.numeric(format(as.Date(date), format="%W"))-13,
           season = 2022) |>
    rename(prob_0 = p_0,
           prob_1 = p_1,
           prob_2 = p_2,
           prob_3 = p_3) |>
    select(-ensemble_n, -p3_sd, -p_3_max, -p_3_min)


predictions <- bind_rows(results21, results22)

#confusion_matrix <- plot_season(results)


### Shiny App ###
ui <- fluidPage(
    titlePanel("Experimental PSP Forecast Results Explorer"),

    sidebarLayout(
        sidebarPanel(
            selectInput("season",
                        "Season:",
                        c("2021", "2022")),
            sliderInput("week",
                        "Week of Season:",
                        min = 1,
                        max = 22,
                        value = 1)
        ),
        mainPanel(verticalLayout(
            leafletOutput("forecast"),
            plotlyOutput("scatter")
            )
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$forecast <- renderLeaflet({
        results <- predictions |>
            filter(season == input$season,
                   season_week == input$week) # How can I only make this call once?
        
        forecast <- leaflet() |>
            setView(lng=-68.5,lat = 44, zoom = 7) |>
            addTiles(group= "Default Background") |>
            addCircleMarkers(data=results,
                             lng = ~lon,
                             lat = ~lat)
    })
    
    output$scatter <- renderPlotly({
        results <- predictions |>
            filter(season == input$season,
                   season_week == input$week)
        
        plot_ly(data=results, 
                x=~prob_3, 
                y=~toxicity,
                #color=~correct,
                #colors = pal,
                type="scatter",
                mode="markers",
                text=~paste("Location:", location, "<br>", "Date:", date, "<br>", "Predicted Class:", predicted_class, "<br>", "Actual Class", class)) |>
            layout(#shapes=hline(80),
                   legend=list(title=list(text='<b> Prediction was correct </b>')),
                   xaxis = list(title = list(text ='Predicted Probability of Closure-level Toxicity (%)')),
                   yaxis = list(title = list(text ='Toxocity Measured During Forecast Period (units)')))
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
