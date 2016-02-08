# convert dot-string to value in hash
# ex: NetworkSettings.Ports -> hash[NetworkSettings][Ports]
def dig(hash, dotted_path)
  parts = dotted_path.split '.', 2
  match = hash[parts[0]]
  if !parts[1] or match.nil?
    return match
  else
    return dig(match, parts[1])
  end
end

module Fluent
  class DockerInspectInput < Input
    Fluent::Plugin.register_input('docker_inspect', self)

    config_param :emit_interval, :integer, :default => 60
    config_param :docker_url, :string, :default => nil
    config_param :tag, :string, :default => nil
    config_param :add_addr_tag, :string, :default => nil
    config_param :filter, :string, :default => nil
    config_param :only_changed, :bool, :default => true

    unless method_defined?(:log)
      define_method(:log) { $log }
    end

    def initialize
      super
      require 'json'
      require 'docker'
      require 'socket'

      Docker.url = @docker_url if @docker_url
      @host_addr = get_ipaddress
    end

    class TimerWatcher < Coolio::TimerWatcher
      def initialize(interval, repeat, log, &callback)
        @callback = callback
        # Avoid long shutdown time
        @num_call = 0
        @call_interval = interval / 10
        @log = log
        super(10, repeat)
      end

      def on_timer
        @num_call += 1
        if @num_call >= @call_interval
          @num_call = 0
          @callback.call
        end
      rescue => e
        @log.error e.to_s
        @log.error_backtrace
      end
    end

    def configure(conf)
      super

      # Read configuration for keys and create a hash
      @keys = Hash.new
      conf.elements.select { |element| element.name == 'keys' }.each { |element|
        element.each_pair { |key_name, path|
          element.has_key?(key_name) # to suppress unread configuration warning
          @keys[key_name] = path
          @log.info "Added keys: #{key_name}=>#{@keys[key_name]}"
        }
      }
    end

    def start
      @started_at = Time.now.to_i

      @loop = Coolio::Loop.new
      @timer = TimerWatcher.new(@emit_interval, true, log, &method(:on_timer))
      @loop.attach(@timer)
      @thread = Thread.new(&method(:run))

      @es = MultiEventStream.new
    end

    def shutdown
      log.info "shutdown docker_inspect plugin"

      @loop.watchers.each {|w| w.detach }
      @loop.stop
      @thread.join
    end

    def run
      @loop.run
    rescue => e
      log.error "unexpected error", :error=> e.to_s
      log.error_backtrace
    end

    def on_timer
      time = Engine.now
      tag = @tag
      if @add_addr_tag && @host_addr
        tag = [tag, @host_addr].join(".")
      end

      inspect = get_inspect
      if inspect.length == 0
        return
      end
      inspect.each { | i |
        if @keys.length > 0  # keys are specfied
          k = Hash.new
          changed = false
          @keys.each do |key_name, path|
            tmp = dig(i, path)
            next if tmp == ""
            k[key_name] = tmp
            changed = true  # if nothing matched, not sent
          end
          @es.add(time, k) if changed
        else
          @es.add(time, i)
        end
      }
      router.emit_stream(tag, @es)
    end

    private
    def get_ipaddress
      Socket.getifaddrs.select{|x| 
        if x.addr.ipv4?
          return x.addr.ip_address unless x.addr.ipv4_loopback?
        end
      }
      return nil
    end

    def get_containers
      begin
        if @filter
          Docker::Container.all(:all => true, :filters => @filter)
        else
          Docker::Container.all(:all => true)
        end
      rescue Exception => ex
        @log.error ex
        return []
      end
    end

    def get_inspect
      result = []

      get_containers.each { |c|
        result.push c.json
      }
      # check changed before or not
      if @only_changed && @last_inspect.to_s == result.to_s
        return []
      end
      @last_inspect = result

      return result
    end
  end
end
