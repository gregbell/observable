module Observable
  
  @@observable_classes = []
  
  def self.included(klass)
    klass.send(:extend, ClassMethods)
    @@observable_classes << klass
  end
  
  def self.all_observables
    @@observable_classes.collect do |klass|
      klass.observables.collect{|name| "#{klass}:#{name}" }
    end.flatten
  end
  
  def self.observe(klass, name=nil, method_name=nil, &block)
    if klass.instance_of? Symbol
      name = klass
      klass = AnonymousObservables
    end
    AnonymousObservables.observe(klass, name, method_name, &block)
  end
  
  def self.create(name)
    AnonymousObservables.observable name
  end
  
  def self.notify(name, event)
    AnonymousObservables.notify_observers name, event
  end
  
  
  module ClassMethods
    def observable(name)
      @observables ||= {}
      @observables[name] = []
      setup_attr_accessor_observer(name) if observable_name_is_an_attr_accessor?(name)
    end
    
    def add_observer(name, block)
      @observables[name] << block
    end
    
    def observables
      @observables ? @observables.keys : []
    end
    
    def observe(klass, name, method_name=nil, &block)
      block = lambda{ |event| self.send(method_name, event) } unless block_given?
      klass.add_observer(name, block)
    end
    
    def notify_observers(name, event)
      @observables[name].each {|o| o.call(event)}
    end
    
    private
    
    def observable_name_is_an_attr_accessor?(name)
      instance_methods.include?("#{name.to_s}=")
    end
    
    def setup_attr_accessor_observer(name)
      alias_method "old #{name}=", "#{name}="
      define_method "#{name}=" do |new_value|
        send("old #{name}=", new_value)
        notify name, { self.class.name.downcase.to_sym => self }
      end
    end
  end
  
  class AnonymousObservables
    include Observable
  end
  
  def notify(name, event)
    notify_instance_observers(name, event) if @observables
    self.class.notify_observers(name, event)
  end
  
  def notify_instance_observers(name, event)
    @observables[name].each {|o| o.call(event)}
  end
  
  def observe(name, &block)
    (@observables ||= {}) && (@observables[name] ||= [])
    @observables[name] << block
  end
  
end