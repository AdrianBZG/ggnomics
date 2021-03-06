% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/conveniencefunctions.R
\name{genemodel_helpers}
\alias{genemodel_helpers}
\alias{plottable_genemodel_from_txdb}
\alias{plottable_genemodel_from_gff}
\title{Helpers for gene models}
\usage{
plottable_genemodel_from_txdb(txdb, roi, group_by = "gene")

plottable_genemodel_from_gff(gff_file, roi, group_by = "gene")
}
\arguments{
\item{txdb}{A \code{TxDb} object from the \pkg{GenomicFeatures} package.}

\item{roi}{A \code{GRanges} object specifying a region of interest.}

\item{group_by}{A \code{character} of length 1, either \code{"gene"} or
\code{"transcript"} specifying what feature type you want to summarise
exons over.}

\item{gff_file}{A \code{character} of length 1 containing a filename to a
\code{.gff} file.}
}
\value{
A \code{data.frame} containing a representation of an exon in each
  row originating from the region of interest. Contains the following
  columns:

  \describe{
    \item{seqnames}{the chromosome name.}
    \item{start}{the start coordinate of the exon.}
    \item{end}{the end coordinate of the exon.}
    \item{strand}{the orientation of the gene.}
    \item{id}{either a \code{transcript_id} or \code{gene_id} depending on the \code{group_by} argument.}
    \item{type}{specifying wether the exon is a coding sequence (CDS) or untranslated region (UTR).}
 }
}
\description{
When you just want to plot some gene models and don't want to
  dabble in the dark arts of data wrangling, it would be convenient if there
  simply are functions that do most of the work for you. These are some of
  those functions.
}
\details{
These functions import all required and optional data for
  \code{\link[ggnomics]{geom_genemodel}}.

  Considering that different \code{.gff} files and \code{TxDb} objects
  observe different standards for their particular gene- and
  transcripts-names and -IDs, it was not possible to generalise the
  gene/transcript id columns to a specific output format. Furthermore, there
  is no guarantee that a \code{.gff} file and \code{TxDb} object for the same
  build of the same organism will yield identical results.

  Note that genes and transcripts are imported that have \emph{any} overlap
  with the region of interest, so if you are particular about your region you
  might consider setting x-limits on the plot.
}
\note{
These functions were not tested exhaustively, please report bugs as an
  issue on the GitHub page.
}
\examples{
\dontrun{
roi <- GRanges("chr17", IRanges(63e6, 64e6))

# For plottable_genemodel_from_txdb()
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene

df <- plottable_genemodel_from_txdb(txdb, roi, group_by = "gene")

ggplot(df) +
  geom_genemodel(aes(
    xmin = start, xmax = end, group = gene_id,
    strand = strand, type = type,
    colour = strand, fill = strand)
  )

# For plottable_genemodel_from_gff()
file <- "../some/path/to/dir/genes.gtf"

df <- plottable_genemodel_from_gff(file, roi, group_by = "gene")

ggplot(df) +
  geom_genemodel(aes(
    xmin = start, xmax = end, group = gene_id,
    strand = strand, type = type,
    colour = strand, fill = strand)
  )
}
}
