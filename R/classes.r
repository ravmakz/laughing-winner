#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#
# This software was authored by Zhian N. Kamvar and Javier F. Tabima, graduate 
# students at Oregon State University; and Dr. Nik Grünwald, an employee of 
# USDA-ARS.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for educational, research and non-profit purposes, without fee, 
# and without a written agreement is hereby granted, provided that the statement
# above is incorporated into the material, giving appropriate attribution to the
# authors.
#
# Permission to incorporate this software into commercial products may be
# obtained by contacting USDA ARS and OREGON STATE UNIVERSITY Office for 
# Commercialization and Corporate Development.
#
# The software program and documentation are supplied "as is", without any
# accompanying services from the USDA or the University. USDA ARS or the 
# University do not warrant that the operation of the program will be 
# uninterrupted or error-free. The end-user understands that the program was 
# developed for research purposes and is advised not to rely exclusively on the 
# program for any reason.
#
# IN NO EVENT SHALL USDA ARS OR OREGON STATE UNIVERSITY BE LIABLE TO ANY PARTY 
# FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
# LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, 
# EVEN IF THE OREGON STATE UNIVERSITY HAS BEEN ADVISED OF THE POSSIBILITY OF 
# SUCH DAMAGE. USDA ARS OR OREGON STATE UNIVERSITY SPECIFICALLY DISCLAIMS ANY 
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE AND ANY STATUTORY 
# WARRANTY OF NON-INFRINGEMENT. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS"
# BASIS, AND USDA ARS AND OREGON STATE UNIVERSITY HAVE NO OBLIGATIONS TO PROVIDE
# MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS. 
#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#==============================================================================#
setClassUnion("mlgORnumeric", c("MLG", "numeric"))
#==============================================================================#
#' Genclone class
#' 
#' Genclone is an S4 class that extends the \code{\linkS4class{genind}}
#' from the \pkg{\link{adegenet}} package. It will have all of the same
#' attributes as the \code{\linkS4class{genind}}, but it will contain two
#' extra slots that will help retain information about population hierarchies
#' and multilocus genotypes.
#' 
#' @section Extends: 
#' Class \code{"\linkS4class{genind}"}, directly.
#' 
#' @details The genclone class will allow for more optimized methods of clone
#' correcting and analyzing data over multiple levels of population hierarchy.
#' 
#' Previously, for hierarchical analysis to work in a \code{\link{genind}} 
#' object, the user had to place a data frame in the \code{\link{other}} slot of
#' the object. The suggested name of the data frame was 
#' \code{population_hierarchy}, and this was used to be able to store the 
#' hierarchical information inside the object so that the user did not have to 
#' keep track of that information. This method worked, but it became apparent 
#' that it was a bit confusing to the user as the method for changing the
#' population of an object became:
#' 
#' \code{pop(object) <- other(object)$population_hierarchy$population_name}
#' 
#' That is a lot to keep track of. The new \strong{\code{hierarchy}} slot will
#' allow the user to change the population factor with one function and a formula:
#' 
#' \code{setPop(object) <- ~Population/Subpopulation}
#' 
#' making this become slightly more intuitive and tractable.
#' 
#' Previously for \linkS4class{genind} objects, multilocus genotypes were not
#' retained after a data set was subset by population. The new 
#' \strong{\code{mlg}} slot allows us to assign the multilocus genotypes and 
#' retain that information no matter how we subset the data set.
#' 
#' @name genclone-class
#' @rdname genclone-class
#' @aliases genclone
#' @export
#' @slot mlg a vector representing multilocus genotypes for the data set.
#' @author Zhian N. Kamvar
#' @seealso \code{\link{as.genclone}} \code{\link{strata}} \code{\link{setPop}} 
#' \code{\linkS4class{genind}} 
#' @import methods
#==============================================================================#
setClass("genclone", 
         contains = "genind",
         representation = representation(mlg = "mlgORnumeric"),
         prototype(mlg = integer(0))
)

valid.genclone <- function(object){
  slots   <- slotNames(object)
  if (any(!"mlg" %in% slots)){
    return(FALSE)
  }
  inds    <- nInd(object)
  mlgs    <- length(object@mlg)
  if (mlgs != inds){  
    message("Multilocus genotypes do not match the number of observations")
    return(FALSE)
  }
  return(TRUE)
}

setValidity("genclone", valid.genclone)

# valid.genclone <- function(object){
#   slots   <- slotNames(object)
#   if (any(!c("mlg", "hierarchy") %in% slots)){
#     return(FALSE)
#   }
#   inds    <- length(object@ind.names)
#   mlgs    <- length(object@ind.names)
#   hier    <- length(object@hierarchy)
#   hierobs <- nrow(object@hierarchy)
#   if (mlgs != inds){  
#     cat("Multilocus genotypes do not match the number of observations")
#     return(FALSE)
#   }
#   if (hier > 0 & hierobs != inds){
#     cat("Hierarchy does not match the number of observations")
#     return(FALSE)
#   }
#   return(TRUE)
# }
# 
# setValidity("genclone", valid.genclone)
#==============================================================================#
#' SNPclone class
#' 
#' SNPclone is an S4 class that extends the \code{\linkS4class{genlight}}
#' from the \pkg{\link{adegenet}} package. It will have all of the same
#' attributes as the \code{\linkS4class{genlight}}, but it will contain two
#' extra slots that will help retain information about population hierarchies
#' and multilocus genotypes.
#' 
#' @section Extends: 
#' Class \code{"\linkS4class{genlight}"}, directly.
#' 
#' @details The snpclone class will allow for more optimized methods of clone
#' correcting and analyzing data over multiple levels of population hierarchy.
#' 
#' 
#' @name snpclone-class
#' @rdname snpclone-class
#' @aliases snpclone
#' @export
#' @slot mlg a vector representing multilocus genotypes for the data set.
#' @author Zhian N. Kamvar
#' @seealso \code{\link{as.snpclone}} \code{\linkS4class{genclone}} 
#' \code{\linkS4class{genlight}} 
#' @import methods
#==============================================================================#
setClass("snpclone",
         contains = "genlight",
         representation = representation(mlg = "mlgORnumeric"),
         prototype = prototype(mlg = integer(0))
)


#==============================================================================#
#' bruvomat object
#' 
#' An internal object used for bruvo's distance. 
#' Not intended for user interaction.
#' 
#' 
#' @name bruvomat-class
#' @rdname bruvomat-class
#' @export
#' @slot mat a matrix of genotypes with one allele per locus. Number of rows will
#' be equal to (ploidy)*(number of loci)
#' @slot replen repeat length of microsatellite loci
#' @slot ploidy the ploidy of the data set
#' @slot ind.names names of individuals in matrix rows.
#' @keywords internal
#' @author Zhian N. Kamvar
#' @import methods
#==============================================================================#
setClass(
  Class = "bruvomat", 
  representation = representation(
    mat = "matrix", 
    replen = "numeric",
    ploidy = "numeric",
    ind.names = "character"
  ),
  prototype = prototype(
    mat = matrix(ncol = 0, nrow = 0),
    replen = integer(0),
    ploidy = integer(0),
    ind.names = character(0)
  )
)

#==============================================================================#
#' Bootgen object
#' 
#' An internal object used for bootstrapping. Not intended for user interaction.
#' 
#' @section Extends: 
#' Virtual Class \code{"\linkS4class{gen}"}.
#' 
#' @name bootgen-class
#' @rdname bootgen-class
#' @export
#' @slot type a character denoting Codominant ("codom") or Dominant data ("P/A")
#' @slot ploidy an integer denoting the ploidy of the data set. (>=1)
#' @slot alllist a list with numeric vectors, each representing a different
#'   locus where each element in the vector represents the index for a specific
#'   allele.
#' @slot names a vector containing names of the observed samples.
#' @keywords internal
#' @author Zhian N. Kamvar
#' @import methods
#==============================================================================#
setClass("bootgen", 
         contains = c("gen"),
         representation = representation(
                          type = "character",
                          ploidy = "integer",
                          names = "vector", 
                          alllist = "list"),
         prototype = prototype(
          type = character(0),
          ploidy = integer(0),
          names = character(0),
          alllist = list()
          )
)
