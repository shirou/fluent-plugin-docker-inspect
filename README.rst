Docker inspect plugin for fluentd
==========================================

Overview
----------

**docker-inspect** plugin emits docker container inspections. If multiple containers running, emit events by each containers.

Installation
--------------------

Simply use RubyGems::

  gem install fluent-plugin-docker-inspect


Configuration
------------------

::

  <source>
    type docker_inspect
    emit_interval 10
    tag docker
    add_addr_tag yes
  </source>


emit_interval
  emit interval by second. (default 60 sec)
tag
  fluentd tag.
docker_url
  specify docker_url if remote. ex: ``tcp://example.com:5422``. If docker runs local, no need to specify this param.
add_addr_tag
  if specify some string such as 'yes', add local host ipv4 addr. (default: nil)
only_changed
  if yes, only emit when docker inspect is changed.

License
----------

MIT

Authors
--------

- WAKAYAMA Shirou (shirou.faw@gmail.com)
