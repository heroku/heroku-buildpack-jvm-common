# frozen_string_literal: true

require_relative 'spec_helper'
require 'json'

RSpec.describe 'Java' do
  expected_jvm_options = {
    'Basic' => { 'MaxRAM' => '536870912', 'CICompilerCount' => '2', 'ThreadStackSize' => '512' },
    'Standard-1X' => { 'MaxRAM' => '536870912', 'CICompilerCount' => '2', 'ThreadStackSize' => '512' },
    'Standard-2X' => { 'MaxRAM' => '1073741824', 'CICompilerCount' => '2', 'ThreadStackSize' => '1024' },
    'Performance-M' => { 'MaxRAM' => '2684354560', 'CICompilerCount' => '2', 'ThreadStackSize' => '1024' },
    'Performance-L' => { 'MaxRAM' => '15032385536', 'CICompilerCount' => '4', 'ThreadStackSize' => '1024' },
    'Performance-L-RAM' => { 'MaxRAM' => '32212254720', 'CICompilerCount' => '3', 'ThreadStackSize' => '1024' },
    'Performance-XL' => { 'MaxRAM' => '66571993088', 'CICompilerCount' => '4', 'ThreadStackSize' => '1024' },
    'Performance-2XL' => { 'MaxRAM' => '135291469824', 'CICompilerCount' => '12', 'ThreadStackSize' => '1024' },
  }

  expected_jvm_options.each do |size, options|
    context "when JVM options for #{size}" do
      let(:app) do
        Hatchet::Runner.new('jvmoptions',
                            buildpack: 'https://github.com/heroku/heroku-buildpack-java#main',
                            config: { JVM_COMMON_BUILDPACK: ENV.fetch('JVM_COMMON_BUILDPACK_TARBALL') })
      end

      it 'has the correct JVM options set' do
        app.deploy do
          app.platform_api.formation.update(app.name, 'web', { 'size' => size })

          # It sometimes takes a moment for the formation to be actually updated, even though the API reports it to be.
          # To avoid flappy tests, we retry a couple of times to get the expected result.
          body = ''
          10.times do
            body = successful_body(app, path: "?vmoptions=#{options.keys.join(',')}")
            body = JSON.parse(body)

            break if body == options

            sleep(1)
          end

          expect(body).to eq(options)
        end
      end
    end
  end
end
