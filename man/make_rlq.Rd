% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RLQ.R
\name{make_rlq}
\alias{make_rlq}
\title{Create matrices for RLQ analysis}
\usage{
make_rlq(sitename, .invert, .traits, .bromvars)
}
\arguments{
\item{sitename}{name of site}

\item{.invert}{invertebrate data.frame}

\item{.traits}{trait data.frame}

\item{.bromvars}{bromeliad variable data.frame}
}
\value{
named list of matrices: R, L and Q
}
\description{
Combines data on inverts, traits and bromeliads to create RLQ matrices.
}
\details{
RLQ analysis is a means of relating three datasets: species traits, habitat traits, and species abundances. There are three matrices required for this analysis, as follows:

\itemize{
  \item  species x traits matrix (fuzzy coding) = matrix Q
  \item a species x bromeliad matrix (abundance data) = matrix L
  \item a bromeliad x environmental variables (plant specific data, including physical, hydrological, ..) = matrix R
}
}

