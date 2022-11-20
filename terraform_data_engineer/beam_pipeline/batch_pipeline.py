import apache_beam as beam

source_path = "./data/test_data.csv"
dest_path = "./data/dest/test_data.csv"
#create beam pipeline
with beam.Pipeline() as p:
    df = p | beam.dataframe.io.read_csv(source_path)
    df.to_csv(dest_path)