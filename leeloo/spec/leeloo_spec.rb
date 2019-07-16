require "spec_helper"

RSpec.describe Leeloo do

  let(:preferences) do
    Leeloo::PrivateLocalFileSystemPreferences.new
  end

  it "has a version number" do
    expect(Leeloo::VERSION).not_to be nil
  end

end
