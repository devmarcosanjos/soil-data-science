library(ggplot2)
library(geobr)
library(dplyr)
library(sf)

# Obter o shapefile do estado de Rondônia
rondonia <- read_state(code_state = "RO", year = 2020)

# Obter os shapes dos municípios de Rondônia
municipios_ro <- read_municipality(code_muni = "RO", year = 2020)
municipios_ro <- municipios_ro %>% mutate(code_muni = as.character(code_muni))


# Criar um vetor de códigos IBGE e associar números fixos aos municípios
municipios_ordem <- tibble(
  code_muni = c("1100205", "1100106", "1100304", "1100015", "1101302", "1101492", "1100908", "1100049", "1100056", "1100924"),
  numero = 1:10,
  nome_municipio = c("Porto Velho", "Guajará-Mirim", "Vilhena", "Alta Floresta D'Oeste", 
                     "Machadinho D'Oeste", "São Francisco Do Guaporé", "Corumbiara", 
                     "Cacoal", "Costa Marques", "Chupinguaia"),
  cor = c("#FFB84D", "#FF9F33", "#FF7F24", "#FF6A1F", "#FF5733", 
          "#E64A19", "#D84315", "#BF360C", "#A52714", "#821D12")
)

# Filtrar e adicionar os números aos municípios selecionados
municipios_selecionados <- municipios_ro %>%
  inner_join(municipios_ordem, by = "code_muni")

# Criar a legenda com número + nome
municipios_selecionados <- municipios_selecionados %>%
  mutate(legenda = paste(numero, "-", nome_municipio))

# Criar um dataframe para a legenda associando número, nome e cor
legenda <- municipios_selecionados %>% select(numero, legenda, cor)

# Criar o mapa
ggplot() +
  geom_sf(data = rondonia, fill = "lightgray", color = "black") +  # Estado de Rondônia
  geom_sf(data = municipios_ro, fill = "white", color = "black") +  # Todos os municípios
  geom_sf(data = municipios_selecionados, aes(fill = as.factor(numero)), color = "black") +  # Cidades selecionadas com cores personalizadas
  geom_sf_text(data = municipios_selecionados, aes(label = numero), color = "black", size = 4, nudge_y = 0.05) +  # Adiciona número ao mapa
  scale_fill_manual(name = "Municípios", 
                    values = setNames(legenda$cor, as.character(legenda$numero)), 
                    labels = setNames(legenda$legenda, as.character(legenda$numero))) +  # Criar legenda associando números a cidades
  theme_minimal() +
  labs(title = "Cidades Selecionadas de Rondônia",
       x = "Longitude",
       y = "Latitude") +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "right")  # Ajusta a posição da legenda para o lado direito
