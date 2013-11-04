config = YAML.load_file("#{Rails.root}/config/config.yml")
APP_CONFIG = config["common"].merge(config[Rails.env])
