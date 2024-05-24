# Terraform module to create a Firebase storage bucket

This is a Terraform module to create a new Firebase cloud storage bucket. 
It requires the [Google Cloud SDK][] to be installed locally and an
existing [Firebase project][Firebase console]. 

To get started:

1.  Install the [Google Cloud SDK][], [Terraform][Terraform install], and
    [Git][Git install].

2.  Create a [Firebase project][Firebase console] with the Blaze Plan.

3.  Add the following config to your terraform tf file:

    ```
    module "tf-fb-storage" {
        source            = "github.com/opentdc/tf-fb-storage"
        project_id        = local.project_id
        location          = local.location

        # Wait until Firestore is provisioned first.
        depends_on = [ module.tf-fb-firestore ]
    }
    ```

4.  Run `terraform init && terraform apply`


## Input variables

| Variable Name               | Type      | Usage       | Default         | Description                                        |
|-----------------------------|-----------|-------------|-----------------|----------------------------------------------------|
| project_id                  | string    | mandatory   |                 | The Firebase project ID                            |
| location                    | string    | mandatory   |                 | Hosting center where the Firestore database and    |
|                             |           |             |                 | the cloud storage bucket will be provisioned.      |
|                             |           |             |                 | This must be the same as the Firestore location.   |


## Output
None