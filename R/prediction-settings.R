# @file prediction-settings.R
#
# Copyright 2022 Observational Health Data Sciences and Informatics
#
# This file is part of OhdsiShinyModules
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


#' The module viewer for exploring prediction settings 
#'
#' @details
#' The user specifies the id for the module
#'
#' @param id  the unique reference id for the module
#' 
#' @return
#' The user interface to the settings module
#'
#' @export
predictionSettingsViewer <- function(id) {
  ns <- shiny::NS(id)
  
  shiny::div(
    
    shinydashboard::box(
      width = 12,
      title = "Settings Dashboard",
      status = "info", solidHeader = TRUE,
      shinydashboard::infoBoxOutput(ns("cohort"), width = 4),
      shinydashboard::infoBoxOutput(ns("outcome"), width = 4),
      shinydashboard::infoBoxOutput(ns("restrictPlpData"), width = 4),
      shinydashboard::infoBoxOutput(ns("population"), width = 4),
      shinydashboard::infoBoxOutput(ns("covariates"), width = 4),
      shinydashboard::infoBoxOutput(ns("featureEngineering"), width = 4),
      shinydashboard::infoBoxOutput(ns("preprocess"), width = 4),
      shinydashboard::infoBoxOutput(ns("split"), width = 4),
      shinydashboard::infoBoxOutput(ns("sample"), width = 4),
      shinydashboard::infoBoxOutput(ns("model"), width = 4),
      shinydashboard::infoBoxOutput(ns("hyperparameters"), width = 4),
      shinydashboard::infoBoxOutput(ns("attrition"), width = 4)
    )
    
  )
}

#' The module server for exploring prediction settings
#'
#' @details
#' The user specifies the id for the module
#'
#' @param id  the unique reference id for the module
#' @param modelDesignId unique id for the model design
#' @param developmentDatabaseId  unique id for the development database
#' @param performanceId unique id for the performance results
#' @param con the connection to the prediction result database
#' @param inputSingleView the current tab 
#' @param mySchema the database schema for the model results
#' @param targetDialect the database management system for the model results
#' @param myTableAppend a string that appends the tables in the result schema
#' 
#' @return
#' The server to the settings module
#'
#' @export
predictionSettingsServer <- function(
  id,
  modelDesignId, 
  developmentDatabaseId, 
  performanceId,
  mySchema, 
  con,
  inputSingleView,
  myTableAppend, 
  targetDialect                     
) {
  
  shiny::moduleServer(
    id,
    function(input, output, session) {
      
      shiny::observe({
        if(
          !is.null(modelDesignId()) & 
          inputSingleView() == 'Design Settings' &
          !is.null(developmentDatabaseId()) & 
          !is.null(performanceId())
          ){
          
          modelDesign <- getModelDesign(
            modelDesignId = modelDesignId,
            mySchema, 
            con,
            myTableAppend, 
            targetDialect   
          )
          
          hyperParamSearch <- getHyperParamSearch(
            modelDesignId = modelDesignId,
            databaseId = developmentDatabaseId,
            mySchema, 
            con,
            myTableAppend, 
            targetDialect   
          ) 
          
          attrition <- getAttrition(
            performanceId = performanceId,
            mySchema, 
            con,
            myTableAppend, 
            targetDialect   
          ) 
          
          # cohort settings
          output$cohort <- shinydashboard::renderInfoBox({
            shinydashboard::infoBox(
              'Cohort',
              shiny::actionButton(session$ns("showCohort"),"View"), 
              icon = shiny::icon("users"),
              color = "light-blue"
            )
          })
          shiny::observeEvent(
            input$showCohort, {
              shiny::showModal(shiny::modalDialog(
                title = "Cohort description",
                shiny::p(modelDesign$cohort$cohortJson),
                easyClose = TRUE,
                footer = NULL
              ))
            }
          )
          
          # outcome settings
          output$outcome <- shinydashboard::renderInfoBox({
            shinydashboard::infoBox(
              'Outcome',
              shiny::actionButton(session$ns("showOutcome"),"View"), 
              icon = shiny::icon("heart"),
              color = "light-blue"
            )
          })
          shiny::observeEvent(
            input$showOutcome, {
              shiny::showModal(shiny::modalDialog(
                title = "Cohort description",
                shiny::p(modelDesign$outcome$cohortJson),
                easyClose = TRUE,
                footer = NULL
              ))
            }
          )
          
          
          # restrictPlpData settings
          output$restrictPlpData <- shinydashboard::renderInfoBox({
            shinydashboard::infoBox(
              'RestrictPlpData',
              shiny::actionButton(session$ns("showRestrictPlpData"),"View"), 
              icon = shiny::icon("filter"),
              color = "light-blue"
            )
          })
          shiny::observeEvent(
            input$showRestrictPlpData, {
              shiny::showModal(shiny::modalDialog(
                title = "Exclusions done during data extraction",
                shiny::p(modelDesign$RestrictPlpData),
                easyClose = TRUE,
                footer = NULL
              ))
            }
          )
          
          
          # Population settings
          output$population <- shinydashboard::renderInfoBox({
            shinydashboard::infoBox(
              'Population',
              shiny::actionButton(session$ns("showPopulation"),"View"), 
              icon = shiny::icon("users-slash"),
              color = "light-blue", 
              width = 3,
            )
          })
          shiny::observeEvent(
            input$showPopulation, {
              shiny::showModal(shiny::modalDialog(
                title = "Population Settings - exclusions after data extraction",
                shiny::div(
                  shiny::a("help", href="https://ohdsi.github.io/PatientLevelPrediction/reference/createStudyPopulation.html", target="_blank"),
                  DT::renderDataTable(
                    formatPopSettings(modelDesign$populationSettings)
                  )
                ),
                easyClose = TRUE,
                footer = NULL
              ))
            }
          )
          
          # Covariate settings
          output$covariates <- shinydashboard::renderInfoBox({
            shinydashboard::infoBox(
              'Covariates',
              shiny::actionButton(session$ns("showCovariates"),"View"), 
              icon = shiny::icon("street-view"),
              color = "light-blue"
            )
          })
          shiny::observeEvent(
            input$showCovariates, {
              shiny::showModal(shiny::modalDialog(
                title = "Covariate Settings",
                shiny::div(
                  shiny::a("help", href="http://ohdsi.github.io/FeatureExtraction/reference/createCovariateSettings.html", target="_blank"),
                  DT::renderDataTable(
                    formatCovSettings(modelDesign$covariateSettings)
                  )
                ),
                easyClose = TRUE,
                footer = NULL
              ))
            }
          )
          
          # Model settings
          output$model <- shinydashboard::renderInfoBox({
            shinydashboard::infoBox(
              'Model',
              shiny::actionButton(session$ns("showModel"),"View"), 
              icon = shiny::icon("sliders-h"),
              color = "light-blue"
            )
          })
          shiny::observeEvent(
            input$showModel, {
              shiny::showModal(shiny::modalDialog(
                title = "Model Settings",
                shiny::div(
                  shiny::h3('Model Settings: ',
                            shiny::a("help", href="https://ohdsi.github.io/PatientLevelPrediction/reference/index.html", target="_blank")
                  ),
                  DT::renderDataTable(
                    formatModSettings(modelDesign$modelSettings  )
                  )
                ),
                easyClose = TRUE,
                footer = NULL
              ))
            }
          )
          
          # featureEngineering settings
          output$featureEngineering <- shinydashboard::renderInfoBox({
            shinydashboard::infoBox(
              'Feature Engineering',
              shiny::actionButton(session$ns("showFeatureEngineering"),"View"), 
              icon = shiny::icon("lightbulb"),
              color = "light-blue"
            )
          })
          shiny::observeEvent(
            input$showFeatureEngineering, {
              shiny::showModal(shiny::modalDialog(
                title = "Feature Engineering Settings",
                shiny::div(
                  shiny::p(modelDesign$featureEngineeringSettings)
                ),
                easyClose = TRUE,
                footer = NULL
              ))
            }
          )
          
          # preprocess settings
          output$preprocess <- shinydashboard::renderInfoBox({
            shinydashboard::infoBox(
              'Preprocess',
              shiny::actionButton(session$ns("showPreprocess"),"View"), 
              icon = shiny::icon("chalkboard"),
              color = "light-blue"
            )
          })
          shiny::observeEvent(
            input$showPreprocess, {
              shiny::showModal(shiny::modalDialog(
                title = "Preprocess Settings",
                shiny::div(
                  shiny::p(modelDesign$preprocessSettings)
                ),
                easyClose = TRUE,
                footer = NULL
              ))
            }
          )
          
          # split settings
          output$split <- shinydashboard::renderInfoBox({
            shinydashboard::infoBox(
              'Split',
              shiny::actionButton(session$ns("showSplit"),"View"), 
              icon = shiny::icon("object-ungroup"),
              color = "light-blue"
            )
          })
          shiny::observeEvent(
            input$showSplit, {
              shiny::showModal(shiny::modalDialog(
                title = "Split Settings",
                shiny::div(
                  shiny::p(modelDesign$splitSettings)
                ),
                easyClose = TRUE,
                footer = NULL
              ))
            }
          )
          
          # sample settings
          output$sample <- shinydashboard::renderInfoBox({
            shinydashboard::infoBox(
              'Sample',
              shiny::actionButton(session$ns("showSample"),"View"), 
              icon = shiny::icon("equals"),
              color = "light-blue"
            )
          })
          shiny::observeEvent(
            input$showSample, {
              shiny::showModal(shiny::modalDialog(
                title = "Sample Settings",
                shiny::div(
                  shiny::p(modelDesign$sampleSettings)
                ),
                easyClose = TRUE,
                footer = NULL
              ))
            }
          )
          
          # extras
          
          # hyper-param
          output$hyperparameters<- shinydashboard::renderInfoBox({
            shinydashboard::infoBox(
              'Hyper-parameters',
              shiny::actionButton(session$ns("showHyperparameters"),"View"), 
              icon = shiny::icon('gear'),
              color = "light-blue"
            )
          })
          shiny::observeEvent(
            input$showHyperparameters, {
              shiny::showModal(shiny::modalDialog(
                title = "Hyper-parameters",
                shiny::div(
                  DT::renderDataTable(
                    DT::datatable(
                      as.data.frame(
                        hyperParamSearch
                      ),
                      options = list(scrollX = TRUE),
                      colnames = 'Fold AUROC'
                    )
                  )
                ),
                easyClose = TRUE,
                footer = NULL
              ))
            }
          )
          
          # attrition
          output$attrition <- shinydashboard::renderInfoBox({
            shinydashboard::infoBox(
              'Attrition',
              shiny::actionButton(session$ns("showAttrition"),"View"), 
              icon = shiny::icon('magnet'),
              color = "light-blue"
            )
          })
          shiny::observeEvent(
            input$showAttrition, {
              shiny::showModal(shiny::modalDialog(
                title = "Attrition",
                shiny::div(
                  DT::renderDataTable(
                    attrition %>% dplyr::select(-.data$performanceId, -.data$outcomeId)
                  )
                ),
                easyClose = TRUE,
                footer = NULL
              ))
            }
          )
          
        }
      }
      )
    }
    
  )
}         



# helpers


# get the data
getModelDesign <- function(
  modelDesignId,
  mySchema, 
  con,
  myTableAppend, 
  targetDialect   
){
  if(!is.null(modelDesignId())){
    print(paste0('model design: ', modelDesignId()))
    
    shiny::withProgress(message = 'Extracting model design', value = 0, {
      
    modelDesign <- list()
    
    shiny::incProgress(1/12, detail = paste("Extracting ids"))
    
    sql <- "SELECT * FROM 
    @my_schema.@my_table_appendmodel_designs 
    WHERE model_design_id = @model_design_id;"
    
    sql <- SqlRender::render(sql = sql, 
                             my_schema = mySchema,
                             model_design_id = modelDesignId(),
                             my_table_append = myTableAppend)
    sql <- SqlRender::translate(sql = sql, targetDialect =  targetDialect)
    ParallelLogger::logInfo("starting population, model setting and covariate setting")
    
    ids <- DatabaseConnector::dbGetQuery(conn =  con, statement = sql) 
    colnames(ids) <- SqlRender::snakeCaseToCamelCase(colnames(ids))
    
    ParallelLogger::logInfo("finishing getting model design setting ids")
    
    popSetId <- ids$populationSettingId
    modSetId <- ids$modelSettingId
    covSetId <- ids$covariateSettingId
    feSetId <- ids$featureEngineeringSettingId
    sampleSetId <- ids$sampleSettingId
    splitId <- ids$splitSettingId
    tId <- ids$targetId
    oId <- ids$outcomeId
    plpDataSettingId <- ids$plpDataSettingId
    tidyCovariatesSettingId <- ids$tidyCovariatesSettingId
    
    shiny::incProgress(2/12, detail = paste("Extracting model settings"))
    
    ParallelLogger::logInfo("start modeSet")
    sql <- "SELECT * FROM @my_schema.@my_table_appendmodel_settings WHERE model_setting_id = @model_setting_id"
    sql <- SqlRender::render(sql = sql, 
                             my_schema = mySchema,
                             model_setting_id = modSetId,
                             my_table_append = myTableAppend)
    sql <- SqlRender::translate(sql = sql, targetDialect =  targetDialect)
    
    tempModSettings <- DatabaseConnector::dbGetQuery(conn =  con, statement = sql) 
    colnames(tempModSettings) <- SqlRender::snakeCaseToCamelCase(colnames(tempModSettings))
    ParallelLogger::logInfo("end modeSet")
    
    modelDesign$modelSettings <- ParallelLogger::convertJsonToSettings(tempModSettings$modelSettingsJson)
    
    shiny::incProgress(3/12, detail = paste("Extracting  covariate settings"))
    ParallelLogger::logInfo("start covSet")
    sql <- "SELECT * FROM @my_schema.@my_table_appendcovariate_settings WHERE covariate_setting_id = @setting_id"
    sql <- SqlRender::render(sql = sql, 
                             my_schema = mySchema,
                             setting_id = covSetId,
                             my_table_append = myTableAppend)
    sql <- SqlRender::translate(sql = sql, targetDialect =  targetDialect)
    tempSettings <- DatabaseConnector::dbGetQuery(conn =  con, statement = sql) 
    colnames(tempSettings) <- SqlRender::snakeCaseToCamelCase(colnames(tempSettings))
    modelDesign$covariateSettings <- ParallelLogger::convertJsonToSettings(tempSettings$covariateSettingsJson)
    ParallelLogger::logInfo("end covSet")
    
    shiny::incProgress(4/12, detail = paste("Extracting population settings"))
    ParallelLogger::logInfo("start popSet")
    sql <- "SELECT * FROM @my_schema.@my_table_appendpopulation_settings WHERE population_setting_id = @setting_id"
    sql <- SqlRender::render(sql = sql, 
                             my_schema = mySchema,
                             setting_id = popSetId,
                             my_table_append = myTableAppend)
    sql <- SqlRender::translate(sql = sql, targetDialect =  targetDialect)
    tempSettings <- DatabaseConnector::dbGetQuery(conn =  con, statement = sql) 
    colnames(tempSettings) <- SqlRender::snakeCaseToCamelCase(colnames(tempSettings))
    modelDesign$populationSettings <- ParallelLogger::convertJsonToSettings(tempSettings$populationSettingsJson)
    ParallelLogger::logInfo("end popSet")
    
    shiny::incProgress(5/12, detail = paste("Extracting feature engineering settingd"))
    ParallelLogger::logInfo("start feSet")
    sql <- "SELECT * FROM @my_schema.@my_table_appendfeature_engineering_settings WHERE feature_engineering_setting_id = @setting_id"
    sql <- SqlRender::render(sql = sql, 
                             my_schema = mySchema,
                             setting_id = feSetId,
                             my_table_append = myTableAppend)
    sql <- SqlRender::translate(sql = sql, targetDialect =  targetDialect)
    tempSettings <- DatabaseConnector::dbGetQuery(conn =  con, statement = sql) 
    colnames(tempSettings) <- SqlRender::snakeCaseToCamelCase(colnames(tempSettings))
    modelDesign$featureEngineeringSettings <- tempSettings$featureEngineeringSettingsJson
    ParallelLogger::logInfo("end feSet")
    
    shiny::incProgress(6/12, detail = paste("Extracting tidy covariate settings"))
    ParallelLogger::logInfo("start tidySet")
    sql <- "SELECT * FROM @my_schema.@my_table_appendtidy_covariates_settings WHERE tidy_covariates_setting_id = @setting_id"
    sql <- SqlRender::render(sql = sql, 
                             my_schema = mySchema,
                             setting_id = tidyCovariatesSettingId,
                             my_table_append = myTableAppend)
    sql <- SqlRender::translate(sql = sql, targetDialect =  targetDialect)
    tempSettings <- DatabaseConnector::dbGetQuery(conn =  con, statement = sql) 
    colnames(tempSettings) <- SqlRender::snakeCaseToCamelCase(colnames(tempSettings))
    modelDesign$preprocessSettings <- tempSettings$tidyCovariatesSettingsJson
    ParallelLogger::logInfo("end tidySet")
    
    shiny::incProgress(7/12, detail = paste("Extracting restrict plp settings"))
    ParallelLogger::logInfo("start RestrictPlpData")
    sql <- "SELECT * FROM @my_schema.@my_table_appendplp_data_settings WHERE plp_data_setting_id = @setting_id"
    sql <- SqlRender::render(sql = sql, 
                             my_schema = mySchema,
                             setting_id = plpDataSettingId,
                             my_table_append = myTableAppend)
    sql <- SqlRender::translate(sql = sql, targetDialect =  targetDialect)
    tempSettings <- DatabaseConnector::dbGetQuery(conn =  con, statement = sql) 
    colnames(tempSettings) <- SqlRender::snakeCaseToCamelCase(colnames(tempSettings))
    modelDesign$RestrictPlpData <- tempSettings$plpDataSettingsJson
    ParallelLogger::logInfo("end RestrictPlpData")
    
    shiny::incProgress(8/12, detail = paste("Extracting sample settings"))
    ParallelLogger::logInfo("start sampleSet")
    sql <- "SELECT * FROM @my_schema.@my_table_appendsample_settings WHERE sample_setting_id = @setting_id"
    sql <- SqlRender::render(sql = sql, 
                             my_schema = mySchema,
                             setting_id = sampleSetId,
                             my_table_append = myTableAppend)
    sql <- SqlRender::translate(sql = sql, targetDialect =  targetDialect)
    tempSettings <- DatabaseConnector::dbGetQuery(conn =  con, statement = sql) 
    colnames(tempSettings) <- SqlRender::snakeCaseToCamelCase(colnames(tempSettings))
    modelDesign$sampleSettings <- tempSettings$sampleSettingsJson
    ParallelLogger::logInfo("end sampleSet")
    
    shiny::incProgress(9/12, detail = paste("Extracting split settings"))
    ParallelLogger::logInfo("start splitSet")
    sql <- "SELECT * FROM @my_schema.@my_table_appendsplit_settings WHERE split_setting_id = @setting_id"
    sql <- SqlRender::render(sql = sql, 
                             my_schema = mySchema,
                             setting_id = splitId,
                             my_table_append = myTableAppend)
    sql <- SqlRender::translate(sql = sql, targetDialect =  targetDialect)
    tempSettings <- DatabaseConnector::dbGetQuery(conn =  con, statement = sql) 
    colnames(tempSettings) <- SqlRender::snakeCaseToCamelCase(colnames(tempSettings))
    modelDesign$splitSettings <- tempSettings$splitSettingsJson
    ParallelLogger::logInfo("end splitSet")
    
    shiny::incProgress(10/12, detail = paste("Extracting target cohort"))
    ParallelLogger::logInfo("start cohort")
    sql <- "SELECT * FROM @my_schema.@my_table_appendcohorts WHERE cohort_id = @setting_id"
    sql <- SqlRender::render(sql = sql, 
                             my_schema = mySchema,
                             setting_id = tId,
                             my_table_append = myTableAppend)
    sql <- SqlRender::translate(sql = sql, targetDialect =  targetDialect)
    tempSettings <- DatabaseConnector::dbGetQuery(conn =  con, statement = sql) 
    colnames(tempSettings) <- SqlRender::snakeCaseToCamelCase(colnames(tempSettings))
    modelDesign$cohort <- tempSettings
    ParallelLogger::logInfo("end cohort")
    
    shiny::incProgress(11/12, detail = paste("Extracting outcome cohort"))
    ParallelLogger::logInfo("start outcome")
    sql <- "SELECT * FROM @my_schema.@my_table_appendcohorts WHERE cohort_id = @setting_id"
    sql <- SqlRender::render(sql = sql, 
                             my_schema = mySchema,
                             setting_id = oId,
                             my_table_append = myTableAppend)
    sql <- SqlRender::translate(sql = sql, targetDialect =  targetDialect)
    tempSettings <- DatabaseConnector::dbGetQuery(conn =  con, statement = sql) 
    colnames(tempSettings) <- SqlRender::snakeCaseToCamelCase(colnames(tempSettings))
    modelDesign$outcome <- tempSettings
    ParallelLogger::logInfo("end outcome")
    
    shiny::incProgress(12/12, detail = paste("Finished"))
    
    })
    
    return(modelDesign)
  }
  return(NULL)
}


getHyperParamSearch <- function(
  modelDesignId,
  databaseId,
  mySchema, 
  con,
  myTableAppend, 
  targetDialect   
){
  ParallelLogger::logInfo(paste0('Getting hyper param settings for model ', modelDesignId(), ' in database ', databaseId()))
  
  sql <- "SELECT train_details FROM @my_schema.@my_table_appendmodels WHERE database_id = @database_id
       and model_design_id = @model_design_id"
  sql <- SqlRender::render(sql = sql, 
                           my_schema = mySchema,
                           database_id = databaseId(),
                           model_design_id = modelDesignId(),
                           my_table_append = myTableAppend)
  sql <- SqlRender::translate(sql = sql, targetDialect =  targetDialect)
  models <- DatabaseConnector::dbGetQuery(conn =  con, statement = sql) 
  colnames(models) <- SqlRender::snakeCaseToCamelCase(colnames(models))
  
  trainDetails <- ParallelLogger::convertJsonToSettings(models$trainDetails)
  
  return(trainDetails$hyperParamSearch)
}


getAttrition <- function(
  performanceId,
  mySchema, 
  con,
  myTableAppend, 
  targetDialect   
){
  ParallelLogger::logInfo(paste0('Getting attrition for performance ', performanceId()))
  
  sql <- "SELECT * FROM @my_schema.@my_table_appendattrition WHERE performance_id = @performance_id"
  ParallelLogger::logInfo("start attrition")
  sql <- SqlRender::render(sql = sql, 
                           my_schema = mySchema,
                           performance_id = performanceId(),
                           my_table_append = myTableAppend)
  sql <- SqlRender::translate(sql = sql, targetDialect =  targetDialect)
  
  attrition  <- DatabaseConnector::dbGetQuery(conn =  con, statement = sql) 
  colnames(attrition) <- SqlRender::snakeCaseToCamelCase(colnames(attrition))
  ParallelLogger::logInfo("end attrition")
  
  return(attrition)
}

# formating
formatModSettings <- function(modelSettings){
  
  modelset <- data.frame(
    paramJson = as.character(
      ParallelLogger::convertSettingsToJson(
        modelSettings$param
      )
    )
  )
  
  return(modelset)
}

# format covariateSettings
formatCovSettings <- function(covariateSettings){
  
  if(class(covariateSettings)=='covariateSettings'){
    covariateSettings <- list(covariateSettings)
  }
  
  #code for when multiple covariateSettings
  covariates <- c() 
  for(i in 1:length(covariateSettings)){
    covariatesTemp <- data.frame(
      fun = attr(covariateSettings[[i]],'fun'),
      setting = i,
      covariateName = names(covariateSettings[[i]]), 
      SettingValue = unlist(
        lapply(
          covariateSettings[[i]], 
          function(x) paste0(x, collapse='-')
        )
      )
    )
    covariates  <- rbind(covariates,covariatesTemp)
  }
  row.names(covariates) <- NULL
  return(covariates)
}

# format populationSettings
formatPopSettings <- function(populationSettings){
  population <- populationSettings
  population$attrition <- NULL # remove the attrition as result and not setting
  population <- data.frame(Setting = names(population), 
                           Value = unlist(lapply(population, 
                                                 function(x) paste0(x, 
                                                                    collapse='-')))
  ) 
  row.names(population) <- NULL
  return(population)
}

