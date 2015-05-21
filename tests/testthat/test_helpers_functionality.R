library(infuser)

###########################################
context("test trim function")

s_given <- "  hello123  "
s_wanted <- "hello123"

test_that("trim function workes OK",{
  expect_equal(trim(s_given), s_wanted)
})


###########################################
context("test read_template functionality")

s_given <- "hello {{var1}}"

test_that("read_template function OK",{
  expect_equal(infuser:::read_template(s_given), s_given)
})

## add filereading test
