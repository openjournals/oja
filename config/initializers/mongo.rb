config = YAML.load_file(Rails.root + 'config' + 'mongodb.yml')
logger = Rails.env.production? ? nil : Rails.logger
MongoMapper.setup(config, Rails.env, { :logger => logger })
