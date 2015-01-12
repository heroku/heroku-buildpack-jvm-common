require_relative 'spec_helper'

describe "Java" do

  before(:each) do
    set_java_version(app.directory, jdk_version)
    app.setup!
    app.set_config("JVM_COMMON_BUILDPACK", "https://github.com/heroku/heroku-buildpack-jvm-common/tarball/#{`git rev-parse HEAD`}")
    app.heroku.put_stack(app.name, "cedar-14")
  end

  ["1.7", "1.8"].each do |version|
    context "on jdk-#{version}" do
      let(:app) { Hatchet::Runner.new("java-servlets-sample") }
      let(:jdk_version) { version }
      it "should not install settings.xml" do
        app.set_config("BUILDPACK_URL", "https://github.com/heroku/heroku-buildpack-java#upgrade-jvm-common")
        app.deploy do |app|
          expect(app.output).to include("Installing OpenJDK #{jdk_version}")
          expect(successful_body(app)).to eq("Hello from Java!")
          expect(app.output).not_to include("Installing Maven")
          expect(app.output).to include("BUILD SUCCESS")
          expect(successful_body(app)).to eq("Hello from Java!")
        end
      end
    end
  end
end
