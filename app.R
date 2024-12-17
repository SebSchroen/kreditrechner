library(shiny)
library(shinydashboard)
library(tidyverse)
library(lubridate)

ui <- dashboardPage(
  dashboardHeader(title = "Kreditrechner"),
  dashboardSidebar(
    numericInput("EK", "Eigenkapital", 75000, min = 0, max = 10^6, step = 1000),
    
    numericInput("Hauspreis", "Hauspreis", 150000, min = 0, max = 10^6, step = 1000),
    numericInput("NK_percentage", "Nebenkosten (% vom Hauspreis):", 10.57, min = 0, max = 100, step = 0.01),
    numericInput("Tilgungsrate", "Tilgungsrate in %", 1.0, min = 0, max = 10, step = 0.1),
    radioButtons("Zinsbindung", label = "Zinsbindungsdauer",
            #     choices = list("5 Jahre" = 5, "10 Jahre" = 10, "15 Jahre" = 15), 
                 choiceNames = c("5 Jahre", "10 Jahre", "15 Jahre"),
                 choiceValues = c(5,10,15),
                 selected = 10),
    numericInput("Interest_rate", "Zinssatz eff. p.a. (%):", 4.0, min = 0, max = 10, step = 0.01)
  ),
  dashboardBody(
    fluidRow(
            valueBoxOutput("kreditbetrag", width = 3),
            valueBoxOutput("rate", width = 2),
            valueBoxOutput("laufzeit", width = 3),
            valueBoxOutput("restschuld", width = 4),
            
            
    ),
    
    fluidRow(
      box(plotOutput("remainingDebtPlot"), width = 10),
      box(plotOutput("rateComponentsPlot"), width = 10)
    )
  )
)

server <- function(input, output) {
  
  # Function to calculate the Tilgungsplan
  calculateTilgungsplan <- reactive({
    H <- input$Hauspreis
    NK <- (input$NK_percentage)/100 * H
    EK <-  input$EK
    P <- H + NK - EK
    p <- input$Tilgungsrate/100
    fix_r <- as.numeric(input$Zinsbindung)
    print(fix_r)
    r <- input$Interest_rate / 100
    C <- (r * P + p * P) / 12
    r_m <- (1 + r)^(1/12) - 1
    t <- -1 * log(1 - P * r_m / C) / log(1 + r_m)
    
    dates <- seq(ceiling_date(today(), "month"), ceiling_date(today(), "month") + months(ceiling(t)), by = '1 month')
    
    plan <- tibble(
      t = 0:ceiling(t),
      t_y = t / 12,
      Datum = dates,
      Rate = C,
      Schuld = NA
    )
    plan$Schuld[1] <- P
    plan$Rate[1] <- 0
    
    for (i in 2:(ceiling(t) + 1)) {
      plan$Schuld[i] <- pmax((1 + r_m) * plan$Schuld[i - 1] - plan$Rate[i], 0)
    }
    
    plan$Zins <- r_m * plan$Schuld
    plan$Tilgung <- plan$Rate - plan$Zins
    plan$Zins[1] <- NA
    plan$Tilgung[1] <- NA
    
    ablauf_zinsbindung  <- ceiling_date(today(), "month") + months(fix_r * 12)
    restschuld <- plan %>% 
      filter(Datum ==ablauf_zinsbindung) %>% 
      pull(Schuld)
    
    results <-  list(plan = plan, 
                     rate = C,
                     laufzeit = t,
                     kreditbetrag = P,
                     restschuld = restschuld,
                     ablauf_zinsbindung = ablauf_zinsbindung)
    return(results)
  })
  
  output$remainingDebtPlot <- renderPlot({
    plan <- calculateTilgungsplan()$plan # Call reactive function to get the plan
    
    
    ggplot(data = plan, aes(x = Datum, y = Schuld)) + 
      geom_line() +
      labs(x = "Datum", y = "Restschuld") +
      theme_minimal() +
      geom_vline(xintercept = calculateTilgungsplan()$ablauf_zinsbindung, linetype = "dashed")
  })
  
  output$rateComponentsPlot <- renderPlot({
    plan <- calculateTilgungsplan()$plan # Use the same plan data
    
    plan %>%  
      select(Datum, Zins, Tilgung) %>% 
      pivot_longer(cols = c(Zins, Tilgung), names_to = "Name", values_to = "Wert") %>% 
      ggplot(aes(x = Datum, y = Wert, fill = Name)) +
      geom_bar(stat = "identity", position = "stack") +
      labs(fill = NULL, y = "Rate") + 
      theme_minimal() +
      theme(legend.position = "bottom") + 
      scale_fill_brewer(palette = "Paired")
  })
  output$kreditbetrag <- renderValueBox({
    valueBox(
      paste0(calculateTilgungsplan()$kreditbetrag, " €"), icon = icon("money-bill"),
      "Kreditbetrag",
      color = "blue"
    )
  })
  output$laufzeit <- renderValueBox({
    valueBox(
      "Laufzeit", paste0(ceiling(calculateTilgungsplan()$laufzeit/12), " Jahre und ",
                         ceiling(calculateTilgungsplan()$laufzeit%%12), " Monate"), 
      color = "blue",
      icon = icon("calendar")
    )
  })
  output$rate <- renderValueBox({

      valueBox(
      paste0(round(calculateTilgungsplan()$rate,2), " €"),
      "monatl. Rate",
      color = "blue",
      icon = icon("money-bill")
    )
  })
  output$restschuld <- renderValueBox({
    print(calculateTilgungsplan()$restschuld)
    valueBox(
      paste0(round(calculateTilgungsplan()$restschuld,0), " €"), 
      "Restschuld nach Zinsbindung",
      color = "blue",
      icon = icon("money-bill")
    )
  })
}

shinyApp(ui, server)