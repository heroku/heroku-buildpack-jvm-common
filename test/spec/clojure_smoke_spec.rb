# frozen_string_literal: true

require_relative 'spec_helper'

# Test both the released version of the Clojure buildpack as well as the code on main
clojure_buildpacks = %w[
  https://buildpack-registry.s3.amazonaws.com/buildpacks/heroku/clojure.tgz
  https://github.com/heroku/heroku-buildpack-clojure#main
]

RSpec.describe 'Usage from Heroku\'s Clojure buildpack' do
  clojure_buildpacks.each do |clojure_buildpack|
    context "when using '#{clojure_buildpack}'" do
      let(:app) do
        Hatchet::Runner.new('clojure-minimal',
                            buildpack: clojure_buildpack,
                            config: { JVM_COMMON_BUILDPACK: ENV.fetch('JVM_COMMON_BUILDPACK_TARBALL') })
      end

      it 'builds the app and works' do
        app.before_deploy do
          set_java_version(Dir.pwd, '8')
        end

        app.deploy do |app|
          expect(successful_body(app)).to include('["Hello" :from Heroku]')
        end
      end
    end
  end
end
