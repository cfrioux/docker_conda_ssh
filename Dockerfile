# Base for conda_ssh
#
# VERSION 0.1
#
# build : docker build -t image_name .
# usage: docker run -ti -v /path/to/share:/mount/point image_name bash
#

FROM ibmjava:latest
MAINTAINER clemence.frioux@inria.fr

# wget and ssh-server and build-essential 
RUN apt-get update && \
    apt-get install openssh-server bzip2 build-essential zlib1g-dev git -qqy && \
    apt-get clean && apt-get purge

# install python3.6
RUN cd /opt && wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tgz && \
    tar -xvf Python-3.6.3.tgz && rm Python-3.6.3.tgz && cd Python-3.6.3 && \
    ./configure && make && make install && cd ../ && rm -rf Python-3.6.3 && cd

# install conda # && rm Miniconda3-3.7.0-Linux-x86_64.sh
RUN wget https://repo.continuum.io/miniconda/Miniconda3-3.7.0-Linux-x86_64.sh -O ~/miniconda.sh
RUN bash ~/miniconda.sh -b -p /opt/miniconda
ENV PATH="/opt/miniconda/bin:$PATH"
RUN conda update conda
RUN conda create --yes -n flutopy python=3.6


# configure sshd
RUN mkdir /var/run/sshd
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]