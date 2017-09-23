require 'yaml'
require 'terminal-table'

module Leeloo
  class Config

    PATH = "#{Dir.home}/.leeloo"

    @@keystores = []

    def self.init
      unless Keystore::secret_key_exists?
        abort "a secret key PGP is mandatory"
      end
      Keystore::add_keystore "private", "#{PATH}/private"
      Config::add_keystore "private", "#{PATH}/private"
    end

    def self.list_keystores
      rows = []
      @@keystores.each { |keystore| rows << [keystore['name'], keystore['path']] }
      say Terminal::Table.new :headings => ['Name', 'Path'], :rows => rows
    end

    def self.load
      FileUtils.mkdir_p PATH
      if File.exist? "#{PATH}/keystores"
        @@keystores = YAML.load_file "#{PATH}/keystores"
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
