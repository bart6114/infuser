#' Infuse a template with values
#'
#' @param  file_or_string the template file or a string containing the template
#' @param ... different keys with related values, used to fill in the template
#' @param  variable_identifier the opening and closing character that denounce a variable in the template
#' @param default_char the character use to specify a default after
#' @param verbose verbosity level
#' @export
infuse <- function(file_or_string, ..., variable_identifier = c("{{", "}}"), default_char = "|", verbose=FALSE){
  template <-
    read_template(file_or_string)

  params_requested <-
    variables_requested(template, default_char = default_char, verbose=verbose)


  params_supplied = list(...)


  for(param in names(params_requested)){

    pattern <- paste0(variable_identifier[1],
                      "\\s*",
                      param,
                      ".*?" ,
                      variable_identifier[2])

    if(param %in% names(params_supplied)){
      ## param is supplied
      template<-
        gsub(pattern,
             paste(params_supplied[[param]], collapse=","),
             template,
             perl = TRUE)
    } else if(!is.na(params_requested[[param]])){
      ## param is not supplied but a default is declared in the template
      template<-
        gsub(pattern,
             params_requested[[param]],
             template,
             perl = TRUE)
      if(verbose) warning(paste0("Requested parameter '", param, "' not supplied -- using default variable instead"))
    } else {
      ## don't do anything but give a warning
      warning(paste0("Requested parameter '", param, "' not supplied -- leaving template as-is"))
    }

  }

  template

}

#' Shows which variables are requested by the template
#'
#' @param  file_or_string the template file or a string containing the template
#' @param  variable_identifier the opening and closing character that denounce a variable in the template
#' @param default_char the character use to specify a default after
#' @param verbose verbosity level
#' @export
variables_requested <- function(file_or_string, variable_identifier = c("{{", "}}"), default_char = "|", verbose=FALSE){
  template <-
    read_template(file_or_string)

  regex_expr <- paste0(variable_identifier[1],
                       "(.*?)",
                       variable_identifier[2])

  params <-
    regmatches(template, gregexpr(regex_expr, template, perl=T))[[1]]

  params <-
    gsub(regex_expr, "\\1", params, perl=T)

  params_splitted <-
    strsplit(params, default_char, fixed=T)

  param_list <- list()

  for(param in params_splitted){
    key <- trim(param[[1]])
    if(length(param) > 1){
      value <- trim(param[[2]])
    } else{
      value <- NA
    }
    param_list[key] <- value
  }

  # print out params requested by the template (and available default variables)
  if(verbose){
    print_requested_params(param_list)
  }



  param_list

}
