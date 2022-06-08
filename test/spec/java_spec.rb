require_relative 'spec_helper'

describe "Java" do

  ["1.7", "1.8", "8", "11", "13", "15", "16", "17", "18", "11.0.15", "openjdk-11.0.15", "zulu-11.0.15", "heroku-17", "zulu-17"].each do |jdk_version|
    context "a simple java app on jdk-#{jdk_version}" do
      it "should deploy" do
        new_default_hatchet_runner("java-servlets-sample").tap do |app|
          app.before_deploy do
            set_java_version(Dir.pwd, jdk_version)
          end
          app.deploy do
            if jdk_version.start_with?("zulu")
              expect(app.output).to include("Installing Azul Zulu OpenJDK #{jdk_version.gsub('zulu-', '')}")
            elsif jdk_version.start_with?("openjdk")
              expect(app.output).to include("Installing Heroku OpenJDK #{jdk_version.gsub('openjdk-', '')}")
            elsif jdk_version.start_with?("heroku")
              expect(app.output).to include("Installing Heroku OpenJDK #{jdk_version.gsub('heroku-', '')}")
            else
              expect(app.output).to include("Installing OpenJDK #{jdk_version}")
            end
            expect(app.output).to include("BUILD SUCCESS")
            expect(successful_body(app)).to eq("Hello from Java!")
          end
        end
      end
    end
  end

  context "a system.properties file with no java.runtime.version" do
    it "should deploy" do
      expected_version = "1.8"
      new_default_hatchet_runner("java-servlets-sample").tap do |app|
        app.before_deploy do
          write_sys_props(Dir.pwd, "maven.version=3.3.9")
        end
        app.deploy do
          expect(app.output).to include("Installing OpenJDK #{expected_version}")
          expect(app.output).to include("BUILD SUCCESS")
          expect(successful_body(app)).to eq("Hello from Java!")
        end
      end
    end
  end

  ["1.7", "1.8", "8", "11", "13", "15", "16", "17", "18"].each do |jdk_version|
    context "jdk-overlay on #{jdk_version}" do
      it "should deploy" do
        new_default_hatchet_runner("java-overlay-test").tap do |app|
          app.before_deploy do
            set_java_version(Dir.pwd, jdk_version)
          end
          app.deploy do
            if jdk_version.start_with?("zulu")
              expect(app.output).to include("Installing Azul Zulu OpenJDK #{jdk_version.gsub('zulu-', '')}")
            elsif jdk_version.start_with?("openjdk")
              expect(app.output).to include("Installing Heroku OpenJDK #{jdk_version.gsub('openjdk-', '')}")
            elsif jdk_version.start_with?("heroku")
              expect(app.output).to include("Installing Heroku OpenJDK #{jdk_version.gsub('heroku-', '')}")
            else
              expect(app.output).to include("Installing OpenJDK #{jdk_version}")
            end
            expect(app.output).to include("BUILD SUCCESS")

            # Workaround (August 2020):
            # When running on CircleCI (and only there), the first app.run command of the test suite will have ^@^@
            # prepended to the result string. It looks like caret encoding for two null bytes and the cause is still
            # unknown.
            cacerts_md5_jdk = app.run("md5sum .jdk/jre/lib/security/cacerts").split(" ")[0].delete("^@^@")
            sleep 5
            cacerts_md5_overlay = app.run("md5sum .jdk-overlay/jre/lib/security/cacerts").split(" ")[0].delete("^@^@")

            expect(cacerts_md5_jdk).to eq(cacerts_md5_overlay)
          end
        end
      end
    end
  end

  ["1.8", "8", "11", "13", "15", "16", "17", "18"].each do |jdk_version|
    context "korvan on jdk-#{jdk_version}" do
      it "runs commands" do
        new_default_hatchet_runner("korvan").tap do |app|
          app.before_deploy do
            set_java_version(Dir.pwd, jdk_version)
          end
          app.deploy do |app|
            if jdk_version.start_with?("zulu")
              expect(app.output).to include("Installing Azul Zulu OpenJDK #{jdk_version.gsub('zulu-', '')}")
            elsif jdk_version.start_with?("openjdk")
              expect(app.output).to include("Installing Heroku OpenJDK #{jdk_version.gsub('openjdk-', '')}")
            elsif jdk_version.start_with?("heroku")
              expect(app.output).to include("Installing Heroku OpenJDK #{jdk_version.gsub('heroku-', '')}")
            else
              expect(app.output).to include("Installing OpenJDK #{jdk_version}")
            end

            sleep 1
            expect(app.run("echo $JAVA_TOOL_OPTIONS")).
                not_to include(%q{-Xmx300m -Xss512k})

            sleep 1
            expect(app.run("echo $JAVA_OPTS")).
                to include(%q{-Xmx300m -Xss512k})

            sleep 1
            if jdk_version.start_with?("zulu-1.")
              # Skip exit-code default option, required to execute a process from Procfile instead of a command in bash.
              expect(app.run("jce", { :heroku => { "exit-code" => Hatchet::App::SkipDefaultOption }})).
                  to include("Illegal key size or default parameters")
            else
              # Skip exit-code default option, required to execute a process from Procfile instead of a command in bash.
              expect(app.run("jce", { :heroku => { "exit-code" => Hatchet::App::SkipDefaultOption }})).
                  to include(%q{Encrypting, "Test"}).
                  and include(%q{Decrypted: Test})
            end

            sleep 1
            # Skip exit-code default option, required to execute a process from Procfile instead of a command in bash.
            expect(app.run("netpatch", { :heroku => { "exit-code" => Hatchet::App::SkipDefaultOption }})).
                to include(%q{name:eth0 (eth0)}).
                and include(%q{name:lo (lo)})

            sleep 1
            # Skip exit-code default option, required to execute a process from Procfile instead of a command in bash.
            expect(app.run("https", { :heroku => { "exit-code" => Hatchet::App::SkipDefaultOption }})).
                to include("Successfully invoked HTTPS service.").
                and match(%r{"X-Forwarded-Proto(col)?":\s?"https"})

            if !jdk_version.match(/^9/) and
              !jdk_version.match(/^openjdk-9/) and
              !jdk_version.match(/^zulu-9/) and
              !jdk_version.match(/^1[0-9]/) and
              !jdk_version.match(/^openjdk-1[0-9]/)

              sleep 1
              # Skip exit-code default option, required to execute a process from Procfile instead of a command in bash.
              expect(app.run("pgssl", { :heroku => { "exit-code" => Hatchet::App::SkipDefaultOption }})).
                  to match(%r{sslmode: require})
            end
          end
        end
      end
    end
  end
end
