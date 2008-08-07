require File.dirname(__FILE__) + '/spec_helper'

describe Observable do
  
  after(:each) do
    # Reset the observables
    Employee.class_eval{ @observables = {} }
  end
  
  describe "- Creating Observables" do
    it "should create new observables with a name" do
      class Employee
        include Observable
        observable :changed_location
      end
    
      Employee.observables.size.should == 1
      Employee.observables.first.should == :changed_location
    end

    it "should create new observables based on the name of an attr_accessor" do
      class Employee
        include Observable
        attr_accessor :salary
        observable :salary
      end
      Employee.observables.size.should == 1
      Employee.observables.first.should == :salary
    end
    
    it "should create a new anonymous observable with a name" do
      Observable.create :system_messages
      Observable.all_observables.should include('Observable::AnonymousObservables:system_messages')
    end
  end
  
  
  describe "- Registering and receiving notifications" do
    before(:each) do
      
      class Employee
        include Observable        
        attr_accessor :salary
        observable :salary
      end      
    end
    after(:each) do
      # Reset the observables
      Employee.class_eval{ @observables = {} }
    end
    it "should register a new observer with a block" do
      class HR
        include Observable
        observe Employee, :salary do |event|
          raise "received event notification"
        end
      end
      lambda{ Employee.new.salary = 5000  }.should raise_error("received event notification")
    end
    it "should register a new observer with a class method as a symbol" do
      class HR
        include Observable
        observe Employee, :salary, :salary_changed
        def self.salary_changed(event)
          raise "received event notification"
        end
      end
      lambda{ Employee.new.salary = 5000  }.should raise_error("received event notification")
    end
    
  end
  
end