if (Sys.getenv("TOGGL_TOKEN") == "" || Sys.getenv("TOGGL_WORKSPACE") == "") {
  stop("Missing Environment Variables: TOGGL_TOKEN or TOGGL_WORKSPACE")
}

togglToken <- Sys.getenv("TOGGL_TOKEN")
togglWid <- Sys.getenv("TOGGL_WORKSPACE")

getClients <- function(token, wid, verbose = FALSE) {
  username <- token
  password <- "api_token"


  base <- "https://toggl.com/api"
  endpoint <- "v8/workspaces"
  what <- "clients"

  call <- paste(base, endpoint, wid, what, sep = "/")

  if (verbose) {
    result <- GET(call, authenticate(username, password), verbose())
  } else {
    result <- GET(call, authenticate(username, password))
  }
  return(result)
}

getUsers <- function(token, wid, verbose = FALSE) {
  username <- token
  password <- "api_token"


  base <- "https://toggl.com/api"
  endpoint <- "v8/workspaces"
  what <- "workspace_users"

  call <- paste(base, endpoint, wid, what, sep = "/")

  if (verbose) {
    result <- GET(call, authenticate(username, password), verbose())
  } else {
    result <- GET(call, authenticate(username, password))
  }
  return(result)
}

getProjects <- function(token, cid, verbose = FALSE) {
  username <- token
  password <- "api_token"


  base <- "https://toggl.com/api"
  endpoint <- "v8/clients"
  what <- "projects"

  call <- paste(base, endpoint, cid, what, sep = "/")

  if (verbose) {
    result <- GET(call, authenticate(username, password), verbose())
  } else {
    result <- GET(call, authenticate(username, password))
  }

  return(result)
}

addStyle <- function(input) {
  data <- input
  if ("billable" %in% colnames(data)) {
    data$style <- as.character(as.numeric(!data$billable))
  }
  return(data)
}

projectPlot <- function(data, name) {
  data <- addStyle(data)

  v1 <- ggplot(data = data) +
    theme(axis.text.x = element_text(angle = 25, hjust = 1, size = 8)) +
    labs(x = NULL, y = "Hours", title = name, caption = "data from toggl")

  if ("actual_hours" %in% colnames(data)) {
    v1 <- v1 + geom_col(aes(
      x = name,
      y = actual_hours,
      fill = hex_color, linetype = style
    ),
    color = "Black",
    show.legend = FALSE
    )
  }
  if ("estimated_hours" %in% colnames(data)) {
    v1 <- v1 + geom_point(aes(x = name, y = estimated_hours),
      shape = 3, size = 2
    )
  }

  return(v1)
}
