/* EXPORT TRAINING MATRIX AND LIST OF COVARIATES - STOCK COS
This script manages the selection of environmental covariates used in subsequent analyses 
and generates the data matrix by merging the COS stock data from SoilData with the covariates module.

MAPBIOMAS SOIL @contact: contato@mapbiomas.org
October 17, 2024

-> VERSIONING: 
  
  MAJOR (vX.0.0): Refers to the dataset.
MINOR (v0.X.0): Refers to the hyperparameters.
PATCH (v0.0.X): Refers to changes in covariates.

-> UPDATES:
  2024-01-X  (Version 0-0-0) - Update of LULC covariate col.8;
- Reprocessing of covariates used in col. beta.
2024-02-26 (Addition)      - Update of IBGE phytophysiognomy covariate to version 2023.
2024-03-11 (Version 0-0-1) - Addition of mapbiomas_granulometry_v001 covariates.
2024-04-08 (Addition)      - Addition of oblique coordinates covariates.
2024-04-30 (Version 0-0-2) - Update of mapbiomas_granulometry_v002 covariates.
2024-05-10 (Version 0-0-3) - Update of mapbiomas_granulometry_v003 covariates.
2024-08-05 (Version 0-1-3) - Change in RF model configuration (ntree 400; ntry 10; maxnodes 20).
2024-08-29 (Version 0-1-4) - Addition of vegetative indices (IV) covariates processed by mapbiomas (only the median (_median)).
2024-08-30 (Version 0-1-5) - Addition of IV wet and dry period covariates processed by mapbiomas (_wet and _dry).
2024-09-10 (Version 0-1-6) - Addition of stable areas and LULC age Collection 9.
2024-10-30 (Version 1-1-7) - New dataset (2024/10/30) and All Covariates (113)
2024-11-07 (Version 1-2-7) - New dataset (2024/10/30), Change in RF model configuration (ntree 400; ntry 16; maxnodes 30), and 103 covariates.
2024-11-13 (Version 1-3-7) - Exclusion of Amazon samples (remaining 6702 samples)

-> BASELINE TESTS:
  2024-06-24 (Version B-0-3) - Addition of StockCOS Map 1984 "mapbiomas_v001_1984" (Using 5202 samples from 1985).
- Removal of coordinates.
2024-07-01 (Version B-1-3) - Change in RF model configuration (Using 5202 samples from 1985).
2024-07-04 (Version B0-1-3)- Using 9634 samples to train the model.


⚠️⚠️MVSC: ESTÁ COM FILTRO, PARA TIRAR E COLOCAR  AS MOSTRAS DA AMAZÔNIA

*/
  //--- VERSIONING

// var municipio_nome = 'Corumbiara';  
// var modelo = 'MODEL1';  
// var version = 'collection2_' + modelo + '_' + municipio_nome;

var version = 'collection2_MODEL1_Corumbiara';
print(version);  // Resultado: collection2_MODEL1_Curumbiara







// --- CALLING ENVIRONMENTAL COVARIATES FROM MODULE
var covariates = require('users/devmarcosanjos/dev:module_covariates')

//var covariates1 = require('users/wallacesilva/mapbiomas-solos:COLECAO_01/development/_module_covariates/module_covariates');
var static_covariates_carbon = covariates.static_covariates();
var dynamic_covariates_carbon = covariates.dynamic_covariates();

// --- DEFINITION OF COVARIATES LIST
var selected_bandnames_static = [
  // List of covariates for available static covariates
  
  //Base Map Mapbiomas 1984
  
  // 'mapbiomas_v001_1984', 
  
  //WRB probability classes
  'Ferralsols',
  'Histosols',
  'Sandysols',
  'Humisols',
  'Thinsols',
  'Wetsols',
  
  //Soilgrids Soil Properties
  // 'bdod',
  // 'cec',
  // 'cfvo',
  'nitrogen',
  'phh2o',
  // 'soc',
  // 'sand', //(Used in STOCKCOS v000)
  // 'clay', //(Used in STOCKCOS v000)
  // 'silt', // (Used in STOCKCOS v000)
  
  'oxides',
  'clayminerals',
  
  //Granulometry MapBiomas
  //v001 (Used in STOCKCOS v001)
  // 'mapbiomas_sand_v001',
  // 'mapbiomas_silt_v001', 
  // 'mapbiomas_clay_v001', 
  //v002 (Used from STOCKCOS v002)
  // 'mapbiomas_sand_v002', 
  // 'mapbiomas_silt_v002', 
  // 'mapbiomas_clay_v002',
  //v003 (Used from STOCKCOS v003)
  // 'mapbiomas_sand_v003', 
  // 'mapbiomas_silt_v003', 
  // 'mapbiomas_clay_v003',
  //v009 0_10cm
  // 'beta_clay_0_30cm',
  // 'beta_sand_0_30cm',
  // 'beta_silt_0_30cm',
  
  'clay_000_030cm',
  'sand_000_030cm',
  'silt_000_030cm',
  
  // Water MapBiomas 
  'mb_water_39y_accumulated', // accumulated water (areas with water present at any time)
  'mb_water_39y_recurrence', // recurrence (number of observations) of the water surface between 1985 and 2023
  
  //Black Soil
  'black_soil_prob',
  
  //Geomorphometry
  'convergence',
  'cti',
  'eastness',
  'northness',
  'pcurv',
  'roughness',
  'slope',
  'spi',
  'elevation',
  
  //Lat-Long (Used in versions below STOCKCOS v002)
  'latitude', 
  'longitude',
  
  //Oblique Coordinates (Used FROM STOCKCOS v002)
  // 'OGC_0', 
  // 'OGC_0_53',
  // 'OGC_1_03', 
  // 'OGC_1_57', 
  // 'OGC_2_10', 
  // 'OGC_2_60',
  
  //Koppen
  'lv1_Humid_subtropical_zone',
  'lv1_Tropical',
  'lv2_monsoon',
  'lv2_oceanic_climate_without_sry_season',
  'lv2_with_dry_summer',
  'lv2_with_dry_winter',
  'lv2_without_dry_season',
  'lv3_with_hot_summer',
  'lv3_with_temperate_summer',
  
  //Biomes 
  'Amazonia',
  // 'Caatinga',
  // 'Cerrado',
  // 'Mata_Atlantica',
  // 'Pampa',
  // 'Pantanal',
  
  //Phytophysiognomy
  'Floresta_Ombrofila_Aberta',
  'Floresta_Estacional_Decidual',
  'Floresta_Ombrofila_Densa',
  'Floresta_Estacional_Semidecidual',
  'Campinarana',
  'Floresta_Ombrofila_Mista',
  'Formacao_Pioneira',
  'Savana',
  'Savana_Estepica',
  'Contato_Ecotono_e_Encrave',
  'Floresta_Estacional_Sempre_Verde',
  'Estepe',
  
  //Geological Provinces
  'Amazonas_Solimoes_Provincia',
  'Amazonia_Provincia',
  'Borborema_Provincia',
  'Cobertura_Cenozoica_Provincia',
  'Costeira_Margem_Continental_Provincia',
  'Gurupi_Provincia',
  'Mantiqueira_Provincia',
  'Massa_d_agua_Provincia',
  'Parana_Provincia',
  'Parecis_Provincia',
  'Parnaiba_Provincia',
  'Reconcavo_Tucano_Jatoba_Provincia',
  'Sao_Francisco_Provincia',
  'Sao_Luis_Provincia',
  'Tocantis_Provincia',
  
  //Fourth National Communication
  // "cagb",
  // "cbgb",
  // "cdw",
  // "clitter",
  // "ctotal",
  
  'Area_Estavel',
  
  'IFN_index'
];

var selected_bandnames_dynamic = [
  // List of covariates for available dynamic covariates
  
  //GT vegetation indices
  // 'evi_mean',
  // 'savi_mean',
  // 'ndvi_mean',
  
  // Mapbiomas vegetation indices 
  // 'mb_ndvi_median',
  // 'mb_evi2_median',
  // 'mb_savi_median',    
  
  'mb_ndvi_median_decay',
  'mb_evi2_median_decay',
  'mb_savi_median_decay',
  
  // 'mb_ndvi_median_wet',
  // 'mb_ndvi_median_dry',    
  
  // 'mb_ndvi_median_wet_decay',
  // 'mb_ndvi_median_dry_decay',
  
  // 'mb_evi2_median_wet',
  // 'mb_evi2_median_dry',    
  
  // 'mb_evi2_median_wet_decay',
  // 'mb_evi2_median_dry_decay',
  
  // 'mb_savi_median_wet',
  // 'mb_savi_median_dry',    
  
  // 'mb_savi_median_wet_decay',
  // 'mb_savi_median_dry_decay',
  
  // Mapbiomas Degradation Beta (SUM(30, 60, 90, 150, 300m))
  'mb_summed_edges',
  
  // Mapbiomas Water Col. 3
  // 'mb_water_accumulate_dynamic',
  // 'mb_water_recurrence_dynamic',
  
  // Mapbiomas Fire Col. 3 
  'mb_fire_accumulate_dynamic',
  'mb_fire_recurrence_dynamic',
  'mb_fire_time_after_fire',
  
  //MapBiomas - Col.8/9
  'campoAlagadoAreaPantanosa', 
  'formacaoCampestre',
  'formacaoFlorestal',
  'formacaoSavanica',
  'lavouras',
  'mosaicoDeUsos',
  'outrasFormacoesFlorestais',
  'pastagem',
  'restingas',
  'silvicultura',
  'antropico',
  'natural',
  
];

// --- --- STATIC
var static_image = ee.Image.cat(static_covariates_carbon.select(selected_bandnames_static));
print(static_image, "static_image");
Map.addLayer(static_image, {}, 'Static Covariates', false);

// --- --- DYNAMIC 
var dynamic_images = dynamic_covariates_carbon.map(function(image) {
  return image.select(selected_bandnames_dynamic);
});
print(dynamic_images, "dynamic_images");
Map.addLayer(dynamic_images, {}, 'Dynamic Covariates', false);

// --- --- --- PREPARING THE TRAINING MATRIX --- --- ---
  var biomas = ee.FeatureCollection('projects/mapbiomas-workspace/AUXILIAR/biomas_IBGE_250mil');
var rondonia = ee.FeatureCollection("projects/mapbiomas-workspace/AUXILIAR/MUNICIPIOS/municipios-RO").union(); 
var municipiosRO = ee.FeatureCollection("projects/mapbiomas-workspace/AUXILIAR/MUNICIPIOS/municipios-RO"); 

// var portoVelho = municipiosRO
//     .filter(ee.Filter.eq('NM_MUN', 'Porto Velho'))
//     .union();

// var novaUniao = municipiosRO
//     .filter(ee.Filter.eq('NM_MUN', 'Nova União'))
//     .union();

var Corumbiara = municipiosRO
.filter(ee.Filter.eq('NM_MUN', 'Corumbiara'))
.union();

// Usando essas variáveis para filtrar o município correspondente
// var municipio = municipiosRO
//     .filter(ee.Filter.eq('NM_MUN', municipio_nome))
//     .union();



print('Municipio', Corumbiara)


// Filtrar os biomas para excluir o bioma 'Amazônia'
var filtro_biomas = biomas.filter(ee.Filter.equals('Bioma', 'Amazônia'));
// var filtro_biomas = biomas.filter(ee.Filter.inList('Bioma', ['Caatinga', 'Cerrado', 'Mata Atlântica', 'Pantanal'])).union();
// var filtro_biomas = biomas.filter(ee.Filter.inList('Bioma', ['Caatinga', 'Cerrado', 'Mata Atlântica', 'Pantanal','Pampa'])).union();
// var points = ee.FeatureCollection('projects/mapbiomas-workspace/SOLOS/AMOSTRAS/ORIGINAIS/2024-11-26-organic-carbon-stock-gram-per-square-meter')
var points = ee.FeatureCollection('projects/mapbiomas-workspace/SOLOS/AMOSTRAS/ORIGINAIS/2024-12-01-organic-carbon-stock-gram-per-square-meter-filter-rep')
.filterBounds(Corumbiara) 
// .map(function(point){
  //     return point
  //         .select(['estoque', 'year', 'dataset_id'], ['estoque', 'year', 'dataset_id']);
  //         // .select(['soc_stock_t_ha', 'sampling_year', 'id'], ['estoque', 'year', 'dataset_id']);
  //         // .select(['carbono_estoque_gm2','data_coleta_ano','id'],['estoque','year','dataset_id']);
  // })

//Map.addLayer(points, {color: 'ff0000'}, 'Filtered Points', false);
Map.centerObject(Corumbiara, 8);
Map.addLayer(Corumbiara, {color: 'blue', opacity: 0.3}, 'Corumbiara');
Map.addLayer(points, {color: 'red'}, 'Amostras');


print('Total de amostras:', points.size());
print('Primeira amostra:', points.first());


var static_covariates = static_image; 
var dynamic_covariates = dynamic_images;

var matrix = ee.List([]);
points.aggregate_array('year').distinct().sort().evaluate(function(years){
  print('years',years);
  years.forEach(function(year){
    var dynamic_covariates_year = dynamic_covariates
    .filter(ee.Filter.eq('year',year))
    .first();
    
    var covariates = ee.Image().select()
    .addBands(static_covariates).round()
    .addBands(dynamic_covariates_year).round()
    .addBands(ee.Image(year).int16().rename('year'));
    
    var points_year = points
    .filter(ee.Filter.eq('year',year));
    
    var datatraining = covariates
    .sampleRegions({
      collection: points_year,
      properties: ['estoque','year','dataset_id'],
      scale: 30,
      geometries:true
    });
    
    matrix = matrix.add(datatraining);
  });
  
  matrix = ee.FeatureCollection(matrix).flatten();
  print('matrix', matrix.limit(10), matrix.size());
  
  
  
  var assetId = 'projects/ee-marcosanjos/assets/DEV/Corumbiara/matriz-' + version;
  //var assetId = 'projects/ee-marcosanjos/assets/DEV/' + municipio_nome + '/' + 'matriz-' + version;
  
  
  Export.table.toAsset({
    collection: matrix,
    description:version,
    assetId:assetId,
  });
});