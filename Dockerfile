FROM apache/airflow:3.0.2
COPY requirements.txt /

RUN apt update && apt upgrade 
RUN sudo apt install snapd
RUN snap install spark-client

RUN pip install --no-cache-dir "apache-airflow==${AIRFLOW_VERSION}" -r /requirements.txt