require "spec_helper"

RSpec.describe Leeloo do

    KEYSTORE_TEST_PATH = "./test/test"

    let(:preferences) do
        preferences = Leeloo::PrivateLocalFileSystemPreferences.new
        preferences.load "#{Dir.pwd}/test"
        return preferences
    end

    it "can load local preferences" do
        default_keystore = Leeloo::PrivateLocalFileSystemKeystore.new "test", KEYSTORE_TEST_PATH
        expect(preferences.default_keystore).to eq(default_keystore)
    end

end