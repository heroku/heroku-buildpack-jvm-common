# frozen_string_literal: true

require_relative 'spec_helper'

# Test both the released version of the Gradle buildpack as well as the code on main
gradle_buildpacks = %w[
  heroku/gradle
  https://github.com/heroku/heroku-buildpack-gradle#main
]

RSpec.describe 'Usage from Heroku\'s Gradle buildpack' do
  gradle_buildpacks.each do |gradle_buildpack|
    context "when using '#{gradle_buildpack}'" do
      let(:app) do
        Hatchet::Runner.new('spring-boot-gradle',
                            buildpack: gradle_buildpack,
                            config: { JVM_COMMON_BUILDPACK: ENV.fetch('JVM_COMMON_BUILDPACK_TARBALL') })
      end

      it 'builds the app and works' do
        app.before_deploy do
          set_java_version(Dir.pwd, '8')
        end

        app.deploy do |app|
          expect(successful_body(app)).to include('Hello from Spring Boot')
        end
      end
    end
  end
end
