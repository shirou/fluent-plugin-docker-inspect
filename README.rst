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
     emit_interval 30
     tag docker.inspects
     add_addr_tag yes
     filter { "status": ["running"] }  # see Docker remote API
     only_changed true
     <keys>
       id Id
       created Created
       path Path
       status State.Status
       ports NetworkSettings.Ports
       ip_addr NetworkSettings.IPAddress
       mac_addr NetworkSettings.MacAddress
     </keys>
   </source>

emit_interval
  Emit interval by second. (default 60 sec)
tag
  fluentd tag.
docker_url
  Specify docker_url if remote. ex: ``tcp://example.com:5422``. If docker runs local, no need to specify this param.
add_addr_tag
  If specify some string such as 'yes', add local host ipv4 addr. (default: nil).
filter
  Set fileter about container. See Docker remote API to specify params.
only_changed
  If true, only emit when docker inspect is changed. (default is true)
keys
  If set, output values containes only specified keys and path(period separated value). Default is output all values as one JSON.

License
----------

MIT

Authors
--------

- WAKAYAMA Shirou (shirou.faw@gmail.com)
