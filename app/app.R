# app.R — Shiny + Tableau (desktop layout, fluid width in range, height fits viewport)
library(shiny)
library(htmltools)

# Tableau: set each dashboard to Size = Width: Range, Height: Automatic.
# Keep device=desktop to prevent phone stacking; add refresh to avoid stale cache.
url1 <- "https://public.tableau.com/views/Book1map_17615369781360/Dashboard1?:showVizHome=no&:embed=true&:language=en-GB&:device=desktop&:refresh=yes"
url2 <- "https://public.tableau.com/views/SuburbInformation/Dashboard1?:showVizHome=no&:embed=true&:language=en-GB&:device=desktop&:refresh=yes"
url3 <- "https://public.tableau.com/views/Tab3-ServiceSupplyAccessibility/Tab3ServiceSupplyAccessibility?:showVizHome=no&:embed=true&:language=en-GB&:device=desktop&:refresh=yes"
url4 <- "https://public.tableau.com/views/Melbourneservice/Dashboard1?:showVizHome=no&:embed=true&:language=en-GB&:device=desktop&:toolbar=no&:showTabs=no&:refresh=yes"

# Wrapper: fluid width within a desktop range, height is set to fit the viewport.
tableau_iframe <- function(url, min_w = 1200, max_w = 2000){
  tags$div(
    class = "tbl-scroll",
    style = "width:100%; overflow-x:auto; overflow-y:hidden; -webkit-overflow-scrolling:touch;",
    tags$div(
      class = "tbl-wrap",
      style = sprintf("
        min-width:%dpx; max-width:%dpx; width:100%%; margin:0 auto;
        box-shadow:0 0 12px rgba(0,0,0,.08); border-radius:12px; overflow:hidden;
      ", min_w, max_w),
      tags$iframe(
        src   = url,
        class = "tbl-embed",
        style = "width:100%; height:1px; border:none; display:block;",  # JS sets the real height
        allowfullscreen = NA
      )
    )
  )
}

ui <- navbarPage(
  title = div("Community Service Accessibility — Melbourne", style = "white-space:nowrap;"),
  id = "topnav", collapsible = FALSE,
  header = tagList(
    tags$head(
      # Page chrome: no vertical page scroll; tabs and iframe fill the viewport.
      tags$style(HTML("
        html, body { height:100%; overflow:hidden; background:#f8f9fa; }
        .navbar-nav { white-space:nowrap; overflow-x:auto; overflow-y:hidden; }
        .navbar-nav > li { float:none; display:inline-block; }
        .container, .container-fluid { max-width:100%; }
        .tab-content { height:100%; }
        iframe.tbl-embed { transition: height .2s ease; }
      ")),
      # Height logic: iframe height = window height − navbar.
      tags$script(HTML("
        function fitDashboards(){
          var nav = document.querySelector('.navbar');
          var navH = nav ? nav.offsetHeight : 0;
          var margin = 12; // subtle breathing space
          var h = Math.max(0, window.innerHeight - navH - margin*2);
          document.querySelectorAll('iframe.tbl-embed').forEach(function(f){
            f.style.height = h + 'px';
          });
        }
        window.addEventListener('load', fitDashboards);
        window.addEventListener('resize', fitDashboards);
        document.addEventListener('shown.bs.tab', fitDashboards);
      "))
    )
  ),
  
  # One full desktop dashboard per tab.
  tabPanel("Map Distribution",            fluidPage(tableau_iframe(url1))),
  tabPanel("Suburb Resident Information", fluidPage(tableau_iframe(url2))),
  tabPanel("Service Supply Accessibility",fluidPage(tableau_iframe(url3))),
  tabPanel("Community Profile",           fluidPage(tableau_iframe(url4)))
)

server <- function(input, output, session) {}

shinyApp(ui, server)
