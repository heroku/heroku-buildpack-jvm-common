require_relative 'spec_helper'

describe "JVM Metrics" do
  ["1.7", "1.8", "11", "14", "15"].each do |jdk_version|
    context "a simple java app on jdk-#{jdk_version}" do
      it "should deploy" do
        Hatchet::Runner.new(
          "java-servlets-sample",
          labs: "runtime-heroku-metrics",
          buildpacks: ["https://github.com/heroku/heroku-buildpack-java"],
          stack:  ENV["HEROKU_TEST_STACK"],
          config: {
            "JVM_COMMON_BUILDPACK" => "https://api.github.com/repos/heroku/heroku-buildpack-jvm-common/tarball/#{jvm_common_branch}"
          }
        ).tap do |app|
          app.before_deploy do
            set_java_version(Dir.pwd, jdk_version)
          end
          app.deploy do
            expect(app.output).to include("BUILD SUCCESS")
            expect(successful_body(app)).to eq("Hello from Java!")
          end
        end
      end
    end
  end
end
