## basic example of using cloud build
    - reference link: https://cloud.google.com/build/docs/configuring-builds/create-basic-configuration
    - github reference link: https://github.com/GoogleCloudPlatform/cloud-build-samples/tree/main/basic-config

## content of this page
    - create and develop a cloudbuild.yaml config file for:
        - build custom image
        - push custom image to repository
        - create a compute engine instance in google cloud
    - to start or trigger cloud build using gcloud command:
        - gcloud builds submit --config=cloudbuild.yaml --substitutions _ARTIFACT_REGISTRY_REPO=my-docker-repo,_BUCKET_NAME=toanbui1991-python-logs,SHORT_SHA=latest

    - substitute or supply cloud environment variables with substitutions flag
        example command: - gcloud builds submit --config=cloudbuild.yaml --substitutions _ARTIFACT_REGISTRY_REPO=my-docker-repo,_BUCKET_NAME=toanbui1991-python-logs,SHORT_SHA=latest

    - cloud build environment variables
        - reference link:  https://cloud.google.com/build/docs/configuring-builds/substitute-variable-values
        - $SHORT_SHA is support when using trigger. it is not support when using command