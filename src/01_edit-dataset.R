# Carregar pacotes necessários
library(dplyr)
library(tidyr)
library(jsonlite)
library(purrr)  # Necessário para map_dbl

# Ler o arquivo CSV
dados <- read.csv("data/soc_stock_comparison_RO-matrix-RO - Copy.csv", stringsAsFactors = FALSE)

# Extrair latitude e longitude da coluna .geo
dados <- dados %>%
  mutate(
    longitude = map_dbl(.geo, ~ fromJSON(.)$coordinates[1]),
    latitude = map_dbl(.geo, ~ fromJSON(.)$coordinates[2])
  ) %>%
  select(-.geo)  # Remover coluna original .geo

# Salvar a tabela padronizada em um novo CSV
write.csv(dados, "data/dados_padronizados.csv", row.names = FALSE)

# Visualizar a tabela padronizada
print(dados)
