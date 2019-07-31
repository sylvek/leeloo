require 'gpgme'

module Leeloo
    class Recipient
        attr_reader :keys

        def add key
        end

        def remove key
        end
    end

    class GpgPrivateLocalFileSystemRecipient < Recipient
        def initialize path
            @keys = []
            @path = path

            FileUtils.mkdir_p "#{@path}/keys"
            Dir.glob("#{@path}/keys/*") { |key| @keys << File.basename(key) }
        end

        def add key=nil
            GPGME::Key.find(:public, nil, ).each do |k|
                if key == nil || key == k.uids.first.email
                    k.export(:output => File.open("#{@path}/keys/#{k.uids.first.email}", "w+")) 
                    @keys << k.uids.first.email
                end
            end
        end

        def remove key
            if File.file? "#{@path}/keys/#{key}"
                @keys.delete key if File.delete "#{@path}/keys/#{key}"
            end
        end
    end
end