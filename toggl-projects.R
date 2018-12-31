#!/usr/bin/env Rscript

#  install.packages("tidyverse")
library(tidyverse)
#  install.packages("jsonlite")
library(jsonlite)
# install.package("httr")
library(httr)

if(Sys.getenv("TOGGL_TOKEN") == "" || Sys.getenv("TOGGL_WORKSPACE") == "") {
  stop("Missing Environment Variables: TOGGL_TOKEN or TOGGL_WORKSPACE")
}

togglToken <- Sys.getenv("TOGGL_TOKEN")
togglWid   <- Sys.getenv("TOGGL_WORKSPACE")


getClients <- function(token, wid, verbose = FALSE) {
  username <- token
  password <- "api_token"


  base <- "https://toggl.com/api"
  endpoint <- "v8/workspaces"
  what <- "clients"

  call <- paste(base,endpoint,wid,what, sep="/")

  if(verbose) {
    result <- GET(call, authenticate(username,password), verbose())
  } else {
    result <- GET(call, authenticate(username,password))
  }
  return(result)
}

getProjects <- function(token, cid, verbose = FALSE) {
  username <- token
  password <- "api_token"


  base <- "https://toggl.com/api"
  endpoint <- "v8/clients"
  what <- "projects"

  call <- paste(base,endpoint,cid,what, sep="/")

  if(verbose) {
    result <- GET(call, authenticate(username,password), verbose())
  } else {
    result <- GET(call, authenticate(username,password))
  }

  return(result)
}

projectPlot <- function(data, name) {
  # ToDo: check if data contains estimated_hours, colnames()
  v1 <- ggplot(data=data) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) +
    labs(x=NULL, y="Hours", title=name, caption="data from toggl")

  if ("actual_hours" %in% colnames(data)) {
    v1 <- v1 + geom_col(aes(
      x=name,
      y=actual_hours,
      fill=hex_color),
      color = "Black",
      show.legend = FALSE)
  }
  if ("estimated_hours" %in% colnames(data)) {
    v1 <- v1 + geom_point(aes(x=name, y=estimated_hours),
                          shape = 3, size = 2)
  }

  return(v1)
}

clientsJSON <- getClients(togglToken, togglWid)

clients <- as.tibble(fromJSON(content(clientsJSON, "text")))

if(nrow(clients) > 0) {
  for (row in 1:nrow(clients)) {
    cId <- clients[row, "id" ][[1]]
    cName <- clients[row, "name"][[1]]

    print(paste(cId, cName))
    t1 <- Sys.time()
    if(!(Sys.getenv("RSTUDIO") == 1) || (row %% 10 == 0)) {
      projectsJSON <- getProjects(togglToken, cId)
      projects <- as.tibble(fromJSON(content(projectsJSON, "text")))
      p1 <- projectPlot(projects, cName)
      plot(p1)
      # ToDo: break out to a function e.g. savePlot
      fName <- gsub("/", "-", gsub(" ", "-", cName))
      if(!dir.exists("img")){
        dir.create("img")
      }
      png(paste("img/", fName, ".png", sep=""), width=5000, height=3000, res=550, pointsize=10)
      plot(p1)
      dev.off()
    } else {
      print("When running in RStudio, only 1 in 10 plots are generated")
    }
    if(Sys.time()-t1 < 1) {
      Sys.sleep(1)
    }
  }
}


