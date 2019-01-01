# toggl-projects

## R
`toggl-projects.R` is a simple R script that based on environment variables `TOGGL_TOKEN` and `TOGGL_WORKSPACE`, fetches a list of clients in the workspace and for each of the clients, renders a bar graph of time logged on active projects. The graphs are saved as a png-file for each image in the img-directory

Use `./toggl-projects.R` or `RScript toggl-projects.R`

## RMarkdown
`toggl-projects.Rmd` is the same script as Rmarkdown. The images are saved in one file `toggl-projects.html`

Use the knitr 'button' in RStudio or `R -e "rmarkdown::render('toggl-projects.Rmd')"` from the command line, you need `Pandoc` in the `PATH` for this.

## Shiny
`shiny-projects.Rmd` is showing the same data in an interactive document.

Open the file in RStudio and press the `Run Document` button to see the generated output.



