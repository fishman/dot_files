begin
  # load wirble
  require 'rubygems'
  require 'wirble'
  require 'hirb'

  # start wirble (with color)
  Wirble.init
  Wirble.colorize

  Hirb::View.enable
  Hirb::View.formatter_config
rescue LoadError => err
  warn "Couldn't load Wirble: #{err}"
end
