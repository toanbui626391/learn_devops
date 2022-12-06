import apache_beam as beam
# from apache_beam.dataframe.io import read_csv
from apache_beam.io.filesystem import FileSystem as beam_fs
from apache_beam.options.pipeline_options import PipelineOptions
from typing import List, Dict, Iterable
import logging
import argparse
import json
# from fastavro import writer, reader, parse_schema
from apache_beam.io.gcp.bigquery_tools import parse_table_schema_from_json


#command to run pipeline in your local:
    # python3 main.py --input_pattern="gs://toanbui1991-destination/data-00000-of-00001.avro" --dest_bucket="gs://toanbui1991-destination/"
#execute beam pipeline in dataflow
    # gcloud dataflow flex-template run $job_name --template-file-gcs-location=$template_path --region=$region --parameters=$parameters --max-workers=$max_workers
#to check result:
    # gsutil ls gs://toanbui1991-destination/
########################################################## combine apache beam component into complete pipeline here
def run(
    input_pattern: str,
    dest_bucket: str,
    beam_args: List[str] = None
) -> None:
    #build PipelineOptions object which get from main so that dataflow runner can get correct config
    options = PipelineOptions(beam_args, save_main_session=True, streaming=False)
    #build your pipeline here
    # keys = ["Store_id", "Store_location", "Product_id", "Product_category", "number_of_pieces_sold", "buy_rate", "sell_price"]
    project_id = "dna-poc-training"
    dataset = "ds_toanbui1991"
    table_name = "sales_toanbui1991"
    temp_location = "gs://toanbui1991-dataflow-templates/"
    #table and schema have to follow below format
    table_id = "{}:{}.{}".format(project_id, dataset, table_name)
    schema = {
        'fields': [{
            'name': 'Store_id', 'type': 'STRING'
        }, {
            'name': 'Store_location', 'type': 'STRING'
        }, {
            'name': 'Product_id', 'type': 'STRING'
        }, {
            'name': 'Product_category', 'type': 'STRING'
        }, {
            'name': 'number_of_pieces_sold', 'type': 'INTEGER'
        }, {
            'name': 'buy_rate', 'type': 'INTEGER'
        }, {
            'name': 'sell_price', 'type': 'INTEGER'
        }
        ]
    }
    with beam.Pipeline(options=options) as pipeline:
        (
            pipeline
            | 'Read avro file' >> beam.io.ReadFromAvro(input_pattern)
            # | 'Print data point' >> beam.Map(print)
            | 'Write to bigquery' >> beam.io.WriteToBigQuery(
                table=table_id,
                schema=schema,
                create_disposition=beam.io.BigQueryDisposition.CREATE_NEVER,
                write_disposition=beam.io.BigQueryDisposition.WRITE_TRUNCATE,
                custom_gcs_temp_location=temp_location
            )
        )

############################################################ main program
#python3 terraform_data_engineer/beam_read_csv/pipeline_read_a_csv.py --input_pattern terraform_data_engineer/data/test_data.csv
if __name__ == "__main__":
    #do not need to init logging instance
    #some test change
    logging.getLogger().setLevel(logging.INFO)
    parser = argparse.ArgumentParser()

    #parse arguments
    parser.add_argument(
        "--input_pattern",
        help="gs source file path"
    )

    parser.add_argument(
        "--dest_bucket",
        help="gs dest bucket"
    )
    #dataflow will call this file with additional argument. This line will help script to capture additional arguments like runner and stagging job description
    args, beam_args = parser.parse_known_args()
    run(
        input_pattern=args.input_pattern,
        dest_bucket=args.dest_bucket,
        beam_args=beam_args
    )
