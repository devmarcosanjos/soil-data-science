/* SPATIAL-TEMPORAL PREDICTION AND STOCKCOS UNCERTAINTY
The prediction uses the RF model saved with the covariates and exports the predicted map/data.

MAPBIOMAS SOIL @contact: contato@mapbiomas.org
October 26, 2024
*/
  
  // --- VERSIONING
// var municipio_nome = 'Corumbiara';  
// var modelo = 'MODEL1';  
// var version = 'collection2_' + modelo + '_' + municipio_nome;
var version = 'collection2_MODEL1_Corumbiara';
print(version);  // Resultado: collection2_MODEL1_Curumbiara




//var version = 'collection2_MODEL1_CURUMBIARA'; 

// --- DEFINITION OF DATA FOR PREDICTION
//var matrix = 'projects/mapbiomas-workspace/SOLOS/AMOSTRAS/MATRIZES/soil_organic_carbon/matriz-' + version;
//var matrix = 'projects/ee-marcosanjos/assets/DEV/matriz_treinamento-collection2_MODEL1_AMAZONIA' 
var matrix = 'projects/ee-marcosanjos/assets/DEV/Corumbiara/matriz-collection2_MODEL1_Corumbiara';
//var matrix = 'projects/ee-marcosanjos/assets/DEV/' + municipio_nome + '/matriz-' + version;


var dataTraining = ee.FeatureCollection(matrix);
print('Training data:', dataTraining.limit(10));

var dataTrainingColumns = dataTraining.first().propertyNames();

// Importa o shapefile do estado de Roraima
//var rr = ee.FeatureCollection('projects/mapbiomas-workspace/AUXILIAR/MUNICIPIOS/municipios-RO').union()

// Carregar municípios de Rondônia e filtrar Porto Velho
var municipiosRO = ee.FeatureCollection("projects/mapbiomas-workspace/AUXILIAR/MUNICIPIOS/municipios-RO");
// var portoVelho = municipiosRO
//     .filter(ee.Filter.eq('NM_MUN', 'Porto Velho'))
//     .union();

// var NovaUniao = municipiosRO
//     .filter(ee.Filter.eq('NM_MUN', 'Nova União'))
//     .union();

var Corumbiara = municipiosRO
.filter(ee.Filter.eq('NM_MUN', 'Corumbiara'))
.union();

// var municipio = municipiosRO
//     .filter(ee.Filter.eq('NM_MUN', municipio_nome))
//     .union();


// Filtra os dados de treinamento para Roraima
var dataTraining = ee.FeatureCollection(matrix).filterBounds(Corumbiara);



// --- IMPORTING COVARIATES MODULE
//var covariates = require('users/wallacesilva/mapbiomas-solos:COLECAO_01/development/_module_covariates/module_covariates');
var covariates = require('users/devmarcosanjos/dev:module_covariates')


var staticCovariates = covariates.static_covariates();
var dynamicCovariates = covariates.dynamic_covariates();

var staticCovariatesModule = staticCovariates.bandNames();
var dynamicCovariatesModule = dynamicCovariates.first().bandNames();

var staticCovariatesNames = staticCovariatesModule.filter(ee.Filter.inList('item', dataTrainingColumns));
var dynamicCovariatesNames = dynamicCovariatesModule.filter(ee.Filter.inList('item', dataTrainingColumns));

var covariatesNames = staticCovariatesNames.cat(dynamicCovariatesNames);
print('Set of covariate:', covariatesNames);

// -- LIBRARY FOR DECODE RANDOM FOREST ASSET TABLE
function decodeFeatureCollection(featureCollection) {
  return featureCollection
  .map(function (feature) {
    var dict = feature.toDictionary();
    var keys = dict.keys().map(function (key) {
      return ee.Number.parse(ee.String(key));
    });
    var value = dict.values().sort(keys).join();
    return ee.Feature(null, { value: value });
  })
  .aggregate_array('value')
  .join()
  .decodeJSON();
}

// --- IMPORTING RANDOM FOREST MODEL
//var assetModelRandomForest = 'projects/mapbiomas-workspace/SOLOS/MODELOS_RF/soil_organic_carbon/randomForestModel-' + version;
//var assetModelRandomForest = 'projects/ee-marcosanjos/assets/DEV/matriz_treinamento-collection2_MODEL1_AMAZONIA'
//var assetModelRandomForest = 'projects/ee-marcosanjos/assets/DEV/' + municipio_nome + '/' +  'RandonFlorestModel-' + version;

var assetModelRandomForest ='projects/ee-marcosanjos/assets/DEV/Corumbiara/RandonFlorenstcollection2_MODEL1_Corumbiara'
var featureCollectionModelRandomForest = ee.FeatureCollection(assetModelRandomForest);
var getModelForest = decodeFeatureCollection(featureCollectionModelRandomForest);
print('Model trees:', getModelForest)
var TreeEnsemble = ee.Classifier.decisionTreeEnsemble(getModelForest);

// --- LULC MASKS
// var mapbiomasLulc = 'projects/mapbiomas-workspace/public/collection8/mapbiomas_collection80_integration_v1'; // (1985-2022)
var mapbiomasLulc = 'projects/mapbiomas-public/assets/brazil/lulc/collection9/mapbiomas_collection90_integration_v1';    // (1985-2023)
var lulc = ee.Image(mapbiomasLulc);

// --- TEMPORAL PREDICTION AND INTERVAL CALCULATION
var dataTrainingOutput = ee.FeatureCollection([]);

var containerMean = ee.Image().select();
var containerMedian = ee.Image().select();
// var container = ee.Image().select();
// var containerUncertainty = ee.Image().select();

var years = [
  1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997,
  1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010,
  2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023,
];

var numberOfTreesRF = 399;

years.forEach(function (year) {
  var dynamicCovariatesYear = dynamicCovariates
  .select(dynamicCovariatesNames)
  .filter(ee.Filter.eq("year", year))
  .first();
  
  var covariates = ee
  .Image()
  .select()
  .addBands(staticCovariates.select(staticCovariatesNames))
  .addBands(dynamicCovariatesYear)
  .addBands(ee.Image(year).int16().rename("year"));
  
  var bandName = "prediction_" + year;
  
  var lulcYear = lulc.select("classification_" + year);
  
  var blend = ee
  .Image()
  .blend(lulcYear.eq(29).selfMask())
  .blend(lulcYear.eq(23).selfMask())
  .blend(lulcYear.eq(24).selfMask())
  .blend(lulcYear.eq(30).selfMask())
  .blend(lulcYear.eq(32).selfMask())
  .multiply(0);
  
  // Classifies the covariates image using a tree ensemble, renames the prediction band, blends with the blend image.
  var prediction = covariates
  .classify(TreeEnsemble)
  .rename(bandName)
  .blend(blend)
  .round()
  .int16();
  
  // Iterates in sequence, classifying the image with each tree and adding the resulting images as bands to the containerTrees image.
  var containerTrees = ee.Image(
    ee.List.sequence(0, numberOfTreesRF).iterate(function (current, previous) {
      var treesClassifier = ee.Classifier.decisionTree(ee.List(getModelForest).getString(ee.Number(current)));
      
      var img = covariates
      .classify(treesClassifier)
      .rename(bandName)
      .blend(blend)
      .round()
      .int16();
      return ee.Image(previous).addBands(img);
    }, ee.Image().select())
  );
  
  //prediction mean RF
  containerMean = containerMean.addBands(containerTrees.reduce("mean").round().rename(bandName.replace("_", "_mean_")));
  containerMedian = containerMedian.addBands(containerTrees.reduce("median").round().rename(bandName.replace("_", "_median_")));
  
  // container = container.addBands(prediction);
  //     //prediction interval (PI) = P95 - P05 
  // containerUncertainty = containerUncertainty.addBands(containerTrees.reduce(ee.Reducer.percentile([95]))
                                                          //                                                               .subtract(containerTrees.reduce(ee.Reducer.percentile([5]))).round()
                                                          //                                                                     .rename(bandName.replace("_", "_uncertainty_")));
});

// --- TEMPORAL GAPPING
var cloudSeriesFilter = function (image) {
  var filtered = ee.List(image.bandNames())
  .slice(1)
  .iterate(function (bandName, previousImage) {
    bandName = ee.String(bandName);
    var imageYear = ee.Image(image).select(bandName);
    previousImage = ee.Image(previousImage);
    
    var filtered = imageYear.where(
      imageYear.eq(-2),
      previousImage.slice(-1)
    );
    
    return previousImage.addBands(filtered);
  }, ee.Image(image.slice(0, 1)));
  
  image = ee.Image(filtered);
  
  var bandNames1 = ee.List(image.bandNames()).reverse();
  filtered = ee.List(bandNames1)
  .slice(1)
  .iterate(function (bandName, previousImage) {
    bandName = ee.String(bandName);
    var imageYear = ee.Image(image).select(bandName);
    previousImage = ee.Image(previousImage);
    
    var filtered = imageYear.where(
      imageYear.eq(-2),
      previousImage.slice(-1)
    );
    
    return previousImage.addBands(filtered);
  }, ee.Image(image.slice(-1)));
  
  image = ee.Image(filtered);
  
  return image.select(image.bandNames().sort());
};

// --- MASKING SUBMERGED AREAS (Natural and anthropized water bodies)
var waterBodies = ee.ImageCollection("projects/mapbiomas-workspace/AMOSTRAS/GTAGUA/OBJETOS/CLASSIFICADOS/TESTE_1_raster")
.filter(ee.Filter.eq("version", "3"))
.filter(ee.Filter.eq("year", 2023))
.mosaic();

Map.addLayer(waterBodies.randomVisualizer(),{},'waterBodies', false);

var anthropizedBodies = waterBodies.neq(1);

Map.addLayer(anthropizedBodies.randomVisualizer(),{},'anthropizedBodies', false);

var submergedAreas = lulc.eq(33).or(lulc.eq(31)).reduce("sum").selfMask();

submergedAreas = submergedAreas
.gte(37)
.where(anthropizedBodies.eq(1), 0)
.multiply(-1)
.int16();


var maskAnthropizedBodies = lulc
.eq(33)
.or(lulc.eq(31))
.where(anthropizedBodies.unmask().eq(0), 0)
.eq(1);


var containerList = [
  ["mean_", containerMean],
  ["median_", containerMedian],
  // ["", container],
  // ["uncertainty_", containerUncertainty]
];

print("Computed statistics of prediction and visualization year:")
containerList.forEach(function (list) {
  var cos = list[1];
  var string = list[0];
  print("prediction_" + string + "2023");
  
  
  
  var visualParams = {
    bands: ["prediction_" + string + "2023"],
    min: 0,
    max: 90,
    palette:  [
      "#f4f0f0",
      "#e9e1e1",
      "#ddd3d2",
      "#c7b8b6",
      "#bbaca8",
      "#b09f9b",
      "#a4948e",
      "#998882"
    ] 
  };
  
  cos = cos
  .where(submergedAreas.eq(-1), -1)
  .where(maskAnthropizedBodies, -1);
  
  // print("cos", cos);
  cos = cloudSeriesFilter(cos.unmask(-2));
  // print("cos cloudSeriesFilter", cos);
  var cos_t_ha = cos.updateMask(lulc.select(0));
  // Map.addLayer(cos_t_ha, visualParams, "cos_t_ha_" + string);
  // Aplicar o recorte para o estado de Roraima
  
  // Aplicar o recorte para o estado de Roraima
  var cos_t_ha_rr = cos_t_ha.clip(Corumbiara);
  
  Map.addLayer(cos_t_ha_rr, visualParams, "cos_t_ha_" + string);
  // Centraliza a visualização no estado de Roraima
  Map.centerObject(Corumbiara, 6);
  
  
  // --- EXPORTING RESULTS
  var biomes = ee.FeatureCollection("projects/mapbiomas-workspace/AUXILIAR/biomas_IBGE_250mil");
  var aoi = biomes;
  var aoiImg = ee.Image().paint(aoi).eq(0);
  var aoiBounds = aoi.geometry().bounds();
  
  var output = "spacil_prediction_RR_V_1_SOC_tC_ha-000_030cm";
  
  
  Export.image.toAsset({
    image: cos_t_ha.updateMask(aoiImg),
    assetId: output,
    pyramidingPolicy: "median",
    region: aoiBounds,
    scale: 30,
    maxPixels: 1e13,
  });
});

// Carregar o dataset de amostras
print('Municipio selecionado:', Corumbiara);
print(municipiosRO.aggregate_array('NM_MUN'));

//var samples = ee.FeatureCollection('projects/mapbiomas-workspace/SOLOS/AMOSTRAS/ORIGINAIS/2024-10-31-points-soc-stock-tha');
//var samples = ee.FeatureCollection('projects/mapbiomas-workspace/SOLOS/AMOSTRAS/ORIGINAIS/2024-10-31-points-soc-stock-tha').filterBounds(municipio);
var samples = ee.FeatureCollection('projects/mapbiomas-workspace/SOLOS/AMOSTRAS/ORIGINAIS/2024-10-31-points-soc-stock-tha').filterBounds(Corumbiara);


// Definir o ano mínimo como 1985
samples = samples.map(function(feature) {
  var year = ee.Number(feature.get('sampling_year')).max(1985);
  return feature.set('sampling_year', year);
});

// Filtrar as predições de media e mediana para as bandas de anos específicos
function getPredictionValues(feature) {
  var year = ee.String(feature.get('sampling_year')); // Converter ano para string
  
  
  // Extrair valores para o ano específico nas predições de media e mediana
  
  var meanBand = ee.String('prediction_mean_').cat(year);
  var medianBand = ee.String('prediction_median_').cat(year);
  
  var meanValue = containerMean.select(meanBand).reduceRegion({
    reducer: ee.Reducer.first(),
    geometry: feature.geometry(),
    scale: 30,
    maxPixels: 1e9
  }).get(meanBand);
  
  var medianValue = containerMedian.select(medianBand).reduceRegion({
    reducer: ee.Reducer.first(),
    geometry: feature.geometry(),
    scale: 30,
    maxPixels: 1e9
  }).get(medianBand);
  
  print('Bandas de containerMean:', containerMean.bandNames());
  print('Bandas de containerMedian:', containerMedian.bandNames());
  
  
  // Adicionar resultados ao recurso
  return feature.set({
    'mean_prediction': meanValue,
    'median_prediction': medianValue
  });
}

// Aplicar a função de obtenção de predições
var samplesWithPredictions = samples.map(getPredictionValues);

print("samplesWithPredictions", samplesWithPredictions.limit(2))
// Exportar os resultados para uma tabela
Export.table.toDrive({
  collection: samplesWithPredictions,
  //description: 'soc_stock_comparison_PORTO_VELHO',
  description: 'soc_stock_comparison_' + version.replace(/\//g, '_'), // Add version
  fileFormat: 'CSV'
});



