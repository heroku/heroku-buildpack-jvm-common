require_relative 'spec_helper'

describe "Java" do

  before(:each) do
    set_java_version(app.directory, jdk_version)
    app.setup!
    app.set_config("JVM_COMMON_BUILDPACK" => "https://github.com/heroku/heroku-buildpack-jvm-common/tarball/#{`git rev-parse HEAD`}")
  end

  ["1.7", "1.8"].each do |version|
    context "on jdk-#{version}" do
      let(:app) { Hatchet::Runner.new("java-servlets-sample",
        :buildpack_url => "https://github.com/heroku/heroku-buildpack-java") }
      let(:jdk_version) { version }
      it "should deploy a simple java app" do
        app.deploy do |app|
          expect(app.output).to include("Installing OpenJDK #{jdk_version}")
          expect(app.output).to include("BUILD SUCCESS")
          expect(successful_body(app)).to eq("Hello from Java!")
        end
      end
    end
  end
end
