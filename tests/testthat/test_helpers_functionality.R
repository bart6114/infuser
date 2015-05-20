library(infuser)

###########################################
context("test trim function")

s_given <- "  hello123  "
s_wanted <- "hello123"

test_that("trim function workes OK",{
  expect_equal(trim(s_given), s_wanted)
})
