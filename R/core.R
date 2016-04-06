.onLoad <- function(libname, pkgname) {
  options(variable_identifier=c("{{", "}}"))
}


#' Infuse a template with values.
#'
#' For more info and usage examples see the README on the \href{https://github.com/Bart6114/infuser}{\code{infuser} github page}.
#' To help prevent \href{https://xkcd.com/327/}{SQL injection attacks} (or other injection attacks), use a transformation function to escape special characters and provide it through the \code{transform_function} argument. \code{\link[dplyr]{build_sql}} is a great default escaping function for SQL templating.  For templating in other languages you will need to build/specify your own escaping function.
#'
#' @param file_or_string the template file or a character string containing the template
#' @param ... different keys with related values, used to fill in the template (if first passed item is a list/environment the contents of this will be processed instead)
#' @param variable_identifier the opening and closing character that denounce a variable in the template, defaults to \code{c("{{", "}}")} and can be set persistently using e.g. \code{options(variable_identifier=c("{{", "}}"))}
#' @param default_char the character use to specify a default after
#' @param collapse_char the character used to collapse a supplied vector
#' @param transform_function a function through which all specified values are passed, can be used to make inputs safe(r).  dplyr::build_sql is a good default for SQL templating.
#' @param verbose verbosity level
#' @param simple_character if \code{TRUE} returns only a character vector, else adds the \code{infuser} class to the returned object.
#' @export
infuse <- function(file_or_string, ..., variable_identifier = getOption("variable_identifier"),
                   default_char = "|", collapse_char = ",",
                   transform_function = function(value) return(value),
                   verbose=getOption("verbose"),
                   simple_character = FALSE){

  template <-
    read_template(file_or_string)

  params_requested <-
    variables_requested(template,
                        variable_identifier = variable_identifier,
                        default_char = default_char,
                        verbose = verbose)


  params_supplied <- list(...)

  ## if a list or environment is passed as the first argument, only process this
  if("key_value_list" %in% names(params_supplied)) warning("specification of key_value_list no longer required; simply pass the list/environment as the first parameter")

  if(inherits(params_supplied[[1]], "list") || inherits(params_supplied[[1]], "environment")){
    params_supplied <- params_supplied[[1]]
  }


  for(param in names(params_requested)){

    pattern <- paste0(variable_identifier[1],
                      "\\s*?",
                      param,
                      "\\s*?" ,
                      variable_identifier[2],
                      "|",  # or match with default in place
                      variable_identifier[1],
                      "\\s*?",
                      param,
                      "\\s*?\\",
                      default_char,
                      ".*?",
                      variable_identifier[2])

    if(param %in% names(params_supplied)){
      ## param is supplied
      template<-
        gsub(pattern,
             ## do this as a paste function e.g. if user supplied c(1,2,3)
             ## pass it through the transform function
             transform_function(
               paste(params_supplied[[param]], collapse=collapse_char)
             ),
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

  ## add 'infuse' class to the character string, done to control show method
  if(!simple_character){
    class(template) <- append(class(template), "infuse")
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
