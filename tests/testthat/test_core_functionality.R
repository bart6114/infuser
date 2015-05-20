library(infuser)

###########################################
context("replacing simple string parameters")


SQL_string <- "SELECT LAT_N, CITY, TEMP_F
FROM STATS, STATION
WHERE MONTH = {{month}}
AND YEAR = {{year}}
AND STATS.ID = STATION.ID
ORDER BY TEMP_F;"

SQL_string_with_whitespaces <- "SELECT LAT_N, CITY, TEMP_F
FROM STATS, STATION
WHERE MONTH = {{month}}
AND YEAR = {{year}}
AND STATS.ID = STATION.ID
ORDER BY TEMP_F;"

SQL_string_with_defaults <- "SELECT LAT_N, CITY, TEMP_F
FROM STATS, STATION
WHERE MONTH = {{ month|3}}
AND YEAR = {{year}}
AND STATS.ID = STATION.ID
ORDER BY TEMP_F;"

SQL_string_wanted <-"SELECT LAT_N, CITY, TEMP_F
FROM STATS, STATION
WHERE MONTH = 3
AND YEAR = 2020
AND STATS.ID = STATION.ID
ORDER BY TEMP_F;"


test_that("string replacements occurs as expected",{
  expect_equal(infuse(SQL_string, month=3, year=2020), SQL_string_wanted)
  expect_equal(infuse(SQL_string_with_whitespaces, month=3, year=2020), SQL_string_wanted)
})

context("replacing string parameters with defaults")

test_that("string replacements occurs as expected with defaults in place",{
  expect_equal(infuse(SQL_string_with_defaults, year=2020), SQL_string_wanted)
})

context("replacing parameters in template file")

test_that("string replacements occurs as expected with defaults in place",{
  expect_equal(infuse(system.file("extdata", "sql1.sql", package = "infuser"), year=2020), SQL_string_wanted)
})

###########################################
context("replacing parameters with multiple occurences")

SQL_string <- "SELECT LAT_N, CITY, TEMP_F
FROM STATS, STATION
WHERE MONTH = {{month|3}}
AND YEAR = {{year}}
AND YEAR2 = {{year}}
AND STATS.ID = STATION.ID
ORDER BY TEMP_F;"

SQL_string_wanted <-"SELECT LAT_N, CITY, TEMP_F
FROM STATS, STATION
WHERE MONTH = 3
AND YEAR = 2020
AND YEAR2 = 2020
AND STATS.ID = STATION.ID
ORDER BY TEMP_F;"


test_that("string replacements occurs as expected with defaults in place",{
  expect_equal(infuse(SQL_string, year=2020), SQL_string_wanted)
})

###########################################
context("custom transform function")

sql<-"INSERT INTO Students (Name) VALUES ({{name}})"
name <- "Robert'); DROP TABLE Students;--"

my_transform_function<-function(v){
  # replace single quotes with double quotes
  v<-gsub("'", "''", v)
  # encloses the string in single quotes
  v<-paste0("'",v,"'")

  return(v)
}

BOBBY_wanted <- "INSERT INTO Students (Name) VALUES ('Robert''); DROP TABLE Students;--')"

test_that("the custom transform function works",{
  expect_equal(infuse(sql, name = name, transform_function = my_transform_function), BOBBY_wanted)
})
