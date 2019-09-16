FROM debian:buster
WORKDIR /root/circleci-setup
COPY .circleci/primary/setup.sh .ruby-version .nvmrc Aptfile ./
RUN ./setup.sh
