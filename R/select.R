##' Select rows or columns from data frames or matrices
##'
##' Select rows or columns from data frames or matrices while always returning a data frame or a matrix
##'
##' The primary contribution of this function is that if a single row or column is selected, the
##' object that is returned will be a matrix or a dataframe---and it will not be collapsed into a
##' single vector, as is the usual behavior in R.
##'
##' @export select
##' 
##' @rdname select
##'
##' @param data A matrix or dataframe from whence data will be selected
##'
##' @param selection A character vector with column (or row) names, or, a numeric vector with
##' column (or row) indexes.
##'
##' @param cols A logical, that when \code{TRUE}, indicates that columns will be selected.
##' If \code{FALSE}, rows will be selected.
##'
##' @return The matrix or data frame is returned with the selected columns or rows.
##'
##' @author Landon Sego
##'
##' @examples
##' # Consider this data frame
##' d <- data.frame(a = 1:5, b = rnorm(5), c = letters[1:5], d = factor(6:10),
##'                 row.names = LETTERS[1:5], stringsAsFactors = FALSE)
##'
##' # We get identical behavior when selecting more than one column
##' d1 <- d[, c("d", "c")]
##' d1c <- select(d, c("d", "c"))
##' d1
##' d1c
##' identical(d1, d1c)
##'
##' # Different behavior when selecting a single column
##' d[,"a"]
##' select(d, "a")
##'
##' # We can also select using numeric indexes
##' select(d, 1)
##'
##' # Selecting a single row from a data frame produces results identical to default R behavior
##' d2 <- d[2,]
##' d2c <- select(d, "B", cols = FALSE)
##' identical(d2, d2c)
##'
##' # Now consider a matrix
##' m <- matrix(rnorm(20), nrow = 4, dimnames = list(LETTERS[1:4], letters[1:5]))
##'
##' # Column selection with two or more or more columns is equivalent to default R behavior
##' m1 <- m[,c(4, 3)]
##' m1c <- select(m, c("d", "c"))
##' m1
##' m1c
##' identical(m1, m1c)
##'
##' # Selecting a single column returns a matrix of 1 column instead of a vector
##' m[,2]
##' select(m, 2)
##'
##' # Selecting a single row returns a matrix of 1 row instead of a vector
##' m2 <- m["C",]
##' m2c <- select(m, "C", cols = FALSE)
##' m2
##' m2c
##' is.matrix(m2)
##' is.matrix(m2c)
##'
##' \dontshow{
##' # Running checks on select()
##' Smisc:::test_select()
##' }

select <- function(data, selection, cols = TRUE) {

  # Check types
  stopifnot(is.matrix(data) | is.data.frame(data),
            is.numeric(selection) | is.character(selection),
            is.vector(selection),
            length(selection) > 0,
            is.logical(cols))

  # Define an error message function if wrong rows or columns are selected
  errMsg <- function(nt) {

    paste(ifelse(cols, "Columns '", "Rows '"),
          ifelse1(length(nt) <= 5,
                  paste(paste(nt, collapse = "', "), "' ", sep = ""),
                  paste(paste(nt[1:5], collapse = "', '"), "', and others ", sep = "")),
          "are not present in 'data'.", sep = "")

  } # errMsg

  # Convert characters to indexes if necessary
  if (is.character(selection)) {

    # If we have columns
    if (cols) {

      # Verify column names match
      if (length(notThere <- setdiff(selection, colnames(data))))
        stop(errMsg(notThere))

      # Get the column indexes. This complicated code preserves the ordering of 'selection'
      cd <- colnames(data)
      selection <- unlist(lapply(selection, function(x) which(cd %in% x)))

    }

    # If we're working with rows
    else {

      # Verify row names match
      if (length(notThere <- setdiff(selection, rownames(data))))
        stop(errMsg(notThere))

      # Get the row indexes
      rd <- rownames(data)
      selection <- unlist(lapply(selection, function(x) which(rd %in% x)))

    }
  }

  # Verify that the numeric indexes are in the range of 'data'''
  else {
    if (cols) {
      if (length(notThere <- setdiff(selection, 1:NCOL(data))))
        stop(errMsg(notThere))
    }
    else {
      if (length(notThere <- setdiff(selection, 1:NROW(data))))
        stop(errMsg(notThere))
    }
  }

  # If the length of selection is 2 or more:
  if (length(selection) > 1) {

     if (cols)
       out <- data[,selection]
     else
       out <- data[selection,]
  }

  # Selecting a single row or column
  else {

    # If we're working with matrices
    if (is.matrix(data)) {

      if (cols) {

        # Create a new matrix of one column
        out <- matrix(data[,selection], ncol = 1,
                      dimnames = list(rownames(data), colnames(data)[selection]))

      }
      else {

        # Create a new matrix of one row
        out <- matrix(data[selection,], nrow = 1,
                      dimnames = list(rownames(data)[selection], colnames(data)))

      }

    } # Working with matrices


    # If we're working with a data frame
    else {

      if (cols) {

        # Determine whether the single column is character
        isChar <- is.character(singleCol <- data[,selection])

        # Create a new data frame with one column
        out <- data.frame(singleCol, row.names = rownames(data), stringsAsFactors = !isChar)
        colnames(out) <- colnames(data)[selection]

      }
      else {

        # Create a new data frame with one row
        out <- data[selection,]

      }

    } # Working with data frames

  } # Selecting a single row or column

  # Return the result
  return(out)

} # select


# A function for testing the behavior of select()
test_select <- function() {

  # Consider this data frame
  d <- data.frame(a = 1:5, b = rnorm(5), c = letters[1:5], d = factor(6:10),
                  row.names = LETTERS[1:5], stringsAsFactors = FALSE)
 
  # We get identical behavior when selecting more than one column
  d1 <- d[, c("d", "c")]
  d1c <- select(d, c("d", "c"))
  stopifnot(identical(d1, d1c))
 
  # Selecting a single row from a data frame produces results identical to default R behavior
  d2 <- d[2,]
  d2c <- select(d, "B", cols = FALSE)
  stopifnot(identical(d2, d2c))
 
  # Now consider a matrix
  m <- matrix(rnorm(20), nrow = 4, dimnames = list(LETTERS[1:4], letters[1:5]))
 
  # Column selection with two or more or more columns is equivalent to default R behavior
  m1 <- m[,c(4, 3)]
  m1c <- select(m, c("d", "c"))
  stopifnot(identical(m1, m1c))
 
  # Selecting a single row returns a matrix of 1 row instead of a vector
  m2 <- m["C",]
  m2c <- select(m, "C", cols = FALSE)
  stopifnot(!is.matrix(m2),
            is.matrix(m2c))

  # Test more results
  a1 <- select(d, "a")
  a2 <- select(d, c("a","d"))
  a3 <- select(d, c("c","b","d"))
  a4 <- select(d, c("a","d"))
  a5 <- select(d, c("c"))
  a6 <- select(d, c("d"))

  # Now make the same calls using indexes
  a1c <- select(d, 1)
  a2c <- select(d, c(1, 4))
  a3c <- select(d, c(3, 2, 4))
  a4c <- select(d, c(1, 4))
  a5c <- select(d, 3)
  a6c <- select(d, 4)

  # Check results
  stopifnot(identical(d1, d1c),
            identical(a1, a1c),
            identical(a2, a2c),
            identical(a3, a3c),
            identical(a4, a4c),
            identical(a5, a5c),
            identical(a6, a6c))

  # Now try rows
  b1 <- select(d, c(4, 1), cols = FALSE)
  b2 <- select(d, 2, cols = FALSE)
  b3 <- select(d, 4, cols = FALSE)

  b1c <- select(d, c("D", "A"), cols = FALSE)
  b2c <- select(d, "B", cols = FALSE)
  b3c <- select(d, "D", cols = FALSE)

  # Check results
  stopifnot(identical(a1, a1c),
            identical(a2, a2c),
            identical(a3, a3c))

  # Checks for the matrix stuff
  m3 <- select(m, c("d", "c"))
  m3c <- select(m, c(4, 3))
  m4 <- select(m, "b")
  m4c <- select(m, 2)
  m5 <- select(m, c("D", "C"), cols = FALSE)
  m5c <- select(m, c(4, 3), cols = FALSE)
  m6 <- select(m, "B", cols = FALSE)
  m6c <- select(m, 2, cols = FALSE)

  # Check results
  stopifnot(identical(m3, m3c),
            identical(m4, m4c),
            identical(m5, m5c),
            identical(m6, m6c))

  return(print("All checks completed successfully"))

}  # test_select
