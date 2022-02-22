# set base image (host OS)
FROM python:latest

# set the working directory in the container
WORKDIR /code



ENV DEBIAN_FRONTEND noninteractive
# install dependencies
#RUN apt-get update -y
#RUN apt-get install python 3.10 -y
#RUN apt-get install vim -y
#RUN apt-get install python3-pip -y
#RUN python3 -m pip install --upgrade pip

# copy the dependencies file to the working directory
COPY requirements.txt .

RUN pip3 install --no-cache-dir -r requirements.txt


# copy the content of the local src directory to the working directory
COPY ./src .

RUN sed -i -e 's/\r$//' route53_backup_lambda.py

# command to run on container start
CMD [ "python", "route53_backup_lambda.py" ]