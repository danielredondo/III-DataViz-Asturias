# ---- Packages ----

library(qs)
library(dplyr)
library(ggplot2)
library(ggrepel)

# To use external fonts
library(extrafont)
# font_import()
loadfonts(device = "win")

# ---- Data import ----

telemetry <- qread(file = "f1dataR/2021/telemetry_2021.qs")
drivers   <- qread(file = "f1dataR/2021/drivers_2021.qs")
races     <- qread(file = "f1dataR/2021/races_2021.qs")

# ---- Preprocessing ----

data <- telemetry %>%
  # Join with drivers
  inner_join(drivers,  by = c("driverCode" = "code")) %>%
  # Join with races
  inner_join(races, by = c("round")) %>%
  # Extract time in a new variable
  mutate(hora = lubridate::hour(Date),
    minuto = lubridate::minute(Date),
    segundo = lubridate::second(Date)) %>%
  mutate(tiempo = round(hora * 3600 + minuto * 60 + segundo), 1) %>%
  # Group by driver, circuit and time
  group_by(driverCode, round, tiempo) %>%
  # If there are more than one observation of the same driver, circuit
  #   and time, compute the mean of coordinates X and Y
  summarise(x = mean(X),
            y = mean(Y))

# ---- Circuits, all drivers ----

seleccion <- data %>% inner_join(races, by = c("round"))

nrow(seleccion)

# Order data by race
seleccion$locality <- factor(seleccion$locality,
                             levels = races$locality,
                             labels = toupper(races$locality),
                             ordered = T)

# Graph
ggplot(data = seleccion, aes(x = x, y = y)) +
  # Add points with transparency
  geom_point(alpha = .1) +
  # One graph for each circuit
  facet_wrap(~locality, nrow = 3, ncol = 7, scales = "free", drop = F) +
  # Theme for the graph
  theme_light(base_family = "Formula1 Display-Bold") +
  theme(axis.title = element_blank(),
        axis.text = element_blank(),
        panel.grid = element_blank(),
        axis.ticks = element_blank(),
        panel.border = element_blank(),
        strip.background = element_rect(fill = "white"),
        strip.text = element_text(size = 10, face = "bold",
                                  color = "black",
                                  family = "Formula1 Display-Bold")
        ) -> g

# Save graph
ggsave("circuits/circuits_ALL.png", g, width = 10, height = 7)

# ---- Circuits by driver ----

for(i in drivers$code){

  if(i == "KUB"){
    print("Kubica - no races in telemetry")
  } else {
  
    # Join with races and drivers, and filter the specific driver
    seleccion <- data %>% 
      inner_join(races, by = c("round")) %>% 
      inner_join(drivers, by = c("driverCode" = "code")) %>% 
      filter(driverCode == i)
    
    # In the Italian Grand Prix Tsunoda did not start the race
    # https://en.wikipedia.org/wiki/2021_Italian_Grand_Prix
    if(i == "TSU"){
      seleccion <- seleccion %>% 
        filter(locality != "Monza")
    }
    
    # In the Monaco Grand Prix Tsunoda did not start the race
    # https://en.wikipedia.org/wiki/2021_Italian_Grand_Prix
    if(i == "LEC"){
      seleccion <- seleccion %>% 
        filter(locality != "Monte-Carlo")
    }
    
    # Order data by race
    seleccion$locality <- factor(seleccion$locality,
                                 levels = races$locality,
                                 labels = toupper(races$locality),
                                 ordered = T)
    
    # Graph
    ggplot(data = seleccion, aes(x = x, y = y)) +
      # Add points with transparency
      geom_point(alpha = .1) +
      # One graph for each circuit
      facet_wrap(~locality, nrow = 3, ncol = 7, scales = "free", drop = F) + 
      # Theme for the graph
      theme_light(base_family = "Formula1 Display-Bold") +
      theme(axis.title = element_blank(),
            axis.text = element_blank(),
            panel.grid = element_blank(),
            axis.ticks = element_blank(),
            panel.border = element_blank(),
            strip.background = element_rect(fill = "white"),
            strip.text = element_text(size = 10, face = "bold",
                                      color = "black",
                                      family = "Formula1 Display-Bold")
      ) -> g
    
    # Save graph
    ggsave(paste0("circuits/circuits_", i, ".png"), g, width = 10, height = 7)
    
    # Print message
    print(paste0(i, " completed"))
  }
}


