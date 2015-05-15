# returns string w/o leading or trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

#' Reads the template from a file or string
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
