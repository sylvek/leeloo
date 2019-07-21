require "spec_helper"

RSpec.describe Leeloo do

    KEYSTORE_TEST_PATH = "./test/test"

    let(:preferences) do
        preferences = Leeloo::PrivateLocalFileSystemPreferences.new
        preferences.load "#{Dir.pwd}/test"
        return preferences
    end

    it "can describe secrets" do
       expect(preferences.keystore().secrets).to eq(
           [Leeloo::LocalFileSystemSecret.new("#{KEYSTORE_TEST_PATH}/secrets/my/secret", "my/secret"),
            Leeloo::LocalFileSystemSecret.new("#{KEYSTORE_TEST_PATH}/secrets/my_secret", "my_secret")])
    end

    it "can read a secret" do
        expect(preferences.keystore().secrets[0].read).to eq("hello")
    end

end