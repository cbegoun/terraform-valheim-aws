resource "github_repository_file" "config_js" {
  repository = var.github_repository
  file       = "config.js"
  content    = templatefile("${path.module}/webapp/config.js.template", {
    API_ID = var.api_id
    REGION = var.aws_region
  })
  commit_message = "Updated config.js with API ID and region"
}

resource "github_repository_file" "start_instance_html" {
  repository = var.github_repository
  file       = "start_instance.html"
  content    = file("${path.module}/webapp/start_instance.html")
  commit_message = "Added start_instance.html"
}

resource "github_repository_file" "config_js_template" {
  repository = var.github_repository
  file       = "config.js.template"
  content    = file("${path.module}/webapp/config.js.template")
  commit_message = "Added config.js.template"
}
