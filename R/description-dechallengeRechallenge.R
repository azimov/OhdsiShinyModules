# @file description-DechallengeRechallenge.R
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


#' The module viewer for exploring Dechallenge Rechallenge results 
#'
#' @details
#' The user specifies the id for the module
#'
#' @param id  the unique reference id for the module
#' 
#' @return
#' The user interface to the description Dechallenge Rechallenge module
#'
#' @export
descriptionDechallengeRechallengeViewer <- function(id) {
  ns <- shiny::NS(id)
  shiny::div(
    
    shiny::fluidRow(
      shinydashboard::box(
        status = 'info', width = 12,
        title = 'Options',
        solidHeader = TRUE,
        shiny::p('Select settings:'),
        shiny::uiOutput(ns('dechalRechalInputs'))
        )
    ),
    
    shiny::fluidRow(
    shinydashboard::tabBox(
      width = 12,
      # Title can include an icon
      title = shiny::tagList(shiny::icon("gear"), "Plots"),
      shiny::tabPanel(
        "Table",
         reactable::reactableOutput(ns('tableResults'))
      ),
      shiny::tabPanel(
        "Plot",
        shiny::plotOutput(ns('dechalplot'))
      )
    )
    )
    
    
  )
}


#' The module server for exploring Dechallenge Rechallenge results 
#'
#' @details
#' The user specifies the id for the module
#'
#' @param id  the unique reference id for the module
#' @param con the connection to the prediction result database
#' @param mainPanelTab the current tab 
#' @param schema the database schema for the model results
#' @param dbms the database management system for the model results
#' @param tablePrefix a string that appends the tables in the result schema
#' @param tempEmulationSchema  The temp schema (optional)
#' @param cohortTablePrefix a string that appends the cohort table in the result schema
#' @param databaseTable  name of the database table
#' 
#' @return
#' The server to the Dechallenge Rechallenge module
#'
#' @export
descriptionDechallengeRechallengeServer <- function(
  id, 
  con,
  mainPanelTab,
  schema, 
  dbms,
  tablePrefix,
  tempEmulationSchema,
  cohortTablePrefix = 'cg_',
  databaseTable = 'DATABASE_META_DATA'
) {
  shiny::moduleServer(
    id,
    function(input, output, session) {
      
      #if(mainPanelTab() != 'Time To Event'){
      #  return(invisible(NULL))
      #}
      
      # get the possible target ids
      bothIds <- dechalRechalGetIds(
        con,
        schema, 
        dbms,
        tablePrefix,
        tempEmulationSchema,
        cohortTablePrefix
      )

      shiny::observeEvent(
        input$targetId,{
          val <- bothIds$outcomeIds[[which(names(bothIds$outcomeIds) == input$targetId)]]
          shiny::updateSelectInput(
            session = session,
            inputId = 'outcomeId', 
            label = 'Outcome id: ',
            choices = val
          )
        }
      )
      
      # update UI
      output$dechalRechalInputs <- shiny::renderUI({
        
        shiny::fluidPage(
          shiny::fluidRow(
            shiny::selectInput(
              inputId = session$ns('targetId'), 
              label = 'Target id: ', 
              choices = bothIds$targetIds, 
              multiple = FALSE
            ),
            
            shiny::selectInput(
              inputId = session$ns('outcomeId'), 
              label = 'Outcome id: ', 
              choices = bothIds$outcomeIds[[1]],
              selected = 1
            ),
            
            shiny::actionButton(
              inputId = session$ns('fetchData'),
              label = 'Select'
            )
          )
        )
      }
      )
      
      databases <- shiny::reactiveVal(c())
      dechallengeStopInterval <- shiny::reactiveVal(c())
      dechallengeEvaluationWindow <- shiny::reactiveVal(c())
      
      # fetch data when targetId changes
      shiny::observeEvent(
        eventExpr = input$fetchData,
        {
          if(is.null(input$targetId) | is.null(input$outcomeId)){
            print('Null ids value')
            return(invisible(NULL))
          }
          allData <- getDechalRechalInputsData(
            targetId = input$targetId,
            outcomeId = input$outcomeId,
            con = con,
            schema = schema, 
            dbms = dbms,
            tablePrefix = tablePrefix,
            tempEmulationSchema = tempEmulationSchema,
            databaseTable = databaseTable
          )
          
          databases(allData$databaseId)
          dechallengeStopInterval(allData$dechallengeStopInterval)
          dechallengeEvaluationWindow(allData$dechallengeEvaluationWindow)
          
          output$tableResults <- reactable::renderReactable(
            {
              reactable::reactable(
                data = cbind(
                  view = rep("",nrow(allData)),
                  allData
                  )
                ,
                columns = list(  
                  view = reactable::colDef(
                    name = "",
                    sortable = FALSE,
                    cell = function() htmltools::tags$button("Plot Fails")
                  )
                ),
                onClick = reactable::JS(paste0("function(rowInfo, column) {
    // Only handle click events on the 'details' column
    if (column.id !== 'view') {
      return
    }

    if (window.Shiny) {
    if(column.id == 'view'){
      Shiny.setInputValue('",session$ns('databaseRowId'),"', { index: rowInfo.index + 1 }, { priority: 'event' })
    }
    }
  }")
                ),
                filterable = TRUE
              )
                
                
                
            }
          )
 
        }
      )
      
      
      # select database to view fails
      shiny::observeEvent(
        eventExpr = input$databaseRowId,
        {
          
          failData <- getDechalRechalFailData(
            targetId = input$targetId,
            outcomeId = input$outcomeId,
            databaseId = databases()[input$databaseRowId$index],
            dechallengeStopInterval = dechallengeStopInterval()[input$databaseRowId$index],
            dechallengeEvaluationWindow = dechallengeEvaluationWindow()[input$databaseRowId$index],
            con = con,
            schema = schema, 
            dbms = dbms,
            tablePrefix = tablePrefix,
            tempEmulationSchema = tempEmulationSchema
          )
          
        # do the plots reactively
        output$dechalplot <- shiny::renderPlot(
          plotDechalRechal(
            dechalRechalData = failData
          )
        )
      })
    
      
      return(invisible(NULL))
      
    }
  )
}

dechalRechalGetIds <- function(
  con,
  schema, 
  dbms,
  tablePrefix,
  tempEmulationSchema,
  cohortTablePrefix
){
  
  shiny::withProgress(message = 'Getting dechal Rechal T and O ids', value = 0, {
  
    
    sql <- "SELECT DISTINCT 
     t.COHORT_NAME as target, dr.TARGET_COHORT_DEFINITION_ID, 
     o.COHORT_NAME as outcome, dr.OUTCOME_COHORT_DEFINITION_ID 
  FROM @result_database_schema.@table_prefixDECHALLENGE_RECHALLENGE dr
 inner join @result_database_schema.@cohort_table_prefixCOHORT_DEFINITION t
          on dr.TARGET_COHORT_DEFINITION_ID = t.COHORT_DEFINITION_ID
   inner join @result_database_schema.@cohort_table_prefixCOHORT_DEFINITION o
          on dr.OUTCOME_COHORT_DEFINITION_ID = o.COHORT_DEFINITION_ID
  ;"
    
  sql <- SqlRender::render(
    sql = sql, 
    result_database_schema = schema,
    table_prefix = tablePrefix,
    cohort_table_prefix = cohortTablePrefix
  )
  
  shiny::incProgress(1/4, detail = paste("Rendering and translating sql"))
  
  sql <- SqlRender::translate(
    sql = sql, 
    targetDialect = dbms, 
    tempEmulationSchema = tempEmulationSchema
  )
  
  shiny::incProgress(2/4, detail = paste("Fetching ids"))
  
  bothIds <- DatabaseConnector::querySql(
    connection = con, 
    sql = sql, 
    snakeCaseToCamelCase = T
  )
  
  shiny::incProgress(3/4, detail = paste("Processing ids"))
  
  targetUnique <- bothIds %>% 
    dplyr::select(.data$targetCohortDefinitionId, .data$target) %>%
    dplyr::distinct()
  
  targetIds <- targetUnique$targetCohortDefinitionId
  names(targetIds) <- targetUnique$target
  
  outcomeIds <- lapply(targetIds, function(x){
    
    outcomeUnique <- bothIds %>% 
      dplyr::filter(.data$targetCohortDefinitionId == x) %>%
      dplyr::select(.data$outcomeCohortDefinitionId, .data$outcome) %>%
      dplyr::distinct()
    
    outcomeIds <- outcomeUnique$outcomeCohortDefinitionId
    names(outcomeIds) <- outcomeUnique$outcome
    
    return(outcomeIds)
    
  })
  
  names(outcomeIds) <- targetIds
  
  shiny::incProgress(4/4, detail = paste("Finished"))
  
  })
  
  return(
    list(
      targetIds = targetIds, 
      outcomeIds = outcomeIds
      )
  )
}

# pulls all data for a target and outcome
getDechalRechalInputsData <- function(
  targetId,
  outcomeId,
  con,
  schema, 
  dbms,
  tablePrefix,
  tempEmulationSchema,
  databaseTable
){
  
  
  shiny::withProgress(message = 'Extracting DECHALLENGE_RECHALLENGE data', value = 0, {
  
  sql <- "SELECT dr.*, d.CDM_SOURCE_ABBREVIATION as database_name 
          FROM @result_database_schema.@table_prefixDECHALLENGE_RECHALLENGE dr 
          inner join @result_database_schema.@database_table d
          on dr.database_id = d.database_id
          where dr.TARGET_COHORT_DEFINITION_ID = @target_id
          and dr.OUTCOME_COHORT_DEFINITION_ID = @outcome_id;"
  sql <- SqlRender::render(
    sql = sql, 
    result_database_schema = schema,
    table_prefix = tablePrefix,
    target_id = targetId,
    outcome_id = outcomeId,
    database_table = databaseTable
  )
  
  shiny::incProgress(1/3, detail = paste("Rendering and translating sql"))
  
  sql <- SqlRender::translate(
    sql = sql, 
    targetDialect = dbms, 
    tempEmulationSchema = tempEmulationSchema
  )
  
  shiny::incProgress(2/3, detail = paste("Fetching data"))
  
  data <- DatabaseConnector::querySql(
    connection = con, 
    sql = sql, 
    snakeCaseToCamelCase = T
  )
  
  shiny::incProgress(3/3, detail = paste("Finished"))
  
  })
  
  return(data)
}


getDechalRechalFailData <- function(
  targetId,
  outcomeId,
  databaseId,
  dechallengeStopInterval,
  dechallengeEvaluationWindow,
  con = con,
  schema = schema, 
  dbms = dbms,
  tablePrefix = tablePrefix,
  tempEmulationSchema = tempEmulationSchema
){
  
  shiny::withProgress(message = 'Extracting FAILLED DECHALLENGE_RECHALLENGE data', value = 0, {
    
    sql <- "SELECT * FROM @result_database_schema.@table_prefixRECHALLENGE_FAIL_CASE_SERIES 
          where TARGET_COHORT_DEFINITION_ID = @target_id
          and OUTCOME_COHORT_DEFINITION_ID = @outcome_id
          and DATABASE_ID = '@database_id'
          and DECHALLENGE_STOP_INTERVAL = @dechallenge_stop_interval	
          and DECHALLENGE_EVALUATION_WINDOW = @dechallenge_evaluation_window;"
    sql <- SqlRender::render(
      sql = sql, 
      result_database_schema = schema,
      table_prefix = tablePrefix,
      target_id = targetId,
      outcome_id = outcomeId,
      database_id = databaseId,
      dechallenge_stop_interval = dechallengeStopInterval,
      dechallenge_evaluation_window = dechallengeEvaluationWindow
    )
    
    shiny::incProgress(1/3, detail = paste("Rendering and translating sql"))
    
    sql <- SqlRender::translate(
      sql = sql, 
      targetDialect = dbms, 
      tempEmulationSchema = tempEmulationSchema
    )
    
    shiny::incProgress(2/3, detail = paste("Fetching data"))
    
    data <- DatabaseConnector::querySql(
      connection = con, 
      sql = sql, 
      snakeCaseToCamelCase = T
    )
    
    shiny::incProgress(3/3, detail = paste("Finished"))
    
  })
  
  return(data)
  
}

plotDechalRechal <- function(
  dechalRechalData,
  i = 1
){
  
  if(is.null(dechalRechalData)){
    return(NULL)
  }
  
  shiny::withProgress(message = 'Plotting DECHALLENGE_RECHALLENGE', value = 0, {
    
    
    # add the offsets (hack until update results)
    dechalRechalData <- dechalRechalData %>% 
      dplyr::mutate(
        dechallengeExposureNumber = .data$firstExposureNumber,
        dechallengeOutcomeNumber = .data$firstOutcomeNumber,
        dechallengeExposureEndDateOffset = difftime(.data$firstExposureStartDate, .data$firstExposureEndDate, units = "days"), 
        dechallengeExposureStartDateOffset = difftime(.data$firstExposureStartDate, .data$firstExposureStartDate, units = "days"), 
        dechallengeOutcomeStartDateOffset = difftime(.data$firstExposureStartDate, .data$firstOutcomeStartDate, units = "days"),  
        rechallengeExposureStartDateOffset = difftime(.data$firstExposureStartDate, .data$rechallengeExposureStartDate, units = "days"),   
        rechallengeExposureEndDateOffset = difftime(.data$firstExposureStartDate, .data$rechallengeExposureEndDate, units = "days"),   
        rechallengeOutcomeStartDateOffset = difftime(.data$firstExposureStartDate, .data$rechallengeOutcomeStartDate, units = "days"),  
      )
    
  
    #order the data so that cases are in order of exposure/outcome offsets
    dechalRechalData <- dechalRechalData %>% 
      dplyr::arrange(
        dechallengeExposureStartDateOffset, 
        dechallengeOutcomeStartDateOffset, 
        rechallengeExposureStartDateOffset, 
        rechallengeOutcomeStartDateOffset
        )
    
    #give temp ID for purposes of allowing plotting in order of sort
    cases <- data.frame(subjectId = unique(dechalRechalData$subjectId))
    cases <- tibble::rowid_to_column(cases, "PID")
    dechalRechalData <- dechalRechalData %>% dplyr::inner_join(cases)
    
    
      i50 <- min(i + 49,length(cases$subject_id))
      caseSubset <- cases[i:i50,2]
      
      #grab the cases to plot      
      rdcsSubset <- dechalRechalData %>% 
        dplyr::filter(
          .data$subjectId %in% caseSubset
          )
      
      #small datasets to fit ggplot
      dechallengeExposure <- rdcsSubset %>%
        dplyr::select(
          .data$PID, 
          .data$targetCohortDefinitionId, 
          .data$outcomeCohortDefinitionId, 
          .data$subjectId, 
          .data$dechallengeExposureNumber,
          .data$dechallengeExposureStartDateOffset, 
          .data$dechallengeExposureEndDateOffset
          ) %>%
        dplyr::mutate(
          eventId = .data$subjectId*1000 + .data$dechallengeExposureNumber
          ) %>%
        dplyr::rename(
          eventNumber = .data$dechallengeExposureNumber, 
          eventStart = .data$dechallengeExposureStartDateOffset, 
          eventEnd = .data$dechallengeExposureEndDateOffset) %>%
        dplyr::distinct() %>%
        tidyr::pivot_longer(
          cols = c(.data$eventStart, .data$eventEnd),
          names_to = "eventDateType",
          values_to = "offset"
        )
      
      dechallengeStarts <- dechallengeExposure %>% 
        dplyr::filter(.data$eventDateType == "eventStart")
      
      dechallengeOutcome <- rdcsSubset %>%
        dplyr::select(
          .data$PID, 
          .data$targetCohortDefinitionId, 
          .data$outcomeCohortDefinitionId, 
          .data$subjectId, 
          .data$dechallengeOutcomeNumber, 
          .data$dechallengeOutcomeStartDateOffset
          ) %>%
        dplyr::mutate(
          eventId = .data$subjectId*1000 + .data$dechallengeOutcomeNumber
          ) %>%
        dplyr::rename(
          eventNumber = .data$dechallengeOutcomeNumber, 
          offset = .data$dechallengeOutcomeStartDateOffset
          ) %>%
        dplyr::distinct()
      
      
      rechallengeExposure <- rdcsSubset %>%
        dplyr::select(
          .data$PID, 
          .data$targetCohortDefinitionId, 
          .data$outcomeCohortDefinitionId, 
          .data$subjectId, 
          .data$rechallengeExposureNumber, 
          .data$rechallengeExposureStartDateOffset, 
          .data$rechallengeExposureEndDateOffset
          ) %>%
        dplyr::mutate(
          eventId = .data$subjectId*1000 + .data$rechallengeExposureNumber
          ) %>%
        dplyr::rename(
          eventNumber = .data$rechallengeExposureNumber, 
          eventStart = .data$rechallengeExposureStartDateOffset, 
          eventEnd = .data$rechallengeExposureEndDateOffset
          ) %>%
        dplyr::distinct() %>%
        tidyr::pivot_longer(
          cols = c(.data$eventStart, .data$eventEnd),
          names_to = "eventDateType",
          values_to = "offset"
        )
      
      rechallengeStarts <- rechallengeExposure %>% 
        dplyr::filter(
          .data$eventDateType == "eventStart"
          )
      
      
      rechallengeOutcome <- rdcsSubset %>%
        dplyr::select(
          .data$PID, 
          .data$targetCohortDefinitionId, 
          .data$outcomeCohortDefinitionId, 
          .data$subjectId, 
          .data$rechallengeOutcomeNumber, 
          .data$rechallengeOutcomeStartDateOffset
          ) %>%
        dplyr::mutate(
          eventId = .data$subjectId*1000 + .data$rechallengeOutcomeNumber
          ) %>%
        dplyr::rename(
          eventNumber = .data$rechallengeOutcomeNumber, 
          offset = .data$rechallengeOutcomeStartDateOffset) %>%
        dplyr::distinct()
      
      shiny::incProgress(1/2, detail = paste("Formatted data, now plotting"))
      
      
      # ggplot lays out dechallenge/rechallenge exposure eras and points for each outcome
      plot <- ggplot2::ggplot(
        data = dechallengeExposure, 
        ggplot2::aes(
          x = .data$offset, 
          y = .data$PID, 
          label = .data$eventNumber
          )
        ) +
        ggplot2::geom_line(
          data = dechallengeExposure, 
          ggplot2::aes(group = .data$eventId), 
          size = 2, 
          color = "blue"
          ) +
        ggplot2::geom_line(
          data = rechallengeExposure, 
          ggplot2::aes(group = eventId), 
          size = 2, 
          color = "navyblue"
          ) +
        ggplot2::geom_point(
          data = dechallengeOutcome, 
          color = "darkorange", 
          size = 2, 
          shape = 8
          ) +
        ggplot2::geom_point(
          data = rechallengeOutcome, 
          color = "orangered", 
          size = 2, 
          shape = 8
          ) +
        ggplot2::geom_text(
          data = dechallengeStarts, 
          hjust = 1, 
          vjust = 0, 
          color = "blue", 
          size = 2
          ) +
        ggplot2::geom_text(
          data = rechallengeStarts, 
          hjust = 1, 
          vjust = 0, 
          color = "navyblue", 
          size = 2
          ) +
        ggplot2::geom_text(
          data = dechallengeOutcome, 
          color = "darkorange", 
          hjust = -.5, 
          vjust = -.5, 
          size = 2
          ) +
        ggplot2::geom_text(
          data = rechallengeOutcome, 
          color = "orangered", 
          hjust = -.5, 
          vjust = -.5, 
          size = 2
          ) +
        ggplot2::scale_y_reverse() +
        ggplot2::theme_bw() + 
        ggplot2::theme(
          panel.border = ggplot2::element_blank(), 
          panel.grid.major = ggplot2::element_blank(),
          panel.grid.minor = ggplot2::element_blank(), 
          axis.line = ggplot2::element_line(colour = "black"),
          axis.text.y = ggplot2::element_blank(),
          axis.ticks.y = ggplot2::element_blank() 
          ) +
        ggplot2::xlab("Time from first exposure") + 
        ggplot2::ylab("Each horizontal line is one person")
  
  shiny::incProgress(2/2, detail = paste("Finished"))
  
  })
  
  
    return(plot)
}
