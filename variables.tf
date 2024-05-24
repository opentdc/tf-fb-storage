variable "project_id" {
  description = "The Firebase project ID."
  type        = string
}

variable "location" {
  description = "Hosting center to use for the Cloud Storage bucket. This must be the same as for Firestore database."
  type        = string
  default     = "europe-west6"
}
