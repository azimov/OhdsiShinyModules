context("prediction-cutoff")

shiny::testServer(
  app = predictionCutoffServer, 
  args = list(
    performanceId = shiny::reactiveVal(1),
    con = connection,
    mySchema = mySchemaTest,
    inputSingleView = shiny::reactiveVal("Threshold Dependant"),
    targetDialect = targetDialectTest,
    myTableAppend = myTableAppendTest
  ), 
  expr = {
    
    # check the view to trigger event
    inputSingleView(NULL)
    inputSingleView("Threshold Dependant")
    
    expect_true(!is.null(thresholdSummary()))
    
    session$setInputs(slider1 = 1)
    expect_true(!is.null(performance()))
    expect_true(performance()$threshold >= 0) 
    expect_true(performance()$threshold <= 1) 
    expect_true(nrow(performance()$twobytwo)>0)

  })