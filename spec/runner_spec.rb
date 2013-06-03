require 'semver'
require 'runner'

describe XSemVer::Runner do
  
  
  
  
  describe "init(ialize)" do
    
    describe "when no .semver file exists" do
      
      it "creates a new .semver file" do
        pending
      end
      
    end
    
    describe "when a .semver file already exists" do
      
      it "does not overwrite the existing file" do
        pending
      end
      
      it "displays an error message" do
        pending
      end
      
    end
    
  end




  describe "inc(rement)" do
    
    describe "major" do
      
      it "increments the major version" do
        pending
      end
      
      it "sets the minor version to 0" do
        pending
      end
      
      it "sets the patch vesion to 0" do
        pending
      end
      
    end
    
    describe "minor" do
      
      it "does not change the major version" do
        pending
      end
      
      it "increments the minor version" do
        pending
      end
      
      it "sets the patch version to 0" do
        pending
      end
      
    end
    
    describe "patch" do
      
      it "does not change the major version" do
        pending
      end
      
      it "does not change the minor version" do
        pending
      end
      
      it "increments the patch version" do
        pending
      end
      
    end
    
    describe "without a valid subcommand" do
      
      it "raises an exception" do
        pending
      end
      
    end
    
  end
  
  
  
  
  describe "spe(cial)" do
    
    describe "when a string argument is provided" do
      
      it "sets the pre-release of the SemVer" do
        pending
      end
      
    end
    
    describe "without a string argument" do
      
      it "raises an exception" do
        pending
      end
      
    end
    
  end
  
  
  
  
  describe "format" do
    
    describe "when a format argument is provided" do
      
      it "returns the SemVer formatted according to the format string" do
        pending
      end
      
    end
    
    describe "without a format argument" do
      
      it "raises an exception" do
        pending
      end
      
    end
    
  end
  
  
  
  
  describe "tag" do
    
    it "outputs the SemVer with default formatting" do
      pending
    end
    
  end
  
  
  
  
end