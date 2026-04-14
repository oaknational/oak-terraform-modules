output "url" {
  description = "The deployed url for the function"
  value       = google_cloudfunctions2_function.this.url
}

