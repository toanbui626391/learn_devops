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
from apache_beam.dataframe.io import read_csv
from typing import List
import logging
import argparse

#define run function
#reference for using logging package (basic use): https://docs.python.org/3/howto/logging.html#basic-logging-tutorial
#reference for using argparse package: https://docs.python.org/3/howto/argparse.html

#command to run pipeline in your local:
    # python3 batch_pipeline.py --source_path="../data/test_data.csv" --dest_path="../data/dest"
def run(
    source_path: str,
    dest_path: str,
    beam_args: List[str] = None
) -> None:
    #build your pipeline here
    with beam.Pipeline() as p:
        #dataframe is actually a pandas package
        df = p | read_csv(source_path)
        df.to_csv(dest_path)

if __name__ == "__main__":
    #do not need to init logging instance
    logging.getLogger().setLevel(logging.INFO)
    parser = argparse.ArgumentParser()

    #parse arguments
    parser.add_argument(
        "--source_path",
        help="gs source file path"
    )
    parser.add_argument(
        "--dest_path",
        help="gs destination file path"
    )
    #return (namespace, list_of_args)
    args, beam_args = parser.parse_known_args()

    run(
        source_path=args.source_path,
        dest_path=args.dest_path,
        beam_args=beam_args
    )
