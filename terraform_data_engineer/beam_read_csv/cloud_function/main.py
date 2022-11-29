import functions_framework
from googleapiclient.discovery import build
import google.auth
import os

#trigger function command: gsutil cp terraform_data_engineer/data/test_data.csv gs://fce2845e810918fb-gcf-trigger-bucket/
@functions_framework.cloud_event
def dataflow_trigger(cloud_event):
    print("this is a test change")
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


    #template_path here
    job_name = os.environ["job_name"]
    template_path = os.environ["template_path"] 
    stagging_bucket = os.environ["stagging_bucket"]
    temp_bucket = os.environ["temp_bucket"]
    location = os.environ["LOCATION"]
    input_pattern = os.environ["input_pattern"]
    # source_path = "gs://{}/{}".format(bucket, name)
    # dest_path = os.environ["dest_path"]
    template_body = {
        "launchParameter": {
            #Details: "JobName invalid; the name must consist of only the characters [-a-z0-9], starting with a letter and ending with a letter or number">
            "jobName": job_name,
            "parameters": {
                "input_pattern": input_pattern,
                # "dest_path": dest_path,
            },
            "environment": {
                "tempLocation": temp_bucket,
                "stagingLocation": stagging_bucket
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