import apache_beam as beam
# from apache_beam.dataframe.io import read_csv
from apache_beam.options.pipeline_options import PipelineOptions
from typing import List, Dict, Iterable
import logging
import argparse
import json
from fastavro import writer, reader, parse_schema

#command to run pipeline in your local:
    # python3 main.py --customer_path="gs://dna-poc-training-saurav/dummydata/customers.json" --transaction_path="gs://dna-poc-training-saurav/dummydata/transaction.json"
#execute beam pipeline in dataflow
    # gcloud dataflow flex-template run $job_name --template-file-gcs-location=$template_path --region=$region --parameters=$parameters --max-workers=$max_workers
#to check result:
    # gsutil ls gs://toanbui1991-destination/
########################################################## combine apache beam component into complete pipeline here
def classify_transaction(transaction, num_partitions):
    if transaction["name"] == "" or transaction["name"] is None:
        return 0
    else:
        return 1
def run(
    customer_path: str,
    transaction_path: str,
    beam_args: List[str] = None
) -> None:
    #build PipelineOptions object which get from main so that dataflow runner can get correct config
    options = PipelineOptions(beam_args, save_main_session=True, streaming=False)
    #build your pipeline here
    customer_schema = {
            "fields":[
                {"name":"name", "type":"STRING"},
                {"name":"address", "type":"STRING"},
                {"name":"workplace", "type":"STRING"},
                {"name":"bank_account_number", "type": "STRING"},
                {"name":"cc_number", "type":"STRING"},
                {"name":"cc_provider", "type":"STRING"}
            ]
        }

    transaction_schema = {
            "fields":[
                {"name":"name", "type":"STRING"},
                {"name":"transaction_date", "type":"DATETIME"},
                {"name":"transaction_amnt", "type":"FLOAT64"}
            ]
        }
    temp_location = "gs://toanbui1991-dataflow-templates/"
    with beam.Pipeline(options=options) as pipeline:
        customer = (
            pipeline
            | 'Read customer data' >> beam.io.ReadFromText(file_pattern=customer_path)
            | "Convert string to dict" >> beam.Map(json.loads)
            | "Write to Bigquery" >> beam.io.WriteToBigQuery(
                table="dna-poc-training:ds_toanbui1991.customer",
                schema=customer_schema,
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                write_disposition=beam.io.BigQueryDisposition.WRITE_TRUNCATE,
                custom_gcs_temp_location=temp_location
            )
        )
        transaction = (
            pipeline
            | 'Read transaction data' >> beam.io.ReadFromText(file_pattern=transaction_path)
            | "convert string to dict" >> beam.Map(json.loads)
        )
        wrong_tran, correct_tran = (
            transaction
            | "Filter correct and wrong transaction" >> beam.Partition(classify_transaction, 2)
        )
        write_to_gs = (
            wrong_tran
            | "Write wrong transaction to gs bucket" >> beam.io.WriteToText(
                file_path_prefix="gs://dna-poc-training-toanbui1991/wrong_transaction/",
                file_name_suffix=".json"
            )
        )
        write_to_bq = (
            correct_tran
            | "Write correct transaction to bigquery" >> beam.io.WriteToBigQuery(
                table="dna-poc-training:ds_toanbui1991.fact_transaction",
                schema=transaction_schema,
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                write_disposition=beam.io.BigQueryDisposition.WRITE_TRUNCATE,
                custom_gcs_temp_location=temp_location
            )
        )
            

############################################################ main program
if __name__ == "__main__":
    #do not need to init logging instance
    #some test change
    logging.getLogger().setLevel(logging.INFO)
    parser = argparse.ArgumentParser()

    #parse arguments
    parser.add_argument(
        "--customer_path",
        help="gs source file path to customer data"
    )

    parser.add_argument(
        "--transaction_path",
        help="gs source file path to transaction data"
    )

    #dataflow will call this file with additional argument. This line will help script to capture additional arguments like runner and stagging job description
    args, beam_args = parser.parse_known_args()
    run(
        customer_path=args.customer_path,
        transaction_path=args.transaction_path,
        beam_args=beam_args
    )
