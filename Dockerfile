FROM rocker/verse:3.6.1
RUN cat /etc/os-release

ENV WORKON_HOME /opt/virtualenvs
ENV PYTHON_VENV_PATH $WORKON_HOME/ma_env
ENV SPARK_VERSION 2.4.0
ENV SPARKLYR_VERSION 1.0.5

RUN apt-get update \
	&& apt-get install -y libudunits2-dev
RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential python3 python3-dev python3-wheel \
	libpython3-dev python3-virtualenv \
    python3-pip libssl-dev libffi-dev apt-utils

## Prepara environment de python
RUN python3 -m virtualenv --python=/usr/bin/python3 ${PYTHON_VENV_PATH}
RUN chown -R rstudio:rstudio ${WORKON_HOME}
ENV PATH ${PYTHON_VENV_PATH}/bin:${PATH}
## And set ENV for R! It doesn't read from the environment...
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron && \
    echo "WORKON_HOME=${WORKON_HOME}" >> /usr/local/lib/R/etc/Renviron && \
    echo "RETICULATE_PYTHON_ENV=${PYTHON_VENV_PATH}" >> /usr/local/lib/R/etc/Renviron

## Because reticulate hardwires these PATHs
RUN ln -s ${PYTHON_VENV_PATH}/bin/pip /usr/local/bin/pip && \
    ln -s ${PYTHON_VENV_PATH}/bin/virtualenv /usr/local/bin/virtualenv
RUN chmod -R a+x ${PYTHON_VENV_PATH}

RUN .${PYTHON_VENV_PATH}/bin/activate && \
 pip install --upgrade setuptools==42.0.2 && \
 pip install --upgrade tensorflow==2.0.0b1 \
     keras==2.3.1 \ 
     numpy==1.16.5 \
     scipy==1.2.2 \
     pandas==0.25.3 \
     h5py==2.10.0 \
     requests==2.22.0 \
     scikit-learn==0.22 

## Instalacion de spark
RUN r -e 'devtools::install_version("sparklyr", version = Sys.getenv("SPARKLYR_VERSION"))' 
RUN r -e 'sparklyr::spark_install(version = Sys.getenv("SPARK_VERSION"), verbose = TRUE)'

RUN mv /root/spark /opt/ && \
chown -R rstudio:rstudio /opt/spark/ && \
ln -s /opt/spark/ /home/rstudio/


RUN install2.r --error \
     reticulate tensorflow  keras \ 
     graphframes \
     arules arulesViz \
     tidygraph \
     broom 

RUN install2.r --error tm text2vec textrank \
     tidytext textreuse \
     ggraph here 


