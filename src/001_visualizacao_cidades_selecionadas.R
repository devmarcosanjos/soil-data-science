library(ggplot2)
library(geobr)
library(dplyr)
library(sf)

# Obter o shapefile do estado de Rondônia
rondonia <- read_state(code_state = "RO", year = 2020)

# Obter os shapes dos municípios de Rondônia
municipios_ro <- read_municipality(code_muni = "RO", year = 2020)

# Filtrar os municípios de interesse (usando o código do município)
codigos_selecionados <- c("1100205", "1100379", "1100940", "1100114")  # Códigos de Porto Velho, Alto Alegre dos Parecis, Cujubim e Jaru
municipios_selecionados <- municipios_ro %>% filter(code_muni %in% codigos_selecionados)

# Adicionar uma coluna de número de amostras e associar cor diretamente
municipios_selecionados <- municipios_selecionados %>%
  mutate(num_amostras = case_when(
    code_muni == "1100205" ~ 286,  # Porto Velho
    code_muni == "1100379" ~ 58,   # Alto Alegre dos Parecis
    code_muni == "1100940" ~ 31,   # Cujubim
    code_muni == "1100114" ~ 15    # Jaru
  ),
  cor = case_when(
    num_amostras == 286 ~ "#FFB84D",  # Porto Velho
    num_amostras == 58  ~ "#FF9F33",  # Alto Alegre dos Parecis
    num_amostras == 31  ~ "#FF7F24",  # Cujubim
    num_amostras == 15  ~ "#FF6A1F"   # Jaru
  ),
  municipio_numero = case_when(  # Coluna para número do município
    code_muni == "1100205" ~ "1",  # Porto Velho
    code_muni == "1100379" ~ "2",  # Alto Alegre dos Parecis
    code_muni == "1100940" ~ "3",  # Cujubim
    code_muni == "1100114" ~ "4"   # Jaru
  ))

# Criar o mapa com todas as cidades e adicionar a legenda personalizada
ggplot() +
  geom_sf(data = rondonia, fill = "lightgray", color = "black") +  # Estado de Rondônia
  geom_sf(data = municipios_ro, fill = "white", color = "black") +  # Todos os municípios
  geom_sf(data = municipios_selecionados, aes(fill = cor), color = "black") +  # Cidades selecionadas com cores personalizadas
  scale_fill_identity() +  # Usar as cores definidas na coluna 'cor'
  geom_sf_text(data = municipios_selecionados, aes(label = municipio_numero), color = "black", size = 3, nudge_y = 0.05) +  # Número do município
  theme_minimal() +
  labs(title = "Cidades de Rondônia com Destaque para as Selecionadas",
       x = "Longitude",
       y = "Latitude") +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5)) +
  scale_fill_manual(values = municipios_selecionados$cor, name = "Cidades Selecionadas",
                    labels = c("1 - Porto Velho (286 amostras)", 
                               "2 - Alto Alegre dos Parecis (58 amostras)", 
                               "3 - Cujubim (31 amostras)", 
                               "4 - Jaru (15 amostras)"))
