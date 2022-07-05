FROM centos:7

LABEL maintainer="ivansergeevichfrolov@gmail.com"

ENV ES_HOME="/var/lib/elasticsearch" \
    ES_PATH_CONF="/var/lib/elasticsearch/config"

ENV GROUP_ID=1000
ENV USER_ID=1000

RUN yum -y install wget \
    # пришлось ставить wget и perl-Digest-SHA..
    && yum install perl-Digest-SHA -y \
    # копипаста из руководства по установке (https://www.elastic.co/guide/en/elasticsearch/reference/7.17/targz.html)
    && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.5-linux-x86_64.tar.gz \
    && wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.5-linux-x86_64.tar.gz.sha512 \
    && shasum -a 512 -c elasticsearch-7.17.5-linux-x86_64.tar.gz.sha512 \
    && tar -xzf elasticsearch-7.17.5-linux-x86_64.tar.gz \
    && mv elasticsearch-7.17.5 ${ES_HOME} \
    # удаляем ненужное
    && rm -f elasticsearch-7.17.5-linux-x86_64.tar.gz \
    # чистим за собой
    && yum -y remove wget \
    && yum clean all \
    # создадим пользователя и дадим ему права
    && groupadd --gid ${GROUP_ID} elasticsearch \
    && useradd --uid ${USER_ID} --gid elasticsearch --create-home elasticsearch \
    && chown -R elasticsearch:elasticsearch ${ES_HOME}
    
    # перенесем конфиг
COPY --chown=elasticsearch:elasticsearch /config/* ${ES_PATH_CONF}

    # далее от пользователя elasticsearch
USER elasticsearch

EXPOSE 9200

WORKDIR ${ES_HOME}

# поехали!
CMD ["sh", "-c", "${ES_HOME}/bin/elasticsearch"]