import apache_beam as beam
# from apache_beam.dataframe.io import read_csv
from apache_beam.io.filesystem import FileSystem as beam_fs
from apache_beam.options.pipeline_options import PipelineOptions
import codecs
import csv
from typing import List, Dict, Iterable
import logging
import argparse
from fastavro import writer, reader, parse_schema

#command to run pipeline in your local:
    # python3 main.py --input_pattern="gs://dna-poc-training-saurav/avroutput/dpd-00000-of-00001.avro"
#execute beam pipeline in dataflow
    # gcloud dataflow flex-template run $job_name --template-file-gcs-location=$template_path --region=$region --parameters=$parameters --max-workers=$max_workers
#to check result:
    # gsutil ls gs://toanbui1991-destination/
########################################################## combine apache beam component into complete pipeline here
def run(
    input_pattern: str,
    beam_args: List[str] = None
) -> None:
    #build PipelineOptions object which get from main so that dataflow runner can get correct config
    options = PipelineOptions(beam_args, save_main_session=True, streaming=False)
    #build your pipeline here
    #specify colum value with NUMERIC cause error. it have to be float64
    schema = {
            "fields":[
                {"name":"name", "type":"STRING"},
                {"name":"id", "type":"STRING"},
                {"name":"value", "type":"FLOAT64"},
                {"name":"date", "type": "DATE", },
                {"name":"location", "type":"STRING"}
            ]
        }
    temp_location = "gs://toanbui1991-dataflow-templates/"
    with beam.Pipeline(options=options) as pipeline:
        all_sales = (
            pipeline
            | 'Read files' >> beam.io.ReadFromAvro(file_pattern=input_pattern)
        )
        india_sales = (
            all_sales
            | "Filter India sales" >>  beam.Filter(lambda x: x["location"] == "India")
        )
        europe_sales = (
            all_sales
            | "Filter Europe sales" >>  beam.Filter(lambda x: x["location"] == "Europe")
        )
        us_sales = (
            all_sales
            | "Filter US sales" >>  beam.Filter(lambda x: x["location"] == "US")
        )
        australia_sales = (
            all_sales
            | "Filter Australia sales" >>  beam.Filter(lambda x: x["location"] == "Australia")
        )
        (
            india_sales
            | "Write India sales data to bigquery" >> beam.io.WriteToBigQuery(
                table="dna-poc-training:ds_toanbui1991.india_sales",
                schema=schema,
                create_disposition=beam.io.BigQueryDisposition.CREATE_NEVER,
                write_disposition=beam.io.BigQueryDisposition.WRITE_TRUNCATE,
                custom_gcs_temp_location=temp_location
            )

        )
        (
            europe_sales
            | "Write Europe sales data to bigquery" >> beam.io.WriteToBigQuery(
                table="dna-poc-training:ds_toanbui1991.europe_sales",
                schema=schema,
                create_disposition=beam.io.BigQueryDisposition.CREATE_NEVER,
                write_disposition=beam.io.BigQueryDisposition.WRITE_TRUNCATE,
                custom_gcs_temp_location=temp_location
            )

        )
        (
            us_sales
            | "Write US sales data to bigquery" >> beam.io.WriteToBigQuery(
                table="dna-poc-training:ds_toanbui1991.us_sales",
                schema=schema,
                create_disposition=beam.io.BigQueryDisposition.CREATE_NEVER,
                write_disposition=beam.io.BigQueryDisposition.WRITE_TRUNCATE,
                custom_gcs_temp_location=temp_location
            )

        )
        (
            australia_sales
            | "Write Australia sales data to bigquery" >> beam.io.WriteToBigQuery(
                table="dna-poc-training:ds_toanbui1991.australia_sales",
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

    #dataflow will call this file with additional argument. This line will help script to capture additional arguments like runner and stagging job description
    args, beam_args = parser.parse_known_args()
    run(
        input_pattern=args.input_pattern,
        beam_args=beam_args
    )
