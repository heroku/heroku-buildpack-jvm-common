# frozen_string_literal: true

require_relative 'spec_helper'

LATEST_HEROKU_OPENJDK_8_STRING = 'OpenJDK Runtime Environment (build 1.8.0_442-heroku-b06)'
LATEST_HEROKU_OPENJDK_21_STRING = 'OpenJDK Runtime Environment (build 21.0.6+7)'
LATEST_ZULU_OPENJDK_8_STRING = 'OpenJDK 64-Bit Server VM (Zulu 8.84.0.15-CA-linux64) (build 25.442-b06, mixed mode)'
LATEST_ZULU_OPENJDK_11_STRING = 'OpenJDK Runtime Environment Zulu11.78+15-CA (build 11.0.26+4-LTS)'
LATEST_ZULU_OPENJDK_17_STRING = 'OpenJDK Runtime Environment Zulu17.56+15-CA (build 17.0.14+7-LTS)'
LATEST_ZULU_OPENJDK_21_STRING = 'OpenJDK Runtime Environment Zulu21.40+17-CA (build 21.0.6+7-LTS)'
LATEST_ZULU_OPENJDK_23_STRING = 'OpenJDK Runtime Environment Zulu23.32+11-CA (build 23.0.2+7)'

EXPECTED_JAVA_VERSIONS = {
  'heroku-20' => {
    nil => LATEST_HEROKU_OPENJDK_8_STRING,
    '1.8' => LATEST_HEROKU_OPENJDK_8_STRING,
    '8' => LATEST_HEROKU_OPENJDK_8_STRING,
    '11' => 'OpenJDK Runtime Environment (build 11.0.26+4)',
    '17' => 'OpenJDK Runtime Environment (build 17.0.14+7)',
    '21' => LATEST_HEROKU_OPENJDK_21_STRING,
    '23' => 'OpenJDK Runtime Environment (build 23.0.2+7)',
    'heroku-21' => LATEST_HEROKU_OPENJDK_21_STRING,
    'zulu-21' => LATEST_ZULU_OPENJDK_21_STRING,
    '21.0.6' => LATEST_HEROKU_OPENJDK_21_STRING,
    'zulu-21.0.6' => LATEST_ZULU_OPENJDK_21_STRING,
  },
  'heroku-22' => {
    nil => LATEST_ZULU_OPENJDK_8_STRING,
    '1.8' => LATEST_ZULU_OPENJDK_8_STRING,
    '8' => LATEST_ZULU_OPENJDK_8_STRING,
    '11' => LATEST_ZULU_OPENJDK_11_STRING,
    '17' => LATEST_ZULU_OPENJDK_17_STRING,
    '21' => LATEST_ZULU_OPENJDK_21_STRING,
    '23' => LATEST_ZULU_OPENJDK_23_STRING,
    'heroku-21' => LATEST_HEROKU_OPENJDK_21_STRING,
    'zulu-21' => LATEST_ZULU_OPENJDK_21_STRING,
    '21.0.6' => LATEST_ZULU_OPENJDK_21_STRING,
    'heroku-21.0.6' => LATEST_HEROKU_OPENJDK_21_STRING,
  },
  'heroku-24' => {
    nil => LATEST_ZULU_OPENJDK_21_STRING,
    '1.8' => LATEST_ZULU_OPENJDK_8_STRING,
    '8' => LATEST_ZULU_OPENJDK_8_STRING,
    '11' => LATEST_ZULU_OPENJDK_11_STRING,
    '17' => LATEST_ZULU_OPENJDK_17_STRING,
    '21' => LATEST_ZULU_OPENJDK_21_STRING,
    '23' => LATEST_ZULU_OPENJDK_23_STRING,
    'heroku-21' => LATEST_HEROKU_OPENJDK_21_STRING,
    'zulu-21' => LATEST_ZULU_OPENJDK_21_STRING,
    '21.0.6' => LATEST_ZULU_OPENJDK_21_STRING,
    'heroku-21.0.6' => LATEST_HEROKU_OPENJDK_21_STRING,
    # Ensure that slightly incorrect version strings work
    '    21 ' => LATEST_ZULU_OPENJDK_21_STRING,
  },
}.freeze

# These installed files rarely change so we can check their MD5 hashes
# to validate they were properly installed. However, This is not a
# replacement for testing their functionality in dedicated tests!
FILE_MD5_HASHES = {
  '.profile.d/jvmcommon.sh' => 'f4727529254d7e5bd9f7de2ec110bffe',
  '.profile.d/default-proc-warning.sh' => 'bb7cd4e1747e2a0c0e9a7137e84d3cf5',
  '.profile.d/heroku-jvm-metrics.sh' => '9f48b384bc3d9161e45e15906793b191',
  '.profile.d/jdbc.sh' => '7a5ce665af22b057c027b1080d2df3d3',
  '.profile.d/jvm-redis.sh' => '7873896b3392a91b35af7dcfad115d6b',
  '.heroku/with_jmap/bin/java' => 'adc9d1e5abbc1b39d56dc37ce3e26ab8',
  '.heroku/with_jmap_and_jstack/bin/java' => '5dbd18ed94a0b1f3542ab100f88fd47d',
  '.heroku/with_jstack/bin/java' => '9155584750b1dd1fa621f1e28eab5b04',
  '.heroku/bin/heroku-metrics-agent.jar' => '050e7e5b418d0fccd020fa825e915f58',
  '.heroku/bin/with_jmap' => '6674c0a0be0ac28ac34767da39e8d2ec',
  '.heroku/bin/with_jmap_and_jstack' => '4e3d7b42abfb20502a4e47f963286625',
  '.heroku/bin/with_jstack' => '31eb167b16d3dcc2450983964aa57ee7',
}.freeze

RSpec.describe 'Java installation' do
  EXPECTED_JAVA_VERSIONS.each do |stack, expected_java_versions|
    expected_java_versions.each do |openjdk_selection_string, java_version|
      # Skip any tests where the Hatchet stack does not match the stack to test.
      # We're not using the tagging approach with "stacks" as it does not work with dynamically
      # generated tests.
      next if ENV.fetch('HATCHET_DEFAULT_STACK') != stack

      context "when stack is '#{stack}' and selection string is '#{openjdk_selection_string}'" do
        let(:app) { Hatchet::Runner.new('empty') }

        it 'installs the correct OpenJDK version, metrics agent, tools and profile.d scripts' do
          app.before_deploy do
            set_java_version(Dir.pwd, openjdk_selection_string) unless openjdk_selection_string.nil?
          end

          app.deploy do |app|
            expect(app.run('java -version')).to include(java_version)

            FILE_MD5_HASHES.each do |file_path, md5_hash|
              expect(app.run("md5sum #{file_path}")).to start_with md5_hash
            end
          end
        end
      end
    end
  end

  context 'when no OpenJDK version is specified on Heroku-24', stacks: %w[heroku-24] do
    let(:app) { Hatchet::Runner.new('empty') }

    it 'emits the correct warning' do
      app.deploy do
        expect(clean_output(app.output)).to match(Regexp.new(<<~REGEX, Regexp::MULTILINE))
          remote: -----> JVM Common app detected
          remote: 
          remote:  !     WARNING: No OpenJDK version specified
          remote:  !     
          remote:  !     Your application does not explicitly specify an OpenJDK
          remote:  !     version. The latest long-term support \\(LTS\\) version will be
          remote:  !     installed. This currently is OpenJDK 21.
          remote:  !     
          remote:  !     This default version will change when a new LTS version is
          remote:  !     released. Your application might fail to build with the new
          remote:  !     version. We recommend explicitly setting the required OpenJDK
          remote:  !     version for your application.
          remote:  !     
          remote:  !     To set the OpenJDK version, add or edit the system.properties
          remote:  !     file in the root directory of your application to contain:
          remote:  !     
          remote:  !     java.runtime.version = 21
          remote: 
          remote: -----> Installing Azul Zulu OpenJDK 21.0.[0-9]+
          remote: -----> Discovering process types
          remote:        Procfile declares types -> \\(none\\)
        REGEX
      end
    end
  end

  context 'when no OpenJDK version is specified on Heroku-20/Heroku-22', stacks: %w[heroku-20 heroku-22] do
    let(:app) { Hatchet::Runner.new('empty') }

    it 'emits the correct warning' do
      app.deploy do
        expect(clean_output(app.output)).to match(Regexp.new(<<~REGEX, Regexp::MULTILINE))
          remote: -----> JVM Common app detected
          remote: 
          remote:  !     WARNING: No OpenJDK version specified
          remote:  !     
          remote:  !     Your application does not explicitly specify an OpenJDK
          remote:  !     version. OpenJDK 1.8 will be installed.
          remote:  !     
          remote:  !     This default version will change at some point. Your
          remote:  !     application might fail to build with the new version. We
          remote:  !     recommend explicitly setting the required OpenJDK version for
          remote:  !     your application.
          remote:  !     
          remote:  !     To set the OpenJDK version, add or edit the system.properties
          remote:  !     file in the root directory of your application to contain:
          remote:  !     
          remote:  !     java.runtime.version = 1.8
          remote: 
          remote: -----> Installing .* OpenJDK 1.8.0_[0-9]+
          remote: -----> Discovering process types
          remote:        Procfile declares types -> \\(none\\)
        REGEX
      end
    end
  end

  context 'when an invalid OpenJDK version has been specified' do
    let(:app) { Hatchet::Runner.new('empty', allow_failure: true) }

    it 'fails the build with the correct error' do
      app.before_deploy do
        set_java_version(Dir.pwd, '.NET')
      end

      app.deploy do
        expect(clean_output(app.output)).to include(<<~OUTPUT)
          remote: -----> JVM Common app detected
          remote: 
          remote:  !     ERROR: Unsupported Java version: .NET
          remote:  !     
          remote:  !     Please check your system.properties file to ensure the java.runtime.version
          remote:  !     is among the list of supported version on the Dev Center:
          remote:  !     https://devcenter.heroku.com/articles/java-support#supported-java-versions
          remote:  !     
          remote:  !     If you continue to have trouble, you can open a support ticket here:
          remote:  !     https://help.heroku.com
          remote:  !     
          remote:  !     Thanks,
          remote:  !     Heroku
          remote: 
          remote:  !     Push rejected, failed to compile JVM Common app.
        OUTPUT
      end
    end
  end

  context 'when a JDK is already present in .jdk' do
    it 'skips installing OpenJDK and outputs the correct message' do
      app = Hatchet::Runner.new('empty')

      app.before_deploy do
        # Create a system.properties file to ensure the contents
        # are ignored when a custom JDK is present.
        set_java_version(Dir.pwd, '21')

        # Install Amazon Corretto to the .jdk directory of the application
        url = 'https://corretto.aws/downloads/resources/21.0.6.7.1/amazon-corretto-21.0.6.7.1-linux-x64.tar.gz'
        tarball_name = 'corretto.tar.gz'
        jdk_dir = '.jdk'

        system("curl --silent -o #{tarball_name} --fail '#{url}'")
        system("mkdir #{jdk_dir}")
        system("tar --strip-components=1 -C #{jdk_dir} -xzf #{tarball_name}")
      end

      app.deploy do
        expect(clean_output(app.output)).to match(Regexp.new(<<~REGEX, Regexp::MULTILINE))
          remote: -----> JVM Common app detected
          remote: -----> Using provided JDK
        REGEX

        # Historically, the buildpack has not installed anything into .profile.d nor installed the metrics agent
        # when a provided JDK is used. This might not have been intentional back then, but we test this behaviour
        # here to ensure a change to that behaviour is noticed and intentional.
        FILE_MD5_HASHES.each_key do |file_path|
          expect(app.run("md5sum #{file_path}")).to include('No such file or directory')
        end

        expect(app.run('.jdk/bin/java -version')).to include('OpenJDK Runtime Environment Corretto-21.0.6.7.1')
      end
    end
  end
end
