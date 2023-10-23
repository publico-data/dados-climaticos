library(tidyverse)
library(jsonlite)
library(lubridate)
library(glue)

co2 <- read_csv("https://gml.noaa.gov/webdata/ccgg/trends/co2/co2_mm_mlo.csv", skip = 40) %>% 
  select(year, month, average, deseasonalized) %>% 
  mutate(date = glue("{year}-{month}-01")) %>% 
  mutate(date = ymd(date))

compare_co2_1 <- co2 %>% 
  filter(date == max(date))

compare_co2_2 <- co2 %>% 
  filter(month == month(compare_co2_1$date[1])) %>% 
  filter(date == min(date))

compare_co2 <- compare_co2_1 %>% 
  bind_rows(compare_co2_2)

diff <- compare_co2$average[1] - compare_co2$average[2]

co_data <- list(
  nome= "Concentração de Dióxido de Carbono na Atmosfera",
  descricao= "Valores mensais de Dióxido de Carbono na Atmosfera registados nos sensores do observatório de Mauna Loa, Havai",
  utltima_actualizacao = compare_co2_1$date,
  periodicidade = "mensal",
  unidade = "ppm",
  unidade_full = "partes por milhão",
  fonte =  "Instituto Scripps de Oceanografia/Administração Nacional Oceânica e Atmosférica dos EUA",
  value = diff,
  descricao_valor = glue("Diferença face a {month(compare_co2$month[2], label = T, abbr = F, locale = 'pt_PT')} de {compare_co2$year[2]}"),
  data = co2 %>% select(date,average, deseasonalized) %>% rename("trend" = "deseasonalized")
)

co_data %>% toJSON( auto_unbox = T) %>% write_file("data/concentracao_co2.json")


