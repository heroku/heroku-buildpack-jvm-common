# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'using an application provided JDK' do
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
      expect(app.run('.jdk/bin/java -version')).to include('OpenJDK Runtime Environment Corretto-21.0.6.7.1')

      expect(app.output).to match(Regexp.new(<<~REGEX, Regexp::MULTILINE))
        remote: -----> JVM Common app detected        
        remote: -----> Using provided JDK        
      REGEX
    end
  end
end
