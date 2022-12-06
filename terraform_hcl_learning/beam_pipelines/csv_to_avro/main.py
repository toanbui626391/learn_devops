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
    # python3 main.py --input_pattern="gs://toanbui1991-source/store_sales.csv" --dest_bucket="gs://toanbui1991-destination/"
    #  python3 main.py --input_pattern="./store_sales.csv" --dest_bucket="."
#execute beam pipeline in dataflow
    # gcloud dataflow flex-template $job_name --template-file-gcs-location=$template_path --region=$region --parameters=$parameters --max-workers=$max_workers
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
    keys = ["Store_id", "Store_location", "Product_id", "Product_category", "number_of_pieces_sold", "buy_rate", "sell_price"]
    schema = {"namespace": "example.avro",
            "type": "record",
            "name": "Sale",
            "fields": [
                {"name": "Store_id", "type": "string"},
                {"name": "Store_location", "type": "string"},
                {"name": "Product_id", "type": "string"},
                {"name": "Product_category", "type": "string"},
                {"name": "number_of_pieces_sold", "type": "string"},
                {"name": "buy_rate", "type": "string"},
                {"name": "sell_price", "type": "string"}
            ]
            }
    parsed_schema = parse_schema(schema)
    print("parsed_schema: ", parsed_schema)
    with beam.Pipeline(options=options) as pipeline:
        (
            pipeline
            | 'Read files' >> beam.io.ReadFromText(input_pattern, skip_header_lines=1)
            | 'Text to list' >> beam.Map(lambda x: x.split(","))
            | 'List to dict' >> beam.Map(lambda x: dict(zip(keys, x)))
            # | 'Print data point' >> beam.Map(print)
            | 'Write to files' >> beam.io.WriteToAvro(
                file_path_prefix="{}data".format(dest_bucket),
                schema=parsed_schema,
                file_name_suffix=".avro"
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
