FROM gcr.io/dataflow-templates-base/python38-template-launcher-base
#config variable with ENV. variable is reference to container file system (not your local file system)
ENV FLEX_TEMPLATE_PYTHON_REQUIREMENTS_FILE="/template/requirements.txt"
#change your pipelie here to change content of docker image build
ENV FLEX_TEMPLATE_PYTHON_PY_FILE="/template/main.py"
#copy your current directory to /template folder in the container file system
COPY . /template

# run linux command with RUN
RUN apt-get update \
    && apt-get install -y libffi-dev git \
    && rm -rf /var/lib/apt/lists/* \
    # Upgrade pip and install the requirements.
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r $FLEX_TEMPLATE_PYTHON_REQUIREMENTS_FILE \
    # Download the requirements to speed up launching the Dataflow job.
    && pip download --no-cache-dir --dest /tmp/dataflow-requirements-cache -r $FLEX_TEMPLATE_PYTHON_REQUIREMENTS_FILE

# Since we already downloaded all the dependencies, there's no need to rebuild everything.
ENV PIP_NO_DEPS=True