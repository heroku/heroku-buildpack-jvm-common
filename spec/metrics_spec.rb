require_relative 'spec_helper'

describe "JVM Metrics" do

  before(:each) do
    set_java_version(app.directory, jdk_version)
    app.setup!
    app.set_config(
      "JVM_COMMON_BUILDPACK" =>
      "https://api.github.com/repos/heroku/heroku-buildpack-jvm-common/tarball/#{jvm_common_branch}")
    `heroku features:enable runtime-heroku-metrics --app #{app.name}`
  end

  ["1.7", "1.8", "11"].each do |version|
    context "a simple java app on jdk-#{version}" do
      let(:app) { Hatchet::Runner.new("java-servlets-sample",
        :buildpack_url => "https://github.com/heroku/heroku-buildpack-java") }
      let(:jdk_version) { version }
      it "should deploy" do
        app.deploy do |app|
          expect(app.output).to include("BUILD SUCCESS")
          expect(successful_body(app)).to eq("Hello from Java!")
        end
      end
    end
  end
end
