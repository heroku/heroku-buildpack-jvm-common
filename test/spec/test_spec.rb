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
    Hatchet::Runner.new("java-getting-started", buildpacks: ["https://github.com/heroku/heroku-buildpack-java"], allow_failure: true).tap do |app|
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
    Hatchet::Runner.new("java-getting-started", buildpacks: buildpacks).tap do |app|
      app.deploy do
        #deploy works
      end
    end
  end

  it "uses the cache with ci" do
    Hatchet::Runner.new("java-getting-started", buildpacks: ["https://github.com/heroku/heroku-buildpack-java"]).run_ci do |test_run|
      expect(test_run.output).to include("Downloading from central")
      test_run.run_again
      expect(test_run.output).to_not include("Downloading from central")
    end
  end

  it "should not restore cached directories" do
    Hatchet::Runner.new("java-overlay-test", stack: "heroku-18").deploy do |app, heroku|
      expect(app.output).to_not include("Loading from cache")
      app.update_stack("heroku-16")
      app.commit!
      app.push!
      #outputs are the same
    end
  end

#Test cache for regular deploys is used on repeated deploys
  it "should not restore cache if the stack did not change" do
    Hatchet::Runner.new('java-getting-started', stack: "heroku-16").deploy do |app, heroku|
      app.update_stack("heroku-16")
      app.commit!
      app.push!
      #outputs are the same
    end
  end

end
