library(sf)
library(dplyr)
library(geobr)

# Carregar dados
dados <- read.csv("data/soil-organic-carbon-stock-0-30-cm-grams-per-square-meter.csv")

# Obter shapefile de Porto Velho (código 1100205)
porto_velho <- read_municipality(
  code_muni = 1100205,  # Código IBGE de Porto Velho
  year = 2020
) %>% 
  st_transform(4326)

# Converter para objeto espacial
dados_sf <- st_as_sf(dados, 
                     coords = c("longitude", "latitude"),
                     crs = 4326)

# Filtrar pontos dentro de Porto Velho
pontos_porto_velho <- st_join(dados_sf, porto_velho, join = st_intersects) %>% 
  filter(name_muni == "Porto Velho")

# Visualizar resultado
head(pontos_porto_velho)

# Quantidade de amostras
nrow(pontos_porto_velho)

# Salvar dados
write.csv(pontos_porto_velho, 
          "data/soil-organic-carbon-stock-0-30-cm-grams-per-square-meter-Porto-Velho.csv", 
          row.names = FALSE)
