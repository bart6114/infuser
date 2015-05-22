[![Travis Build
Status](https://travis-ci.org/Bart6114/infuser.svg)](https://travis-ci.org/Bart6114/infuser)
[![Coverage
Status](https://coveralls.io/repos/Bart6114/infuser/badge.svg)](https://coveralls.io/r/Bart6114/infuser)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/infuser)](http://cran.r-project.org/web/packages/infuser)
[![Downloads](http://cranlogs.r-pkg.org/badges/infuser)](http://cran.rstudio.com/package=infuser)

`infuser` is a simple and very basic templating engine for R. It
replaces parameters within templates with specified values. Templates
can be either contained in a string or in a file.

Installation
------------

    install.packages("infuser")

If you want to use the most up-to-date version, install using
`devtools::install_github`.

    devtools::install_github("Bart6114/infuser")

Usage
-----

### Working with character strings as templates

Let's have a look at an example string.

    my_sql<-"SELECT * FROM Customers
    WHERE Year = {{year}}
    AND Month = {{month|3}};"

Here the variable parameters are enclosed by `{{` and `}}` characters.
See `?infuse` to use your own specification.

From now on, we suppose the character string `my_sql` is our template.
To show the parameters requested by the template you can run the
following.

    library(infuser)
    variables_requested(my_sql, verbose = TRUE)

    ## Variables requested by template:
    ## >> year
    ## >> month (default = 3)

To fill in the template simply provide the requested parameters.

      infuse(my_sql, year=2016, month=8)

    ## SELECT * FROM Customers
    ## WHERE Year = 2016
    ## AND Month = 8;

You can also provide a named list with the requested parameters.

    my_list<- 
      list(year=2016,
           month=8)

    infuse(my_sql, my_list)

    ## SELECT * FROM Customers
    ## WHERE Year = 2016
    ## AND Month = 8;

If a default value is available in the template, it will be used if the
parameter is not specified.

    infuse(my_sql, year=2016)

    ## SELECT * FROM Customers
    ## WHERE Year = 2016
    ## AND Month = 3;

### Working with text files as templates

Just like we're using a string here, a text file can be used. An example
text file can be found in the package as follows:

    example_file<-
      system.file("extdata", "sql1.sql", package="infuser")

    example_file

    ## [1] "C:/R/R-3.1.3/library/infuser/extdata/sql1.sql"

Again, we can check which parameters are requested by the template.

    variables_requested(example_file, verbose = TRUE)

    ## Variables requested by template:
    ## >> month (default = 3)
    ## >> year

And provide their values.

    infuse(example_file, year = 2016, month = 12)

    ## SELECT LAT_N, CITY, TEMP_F
    ## FROM STATS, STATION
    ## WHERE MONTH = 12
    ## AND YEAR = 2016
    ## AND STATS.ID = STATION.ID
    ## ORDER BY TEMP_F;

### Infusing vectors

It is quite easy to insert a vector.

    years <- c(2013,2014,2015)
    sql_string <- "SELECT * FROM T1 WHERE Year IN ({{years}})"

    infuse(sql_string, years=years)

    ## SELECT * FROM T1 WHERE Year IN (2013,2014,2015)

You can also specify the collapse character.

    infuse(sql_string, years=years, collapse_char = ";")

    ## SELECT * FROM T1 WHERE Year IN (2013;2014;2015)

### Processing / transforming your inputs

A `transform_function` can be specified in the `infuse` command. This
allows for pre-processing of the parameter values before inserting them
in the template.

What we don't want to happen is the following:

    sql<-"INSERT INTO Students (Name) VALUES ({{name}})"
    name <- "Robert'); DROP TABLE Students;--"

    infuse(sql, name = name)

    ## INSERT INTO Students (Name) VALUES (Robert'); DROP TABLE Students;--)

Yikes! A way to solve this is to specify your own custom transform
function.

    my_transform_function<-function(v){
      # replace single quotes with double quotes
      v<-gsub("'", "''", v)
      # encloses the string in single quotes
      v<-paste0("'",v,"'")
      
      return(v)
    }

    infuse(sql, name = name, transform_function = my_transform_function)

    ## INSERT INTO Students (Name) VALUES ('Robert''); DROP TABLE Students;--')

Of course you can also use functions from other packages. Specifically
for SQL I advise you to take a look at the `dplyr::build_sql` function.

    infuse(sql, name = name, transform_function = dplyr::build_sql)

    ## INSERT INTO Students (Name) VALUES ('Robert''); DROP TABLE Students;--')

Issues / questions
------------------

Simply create a new issue at this GitHub repository.

Changes
-------

### v.0.1.4

-   updated print function for output of infuse (uses `cat` for now on)

### v0.1.3

-   added optional `collapse_char` argument to `infuse` command

### v0.1.2

-   added optional `key_value_list` argument to `infuse` command

### v0.1.1

-   added optional `transform_function` argument to `infuse` command
