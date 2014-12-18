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
# This is simply a convenience function that serves as a wrapper for useful, but
# slightly obscure base R functions. 
#' Get a file name and path and store them in a list.
#'
#' getfile is a convenience function that serves as a wrapper for the functions
#' \code{\link{file.choose}, \link{file.path},} and \code{\link{list.files}}. 
#' If the user is working in a GUI environment, a window will pop up, allowing 
#' the user to choose a specified file regardless of path.
#'
#' @param multi this is an indicator to allow the user to store the names of
#' multiple files found in the directory. This is useful in conjunction with
#' \code{\link{poppr.all}}. 
#'
#' @param pattern a \code{\link{regex}} pattern for use while 
#' \code{multi == TRUE}. This will grab all files matching this pattern. 
#' 
#' @param combine \code{logical}. When this is set to \code{TRUE} (default), the
#' \code{$files} vector will have the path appended to them. When it is set to
#' \code{FALSE}, it will have the basename. 
#'
#' @return \item{path}{a character string of the absolute path to the
#' chosen file or files}
#' \item{files}{a character vector containing the chosen file
#' name or names.}
#' @author Zhian N. Kamvar
#'
#' @examples
#' \dontrun{
#'
#' x <- getfile()
#' poppr(x$files)
#'
#' y <- getfile(multi=TRUE, pattern="^.+?dat$") 
#' #useful for reading in multiple FSTAT formatted files.
#'
#' yfiles <- poppr.all(y$files)
#' 
#' # Write results to a file in that directory.
#' setwd(y$path)
#' write.csv(yfiles)
#' }  
#' @export
#==============================================================================#
getfile <- function(multi=FALSE, pattern=NULL, combine=TRUE){
  # the default option is to grab a single file in the directory. If multFile is 
  # set to TRUE, it will grab all the files in the directory corresponding to any
  # pattern that is set. If there is no pattern, all files will be grabbed.
  if (multi==TRUE){
    # this sets the path variable that the user can use to set the path
    # to the files with setwd(x$path), where x is the datastructure 
    # this function dumped into.
    pathandfile <- file.path(file.choose())
    path <- dirname(pathandfile)
    if (!is.null(pattern)){
      pat <- pattern
      x <- list.files(path, pattern=pat)
    }
    else {
      x <- list.files(path)
    }
  }
  else {
    # if the user chooses to analyze only one file, a pattern is not needed
    pathandfile <- file.path(file.choose())
    path <- dirname(pathandfile)
    x <- basename(pathandfile)
  }
  if(combine == TRUE){
    x <- paste(path, x, sep="/")
  }
  filepath <- list(files=x, path=path)
  return(filepath)
}
#==============================================================================#
# A way of dealing with the different types of data that adegenet can take in.
# This will detect whether or not one should drop all the non-informative loci
# from each separated population or not.
#==============================================================================#
.pop.divide <- function(x, drop=TRUE) {
  divcall <- match.call()
  if(!is.genind(x)){
    stop(c(as.character(divcall[2])," is not a valid genind object"))
  }
  if (is.null(pop(x))){
    pops <- NULL
  }
  #else if (!is.null(x@other$subpops)){
  #  pops <- lapply(seppop(x), function(y) seppop(y, pop=y@other$subpops))
  #}
  else if (x@type !="PA") {
    pops <- seppop(x, drop=drop)
  }
  else {
    pops <- seppop(x)
  }
	return(pops)
}
#==============================================================================#
#' Importing data from genalex formatted *.csv files.
#' 
#' read.genalex will read in a genalex-formatted file that has been exported in 
#' a comma separated format and will parse most types of genalex data. The 
#' output is a \code{\linkS4class{genclone}} or \code{\linkS4class{genind}} 
#' object.
#' 
#' @param genalex a *.csv file exported from genalex
#'   
#' @param ploidy indicate the ploidy of the dataset
#'   
#' @param geo indicates the presence of geographic data in the file. This data 
#'   will be included in a data frame labeled \code{xy} in the
#'   \code{\link{other}} slot.
#'   
#' @param region indicates the presence of regional data in the file.
#'   
#' @param genclone when \code{TRUE} (default), the output will be a
#'   \code{\linkS4class{genclone}} object. When \code{FALSE}, the output will be
#'   a \code{\linkS4class{genind}} object
#'   
#' @param sep A character specifying the column separator of the data. Defaults 
#'   to ",".
#'   
#' @return A \code{\linkS4class{genclone}} or \code{\linkS4class{genind}} 
#'   object.
#'   
#' @note This function cannot handle raw allele frequency data.
#'   
#'   In the case that there are duplicated names within the file, this function 
#'   will assume separate individuals and rename each one to a sequence of 
#'   integers from 1 to the number of individuals. A vector of the original 
#'   names will be saved in the \code{other} slot under \code{original_names}.
#'   
#'   
#' @details \subsection{if \code{genclone = FALSE}}{ The resulting genind object
#'   will have a data frame in the \code{other} slot called 
#'   \code{population_hierarchy}. This will contain a column for your population
#'   data and a column for your Regional data if you have set the flag.}
#'   
#'   \subsection{if \code{genclone = TRUE}}{ The resulting genclone object will 
#'   have a single hierarchical level defined in the hierarchy slot. This will 
#'   be called "Pop" and will reflect the population factor defined in the 
#'   genalex input. If \code{region = TRUE}, a second column will be inserted 
#'   and labeled "Region". If you have more than two hierarchical levels within 
#'   your data set, you should run the command \code{\link{splithierarchy}} on 
#'   your data set to define the unique hierarchical levels. }
#'   
#'   \subsection{FOR POLYPLOID (> 2n) DATA SETS}{ Adegenet's genind object has 
#'   an all-or-none approach to missing data. If a sample has missing data at a 
#'   particular locus, then the entire locus is considered missing. This works 
#'   for diploids and haploids where allelic dosage is unambiguous. For 
#'   polyploids this poses a problem as much of the data set would be 
#'   transformed into missing data. With this function, I have created a 
#'   workaround.
#'   
#'   When importing polyploid data sets, missing data is scored as "0" and kept 
#'   within the genind object as an extra allele. This will break most analyses 
#'   relying on allele frequencies*. All of the functions in poppr will work 
#'   properly with these data sets as multilocus genotype analysis is agnostic 
#'   of ploidy and we have written both Bruvo's distance and the index of 
#'   association in such a way as to be able to handle polyploids presented in 
#'   this manner.
#'   
#'   * To restore functionality of analyses relying on allele frequencies, use
#'   the \code{\link{recode_polyploids}} function.}
#'   
#'   
#' @seealso \code{\link{clonecorrect}}, \code{\linkS4class{genclone}}, 
#'   \code{\linkS4class{genind}}, \code{\link{recode_polyploids}}
#'   
#' @export
#' @author Zhian N. Kamvar
#' @examples
#' 
#' \dontrun{
#' Aeut <- read.genalex(system.file("files/rootrot.csv", package="poppr"))
#' 
#' genalex2 <- read.genalex("genalex2.csv", geo=TRUE)
#' # A genalex file with geographic coordinate data.
#' 
#' genalex3 <- read.genalex("genalex3.csv", region=TRUE) 
#' # A genalex file with regional information.
#' 
#' genalex4 <- read.genalex("genalex4.csv", region=TRUE, geo=TRUE) 
#' # A genalex file with both regional and geographic information.
#' }
#==============================================================================#

read.genalex <- function(genalex, ploidy=2, geo=FALSE, region=FALSE, 
                         genclone = TRUE, sep = ","){
  # The first two lines from a genalex file contain all of the information about
  # the structure of the file (except for ploidy and geographic info)
  gencall  <- match.call()

  all.info <- strsplit(readLines(genalex, n = 2), sep)
  cskip    <- ifelse("connection" %in% class(genalex), 0, 2)
  gena     <- read.table(genalex, sep = sep, header = TRUE, skip = cskip, 
                         stringsAsFactors = FALSE, check.names = FALSE)
  num.info <- as.numeric(all.info[[1]])
  pop.info <- all.info[[2]][-c(1:3)]
  num.info <- num.info[!is.na(num.info)]
  pop.info <- pop.info[!pop.info %in% c("", NA)]
  nloci    <- num.info[1]
  ninds    <- num.info[2]
  npops    <- num.info[3]
  
  # Removing all null columns 
  if (any(is.na(gena[1, ]))){
    gena <- gena[, !is.na(gena[1, ])]
  }
  
  #----------------------------------------------------------------------------#
  # Checking for extra information such as Regions or XY coordinates
  #----------------------------------------------------------------------------#
  
  # Creating vectors that correspond to the different information fields. If the
  # regions are true, then the length of the pop.info should be equal to the
  # number of populations "npop"(npops) plus the number of regions which is the
  # npop+4th entry in the vector. Note that this strategy will only work if the
  # name of the first region does not match any of the populations.
  
  clm <- ncol(gena)

  if (region == TRUE & length(pop.info) == npops + num.info[npops + 4]){
    # Info for the number of columns the loci can take on.
    loci.adj <- c(nloci, nloci*ploidy)
    
    # First question, do you have two or four extra columns? Two extra would 
    # indicate no geographic data. Four extra would indicate geographic data. 
    # Both of these indicate that, while a regional specification exists, a 
    # column indicating the regions was not specified, so it needs to be created
    if (((clm %in% (loci.adj + 4)) & (geo == TRUE)) | (clm %in% (loci.adj + 2))){
      
      pop.vec <- gena[, 2]
      ind.vec <- gena[, 1]
      xy      <- gena[, c((clm-1), clm)]
      region.inds <- ((npops + 5):length(num.info)) # Indices for the regions
      reg.inds    <- num.info[region.inds] # Number of individuals per region
      reg.names   <- all.info[[2]][region.inds] # Names of the regions
      reg.vec     <- rep(reg.names, reg.inds) # Paste into a single vector
      if (geo == TRUE){
        geoinds <- c((clm - 1), clm)
        xy      <- gena[, geoinds]
        gena    <- gena[, -geoinds]
      } else {
        xy <- NULL
      }
      gena <- gena[, c(-1, -2)]
      
    } else {
      
      pop.vec      <- ifelse(any(gena[, 1] == pop.info[1]), 1, 2)
      reg.vec      <- ifelse(pop.vec == 2, 1, 2)
      orig.ind.vec <- NULL
      reg.vec      <- gena[, reg.vec] # Regional Vector 
      pop.vec      <- gena[, pop.vec] # Population Vector
      if (geo == TRUE){
        geoinds <- c((clm-1), clm)
        xy      <- gena[, geoinds]
        gena    <- gena[, -geoinds]
      } else {
        xy <- NULL
      }
      ind.vec <- gena[, clm] # Individual Vector
      gena    <- gena[, c(-1,-2,-clm)] # removing the non-genotypic columns
    }
  } else if (geo == TRUE & length(pop.info) == npops){
    # There are no Regions specified, but there are geographic coordinates
    reg.vec <- NULL
    pop.vec <- gena[, 2]
    ind.vec <- gena[, 1]
    xy      <- gena[, c((clm-1), clm)]
    gena    <- gena[, c(-1,-2,-(clm-1),-clm)]
  } else {
    # There are no Regions or geographic coordinates
    reg.vec <- NULL
    pop.vec <- gena[, 2]
    ind.vec <- gena[, 1]
    xy <- NULL
    gena <- gena[, c(-1,-2)]
  }
  
  #----------------------------------------------------------------------------#
  # The genotype matrix has been isolated at this point. Now this will
  # reconstruct the matrix in a way that adegenet likes it.
  #----------------------------------------------------------------------------#
  
  clm      <- ncol(gena)
  gena.mat <- as.matrix(gena)
  # Checking for greater than haploid data.
  if (nloci == clm/ploidy & ploidy > 1){
    # Missing data in genalex is coded as "0" for non-presence/absence data.
    # this converts it to "NA" for adegenet.
    if(any(gena.mat == "0") & ploidy < 3){
      gena[gena.mat == "0"] <- NA
    }
    type  <- 'codom'
    loci  <- which((1:clm) %% ploidy == 1)
    gena2 <- gena[, loci]
    lapply(loci, function(x) gena2[, ((x-1)/ploidy)+1] <<-
             pop_combiner(gena, hier = x:(x+ploidy-1), sep = "/"))
    res.gid <- df2genind(gena2, sep="/", ind.names = ind.vec, pop = pop.vec,
                         ploidy = ploidy, type = type)
  } else if (nloci == clm & all(gena.mat %in% as.integer(-1:1))) {
    # Checking for AFLP data.
    # Missing data in genalex is coded as "-1" for presence/absence data.
    # this converts it to "NA" for adegenet.
    if(any(gena.mat == -1L)){
      gena[gena.mat == -1L] <- NA
    }
    type <- 'PA'
    res.gid <- df2genind(gena, ind.names = ind.vec, pop = pop.vec,
                         ploidy = ploidy, type = type)
  } else if (nloci == clm & !all(gena.mat %in% as.integer(-1:1))) {
    # Checking for haploid microsattellite data or SNP data
    if(any(gena.mat == "0")){
      gena[gena.mat == "0"] <- NA
    }
    type    <- 'codom'
    res.gid <- df2genind(gena, ind.names = ind.vec, pop = pop.vec,
                         ploidy = 1, type = type)
  } else {
    stop("Something went wrong. Check your geo and region flags to make sure they are set correctly. Otherwise, the problem may lie within the data structure itself.")
  }
  if (any(duplicated(ind.vec))){
    # ensuring that all names are unique
    res.gid@ind.names <- paste("ind", 1:length(ind.vec))
    res.gid@other[["original_names"]] <- ind.vec
  }
  
  res.gid@other[["population_hierarchy"]] <- as.data.frame(list(Pop=pop.vec))
  res.gid@call <- gencall
  
  # Keep the name if it's a URL
  if (length(grep("://", genalex)) < 1 & !"connection" %in% class(genalex)){
    res.gid@call[2] <- basename(genalex)
  }
  if (region){
    res.gid@other[["population_hierarchy"]]$Region <- reg.vec
  }
  if (geo){
    res.gid@other[["xy"]] <- xy
  }
  if (genclone){
    res.gid <- as.genclone(res.gid)
  }
  return(res.gid)
}

#==============================================================================#
#' Exporting data from genind objects to genalex formatted *.csv files.
#' 
#' genind2genalex will export a genclone or genind object to a *.csv file
#' formatted for use in genalex.
#' 
#' @param pop a \code{\linkS4class{genclone}} or \code{\linkS4class{genind}}
#'   object.
#'   
#' @param filename a string indicating the name and/or path of the file you wish
#'   to create.
#'   
#' @param quiet \code{logical} If \code{FALSE} a message will be printed to the 
#'   screen.
#'   
#' @param geo \code{logical} Default is \code{FALSE}. If it is set to 
#'   \code{TRUE}, the resulting file will have two columns for geographic data.
#'   
#' @param geodf \code{character} Since the \code{other} slot in the adegenet 
#'   object can contain many different items, you must specify the name of the 
#'   data frame in the \code{other} slot containing your geographic coordinates.
#'   It defaults to "xy".
#'   
#' @param sep a character specifying what character to use to separate columns. 
#'   Defaults to ",".
#'   
#' @note If you enter a file name that exists, that file will be overwritten. If
#'   your data set lacks a population structure, it will be coded in the new 
#'   file as a single population lableled "Pop". Likewise, if you don't have any
#'   labels for your individuals, they will be labeled as "ind1" through 
#'   "ind\emph{N}", with \emph{N} being the size of your population.
#'   
#' @seealso \code{\link{clonecorrect}}, \code{\linkS4class{genclone}} or
#'   \code{\linkS4class{genind}}
#'   
#' @export
#' @author Zhian N. Kamvar
#' @examples
#' \dontrun{
#' data(nancycats)
#' genind2genalex(nancycats, "~/Documents/nancycats.csv", geo=TRUE)
#' }
#==============================================================================#
genind2genalex <- function(pop, filename = "genalex.csv", quiet = FALSE, 
                           geo = FALSE, geodf = "xy", sep = ","){
  if (!is.genind(pop)) stop("A genind object is needed.")
  if (nchar(sep) != 1) stop("sep must be one byte/character (eg. \",\")")
  if (is.null(pop@pop)){
    pop(pop) <- rep("Pop", nInd(pop))
  }
  popcall <- match.call()
  #topline is for the number of loci, individuals, and populations.
  topline <- c(nLoc(pop), nInd(pop), length(pop@pop.names))
  popsizes <- table(pop@pop)
  # The sizes of the populations correspond to the second line, which is the pop
  # names. 
  topline <- c(topline, popsizes)
  secondline <- c("", "", "", pop@pop.names)
  ploid <- ploidy(pop)
  # Constructing the locus names. GenAlEx separates the alleles of the loci, so
  # There is one locus name for every p ploidy columns you have.
  if(ploid > 1 & pop@type == "codom"){
    locnames <- unlist(strsplit(paste(pop@loc.names, 
                                      paste(rep(" ", ploidy(pop)-1), 
                                            collapse="/"), sep="/"),"/"))
  }
  else{
    locnames <- pop@loc.names
  }
  thirdline <- c("Ind","Pop", locnames)
  
  # This makes sure that you don't get into a stacking error when stacking the
  # first three rows.
  if(length(thirdline) > length(topline)){
    lenfac <- length(thirdline) - length(topline)
    topline <- c(topline, rep("", lenfac))
    secondline <- c(secondline, rep("", lenfac))
  }
  else if(length(thirdline) < length(topline)){
    lenfac <- length(topline) - length(thirdline)
    thirdline <- c(thirdline, rep("", lenfac))
  }
  infolines <- rbind(topline, secondline, thirdline)

  
  # converting to a data frame
  if(any(!pop@tab %in% c(0, ((1:ploid)/ploid), 1, NA))){
    pop@tab[!pop@tab %in% c(0, ((1:ploid)/ploid), 1, NA)] <- NA
  }
  if(!quiet) cat("Extracting the table ... ")
  df <- genind2df(pop, oneColPerAll=TRUE)
  
  # making sure that the individual names are included.
  if(all(pop@ind.names == "") | is.null(pop@ind.names)){
    pop@ind.names <- paste("ind", 1:nInd(pop), sep="")
  }
  df <- cbind(pop@ind.names, df)
  # setting the NA replacement. This doesn't work too well. 
  replacement <- ifelse(pop@type =="PA","-1","0")
  if(!quiet) cat("Writing the table to", filename, "... ")
  
  if(geo == TRUE & !is.null(pop$other[[geodf]])){
    replacemat <- matrix("", 3, 3)
    replacemat[3, 2:3] <- c("X", "Y")
    infolines <- cbind(infolines, replacemat)
    df2 <- data.frame(list("Space" = rep("", nInd(pop))))
    gdf <- as.matrix(pop@other[[geodf]])
    if(nrow(gdf) < nInd(pop)){
      gdf <- rbind(gdf, matrix("", nInd(pop) - nrow(gdf), 2))
    }
    df <- cbind(df, df2, gdf)
  }
  else if (geo == TRUE){
    popcall <- popcall[2]
    warning(paste0("There is no data frame or matrix in ",
                  paste0(substitute(popcall)), "@other called ", geodf,
                  ".\nThe xy coordinates will not be represented in the",
                  " resulting file."))
  }
  
  df[df == "NA" | is.na(df)] <- replacement
  
  if (ncol(infolines) > ncol(df)){
    lendiff <- ncol(infolines) - ncol(df)
    padding <- matrix("", nrow = nInd(pop), ncol = lendiff)
    df      <- cbind(df, padding)
  }
  write.table(infolines, file = filename, quote = FALSE, row.names = FALSE, 
              col.names = FALSE, sep = sep)
  write.table(df, file = filename, quote = TRUE, na = replacement, append = TRUE, 
              row.names = FALSE, col.names = FALSE, sep = sep)
  if(!quiet) cat("Done.\n")
}
