# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Java' do
  expected_max_ram = {
    'Basic' => 536_870_912,
    'Standard-1X' => 536_870_912,
    'Standard-2X' => 1_073_741_824,
    'Performance-M' => 2_684_354_560,
    'Performance-L' => 15_032_385_536,
    'Performance-L-RAM' => 32_212_254_720,
    'Performance-XL' => 66_571_993_088,
    'Performance-2XL' => 135_291_469_824,
  }

  expected_max_ram.each do |size, bytes|
    context "when JVM options for #{size}" do
      let(:app) do
        Hatchet::Runner.new('jvmoptions',
                            buildpack: 'https://github.com/heroku/heroku-buildpack-java#main',
                            config: { JVM_COMMON_BUILDPACK: ENV.fetch('JVM_COMMON_BUILDPACK_TARBALL') })
      end

      it 'has the correct MaxRAM JVM option set' do
        app.deploy do
          app.platform_api.formation.update(app.name, 'web', { 'size' => size })

          # It sometimes takes a moment for the formation to be actually updated, even though the API reports it to be.
          # To avoid flappy tests, we retry a couple of times to get the expected result.
          body = ''
          10.times do
            body = successful_body(app)
            break if body == "MaxRAM=#{bytes}"

            sleep(1)
          end

          expect(body).to eq("MaxRAM=#{bytes}")
        end
      end
    end
  end
end
