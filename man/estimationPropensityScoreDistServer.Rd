% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/estimation-propensityScoreDistribution.R
\name{estimationPropensityScoreDistServer}
\alias{estimationPropensityScoreDistServer}
\title{The module server for rendering a PLE propensity score distribution}
\usage{
estimationPropensityScoreDistServer(
  id,
  selectedRow,
  inputParams,
  connection,
  resultsSchema
)
}
\arguments{
\item{id}{the unique reference id for the module}

\item{selectedRow}{the selected row from the main results table}

\item{inputParams}{the selected study parameters of interest}

\item{connection}{the connection to the PLE results database}

\item{resultsSchema}{the schema with the PLE results}
}
\value{
the PLE propensity score distribution content server
}
\description{
The module server for rendering a PLE propensity score distribution
}
