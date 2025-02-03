# frozen_string_literal: true

require_relative 'spec_helper'

EXPECTED_JAVA_VERSIONS = {
  'heroku-20' => {
    nil => 'OpenJDK Runtime Environment (build 1.8.0_432-heroku-b06)',
    '1.8' => 'OpenJDK Runtime Environment (build 1.8.0_432-heroku-b06)',
    '8' => 'OpenJDK Runtime Environment (build 1.8.0_432-heroku-b06)',
    '11' => 'OpenJDK Runtime Environment (build 11.0.25+9)',
    '17' => 'OpenJDK Runtime Environment (build 17.0.13+11)',
    '21' => 'OpenJDK Runtime Environment (build 21.0.5+11)',
    '23' => 'OpenJDK Runtime Environment (build 23.0.1+11)',
    'heroku-21' => 'OpenJDK Runtime Environment (build 21.0.5+11)',
    'zulu-21' => 'OpenJDK Runtime Environment Zulu21.38+21-CA (build 21.0.5+11-LTS)',
  },
  'heroku-22' => {
    nil => 'OpenJDK 64-Bit Server VM (Zulu 8.82.0.21-CA-linux64) (build 25.432-b06, mixed mode)',
    '1.8' => 'OpenJDK 64-Bit Server VM (Zulu 8.82.0.21-CA-linux64) (build 25.432-b06, mixed mode)',
    '8' => 'OpenJDK 64-Bit Server VM (Zulu 8.82.0.21-CA-linux64) (build 25.432-b06, mixed mode)',
    '11' => 'OpenJDK Runtime Environment Zulu11.76+21-CA (build 11.0.25+9-LTS)',
    '17' => 'OpenJDK Runtime Environment Zulu17.54+21-CA (build 17.0.13+11-LTS)',
    '21' => 'OpenJDK Runtime Environment Zulu21.38+21-CA (build 21.0.5+11-LTS)',
    '23' => 'OpenJDK Runtime Environment Zulu23.30+13-CA (build 23.0.1+11)',
    'heroku-21' => 'OpenJDK Runtime Environment (build 21.0.5+11)',
    'zulu-21' => 'OpenJDK Runtime Environment Zulu21.38+21-CA (build 21.0.5+11-LTS)',
  },
  'heroku-24' => {
    nil => 'OpenJDK Runtime Environment Zulu21.38+21-CA (build 21.0.5+11-LTS)',
    '1.8' => 'OpenJDK 64-Bit Server VM (Zulu 8.82.0.21-CA-linux64) (build 25.432-b06, mixed mode)',
    '8' => 'OpenJDK 64-Bit Server VM (Zulu 8.82.0.21-CA-linux64) (build 25.432-b06, mixed mode)',
    '11' => 'OpenJDK Runtime Environment Zulu11.76+21-CA (build 11.0.25+9-LTS)',
    '17' => 'OpenJDK Runtime Environment Zulu17.54+21-CA (build 17.0.13+11-LTS)',
    '21' => 'OpenJDK Runtime Environment Zulu21.38+21-CA (build 21.0.5+11-LTS)',
    '23' => 'OpenJDK Runtime Environment Zulu23.30+13-CA (build 23.0.1+11)',
    'heroku-21' => 'OpenJDK Runtime Environment (build 21.0.5+11)',
    'zulu-21' => 'OpenJDK Runtime Environment Zulu21.38+21-CA (build 21.0.5+11-LTS)',
    # Ensure that slightly incorrect version strings work
    '    21 ' => 'OpenJDK Runtime Environment Zulu21.38+21-CA (build 21.0.5+11-LTS)',
  },
}.freeze

# These installed files rarely change so we can check their MD5 hashes
# to validate they were properly installed. However, This is not a
# replacement for testing their functionality in dedicated tests!
FILE_MD5_HASHES = {
  '.profile.d/jvmcommon.sh' => 'f4727529254d7e5bd9f7de2ec110bffe',
  '.profile.d/default-proc-warning.sh' => 'ad34c4eb52bb81556a9ad77753ee25ed',
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
end
