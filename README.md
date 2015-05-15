`infuser` is a simple and very basic templating engine. It replaces
parameters within templates with specified values. Templates can be
either contained in a string or in a file. Let's have a look at an
example.

    my_sql<-"SELECT * FROM Customers
    WHERE Year = {{year}}
    AND Month = {{month|3}};"

Parameters are enclosed by `{{` and `}}` characters. See `?infuse` to
use your own specification.

From now, we suppose the character string `my_sql` is our template. To
show the parameters requested by the template you can run the following.

    library(infuser)
    variables_requested(my_sql, verbose = TRUE)

    ## Variables requested by template:
    ## >> year
    ## >> month (default = 3)

To fill in the template simply provide the requested parameters.

    infused_sql<-
    infuse(my_sql, year=2016, month=8)

    cat(infused_sql)

    ## SELECT * FROM Customers
    ## WHERE Year = 2016
    ## AND Month = 8;

If a default value is available in the template, it will be used if the
parameter is not specified.

    infused_sql<-
    infuse(my_sql, year=2016)

    cat(infused_sql)

    ## SELECT * FROM Customers
    ## WHERE Year = 2016
    ## AND Month = 3;

Just like we're using a string here, a text file can be used. An example
textfile can be found as follows:

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

    infused_template<-
      infuse(example_file, year = 2016, month = 12)

    cat(infused_template)

    ## SELECT LAT_N, CITY, TEMP_F
    ## FROM STATS, STATION
    ## WHERE MONTH = 12
    ## AND YEAR = 2016
    ## AND STATS.ID = STATION.ID
    ## ORDER BY TEMP_F;
