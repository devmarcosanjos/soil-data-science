# # ANALISE DE DADOS - COS

if (!require(data.table)) install.packages("data.table")
if (!require(sf)) install.packages("sf")
if (!require(geobr)) install.packages("geobr")
if (!require(gstat)) install.packages("gstat")
if (!require(RColorBrewer)) install.packages("RColorBrewer")


# CARREGAR DADOS 
oob_results <- fread("./data/ALTO_ALEGRE_DOS_PARECIS/110_merge_e_conversao_soc_stock")
nrow(oob_results)

ob_results <- unique(oob_results, by = c("latitude", "longitude"))
nrow(oob_results)
head(oob_results)

oob_results[, error := soc_stock_t_ha_predito - soc_stock_t_ha_observado]

# ADICIONAR CIDADE E ESTADO PARA CADA LINHA
states <- geobr::read_state(year = 2018)
states <- sf::st_transform(states, crs = 4326)

cities <- geobr::read_municipality(year = 2018)
cities <- sf::st_transform(cities, crs = 4326)

oob_results_sf <- st_as_sf(oob_results, coords = c("longitude", "latitude"), crs = 4326)
oob_results_sf <- st_intersection(oob_results_sf, states)
oob_results_sf <- st_join(oob_results_sf, cities)

# FILTRAR OS DADOS SOMENTE DADOS DO ESTADO DE RONDÔNIA || PORTO VELHO
#oob_results_RO <- oob_results_sf[oob_results_sf$name_state == "Rondônia",]
#oob_results_RO <- oob_results_sf[oob_results_sf$name_muni == "Porto Velho",]
#oob_results_RO <- oob_results_sf[oob_results_sf$name_muni == "Jaru",]
#oob_results_RO <- oob_results_sf[oob_results_sf$name_muni == "Cujubim",]
oob_results_RO <- oob_results_sf[oob_results_sf$name_muni == "Alto Alegre Dos Parecis",]
nrow(oob_results_RO)

# SALVAR DADOS EM CSV 
fwrite(oob_results_RO, "./data/ALTO_ALEGRE_DOS_PARECIS/200_analise_oob_result.csv")

# motrar dados
head(oob_results_RO)
