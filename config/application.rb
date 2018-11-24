require_relative 'boot'

require 'rails/all'
Bundler.require(*Rails.groups)

module WapiRails
  class Application < Rails::Application
    config.i18n.fallbacks = [:es, :en]
    config.i18n.default_locale = 'en'
    config.assets.paths << Rails.root.join('node_modules')
    config.load_defaults 5.2
    config.time_zone = 'Santiago'
  end
end
