require_relative 'spec_helper'

describe "Java" do
  expected_max_ram={
    "Basic": 536870912,
    "Standard-1X": 536870912,
    "Standard-2X": 1073741824,
    "Performance-M": 2684354560,
    "Performance-L": 15032385536,
    "Performance-L-RAM": 32212254720,
    "Performance-XL": 66571993088,
    "Performance-2XL": 135291469824
  }

  expected_max_ram.each do |size, bytes|
    context "JVM options for #{size}" do
      it "should have the correct MaxRAM JVM option set" do
        new_default_hatchet_runner("jvmoptions").tap do |app|
          app.deploy do
            app.platform_api.formation.update(app.name, "web", {"size" => size})
            expect(successful_body(app)).to eq("MaxRAM=#{bytes}")
          end
        end
      end
    end
  end
end
