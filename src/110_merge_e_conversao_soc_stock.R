# Merge the two tables and convert the units of the SOC stock to t/ha


# Carregar os dados
soc_stock_comparison_predito <- read.csv("data/ALTO_ALEGRE_DOS_PARECIS/100_dados_padronizados.csv", stringsAsFactors = FALSE)
soil_organic_carbon_observado <- read.csv("data/soil-organic-carbon-stock-0-30-cm-grams-per-square-meter-RO.csv", stringsAsFactors = FALSE)
database <- read.csv("data/soil-organic-carbon-stock-0-30-cm-grams-per-square-meter.csv", stringsAsFactors = FALSE)

# Quais os nomes das colunas tabela1
#colnames(tabela1)  
#colnames(tabela2)

# Converter o tipo das colunas para serem compatíveis
soc_stock_comparison_predito$id <- as.character(soc_stock_comparison_predito$id)
soil_organic_carbon_observado$point_id <- as.character(soil_organic_carbon_observado$point_id)

# Comparar as tabelas e adicionar a coluna soc_stock_g_m2
soc_stock_comparison_predito <- soc_stock_comparison_predito %>%
  left_join(soil_organic_carbon_observado %>%
              select(point_id, soc_stock_g_m2), 
            by = c("id" = "point_id"))

# Verificar o resultado
head(soc_stock_comparison_predito)


# Remover coluna .geo e system.index  da tabela soc_stock_comparison_predito
soc_stock_comparison_predito <- soc_stock_comparison_predito %>%
  select(-.geo, -system.index)

# visualizar os dados
head(soc_stock_comparison_predito)


# converter  g/m2 conversao t/ha 
# soc_stock_t_ha <- soc_stock_g_m2 * 0.01  
soc_stock_comparison_predito$soc_stock_t_ha <- soc_stock_comparison_predito$soc_stock_g_m2 * 0.01

# visualizar os dados
head(soc_stock_comparison_predito)


# Renomear a coluna soc_stock_t_ha para soc_stock_t_ha_predito
soc_stock_comparison_predito <- soc_stock_comparison_predito %>%
  rename(soc_stock_t_ha_predito = soc_stock_t_ha)

# Reanomear soc_stock_tha para soc_stock_t_ha_observado
soc_stock_comparison_predito <- soc_stock_comparison_predito %>%
  rename(soc_stock_t_ha_observado = soc_stock_tha)


# remover coluna soc_stock_g_m2
soc_stock_comparison_predito <- soc_stock_comparison_predito %>%
  select(-soc_stock_g_m2)

# order do dataset id, soc_stock_t_ha_observado, soc_stock_t_ha_predito, mean_prediction median_prediction sampling_year
soc_stock_comparison_predito <- soc_stock_comparison_predito %>%
  select(id, soc_stock_t_ha_observado, soc_stock_t_ha_predito, mean_prediction, median_prediction, sampling_year)


# visualizar os dados
head(soc_stock_comparison_predito)

# Salvar o resultado em um novo arquivo
#write.csv(soc_stock_comparison_predito, "data/ESTADO_RO/110_soc_stock_comparison_updated.csv", row.names = FALSE)

# quantidade de amostras
nrow(soc_stock_comparison_predito)


# A tabela dataset contem latitude e longitude relacionada a cada point_id
# Renomear a coluna point_id para id

database <- database %>%
  rename(id = point_id)


# Na tabela dataset contém a coluna latitude e longitude
# Se id dataset for igual o id do soc_stock_comparison_predito
# Adicionar a coluna latitude e longitude a tabela soc_stock_comparison_predito

soc_stock_comparison_predito <- soc_stock_comparison_predito %>%
  left_join(database %>%
              select(id, latitude, longitude), 
            by = c("id" = "id"))

# Verificar o resultado
head(soc_stock_comparison_predito)

# Salvar o resultado em um novo arquivo
write.csv(soc_stock_comparison_predito, "data/ALTO_ALEGRE_DOS_PARECIS/110_merge_e_conversao_soc_stock", row.names = FALSE)

# quantidade de amostras
nrow(soc_stock_comparison_predito)

