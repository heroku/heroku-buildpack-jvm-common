require_relative 'spec_helper'

describe "JVM Metrics" do
  ["1.8", "8", "11", "17", "21" ,"23"].each do |jdk_version|
    context "a simple java app on jdk-#{jdk_version}" do
      it "should deploy" do
        new_default_hatchet_runner("java-servlets-sample", labs: "runtime-heroku-metrics").tap do |app|
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
