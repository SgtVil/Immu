% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summarise_fastq.R
\name{summarise_fastq}
\alias{summarise_fastq}
\title{A function to summarise the fastq from a run.}
\usage{
summarise_fastq(fastq, cores = 1, number_of_fastq = 10)
}
\arguments{
\item{fastq}{Object returned by \link{list_fastq} function.}

\item{cores}{The number of cores to be used. Default = 10.}

\item{number_of_fastq}{Number of fastq to integrate in the summary. Default = 10}
}
\description{
This function is heavy and depends a lot on the depth of your fastq. Be careful when setting the cores, this function can saturate the RAM.
}
\examples{
# See Vignette.
}
