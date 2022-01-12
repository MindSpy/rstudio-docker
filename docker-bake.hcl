variable "PKG_PROXY" {  }
variable "GIT_BRANCH" {  }
variable "BUILD_DATE" {  }
variable "http_proxy" {  }
variable "https_proxy" {  }

variable "RSTUDIO_VERSION" { default = "2021.09.1+372"  }
variable "RSTUDIO_TAG" {     default = "2021.09.1-372"  }
variable "SHINY_VERSION" { default = "latest" } 

group "default" {
  targets = [ "rbase", "rstudi", "tex" ]
}

target "dev" {
  inherits = [ "rbase" ]
}

target "rbase" {
  platforms = [ "linux/amd64" ]
  context = "."
  dockerfile = "Dockerfile"
  target = "base"
  args = { 
 	PKG_PROXY = "${PKG_PROXY}" 
        http_proxy = "${http_proxy}"
        https_proxy = "${https_proxy}"
        R_VERSION = "4.1.2"
#        BUILDKIT_INLINE_CACHE = "1"
       }
  tags = [
        "mindspy/rbase:4.1.2",
        "mindspy/rbase:4.1",
        "mindspy/rbase:4",
        "mindspy/rbase:latest"
       ]
  cache-to = [ "mode=max,type=inline" ]
}

target "tidyverse" {
  inherits = [ "rbase" ]
  target = "tidyverse"
  tags = [
        "mindspy/rbase:4.1.2-tidyverse",
        "mindspy/rbase:4.1-tidyverse",
        "mindspy/rbase:4-tidyverse",
        "mindspy/rbase:tidyverse"
       ]
#  cache-from = [ "type=registry,ref=mindspy/rbase:latest" ]
}

target "rstudio" {
  inherits = [ "rbase" ]
  target = "rstudio"
  args = {
	RSTUDIO_VERSION = "${RSTUDIO_VERSION}"
  }
  tags = [
        "mindspy/rstudio:${RSTUDIO_TAG}-r4.1.2",
        "mindspy/rstudio:${RSTUDIO_TAG}-r4.1",
        "mindspy/rstudio:${RSTUDIO_TAG}-r4",
        "mindspy/rstudio:${RSTUDIO_TAG}",
        "mindspy/rstudio:latest"
       ]
#  cache-from = [ "type=registry,ref=mindspy/rbase:tidyverse" ]
}

target "tex" {
  inherits = [ "rbase" ]
  target = "tex"
  tags = [
        "mindspy/rstudio:${RSTUDIO_TAG}-r4.1.2-tex",
        "mindspy/rstudio:${RSTUDIO_TAG}-r4.1-tex",
        "mindspy/rstudio:${RSTUDIO_TAG}-r4-tex",
        "mindspy/rstudio:${RSTUDIO_TAG}-tex",
        "mindspy/rstudio:tex"
       ]
#  cache-from = [ "type=registry,ref=mindspy/rstudio:latest" ]
}

target "shiny" {
  inherits = [ "rbase" ]
  target = "shiny"
  args = {
     SHINY_VERSION = "${SHINY_VERSION}"
  }
  tags = [
        "mindspy/shiny:${SHINY_VERSION}-r4.1.2",
        "mindspy/shiny:${SHINY_VERSION}-r4.1",
        "mindspy/shiny:${SHINY_VERSION}-r4",
        "mindspy/shiny:latest"
       ]

}
