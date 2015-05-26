#' Returns string w/o leading or trailing whitespace
#'
#' @param x to string to strip
trim <- function (x) gsub("^\\s+|\\s+$", "", x)


#' Reads the template from a file or string
#'
#' @param file_or_string the file or character string to read
read_template<-function(file_or_string){
  # check if input is file
  # else asume it is a string
  if(is.character(file_or_string) && file.exists(file_or_string)){
    template <-
      paste0(readLines(file_or_string),collapse= "\n")
  } else if(is.character(file_or_string) && nchar(file_or_string > 0)){
    template <- file_or_string
  } else {
    stop("Input is neither an existing for nor a character string")
  }

  template
}

#' Prints requested parameters
#'
#' @param params_requested the list of requested parameters
print_requested_params<-function(params_requested){
  message("Variables requested by template:")
  for(param in names(params_requested)){
    if(!is.na(params_requested[[param]])){
      default <- params_requested[[param]]
      message(">> ", paste0(param, " (default = ", default, ")"))
    } else {
      message(">> ", param)
    }

  }
}

#' prints/shows the result of the \code{infuse} function using the \code{cat} function
#'
#' @param x output of the \code{infuse} function
#' @param ... further arguments passed to or from other methods.
#' @export
print.infuse<-function(x, ...){
  cat(x)
}
