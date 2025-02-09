# Carregar pacotes
library(data.table)
library(ggplot2)
library(dplyr)  # Para manipulação de dados

# Carregar dados
oob_results <- fread("./data/ESTADO_RO/200_soc_stock.csv")

# 1. Calcular o número de amostras por cidade
samples_per_city <- table(oob_results$name_muni)

# 2. Ordenar cidades por número de amostras (decrescente)
samples_sorted <- sort(samples_per_city, decreasing = TRUE)

# 3. Criar um data.frame com rank e número de amostras
df_rank <- data.frame(
  rank = 1:length(samples_sorted),  # Rank (1 = cidade com mais amostras)
  sample_count = as.numeric(samples_sorted)  # Número de amostras
)

# 4. Ajustar modelo de Lei de Potência (y = a * rank^b)
model_rank <- lm(log(sample_count) ~ log(rank), data = df_rank)

# 5. Gráfico de rank vs. amostras
ggplot(df_rank, aes(x = rank, y = sample_count)) +
  geom_point(size = 3, color = "skyblue") +  # Pontos para cada cidade
  geom_line(aes(y = exp(predict(model_rank))), color = "red", linewidth = 1) +  # Linha do modelo
  scale_x_log10() +  # Escala log no eixo x
  scale_y_log10() +  # Escala log no eixo y
  labs(
    title = "Lei de Potência: Rank vs. Amostras",
    subtitle = "Relação entre Rank e Número de Amostras",
    x = "Rank (log)",
    y = "Número de Amostras (log)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))  # Centralizar título

# 6. Calcular os limites dos quartis
quantile_limits <- quantile(df_rank$rank, probs = seq(0, 1, 0.25))  # 0%, 25%, 50%, 75%, 100%

# 7. Adicionar coluna de quartil ao data.frame
df_rank <- df_rank %>%
  mutate(quartil = cut(rank, breaks = quantile_limits, include.lowest = TRUE, labels = c("Q1", "Q2", "Q3", "Q4")))

# 8. Gráfico de rank vs. amostras com quartis e linhas verticais
ggplot(df_rank, aes(x = rank, y = sample_count, color = quartil)) +
  geom_point(size = 3) +  # Pontos coloridos por quartil
  scale_x_log10() +
  scale_y_log10() +
  labs(
    title = "Lei de Potência: Rank vs. Amostras",
    subtitle = "Relação entre Rank e Número de Amostras",
    x = "Rank (log)",
    y = "Número de Amostras (log)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5)) +
  # Adicionar linhas verticais para cada limite de quartil
  geom_vline(xintercept = quantile_limits, linetype = "dashed", color = "black", linewidth = 1)

# 9. Encontrar a melhor cidade (com maior número de amostras) dentro de cada quartil
best_cities_per_quartile <- df_rank %>%
  group_by(quartil) %>%
  arrange(desc(sample_count)) %>%
  slice(1)  # Selecionar a primeira cidade (a melhor, com mais amostras)

# 10. Visualizar as melhores cidades por quartil
print(best_cities_per_quartile)

# 11. Gráfico de rank vs. amostras com destaque para as melhores cidades em cada quartil
ggplot(df_rank, aes(x = rank, y = sample_count, color = quartil)) +
  geom_point(size = 3) +
  scale_x_log10() +
  scale_y_log10() +
  labs(
    title = "Lei de Potência: Rank vs. Amostras",
    subtitle = "Relação entre Rank e Número de Amostras",
    x = "Rank (log)",
    y = "Número de Amostras (log)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5)) +
  # Adicionar linhas verticais nas melhores cidades de cada quartil
  geom_vline(data = best_cities_per_quartile, aes(xintercept = rank), linetype = "solid", color = "blue", linewidth = 1)

# 12. Nome das melhores cidades para análise 
# Adicionar os nomes das cidades ao df_rank (assumindo que o nome da cidade está na coluna 'name_muni')
df_rank$name_muni <- names(samples_sorted)[df_rank$rank]  # Ajustar para pegar os nomes das cidades corretamente

# Encontrar a melhor cidade (com maior número de amostras) dentro de cada quartil
best_cities_per_quartile <- df_rank %>%
  group_by(quartil) %>%
  arrange(desc(sample_count)) %>%
  slice(1)  # Selecionar a primeira cidade (a melhor, com mais amostras)

# Visualizar as melhores cidades por quartil com seus nomes
print(best_cities_per_quartile[, c("quartil", "name_muni", "sample_count")])


# 13. Rank de todas as cidades  
# Adicionar o nome da cidade ao data.frame df_rank
df_rank$name_muni <- names(samples_sorted)[df_rank$rank]  # Ajustar para pegar os nomes das cidades corretamente

# Visualizar o rank de todas as cidades
print(df_rank[, c("rank", "name_muni", "sample_count")])

# 14. Salvar resultados
write.csv(df_rank, "data/ESTADO_RO/001_rank_das_cidades.csv", row.names = FALSE)

