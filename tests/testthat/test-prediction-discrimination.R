context("prediction-discrimination")

shiny::testServer(
  app = predictionDiscriminationServer, 
  args = list(
    performanceId = shiny::reactiveVal(1),
    con = connection,
    mySchema = mySchemaTest,
    inputSingleView = shiny::reactiveVal("Discrimination"),
    targetDialect = targetDialectTest,
    myTableAppend = myTableAppendTest
  ), 
  expr = {
    
    # should have discrimination results
    expect_true(nrow(sumTable())>0)
    expect_true(length(plots())>0)
    
    # check the view to trigger event
    inputSingleView(NULL)
    inputSingleView("Discrimination")
    
    session$setInputs(show_view = list(index = 1)) 
    #prefDistHelp = T
    
    # check helpers
    session$setInputs(prefDistHelp = T) 
    session$setInputs(predDistHelp = T) 
    session$setInputs(boxHelp = T) 
    session$setInputs(f1Help = T) 
    session$setInputs(prcHelp = T) 
    session$setInputs(rocHelp = T)
   
  })