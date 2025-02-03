# frozen_string_literal: true

require_relative 'spec_helper'

# Test both the released version of the Maven buildpack as well as the code on main
maven_buildpacks = %w[
  https://buildpack-registry.s3.amazonaws.com/buildpacks/heroku/java.tgz
  https://github.com/heroku/heroku-buildpack-java#main
]

RSpec.describe 'Usage from Heroku\'s Maven buildpack' do
  maven_buildpacks.each do |maven_buildpack|
    context "when using '#{maven_buildpack}'" do
      let(:app) do
        Hatchet::Runner.new('jvmoptions',
                            buildpack: maven_buildpack,
                            config: { JVM_COMMON_BUILDPACK: ENV.fetch('JVM_COMMON_BUILDPACK_TARBALL') })
      end

      it 'builds the app and works' do
        app.before_deploy do
          set_java_version(Dir.pwd, '21')
        end

        app.deploy do |app|
          expect(successful_body(app)).to include('MaxRAM')
        end
      end
    end
  end
end
