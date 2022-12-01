#reference about apache beam dataframe: https://beam.apache.org/documentation/dsls/dataframes/overview/
#apache beam dataframe:
    # is a domain specific language (DSL) is an api to write pipeline with interface of pandas dataframe
    # it is build on top pandas dataframe
    # it add capacity of parallel processing of apache beam 
    # it also have vectorized of pandas
#note: have to to follow import syntax of the documenets otherwise we will have import and package error. which is import only function you need
#is it a good idea to use dataframe object in apache beam?
    #we have to convert between dataframe and pcollection object. which is not so good
    #for this specific test batch pipeline only
import apache_beam as beam
# from apache_beam.dataframe.io import read_csv
from apache_beam.io.filesystem import FileSystem as beam_fs
from apache_beam.options.pipeline_options import PipelineOptions
import codecs
import csv
from typing import List, Dict, Iterable
import logging
import argparse

#define run function
#reference for using logging package (basic use): https://docs.python.org/3/howto/logging.html#basic-logging-tutorial
#reference for using argparse package: https://docs.python.org/3/howto/argparse.html

#command to run pipeline in your local:
    # python3 batch_pipeline.py --source_path="../data/test_data.csv" --dest_path="../data/dest"
########################################################## define apache beam pipeline component here

########################################################## combine apache beam component into complete pipeline here
def run(
    input_pattern: str,
    dest_bucket: str,
    beam_args: List[str] = None
) -> None:
    #build PipelineOptions object which get from main so that dataflow runner can get correct config
    print("beam_args: ", beam_args)
    options = PipelineOptions(beam_args, save_main_session=True, streaming=False)
    #build your pipeline here
    with beam.Pipeline(options=options) as pipeline:
        (
            pipeline
            | 'Read files' >> beam.io.ReadFromText(input_pattern)
            # | 'Print contents' >> beam.Map(print)
            | 'Write to files' >> beam.io.WriteToText(
            file_path_prefix="{}data".format(dest_bucket),
            file_name_suffix=".csv"
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
