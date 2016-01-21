require_relative 'spec_helper'

describe "Java" do

  before(:each) do
    set_java_version(app.directory, jdk_version)
    app.setup!
    app.set_config("JVM_COMMON_BUILDPACK" => "https://api.github.com/repos/heroku/heroku-buildpack-jvm-common/tarball/master")
  end

  ["1.7", "1.8"].each do |version|
    context "a simple java app on jdk-#{version}" do
      let(:app) { Hatchet::Runner.new("java-servlets-sample",
        :buildpack_url => "https://github.com/heroku/heroku-buildpack-java") }
      let(:jdk_version) { version }
      it "should deploy" do
        app.deploy do |app|
          expect(app.output).to include("Installing OpenJDK #{jdk_version}")
          expect(app.output).to include("BUILD SUCCESS")
          expect(successful_body(app)).to eq("Hello from Java!")
        end
      end
    end

    context "korvan on jdk-#{version}" do
      let(:app) { Hatchet::Runner.new("korvan",
        :buildpack_url => "https://github.com/heroku/heroku-buildpack-java") }
      let(:jdk_version) { version }
      it "runs commands" do
        app.deploy do |app|
          expect(app.output).to include("Installing OpenJDK #{jdk_version}")

          sleep 1
          expect(app.run("echo $JAVA_TOOL_OPTIONS")).
              not_to include(%q{-Xmx350m -Xss512k})

          sleep 1
          expect(app.run("echo $JAVA_OPTS")).
              to include(%q{-Xmx350m -Xss512k})

          sleep 1
          expect(app.run("jce")).
              to include(%q{Encrypting, "Test"}).
              and include(%q{Decrypted: Test})

          sleep 1
          expect(app.run("netpatch")).
              to include(%q{name:eth0 (eth0)}).
              and include(%q{name:lo (lo)})

          sleep 1
          expect(app.run("https")).
              to include("Successfully invoked HTTPS service.").
              and match(%r{"X-Forwarded-Proto(col)?": "https"})

          sleep 1
          expect(app.run("pgssl")).
              to match(%r{sslmode: require})
        end
      end
    end
  end
end
