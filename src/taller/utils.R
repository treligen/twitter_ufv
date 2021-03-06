instalation_packages <- function(){
  pack_installed <- rownames(installed.packages())
  pack_required <- c(
    "twitteR",
    "tidyverse",
    "tm",
    "stringr",
    "lubridate",
    "plotly",
    "rgdal",
    "sf",
    "leaflet",
    "tmap",
    "tmaptools"
  )
  
  pack_to_install <- pack_required[!(pack_required %in% pack_installed)]
  if (length(pack_to_install) > 0) {
    cat("Packages not installed:", pack_to_install, "\n")
    install.packages(pack_to_install, "\n")
  } else{
    cat("All packages required are installed")
  }
}
