# Carregar pacotes necessários
library(dplyr)
library(tidyr)
library(jsonlite)
library(purrr)  # Necessário para map_dbl

# Ler o arquivo CSV
dados <- read.csv("data/PORTO_VELHO/old/soc_stock_comparison_collection2_MODEL1_PORTO_VELHO.csv", stringsAsFactors = FALSE)

# Extrair latitude e longitude da coluna .geo
dados <- dados %>%
  mutate(
    longitude = map_dbl(.geo, ~ fromJSON(.)$coordinates[1]),
    latitude = map_dbl(.geo, ~ fromJSON(.)$coordinates[2])
  ) %>%
  select(-.geo)  # Remover coluna original .geo

# Salvar a tabela padronizada em um novo CSV
write.csv(dados, "data/PORTO_VELHO/dados_padronizados.csv", row.names = FALSE)

# Visualizar a tabela padronizada
print(dados)
