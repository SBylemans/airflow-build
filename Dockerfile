FROM openjdk:21-jdk AS base_java


FROM apache/airflow:3.0.2
COPY requirements.txt /

USER root
RUN sudo apt update && sudo apt -y upgrade 

# RUN curl -o java21.tar.gz https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_linux-x64_bin.tar.gz
# RUN tar xvf java21.tar.gz
# RUN sudo mv jdk-21.0.2/ /usr/local/jdk-21
# ENV JAVA_HOME=/usr/local/jdk-21
# ENV PATH=\$PATH:\$JAVA_HOME/bin

# RUN sudo apt install gnupg ca-certificates curl && \
#     curl -s https://repos.azul.com/azul-repo.key | sudo gpg --dearmor -o /usr/share/keyrings/azul.gpg && \
#     chmod 644 /usr/share/keyrings/azul.gpg && \
#     echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | sudo tee /etc/apt/sources.list.d/zulu.list && \
#     sudo apt update && \
#     sudo apt install -y zulu21-jdk


# Copy Java from OpenJDK stage
COPY --from=base_java /usr/java/openjdk-21 /opt/java/openjdk

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

RUN curl -o spark.tgz https://dlcdn.apache.org/spark/spark-4.0.1/spark-4.0.1-bin-hadoop3.tgz && \
    curl -o spark.asc https://dlcdn.apache.org/spark/spark-4.0.1/spark-4.0.1-bin-hadoop3.tgz.asc && \
    curl -o keys https://archive.apache.org/dist/spark/KEYS && \
    gpg --import keys && \
    gpg --verify spark.asc spark.tgz && \
    tar xvf spark.tgz && \
    sudo mv spark-4.0.1-bin-hadoop3 /usr/local/spark
ENV PATH=$PATH:/usr/local/spark/bin


RUN java --version
RUN spark-submit -h


USER airflow
RUN pip install --no-cache-dir "apache-airflow==${AIRFLOW_VERSION}" -r /requirements.txt