require_relative "spec_helper"

describe "A Java application" do

  it "works with the getting started guide" do
    Hatchet::Runner.new("java-getting-started", buildpacks: ["https://github.com/heroku/heroku-buildpack-java"]).tap do |app|
      app.deploy do
      # deploy works
      end
    end
  end

  it "checks for bad version" do
    Hatchet::Runner.new("java-overlay-test", buildpacks: ["https://github.com/heroku/heroku-buildpack-java"], allow_failure: true).tap do |app|
      app.before_deploy do
        set_java_version(Dir.pwd, "14.badversion")
      end
      app.deploy do
        expect(app.output).to include("ERROR: Unsupported Java version: 14.badversion")
      end
    end
  end

  it "have absolute buildpack paths" do
    buildpacks = [
      :default,
      "https://github.com/sharpstone/force_absolute_paths_buildpack"
    ]
    Hatchet::Runner.new("java-getting-started", buildpacks: buildpacks).tap do |app|
      app.deploy do
        #deploy works
      end
    end
  end
end
