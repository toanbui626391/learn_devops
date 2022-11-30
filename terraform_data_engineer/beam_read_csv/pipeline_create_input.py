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
@beam.ptransform_fn
@beam.typehints.with_input_types(beam.pvalue.PBegin)
@beam.typehints.with_output_types(int)
def Count(pbegin: beam.pvalue.PBegin, n: int) -> beam.PCollection[int]:
  def count(n: int) -> Iterable[int]:
    for i in range(n):
      yield i

  return (
      pbegin
      | 'Create inputs' >> beam.Create([n])
      | 'Generate elements' >> beam.FlatMap(count)
  )
########################################################## combine apache beam component into complete pipeline here
def run(
    n: str,
    # dest_path: str,
    beam_args: List[str] = None
) -> None:
    #build your pipeline here
    #some change in the pipeline
    # input_pattern = [input_pattern]
    # print("input_pattern list: ", input_pattern)
    options = PipelineOptions(flags=[], type_check_additional='all')
    with beam.Pipeline(options=options) as pipeline:
        (
            pipeline
            | f'Count to {n}' >> Count(n)
            | 'Print elements' >> beam.Map(print)
        )

############################################################ main program
#python3 terraform_data_engineer/beam_read_csv/pipeline_read_csv.py --input_pattern gs://fce2845e810918fb-gcf-trigger-bucket/*.csv
if __name__ == "__main__":
    #do not need to init logging instance
    #some test change
    logging.getLogger().setLevel(logging.INFO)
    parser = argparse.ArgumentParser()

    #parse arguments
    parser.add_argument(
        "--n",
        help="an int number"
    )
    #return (namespace, list_of_args)
    args, beam_args = parser.parse_known_args()
    # print("input_pattern: ", args.input_pattern)
    run(
        n=int(args.n),
        # dest_path=args.dest_path,
        beam_args=beam_args
    )
