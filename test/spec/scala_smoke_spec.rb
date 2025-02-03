# frozen_string_literal: true

require_relative 'spec_helper'

# Test both the released version of the Scala buildpack as well as the code on main
scala_buildpacks = %w[
  https://buildpack-registry.s3.amazonaws.com/buildpacks/heroku/scala.tgz
  https://github.com/heroku/heroku-buildpack-scala#main
]

RSpec.describe 'Usage from Heroku\'s Scala buildpack' do
  scala_buildpacks.each do |scala_buildpack|
    context "when using '#{scala_buildpack}'" do
      let(:app) do
        Hatchet::Runner.new('play-scala-seed',
                            buildpack: scala_buildpack,
                            config: { JVM_COMMON_BUILDPACK: ENV.fetch('JVM_COMMON_BUILDPACK_TARBALL') })
      end

      it 'builds the app and works' do
        app.before_deploy do
          set_java_version(Dir.pwd, '21')
        end

        app.deploy do |app|
          expect(successful_body(app)).to include('Welcome to Play!')
        end
      end
    end
  end
end
