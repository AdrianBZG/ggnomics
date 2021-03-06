% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/examples.R
\name{example_cytobands}
\alias{example_cytobands}
\title{Example cytobands data}
\usage{
example_cytobands()
}
\value{
A \code{data.frame} containing cytoband data.
}
\description{
Generates some toy cytoband data to plot ideograms with.
}
\details{
Returns the cytoband data for the first two chromosomes of the human
  genome (build hg38). Full data is available as the \code{cytobands.txt.gz}
  file from the
  \href{http://hgdownload.cse.ucsc.edu/goldenpath/hg38/database/}{UCSC
  database}.
}
\examples{
cyto <- example_cytobands()
}
\seealso{
\code{\link[ggnomics]{example_cytoband_colours}}
  \code{\link[ggnomics]{setup_cytobands}}
}
