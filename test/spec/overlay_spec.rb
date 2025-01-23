# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'JDK overlay' do
  it 'is applied correctly over OpenJDK 8' do
    app = Hatchet::Runner.new('jdk-overlay-java-8')

    app.deploy do
      expect(app.output).to match(Regexp.new(<<~REGEX, Regexp::MULTILINE))
        remote: -----> JVM Common app detected        
        remote: -----> Installing OpenJDK 8        
      REGEX

      expect(app.run('cat .jdk/extra.txt')).to eq("extra.txt contents\n")
      expect(app.run('md5sum .jdk/jre/lib/security/cacerts')).to start_with('86700d98c9b3aaf30b40fabcc12c75fe')
    end
  end

  it 'is applied correctly over OpenJDK >8 (21)' do
    app = Hatchet::Runner.new('jdk-overlay')

    app.deploy do
      expect(app.output).to match(Regexp.new(<<~REGEX, Regexp::MULTILINE))
        remote: -----> JVM Common app detected        
        remote: -----> Installing OpenJDK 21        
      REGEX

      expect(app.run('cat .jdk/extra.txt')).to eq("extra.txt contents\n")
      expect(app.run('md5sum .jdk/lib/security/cacerts')).to start_with('86700d98c9b3aaf30b40fabcc12c75fe')
    end
  end
end
