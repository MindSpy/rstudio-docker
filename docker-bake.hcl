variable "PKG_PROXY" {  }
variable "GIT_BRANCH" {  }
variable "BUILD_DATE" {  }


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
  args = { PKG_PROXY = "${PKG_PROXY}" }
  tags = [
        "docker.io/mindspy/rbase:4.1.2",
        "docker.io/mindspy/rbase:4.1",
        "docker.io/mindspy/rbase:4",
        "docker.io/mindspy/rbase:latest"
       ]
  cache-to = [ "inline" ]
}
