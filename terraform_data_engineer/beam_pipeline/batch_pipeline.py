import apache_beam as beam
from typing import List
import logging
import argparse

#define run function
#reference for using logging package (basic use): https://docs.python.org/3/howto/logging.html#basic-logging-tutorial
#reference for using argparse package: https://docs.python.org/3/howto/argparse.html
def run(
    source_path: str,
    dest_path: str,
    beam_args: List[str] = None
) -> None:
    #build your pipeline here
    with beam.Pipeline() as p:
        df = p | beam.dataframe.io.read_csv(source_path)
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
