# Copyright [2024] [Bruno Kaiser]

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0
# SPDX-License-Identifier: Apache-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# BEWARE: this module depends on the Firestore module to be provisioned first.
# Therefore, insert an depends_on = [module.tf-fb-firestore] in the app module.

terraform {
  required_version = "~> 1.8"
}

# Enable required APIs for Cloud Storage for Firebase.
resource "google_project_service" "storage" {
  provider = google-beta

  project  = var.project_id
  for_each = toset([
    "firebasestorage.googleapis.com",
    "storage.googleapis.com",
  ])
  service = each.key


  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy = false
}

# Provision the default Cloud Storage bucket for the project via Google App Engine.
resource "google_app_engine_application" "default" {
  provider    = google-beta
  project     = var.project_id
  location_id = var.location 
}

# Make the default Storage bucket accessible for Firebase SDKs, authentication, and Firebase Security Rules.
resource "google_firebase_storage_bucket" "default-bucket" {
  provider  = google-beta

  project   = var.project_id
  bucket_id = google_app_engine_application.default.default_bucket
}

# Create a ruleset of Cloud Storage Security Rules from a local file.
resource "google_firebaserules_ruleset" "storage" {
  provider = google-beta

  project  = var.project_id
  source {
    files {
      # Write security rules in a local file named "storage.rules".
      # Learn more: https://firebase.google.com/docs/storage/security/get-started
      name    = "storage.rules"
      content = file("${path.module}/storage.rules")
    }
  }

  # Wait for the default Storage bucket to be provisioned before creating this ruleset.
  depends_on = [
    google_firebase_storage_bucket.default-bucket,
  ]
}

# Release the ruleset to the default Storage bucket.
resource "google_firebaserules_release" "default-bucket" {
  provider     = google-beta

  name         = "firebase.storage/${google_app_engine_application.default.default_bucket}"
  ruleset_name = "projects/${var.project_id}/rulesets/${google_firebaserules_ruleset.storage.name}"
  project      = var.project_id

  lifecycle {
    replace_triggered_by = [
      google_firebaserules_ruleset.storage
    ]
  }
}
