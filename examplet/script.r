# Input load. Please do not change #
#`dataset` = read.csv('C:/Users/User/REditorWrapper_72359c7c-4eed-4928-a2b0-4fa0d153fe95/input_df_748dd640-5e15-4497-b53b-9a3d2e08ead8.csv', check.names = FALSE, encoding = "UTF-8", blank.lines.skip = FALSE);
# Original Script. Please update your script content here and once completed copy below section back to the original editing window #
##############################

library(lubridate)
library(tidyr)
library(plyr)
library(dplyr)
library(maps)
library(highcharter)
library(forecast)


source('./r_files/flatten_HTML.r')

#names(dataset)[1] <- "Province.State"
#names(dataset)[4] <- "Country.Region"
#dataset <- na.omit(dataset)

url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/"

confirmados <- read.csv(paste0(url, "time_series_covid19_confirmed_global.csv")) %>% 
  pivot_longer(-c("Province.State", "Country.Region", "Lat", "Long"),
               names_to = "fecha", values_to = "confirmados") %>% 
  separate(fecha, c("mes", "dia", "anio"), sep="\\.") %>% 
  mutate(mes = gsub("X", "", mes),
         anio = paste0("20", anio),
         fecha = lubridate::date(paste(anio, mes, dia, sep="-")))%>% 
  dplyr::select(Country.Region, Province.State, Long, Lat, fecha, confirmados)


confirmados <- as.data.frame(confirmados)
fecha <- confirmados %>%
  dplyr::filter(fecha == '2022-01-12' & confirmados > 0)


#mapa <- ggplot(confirmados) +
#  borders("world", colour = "gray85", fill = "gray80") +
#  theme_map() + 
#  geom_point(aes(x = Long, y = Lat, size = confirmados, text = paste0(Country.Region, "::", Province.State,'\nContagiados: ', confirmados)), 
#             data = fecha,color = "#356C7E") +
#  scale_size(range=c(2,12))+           # tama?o del c?rculo
#  labs(title = paste0("Confirmados al ", lubridate::today()-2),
#       caption = "") +       # t?tulo
#  theme(plot.title = element_text(hjust = 0.5, size = 15),  
#        plot.caption = element_text(hjust = 1, size =  9),
#        
#        panel.background = element_rect(fill = "transparent"), # bg of the panel
#        plot.background = element_rect(fill = "transparent", color = NA), # bg of the plot
#        panel.grid.major = element_blank(), # get rid of major grid
#        panel.grid.minor = element_blank(), # get rid of minor grid
#        legend.background = element_rect(fill = "transparent"), # get rid of legend bg
#        legend.box.background = element_rect(fill = "transparent") # get rid of legend panel bg
#  )


colnames(fecha) <- c("Country", "Province", "lon","lat","fecha", "z") 

p=hcmap( showInLegend = FALSE) %>% 
  hc_add_series(data = fecha, type = "mapbubble", name = "Confirmados", maxSize = '12%') %>% 
  hc_tooltip(useHTML = T,headerFormat='',pointFormat = paste('Country :{point.Country}<br> Province: {point.Province} <br> Confirmados : {point.z}')) %>% 
  hc_legend(enabled = TRUE,
           # title = list(text = "Mon titre"),
            # bubbleLegend = list(
            #   enabled = TRUE,
            #   borderColor = '#000000',
            #   borderWidth = 3,
            #   color = '#8bbc21',
            #   connectorColor = '#000000'
            # ),
            align = "bottom", layout = "horizontal",
            floating = TRUE ,valueDecimals = 0,
            symbolHeight = 11, symbolWidth = 11, symbolRadius = 0) %>%
  hc_title(text = "Global Seismic Activity") %>% 
  hc_mapNavigation(enabled = T)%>% 
  hc_exporting(enabled = TRUE) %>% 
  hc_chart(
    zoomType = "xy") %>%
  hc_credits(
    enabled = FALSE
  )


internalSaveWidget(p,'out.html')