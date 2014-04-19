# Extended_Include - Deals with some of the finer details of the
# extend-on-included idiom for adding both class and instance methods
# on module import.
#
# Based on these posts:
# * http://stackoverflow.com/questions/15905270/can-you-extend-self-included
# * http://www.kappacs.com/2014/ruby-sub-classes-inheritance-include-extend/
# and hundreds of other posts about the ::included extend ClassMethods hack.
#
# The Extended_Include module is a back-end support module. See the Module
# module extensions for the user interface.
#
# Version 0.0.2, 2014-04-18
#
# @author Brian Katzung (briank@kappacs.com), Kappa Computer Solutions, LLC
# @license Public Domain

module Extended_Include

    VERSION = "0.0.2"

    # The extended_include list, by module
    @include_list = {}

    # The class methods list, by module
    @class_methods = {}

    # Include additional modules.
    def self.add_includes (base, *modules)
	(@include_list[base] ||= []).concat modules
	base.class_exec do
	    # Note that we reverse here to counter ::include's
	    # last-to-first behavior in order to achieve first-to-last
	    # behavior.
	    include *modules.reverse
	    extend Extended_Include
	end
    end

    # Return a module's class method list.
    def self.class_methods_for (base)
	(@class_methods[base] ||= []).uniq!
	@class_methods[base].reverse
    end

    # Include a module's class methods when included.
    def self.include_class_methods (base, *modules, &block)
	(@class_methods[base] ||= []).concat modules
	@class_methods[base].push Module.new(&block) if block
	base.class_exec { extend Extended_Include }
    end

    # Return a module's extended_include list.
    def self.includes_for (base)
	(@include_list[base] ||= []).uniq!
	@include_list[base]
    end

    # The #included method extended to other modules' ::included method.
    def included (base)
	Extended_Include.includes_for(self).each do |mod|
	    mod.included base if mod.respond_to?(:included) &&
	      (!base.respond_to?(:superclass) ||
	      !base.superclass.include?(mod))
	end

	# Note that we reverse here to counter ::extend's
	# last-to-first behavior in order to achieve first-to-last
	# behavior.
	sources = Extended_Include.class_methods_for self
	base.class_exec { extend *sources.reverse } unless sources.empty?

	super base rescue nil
    end

end

# Extend class Module to support additional "include" functionality.
class Module

    # Include additional modules.
    #
    # Unlike a traditional #include, the modules' ::included methods
    # (if present) will be called when the current module is
    # included if they have not already been previously included by
    # the including object's ancestors.
    #
    # Another difference is that multiple modules are always included
    # first-to-last, so it doesn't matter if you
    # "extended_include M1, M2, M3" or
    # "extended_include M1; extended_include M2; extended_include M3"
    # or any other variant with the same reference order. Methods will
    # always be sought in last-to-first order (M3, M2, M1).
    def extended_include (*modules)
	Extended_Include.add_includes self, *modules
    end

    # Extend class methods into the including object when including this
    # module.
    #
    #  include_class_methods        # from sub-module ClassMethods, if present
    #  include_class_methods M1, M2 # from specified sub-modules
    #  include_class_methods do     # defined in a block
    #    def some_class_method; end
    #  end
    #
    # As usual, sub-modules must be defined before reference.
    def include_class_methods (*modules, &block)
	if !block && modules.empty? && const_defined?(:ClassMethods)
	    Extended_Include.include_class_methods self, self::ClassMethods
	else Extended_Include.include_class_methods self, *modules, &block
	end
    end

end
