Observable
==========

A really small and simple implementation of the Observer Pattern in Ruby

To use, include Observable in to any class.

Author:		Greg Bell
Version:	1.0

### 1. CREATE AN OBSERVABLE ATTR_ACCESSOR

To create an observable attr_accessor so that other classes can be notified
when it changes:
  
	class Employee
	  include Observable
	
	  attr_accessor :salary
	  observable :salary
	
	end


### 2. CREATE A CUSTOM OBSERVABLE

To create a custom observable notification:

	class Employee
	  include Observable
	
	  observable :salary_changed
	  
	  def update_salary(new_salary)
	    
	    # update logic code
	    
	    # Then notify any observers passing it an event hash
	    # This will passs the event hash on to any classes who registered
	    # to observe this class observable
	    notify :salary_changed, { :employee => self}
	  end
	
	end


### 3. REGISTER FOR UPDATES

To register for updates to an observable class:

	class HR
	  include Observable
	  
	  # Create an observer and pass the logic to a class method
	  observe Employee, :salary , :employee_salary_updated
	  
	  def self.employee_salary_updated(event)
	    puts "#{self} got employee salary updated with #{event.inspect}"
	  end
	
	  # OR (these would both create the same results)
	  
	  # Create an observer and put logic in a block
	  observe Employee, :salary do |event|
	    puts "#{self} got employee salary updated with #{event.inspect}"
	  end
	  
	end

To register for updates to only ONE observable instance:

	# Employee has setup an observable called :salary
	employee = Employee.new("Bob")
	
	employee.observe :salary do |event|
		HR.employee_salary_updated(event)
	end


### 4. CREATE ANONYMOUS OBSERVABLES

To create observables that are not associated with any class:

	Observable.create :system_message

	Observable.observe :system_message do |event|
	  puts "Received system message: #{event.inspect}"
	end

	class Anon
	  Observable.observe :system_message do |event|
	    puts "Received  inside anon system message: #{event.inspect}"
	  end
	end

	Observable.notify(:system_message, { :message => 'APP STARTED'})

	Observable.observe Employee, :salary do |event|
	  puts "Anonomously observing employee salary"
	end


### 5. VIEW ALL AVAILABLE OBSERVABLES

You can view all currently observables by calling Observable.all_observables


