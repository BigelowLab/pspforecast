#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(pspforecast)




#' Make a confusion matrix for predictions made during experimental forecast season
#' 
#' @param results a list of predictions from the season matched with actual measurements
#' @return confusion matrix
#' 
#' 
plot_season <- function(results) {
    
    total_predictions <- nrow(results)
    
    correct <- results %>% 
        dplyr::filter(predicted_class == class) %>% 
        nrow()
    
    accuracy <- round(correct/total_predictions, digits=3) *100
    
    closures <- results %>% 
        dplyr::filter(class == 3) %>% 
        nrow()
    
    correct_closures <- results %>% 
        dplyr::filter(predicted_class == 3 & class == 3) %>% 
        nrow()
    
    fn <- results %>% 
        dplyr::filter(class !=3 & predicted_class == 3) %>% 
        nrow()
    
    fp <- results %>% 
        dplyr::filter(class == 3 & predicted_class != 3) %>% 
        nrow()
    
    tp <- correct_closures
    
    tn <- results %>% 
        dplyr::filter(class != 3 & predicted_class != 3) %>% 
        nrow()
    
    sensitivity <- tp/tp+fn
    
    specificity <- tn/tn+fp
    
    closure_accuracy <- (tp+tn)/(tp+tn+fp+fn)
    
    num_levels <- 4
    levels <- seq(from=0, to=(num_levels-1))
    
    cm <- as.data.frame(table(predicted = factor(results$predicted_class, levels), actual = factor(results$class, levels)))
    
    confusion_matrix <- ggplot2::ggplot(data = cm,
                                        mapping = ggplot2::aes(x = .data$predicted, y = .data$actual)) +
        ggplot2::geom_tile(ggplot2::aes(fill = log(.data$Freq+1))) +
        ggplot2::geom_text(ggplot2::aes(label = sprintf("%1.0f", .data$Freq)), vjust = 1, size=8) +
        ggplot2::scale_fill_gradient(low = "white", 
                                     high = "blue") +
        ggplot2::labs(x = "Predicted Classifications", 
                      y = "Actual Classifications", 
                      title=paste("2021 PSP Forecast Performance"),
                      subtitle=paste("Accuracy:", accuracy, "%", sep = " "),
                      caption=paste(Sys.Date())) +
        ggplot2::theme_linedraw() +
        ggplot2::theme(axis.text=  ggplot2::element_text(size=14),
                       axis.title= ggplot2::element_text(size=14,face="bold"),
                       title =     ggplot2::element_text(size = 14, face = "bold"),
                       legend.position = "none") 
    
    return(confusion_matrix)
}

predictions <- pspforecast::read_forecast()
psp <- pspdata::read_psp_data()

results <- add_forecast_results(predictions, psp)

confusion_matrix <- plot_season(results)


# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("2021 Experimental PSP Forecast"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           tabsetPanel(
               tabPanel("Last Forecast", dataTableOutput("last_forecast")),
               tabPanel("All Forecasts", dataTableOutput("results")),
               tabPanel("Confusion Matrix", plotOutput("confusion_matrix"))
           )
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$last_forecast <- renderDataTable({
        pspforecast::read_forecast(new_only = TRUE)
    })
    output$results <- renderDataTable({
        add_forecast_results(pspforecast::read_forecast())
    })
    output$confusion_matrix <- renderPlot({
        plot_season(results)
        
    })

}

# Run the application 
shinyApp(ui = ui, server = server)
