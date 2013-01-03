# Install the rabbitmq collector config

include_recipe 'diamond::default'

collector_config "RabbitMQCollector" do
  user     node['diamond']['collectors']['RabbitMQCollector']['user']
  password node['diamond']['collectors']['RabbitMQCollector']['password']
end
