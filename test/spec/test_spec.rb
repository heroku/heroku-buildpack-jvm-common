require_relative "spec_helper"

describe "A Java application" do

  it "checks for bad version" do
    Hatchet::Runner.new("korvan", allow_failure: true).tap do |app|
      app.before_deploy do
        set_java_version(Dir.pwd, "14.badversion")
      end
      app.deploy do
        expect(app.output).to include("ERROR: Unsupported Java version: 14.badversion")
      end
    end
  end

  it "has absolute buildpack paths" do
    buildpacks = [
      :default,
      "https://github.com/sharpstone/force_absolute_paths_buildpack"
    ]
    Hatchet::Runner.new("korvan", buildpacks: buildpacks).tap do |app|
      app.deploy do
        #deploy works
      end
    end
  end

  it "uses the cache with ci" do
    Hatchet::Runner.new("korvan").run_ci do |test_run|
      expect(test_run.output).to include("Downloading from central")
      test_run.run_again
      expect(test_run.output).to_not include("Downloading from central")
    end
  end

end
