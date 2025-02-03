# Extrainado amostras da base de dados Mapbiomas Solo
# 10.60502/SoilData/SXCSDK

# Para estado de RO ==> salva em novo arquivo

library(sf)
library(dplyr)
library(geobr)

# Carregar dados
dados <- read.csv("data/soil-organic-carbon-stock-0-30-cm-grams-per-square-meter.csv")

# Obter shapefile de RO
ro <- read_state(code_state = "RO", year = 2020) %>% 
  st_transform(4326) 

# Converter para objeto espacial
dados_sf <- st_as_sf(dados, 
                     coords = c("longitude", "latitude"),
                     crs = 4326)

# Filtrar pontos dentro de RO
pontos_ro <- st_join(dados_sf, ro, join = st_intersects) %>% 
  filter(abbrev_state == "RO")

# Visualizar resultado
head(pontos_ro)

# Quantidade de amostras
nrow(pontos_ro)

# salvar dados
write.csv(pontos_ro, "data/soil-organic-carbon-stock-0-30-cm-grams-per-square-meter-RO.csv", row.names = FALSE)

