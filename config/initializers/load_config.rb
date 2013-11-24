config = YAML.load_file("#{Rails.root}/config/config.yml")
APP_CONFIG = config["all"].merge(config[Rails.env])
