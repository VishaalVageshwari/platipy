FROM ubuntu:20.04

RUN apt-get update; apt-get install -y redis-server git python3-pip libgl1-mesa-glx libsm6 libxext6 libxrender-dev

RUN ln -s /usr/bin/python3 /usr/bin/python
RUN ln -s /usr/bin/pip3 /usr/bin/pip

WORKDIR /home/service

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY requirements-dev.txt requirements-dev.txt
RUN pip install -r requirements-dev.txt

COPY . platipy

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENV PYTHONPATH "/home/service/platipy"

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV WORK C.UTF-8

ARG dicom_listen_port=7777

ENV DICOM_LISTEN_PORT ${dicom_listen_port}
ENV DICOM_LISTEN_AET PLATIPY_SERVICE

RUN printf '#!/bin/bash\npython3 -m platipy.backend.manage $@\n' > /usr/bin/manage && chmod +x /usr/bin/manage

EXPOSE 8000
EXPOSE ${dicom_listen_port}

ENV WORK /data
RUN mkdir /logs /data && chmod 0777 /logs /data

ENTRYPOINT ["/entrypoint.sh"]

CMD [ "manage" ]
