# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Java' do
  expected_max_ram = {
    Basic: 536_870_912,
    'Standard-1X': 536_870_912,
    'Standard-2X': 1_073_741_824,
    'Performance-M': 2_684_354_560,
    'Performance-L': 15_032_385_536,
    'Performance-L-RAM': 32_212_254_720,
    'Performance-XL': 66_571_993_088,
    'Performance-2XL': 135_291_469_824,
  }

  expected_max_ram.each do |size, bytes|
    context "when JVM options for #{size}" do
      it 'has the correct MaxRAM JVM option set' do
        new_default_hatchet_runner('jvmoptions').tap do |app|
          app.deploy do
            app.platform_api.formation.update(app.name, 'web', { 'size' => size })
            expect(successful_body(app)).to eq("MaxRAM=#{bytes}")
          end
        end
      end
    end
  end
end
