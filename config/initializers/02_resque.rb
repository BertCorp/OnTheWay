require 'resque'
require 'resque_scheduler'
require 'resque_scheduler/server'

Resque.redis = $redis
Resque::Scheduler.dynamic = true
Resque.schedule = YAML.load_file("#{Rails.root}/config/resque_schedule.yml")

ENV['QUEUE'] = '*'
#ENV['QUEUES'] = 'user_data_queue,geocoder_queue'
#ENV['COUNT'] = '5'
