locals {
  status_codes       = ["200", "400", "403", "404", "500"]
  default_code       = "200"
  error_status_codes = [for code in local.status_codes : code if code != local.default_code]
}
