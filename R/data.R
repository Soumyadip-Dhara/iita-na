#' Example Dataset: Knowledge Assessment with Complete Data
#'
#' A simulated binary response dataset representing student performance on
#' a knowledge assessment with 5 items. This dataset contains no missing values
#' and can be used to demonstrate the basic IITA functionality.
#'
#' @format A matrix with 20 rows (subjects) and 5 columns (items):
#' \describe{
#'   \item{Item 1}{Basic knowledge item}
#'   \item{Item 2}{Intermediate item, may require Item 1}
#'   \item{Item 3}{Intermediate item}
#'   \item{Item 4}{Advanced item, may require Items 2 and 3}
#'   \item{Item 5}{Most advanced item}
#' }
#' @details Each entry is either 0 (item failed) or 1 (item passed).
#'   The dataset follows a hierarchical knowledge structure where
#'   more advanced items generally require mastery of prerequisite items.
#'
#' @examples
#' data(knowledge_complete)
#' result <- iita(knowledge_complete)
#' print(result)
"knowledge_complete"

#' Example Dataset: Knowledge Assessment with Missing Data
#'
#' A simulated binary response dataset representing student performance on
#' a knowledge assessment with 5 items, including missing values (NA).
#' This dataset demonstrates the package's ability to handle incomplete data.
#'
#' @format A matrix with 20 rows (subjects) and 5 columns (items):
#' \describe{
#'   \item{Item 1}{Basic knowledge item}
#'   \item{Item 2}{Intermediate item, may require Item 1}
#'   \item{Item 3}{Intermediate item}
#'   \item{Item 4}{Advanced item, may require Items 2 and 3}
#'   \item{Item 5}{Most advanced item}
#' }
#' @details Each entry is 0 (item failed), 1 (item passed), or NA (missing).
#'   Approximately 15% of the data points are missing. The package handles
#'   missing data using pairwise deletion when computing diff values.
#'
#' @examples
#' data(knowledge_missing)
#' result <- iita(knowledge_missing)
#' print(result)
"knowledge_missing"
