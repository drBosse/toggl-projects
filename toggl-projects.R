#!/usr/bin/env Rscript

#  install.packages("tidyverse")
library(tidyverse)
#  install.packages("jsonlite")
library(jsonlite)
# install.package("httr")
library(httr)

source('toggl-helpers.R')

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


