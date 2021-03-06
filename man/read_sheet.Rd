% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/reading.R
\name{read_sheet}
\alias{read_sheet}
\title{Read an excel file from dropbox account}
\usage{
read_sheet(file, sheetname = NULL, ondisk = FALSE, dest = tempdir(), ...)
}
\arguments{
\item{file}{the file name to fetch}

\item{sheetname}{the sheet name you want. must match exactly.}

\item{ondisk}{Are you reading this data from your machine or online?}

\item{dest}{destination for download}
}
\description{
this function reads all the sheets in an excel book on dropbox
}

