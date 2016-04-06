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
  expect_equivalent(infuse(SQL_string, month=3, year=2020, simple_character=TRUE), SQL_string_wanted)
  expect_equivalent(infuse(SQL_string_with_whitespaces, month=3, year=2020, simple_character=TRUE), SQL_string_wanted)
})

test_that("string replacements occurs as expected when providing a list instead of arguments",{
  expect_warning(infuse(SQL_string, key_value_list=list(month=3, year=2020)), simple_character=TRUE) #deprecated
  expect_equivalent(infuse(SQL_string, list(month=3, year=2020), simple_character=TRUE), SQL_string_wanted)
  expect_equivalent(infuse(SQL_string_with_whitespaces, list(month=3, year=2020), simple_character=TRUE), SQL_string_wanted)
})


context("replacing string parameters with defaults")

test_that("string replacements occurs as expected with defaults in place",{
  expect_equivalent(infuse(SQL_string_with_defaults, year=2020, simple_character=TRUE), SQL_string_wanted)
})

test_that("parameters with same prefix are replaced as expected",{
  expect_equivalent(infuse("test-{{output}}-{{outputA}}", output = "do", outputA = "a", simple_character=TRUE), "test-do-a")
})

context("replacing parameters in template file")

test_that("string replacements occurs as expected with defaults in place",{
  expect_equivalent(infuse(system.file("extdata", "sql1.sql", package = "infuser"), year=2020, simple_character=TRUE), SQL_string_wanted)
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
  expect_equivalent(infuse(SQL_string, year=2020, simple_character=TRUE), SQL_string_wanted)
})

###########################################
context("providing a vector and collapsing it with a specified character")

template <- "hello {{var1}}"
to_infuse <- c(1,2,3)
should_be <- "hello 1,2,3"
should_be2 <- "hello 1|2|3"

test_that("infusing of vector with default ',' works",{
  expect_equivalent(infuse(template, var1 = to_infuse, simple_character=TRUE), should_be)
})


test_that("infusing of vector with specified char works",{
  expect_equivalent(infuse(template, var1 = to_infuse, collapse_char = "|", simple_character=TRUE), should_be2)
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
  expect_equivalent(infuse(sql, name = name, transform_function = my_transform_function, simple_character=TRUE), BOBBY_wanted)
})


###############################################
context("variable identifiers")

test_that("variable identifiers are correctly used",{
  expect_equivalent(
    infuse("${test}", variable_identifier = c("\\${", "}"), test = "123", simple_character=TRUE), "123")
})


test_that("variable identifiers are correctly used when set as an option",{
  options(variable_identifier = c("\\${", "}"))
  expect_equivalent(
    infuse("${test}", test = "123", simple_character=TRUE), "123")
})
