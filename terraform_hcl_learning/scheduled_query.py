from google.cloud import bigquery_datatransfer

transfer_client = bigquery_datatransfer.DataTransferServiceClient()

# The project where the query job runs is the same as the project
# containing the destination dataset.
project_id = "dna-poc-training"
dataset_id = "ds_toanbui1991"

# This service account will be used to execute the scheduled queries. Omit
# this request parameter to run the query as the user with the credentials
# associated with this client.
service_account_name = "bigquery-sa@dna-poc-training.iam.gserviceaccount.com"

# Use standard SQL syntax for the query.
query_string = """
select Store_id as store_id
, Product_category as product_category
,sum(number_of_pieces_sold) as total_quantity
,sum(number_of_pieces_sold * (sell_price - buy_rate)) as profit
from `dna-poc-training.ds_toanbui1991.sales_toanbui1991`
group by Store_id, Product_category
"""

parent = transfer_client.common_project_path(project_id)

transfer_config = bigquery_datatransfer.TransferConfig(
    destination_dataset_id=dataset_id,
    display_name="scheduled_query_toanbui1991",
    data_source_id="scheduled_query",
    params={
        "query": query_string,
        "destination_table_name_template": "salesagg_toanbui1991",
        "write_disposition": "WRITE_TRUNCATE",
        "partitioning_field": "",
    },
    schedule="every day 1:00",
)

transfer_config = transfer_client.create_transfer_config(
    bigquery_datatransfer.CreateTransferConfigRequest(
        parent=parent,
        transfer_config=transfer_config,
        service_account_name=service_account_name,
    )
)

print("Created scheduled query '{}'".format(transfer_config.name))