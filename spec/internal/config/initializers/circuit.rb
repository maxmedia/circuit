if defined?(::Mongoid)
  Circuit.set_site_store :mongoid_store
  Circuit.set_node_store :mongoid_store
else
  Circuit.set_site_store :memory_store
  Circuit.set_node_store :memory_store
end

$logger_io = StringIO.new
Circuit.logger = ::Logger.new($logger_io)
