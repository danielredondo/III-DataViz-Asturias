# Para poder usar la fuente de Formula 1 en el servidor Shiny
# dir.create('~/.fonts')
# file.copy("www/Formula1-Regular.ttf", "~/.fonts")
# system('fc-cache -f ~/.fonts')

# Carga de paquetes
library(dplyr)
library(shiny)
library(shinythemes)
library(shinyWidgets)
library(png)

ui <- fluidPage(
  
  # CSS
  tags$style(HTML('h1 {font-family:"Formula1 Display"}')),
  tags$style(HTML('h4 {font-family:"Formula1 Display"}')),
  tags$style(HTML('i {font-family:"Formula1 Display"}')),
  tags$style(HTML('b {font-family:"Formula1 Display"}')),
  
  theme = shinytheme("readable"), # themeSelector(),
  titlePanel(tags$h1(tags$b("III Data Viz Contest, Asturias R user group ")),
             windowTitle = "F1"
  ),
  tags$h4("Web app by ", tags$a("Daniel Redondo.",
                                                     href = "http://www.danielredondo.com"
  )),
  tags$i("This web application shows the telemetry data of the Formula 1 cars
          during the 2021 season. The X and Y coordinates of each car
          are represented as points, with one point for every second."),
  br(),
  tags$b("The code of this app is available in ", tags$a("this link",
                                         href = "https://gist.github.com/danielredondo/06133eb945c43771d79b2fa4a664cb0e"),
         "and the code that generated the images is available in ", tags$a("this link", href = "http://www.danielredondo.com")
         ),
  hr(),
  tags$h4("Select the driver"),
  selectInput(
    inputId = "driver",
    label = "",
    choices = c(
      "All the drivers" = "ALL",
      "Alonso" = "ALO", "Bottas" = "BOT", "Gasly" = "GAS",
      "Giovinazzi" = "GIO", "Hamilton" = "HAM", "Latifi" = "LAT",
      "Leclerc" = "LEC", "Mazepin" = "MAZ", "Norris" = "NOR",
      "Ocon" = "OCO", "Pérez" = "PER", "Räikkönen" = "RAI",
      "Ricciardo" = "RIC", "Russell" = "RUS", "Sainz" = "SAI",
      "Schumacher" = "MSC", "Stroll" = "STR", "Tsunoda" = "TSU",
      "Verstappen" = "VER", "Vettel" = "VET"
    ),
    selected = "ALL"
  ),
  hr(),
  plotOutput("imagen", width = "100%")
)

server <- function(input, output) {
  
  output$imagen <- renderImage({
    filename <- normalizePath(file.path("./circuits",
                                        paste("circuits_", input$driver, ".png", sep="")))
        list(src = filename,
         width = "100%")
  },
  deleteFile = F
  )
  
}

shinyApp(ui = ui, server = server)
