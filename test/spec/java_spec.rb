# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Java' do
  %w[1.8 8 11 17 23 11.0.23 openjdk-11.0.23 zulu-11.0.23 heroku-17 zulu-17 heroku-21 zulu-21].each do |jdk_version|
    context "when a simple java app on jdk-#{jdk_version}" do
      it 'deploys' do
        new_default_hatchet_runner('java-servlets-sample').tap do |app|
          app.before_deploy do
            set_java_version(Dir.pwd, jdk_version)
          end
          app.deploy do
            if jdk_version.start_with?('zulu')
              expect(app.output).to include("Installing Azul Zulu OpenJDK #{jdk_version.gsub('zulu-', '')}")
            elsif jdk_version.start_with?('openjdk')
              expect(app.output).to include("Installing Heroku OpenJDK #{jdk_version.gsub('openjdk-', '')}")
            elsif jdk_version.start_with?('heroku')
              expect(app.output).to include("Installing Heroku OpenJDK #{jdk_version.gsub('heroku-', '')}")
            else
              expect(app.output).to include("Installing OpenJDK #{jdk_version}")
            end

            expect(app.output).not_to include('WARNING: No OpenJDK version specified')
            expect(app.output).to include('BUILD SUCCESS')
            expect(successful_body(app)).to eq('Hello from Java!')
          end
        end
      end
    end
  end

  context 'when a system.properties file with no java.runtime.version' do
    it 'deploys' do
      new_default_hatchet_runner('java-servlets-sample').tap do |app|
        app.before_deploy do
          write_sys_props(Dir.pwd, 'maven.version=3.3.9')
        end
        app.deploy do
          expect(app.output).to include('WARNING: No OpenJDK version specified')

          if app.stack == 'heroku-24'
            expect(app.output).to include('Installing OpenJDK 21')
          else
            expect(app.output).to include('Installing OpenJDK 1.8')
          end

          expect(app.output).to include('BUILD SUCCESS')
          expect(successful_body(app)).to eq('Hello from Java!')
        end
      end
    end
  end

  %w[1.8 8 11 17 21 23].each do |jdk_version|
    context "when jdk-overlay on #{jdk_version}" do
      it 'deploys' do
        new_default_hatchet_runner('java-overlay-test').tap do |app|
          app.before_deploy do
            set_java_version(Dir.pwd, jdk_version)
          end
          app.deploy do
            if jdk_version.start_with?('zulu')
              expect(app.output).to include("Installing Azul Zulu OpenJDK #{jdk_version.gsub('zulu-', '')}")
            elsif jdk_version.start_with?('openjdk')
              expect(app.output).to include("Installing Heroku OpenJDK #{jdk_version.gsub('openjdk-', '')}")
            elsif jdk_version.start_with?('heroku')
              expect(app.output).to include("Installing Heroku OpenJDK #{jdk_version.gsub('heroku-', '')}")
            else
              expect(app.output).to include("Installing OpenJDK #{jdk_version}")
            end

            expect(app.output).not_to include('WARNING: No OpenJDK version specified')
            expect(app.output).to include('BUILD SUCCESS')

            # Workaround (August 2020):
            # When running on CircleCI (and only there), the first app.run command of the test suite will have ^@^@
            # prepended to the result string. It looks like caret encoding for two null bytes and the cause is still
            # unknown.
            cacerts_md5_jdk = app.run('md5sum .jdk/jre/lib/security/cacerts').split[0].delete('^@^@')
            sleep 5
            cacerts_md5_overlay = app.run('md5sum .jdk-overlay/jre/lib/security/cacerts').split[0].delete('^@^@')

            expect(cacerts_md5_jdk).to eq(cacerts_md5_overlay)
          end
        end
      end
    end

    context "when korvan on jdk-#{jdk_version}" do
      it 'runs commands' do
        new_default_hatchet_runner('korvan').tap do |app|
          app.before_deploy do
            set_java_version(Dir.pwd, jdk_version)
          end

          app.deploy do |deployed_app|
            if jdk_version.start_with?('zulu')
              expect(deployed_app.output).to include("Installing Azul Zulu OpenJDK #{jdk_version.gsub('zulu-', '')}")
            elsif jdk_version.start_with?('openjdk')
              expect(deployed_app.output).to include("Installing Heroku OpenJDK #{jdk_version.gsub('openjdk-', '')}")
            elsif jdk_version.start_with?('heroku')
              expect(deployed_app.output).to include("Installing Heroku OpenJDK #{jdk_version.gsub('heroku-', '')}")
            else
              expect(deployed_app.output).to include("Installing OpenJDK #{jdk_version}")
            end

            sleep 1
            expect(deployed_app.run('echo $JAVA_TOOL_OPTIONS'))
              .not_to include('-Xmx300m -Xss512k')

            sleep 1
            expect(deployed_app.run('echo $JAVA_OPTS'))
              .to include('-Xmx300m -Xss512k')

            sleep 1
            if jdk_version.start_with?('zulu-1.')
              # Skip exit-code default option, required to execute a process from Procfile instead of a command in bash.
              expect(deployed_app.run('jce', { heroku: { 'exit-code' => Hatchet::App::SkipDefaultOption } }))
                .to include('Illegal key size or default parameters')
            else
              # Skip exit-code default option, required to execute a process from Procfile instead of a command in bash.
              expect(deployed_app.run('jce', { heroku: { 'exit-code' => Hatchet::App::SkipDefaultOption } }))
                .to include('Encrypting, "Test"')
                .and include('Decrypted: Test')
            end

            sleep 1
            # Skip exit-code default option, required to execute a process from Procfile instead of a command in bash.
            expect(deployed_app.run('netpatch', { heroku: { 'exit-code' => Hatchet::App::SkipDefaultOption } }))
              .to include('name:eth0 (eth0)')
              .and include('name:lo (lo)')

            sleep 1
            # Skip exit-code default option, required to execute a process from Procfile instead of a command in bash.
            expect(deployed_app.run('https', { heroku: { 'exit-code' => Hatchet::App::SkipDefaultOption } }))
              .to include('Successfully invoked HTTPS service.')
              .and match(/"X-Forwarded-Proto(col)?":\s?"https"/)

            if !jdk_version.match(/^9/) &&
               !jdk_version.match(/^openjdk-9/) &&
               !jdk_version.match(/^zulu-9/) &&
               !jdk_version.match(/^[12][0-9]/) &&
               !jdk_version.match(/^openjdk-[12][0-9]/)

              sleep 1
              # Skip exit-code default option, required to execute a process from Procfile instead of a command in bash.
              expect(deployed_app.run('pgssl', { heroku: { 'exit-code' => Hatchet::App::SkipDefaultOption } }))
                .to match(/sslmode: require/)
            end
          end
        end
      end
    end
  end
end
