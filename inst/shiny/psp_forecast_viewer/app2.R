### Interactive PSP Forecast Result Explorer ###


library(shiny)
library(leaflet)

library(dplyr)
library(plotly)
library(ggplot2)


library(pspforecast)


### Data for shiny app ###

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

n_predictions <- c(nrow(predictions21), nrow(predictions22))

current_forecast <- read_forecast(season="2022", new_only = TRUE)


dummy <- read_forecast(season="2022", shiny=TRUE) |> 
    filter(between(date, as.Date("2022-05-22"), as.Date("2022-05-25")))

### Shiny App ###

ui <- fluidPage(
    titlePanel("Interactive PSP Forecast Results Explorer"),
    tabsetPanel(
        tabPanel("Seasonal",
                 titlePanel("Seasonal Results"),
                 sidebarLayout(
                     position="right",
                     sidebarPanel(
                         h3("Select a season"),
                         selectInput("season",
                                     "Season:",
                                     c("2021", "2022"))
                     ),
                 mainPanel(verticalLayout(
                     htmlOutput("season_predictions"),
                     h3("Closure risk vs measured toxicity"),
                     plotlyOutput("seasonalScatter"),
                     h3("Confusion Matrix"),
                     plotOutput("seasonalConfusion",
                                width="80%"))
                 ))
        ),
        tabPanel("Weekly",
                 titlePanel("Weekly Results"),
                 
                 sidebarLayout(
                     position="right",
                     sidebarPanel(
                         h3("Select a week and season"),
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
                         leafletOutput("forecast_map"),
                         h3("Closure risk vs measured toxicity"),
                         plotlyOutput("scatter"),
                         h3("Confusion Matrix"),
                         plotOutput("confusion_matrix",
                                    width="80%"))
                     )
                 )
        ),
        tabPanel("Current Forecast",
                 titlePanel("Experimental Coastal Maine Shellfish PSP Toxicity 4-10 Day Forecast"),
                 mainPanel(
                     verticalLayout(
                         leafletOutput("current_forecast")))
                 )
    )
)

server <- function(input, output) {
    
    output$season_predictions <- renderUI({
        
        results <- predictions |>
            filter(season == input$season)
        
        a <- paste("Total predictions made:", n_predictions[as.numeric(input$season)-2020], sep=" ")
        b <- paste("Measurable predictions:", nrow(results), sep=" ")
        HTML(paste(a, b, sep="<br/>"))
    })
    
    output$seasonalScatter <- renderPlotly({
        results <- predictions |>
            filter(season == input$season)
        
        pal <- c("red", "blue")
        
        plot_ly(data=results, 
                x=~prob_3, 
                y=~toxicity,
                #color=~correct,
                #colors = pal,
                type="scatter",
                mode="markers",
                text=~paste("Location:", location, "<br>", "Date:", date, "<br>", "Predicted Class:", predicted_class, "<br>", "Actual Class", class)) |>
          add_lines(y=80) |>
            layout(#shapes=add_line(80),
                #legend=list(title=list(text='<b> Prediction was correct </b>')),
                xaxis = list(title = list(text ='<b>Predicted Probability of Closure-level Toxicity (%)</b>')),
                yaxis = list(title = list(text ='<b>Toxicity Measured During Forecast Period (units)</b>')))
    })
    
    output$seasonalConfusion <- renderPlot({
        results <- predictions |>
            filter(season == input$season)
        
        num_levels <- 4
        levels <- seq(from=0, to=(num_levels-1))
        
        cm <- as.data.frame(table(predicted = factor(results$predicted_class, levels), actual = factor(results$class, levels)))
        
        ggplot2::ggplot(data = cm,
                        mapping = ggplot2::aes(x = .data$predicted, y = .data$actual)) +
            ggplot2::geom_tile(ggplot2::aes(fill = log(.data$Freq+1))) +
            ggplot2::geom_text(ggplot2::aes(label = sprintf("%1.0f", .data$Freq)), vjust = 1, size=8) +
            ggplot2::scale_fill_gradient(low = "white", 
                                         high = "blue") +
            ggplot2::labs(x = "Predicted Classifications", 
                          y = "Actual Classifications") +
            ggplot2::theme_linedraw() +
            ggplot2::theme(axis.text=  ggplot2::element_text(size=14),
                           axis.title= ggplot2::element_text(size=14,face="bold"),
                           title =     ggplot2::element_text(size = 14, face = "bold"),
                           legend.position = "none") 
    })
    
    output$forecast_map <- renderLeaflet({
        results <- predictions |>
            filter(season == input$season,
                   season_week == input$week) # How can I only make this call once?
        
        pal <- colorNumeric(c("red", "blue"), 0:1)
        
        leaflet() |>
            setView(lng=-68.5,lat = 44, zoom = 7) |>
            #addTiles(group= "Default Background") |>
            addProviderTiles("Esri.NatGeoWorldMap") |>
            addCircleMarkers(data=results,
                             lng = ~lon,
                             lat = ~lat,
                             popup = paste(sep= "<br>",
                                           paste("<b> Location: <b>", results$name),
                                           paste("<b> Class 0 Prob: <b>", round(results$prob_0)),
                                           paste("<b> Class 1 Prob: <b>", round(results$prob_1)),
                                           paste("<b> Class 2 Prob: <b>", round(results$prob_2)),
                                           paste("<b> Class 3 Prob: <b>", round(results$prob_3)),
                                           paste("<b> Predicted Class: <b>", round(results$predicted_class)),
                                           paste("<b> Actual Class: <b>", results$class),
                                           paste("<b> Measured Toxicity: <b>", round(results$toxicity)),
                                           paste("<b> Last Measurement: <b>", results$date),
                                           paste("<b> New Measurement: <b>", results$measurement_date)),
                             color = ~pal(correct))
    })
    
    output$scatter <- renderPlotly({
        results <- predictions |>
            filter(season == input$season,
                   season_week == input$week)
        
        pal <- c("red", "blue")
        
        plot_ly(data=results, 
                x=~prob_3, 
                y=~toxicity,
                color=~correct,
                colors = pal,
                type="scatter",
                mode="markers",
                text=~paste("Location:", location, "<br>", "Date:", date, "<br>", "Predicted Class:", predicted_class, "<br>", "Actual Class", class)) |>
            layout(#shapes=hline(80),
                   legend=list(title=list(text='<b> Prediction was correct </b>')),
                   xaxis = list(title = list(text ='Predicted Probability of Closure-level Toxicity (%)')),
                   yaxis = list(title = list(text ='Toxocity Measured During Forecast Period (units)')))
    })
    
    output$confusion_matrix <- renderPlot({
        results <- predictions |>
            filter(season == input$season,
                   season_week == input$week)
        
        num_levels <- 4
        levels <- seq(from=0, to=(num_levels-1))
        
        cm <- as.data.frame(table(predicted = factor(results$predicted_class, levels), actual = factor(results$class, levels)))
        
         ggplot2::ggplot(data = cm,
                                            mapping = ggplot2::aes(x = .data$predicted, y = .data$actual)) +
            ggplot2::geom_tile(ggplot2::aes(fill = log(.data$Freq+1))) +
            ggplot2::geom_text(ggplot2::aes(label = sprintf("%1.0f", .data$Freq)), vjust = 1, size=8) +
            ggplot2::scale_fill_gradient(low = "white", 
                                         high = "blue") +
            ggplot2::labs(x = "Predicted Classifications", 
                          y = "Actual Classifications") +
            ggplot2::theme_linedraw() +
            ggplot2::theme(axis.text=  ggplot2::element_text(size=14),
                           axis.title= ggplot2::element_text(size=14,face="bold"),
                           title =     ggplot2::element_text(size = 14, face = "bold"),
                           legend.position = "none") 
    })
    
    output$current_forecast <- renderLeaflet({
        pal <- colorNumeric(c("dimgray","gold", "orange", "red"), 0:3)
        
        leaflet() |>
            setView(lng=-68.5,lat = 44, zoom = 7) |>
            #addTiles(group= "Default Background") |>
            addProviderTiles("Thunderforest.Landscape") |>
            addCircleMarkers(data=dummy,
                             lng = ~lon,
                             lat = ~lat,
                             popup = paste(sep= "<br>",
                                           paste("<b> Location: <b>", dummy$name),
                                           paste("<b> Location ID: <b>", dummy$location),
                                           paste("<b> Forecast Window Start Date: <b>", dummy$forecast_start_date),
                                           paste("<b> Forecast Window End Date: <b>", dummy$forecast_end_date),
                                           paste("<b> Probability of Closure-level Toxicity: <b>", dummy$p_3)),
                             color = ~pal(predicted_class)) |>
            addLegend(position = "bottomright", 
                      title = "Predicted Toxicity Class",
                      colors = c("dimgray", "gold", "orange", "red"), 
                      labels = c("Low", "Medium", "High", "Closure-level"))
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
