require 'yaml'
require 'terminal-table'

module Leeloo
  class Config

    PATH = "#{Dir.home}/.leeloo"

    @@keystores = []

    @@default = { "keystore" => "private" }

    def self.default
      @@default
    end

    def self.init
      Keystore::add_keystore "private", "#{PATH}/private"
      Config::add_keystore "private", "#{PATH}/private"
    end

    def self.list_keystores(ascii)
      if ascii
        @@keystores.each { |keystore| puts keystore['name'] }
      else
        rows = []
        @@keystores.each do |keystore|
          is_default = '*' if keystore['name'] == @@default['keystore']
          rows << [keystore['name'], keystore['path'], is_default ]
        end
        say Terminal::Table.new :headings => ['Name', 'Path', 'Default'], :rows => rows
      end
    end

    def self.load
      FileUtils.mkdir_p PATH
      if File.exist? "#{PATH}/keystores"
        @@keystores = YAML.load_file "#{PATH}/keystores"
      end
      if File.exist? "#{PATH}/config"
        @@default = YAML.load_file "#{PATH}/config"
      end
    end

    def self.add_keystore name, path
      keystore = { 'name' => name, 'path' => path}
      unless @@keystores.include? keystore
        @@keystores << keystore
        File.write("#{PATH}/keystores", @@keystores.to_yaml)
      end
    end

    def self.get_keystore name
      @@keystores.each do |keystore|
        return keystore['path'] if keystore['name'] == name
      end

      raise "keystore not found"
    end

  end
end
