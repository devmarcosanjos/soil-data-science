# ANALISE DADOS PARA RONDÔNIA 

if (!require(data.table)) install.packages("data.table")
if (!require(sf)) install.packages("sf")
if (!require(geobr)) install.packages("geobr")
if (!require(gstat)) install.packages("gstat")
if (!require(RColorBrewer)) install.packages("RColorBrewer")
if (!require(tmap)) install.packages("tmap")



# CARREGAR DADOS 
oob_results <- fread("./data/PORTO_VELHO/soc_stock_PORTO-VELHO_v1.csv")
nrow(oob_results)

# verificar se SF 
head(oob_results)

# Compute error statistics
error_stats <- oob_results[, .(
  mean_error = mean(error),
  median_error = median(error),
  min_error = min(error),
  max_error = max(error),
  sd_error = sd(error)
)]
print(error_stats)


# Plot the dispersion of predicted vs observed values
png("res/fig/ro/observed_vs_predicted-ro.png", width = 800, height = 600)
plot(
  y = oob_results$soc_stock_t_ha_observado,
  x = oob_results$soc_stock_t_ha_predito,
  ylab = "Observedo COS (t/ha)",
  xlab = "Predito COS (t/ha)",
  main = "Observedo vs Predito COS",
  xlim = range(c(0, oob_results$soc_stock_t_ha_observado, oob_results$soc_stock_t_ha_predito)),
  ylim = range(c(0, oob_results$soc_stock_t_ha_predito, oob_results$soc_stock_t_ha_observado)),
  panel.first = grid()
)
abline(a = 0, b = 1, col = "red")

dev.off()



# Plot the distribution of prediction errors (histogram)
png("res/fig/ro/his-observed_vs_predicted-ro.png", width = 800, height = 600)
hist(
  oob_results$error,
  breaks = 50,
  main = "Distribuição da predição dos erros",
  xlab = "Predição dos erros (t/ha)",
  ylab = "Frequencia"
)
rug(oob_results$error)
dev.off()

# Separar a coluna geometry em longitude e latitude
oob_results[, c("longitude", "latitude") := tstrsplit(geometry, "\\|")]
oob_results$longitude <- as.numeric(oob_results$longitude)
oob_results$latitude <- as.numeric(oob_results$latitude)

# Converter para objeto sf
oob_results_sf <- st_as_sf(oob_results, coords = c("longitude", "latitude"), crs = 4326)

# Shapefile nova uniao
#rondonia <- read_municipality(code_muni = 1100205, year = 2020)
rondonia <- read_municipality(code_muni = 1100072, year = 2020)

if (st_crs(rondonia)$epsg != 4326) {
  rondonia <- st_transform(rondonia, crs = 4326)
}
png("res/fig/ro/RO-ro.png", width = 800, height = 600)
plot(rondonia$geom, col = "lightgray", main = "Shapefile de Rondônia")
dev.off()


# Plotar mapa de Porto Velho
plot(st_geometry(rondonia), col = "lightgray", main = "Amostras de Erros de Previsão em Nova União", axes = TRUE)
plot(st_geometry(oob_results_sf), pch = 20, col = "red", add = TRUE)

oob_results_sf <- oob_results_sf[!is.na(oob_results_sf$error), ]


# FAZER MAPA DE CORRELACAO DOS ERROS 
#breaks <- c(min(oob_results$error), -100, -10, -5, 0, 5, 10, 100, max(oob_results$error))
breaks <- sort(c(min(oob_results_sf$error), -100, -10,  0 , 10, 100, max(oob_results_sf$error)))

# MAPA DE PORTO VELHO COM AS AMOSTRAS DE ERROS DE PREVISÃO
tm_shape(rondonia) +
  tm_borders() +
  tm_shape(oob_results_sf) +
  tm_dots(
    col = "error", 
    palette = "RdYlBu", 
    size = 0.2,
    breaks = breaks,
    legend.show = TRUE
  ) +
  tm_layout(
    title = "Mapa de Erros Corumbiara", 
    title.position = c("center", "top"), # Centraliza o título no topo
    legend.position = c("right", "center"), # Alinha a legenda à direita e centraliza
    legend.outside = TRUE, # Move a legenda para fora do mapa
    legend.outside.position = "right" # Define a posição da legenda fora do mapa
  )

# SEMIVARIGRAMA AJUSTADO
cutoff <- 45
semivariogram <- gstat::variogram(
  error ~ 1,
  locations = oob_results_sf,
  cutoff = cutoff, 
  width = cutoff / 10 
)
print(semivariogram)

plot(
  x = semivariogram[["dist"]], # Distance
  y = semivariogram[["gamma"]], # Semivariance
  main = "Semivariogram of Prediction Errors",
  xlab = "Distance (m)",
  ylab = "Semivariance",
  pch = 20, panel.first = grid(), ylim = c(0, max(semivariogram$gamma))
)



nugget <- 7 # The nugget effect accounts for measurement error and short-range variability
psill <- 6  - nugget # Partial sill is the maximum semivariance
range <- 10 # The range is the distance at which the semivariogram reaches the sill
model <- "Gau" # Gaussian model é mais suave a curva (PARA REGIOES AREAS COM PONTOS)
#model <- "Exp" # Assume que que tem uma rapida sumida no começo do processo (CURTA DISTANCIA) 
vgm_model <- gstat::vgm(psill = psill, model = model, range = range, nugget = nugget)
fit_vgm_model <- gstat::fit.variogram(semivariogram, model = vgm_model)
print(fit_vgm_model)


vgm_model_line <- gstat::variogramLine(vgm_model, maxdist = cutoff)
fit_vgm_model_line <- gstat::variogramLine(fit_vgm_model, maxdist = cutoff)

print(fit_vgm_model)

plot(
  x = semivariogram[["dist"]], # Distance
  y = semivariogram[["gamma"]], # Semivariance
  main = "Semivariogram of Prediction Errors",
  xlab = "Distance (m)",
  ylab = "Semivariance",
  pch = 20, panel.first = grid(), ylim = c(0, max(semivariogram$gamma))
)
lines(
  x = vgm_model_line[["dist"]],
  y = vgm_model_line[["gamma"]],
  col = "red"
)
lines(
  x = fit_vgm_model_line[["dist"]],
  y = fit_vgm_model_line[["gamma"]],
  col = "blue"
)
legend(
  "bottomright",
  legend = c("Guess", "Fitted"),
  col = c("red", "blue"),
  lty = 1
)


# ---------------------------
# SEMIVARIGRAMA MODELO TEÓRICO 

cutoffs = seq(10, 80, by = 10)
models <- lapply(cutoffs, function(cut) {
  semivariogram <- gstat::variogram(
    error ~ 1, locations = oob_results_sf, 
    cutoff = cut, width = cut / 10
  )
  return(semivariogram)
})

# Plotar semivariogramas para cada cutoff
par(mfrow = c(3, 3))  # Ajustar a disposição das imagens
for (i in 1:length(models)) {
  plot(models[[i]]$dist, models[[i]]$gamma, 
       main = paste("Cutoff =", cutoffs[i]), 
       xlab = "Distância", ylab = "Semivariança", 
       pch = 16, panel.first = grid())
}


cutoff_x = 50
semivariogram <- gstat::variogram(
  error ~ 1,
  locations = oob_results_sf,
  cutoff = cutoff_x, 
  width = cutoff_x / 10 
)
print(semivariogram)

plot(
  x = semivariogram[["dist"]], # Distance
  y = semivariogram[["gamma"]], # Semivariance
  main = "Semivariogram of Prediction Errors (cutoff = 20 | EXP)",
  xlab = "Distance (m)",
  ylab = "Semivariance",
  pch = 20, panel.first = grid(), ylim = c(0, max(semivariogram$gamma))
)



nugget <- 19 # The nugget effect accounts for measurement error and short-range variability
psill <- 80 - nugget # Partial sill is the maximum semivariance
range <- 10 # The range is the distance at which the semivariogram reaches the sill
model <- "Gau" # Gaussian model é mais suave a curva (PARA REGIOES AREAS COM PONTOS)
#model <- "Exp" # Assume que que tem uma rapida sumida no começo do processo (CURTA DISTANCIA) 
#model <- "Sph"

vgm_model <- gstat::vgm(psill = psill, model = model, range = range, nugget = nugget)
fit_vgm_model <- gstat::fit.variogram(semivariogram, model = vgm_model)
print(fit_vgm_model)


vgm_model_line <- gstat::variogramLine(vgm_model, maxdist = cutoff_x)

fit_vgm_model_line <- gstat::variogramLine(fit_vgm_model, maxdist = cutoff_x)

print(fit_vgm_model)

plot(
  x = semivariogram[["dist"]], # Distance
  y = semivariogram[["gamma"]], # Semivariance
  main = "Semivariogram of Prediction Errors (cutoff = 19 | SHP)",
  xlab = "Distance (m)",
  ylab = "Semivariance",
  pch = 20, panel.first = grid(), ylim = c(0, max(semivariogram$gamma))
)
lines(
  x = vgm_model_line[["dist"]],
  y = vgm_model_line[["gamma"]],
  col = "red"
)
lines(
  x = fit_vgm_model_line[["dist"]],
  y = fit_vgm_model_line[["gamma"]],
  col = "blue"
)
legend(
  "bottomright",
  legend = c("Guess", "Fitted"),
  col = c("red", "blue"),
  lty = 1
  
)




