Resque.redis = $redis

require 'resque/server'
require 'resque_scheduler'
Resque.schedule = {}
#Resque.schedule = YAML.load_file("#{Rails.root}/config/resque_schedule.yml")

ENV['QUEUE'] = '*'
#ENV['QUEUES'] = 'user_data_queue,geocoder_queue'
#ENV['COUNT'] = '5'
