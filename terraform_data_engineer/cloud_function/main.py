import functions_framework
from googleapiclient.discovery import build
import google.auth
import os

@functions_framework.cloud_event
def dataflow_trigger(cloud_event):
    data = cloud_event.data

    event_id = cloud_event["id"]
    event_type = cloud_event["type"]

    bucket = data["bucket"]
    name = data["name"]
    metageneration = data["metageneration"]
    timeCreated = data["timeCreated"]
    updated = data["updated"]
    #print event data
    print("event data:")
    # print("data: {}".format(data))
    print("event_id: {}".format(event_id))
    print("event_type: {}".format(event_type))
    print("bucket: {}".format(bucket))
    print("name: {}".format(name))
    print("metageneration: {}".format(metageneration))
    print("timeCreated: {}".format(timeCreated))
    print("updated: {}".format(updated))
    
    #prepare data to execute job
    credentials, _ = google.auth.default()
    print("service_account_email: {}".format(credentials.service_account_email))
    # print()
    service = build('dataflow', 'v1b3', credentials=credentials)
    project_id = os.environ["PROJECT_ID"]
    print("project_id from environment variable: {}".format(project_id))
    source_path = "source_path_here"
    dest_path = "dest_path_here"

    #template_path here
    template_path = "gs://a99a21451e2521d5-test-dataflow-templates/dataflow_test.json" 
    temp_bucket = "gs://a99a21451e2521d5-test-dataflow-temp/"
    location = os.environ["LOCATION"]
    source_path = "gs://{}/{}".format(bucket, name)
    dest_path = "gs://a99a21451e2521d5-test-dest/"
    template_body = {
        "launchParameter": {
            #Details: "JobName invalid; the name must consist of only the characters [-a-z0-9], starting with a letter and ending with a letter or number">
            "jobName": "move-csv",
            "parameters": {
                "source_path": source_path,
                "dest_path": dest_path,
            },
            "environment": {
                "tempLocation": temp_bucket
            },
            "containerSpecGcsPath": template_path
        },
        "validateOnly": False
    }
    #using clasic template
    # request = service.projects().templates().launch(projectId=project_id, gcsPath=template_path, body=template_body)
    #using flex template
    request = service.projects().locations().flexTemplates().launch(projectId=project_id, location=location, body=template_body)
    response = request.execute()

    print(response)