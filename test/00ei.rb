require 'minitest/autorun'
require 'extended_include'

module M1
    module ClassMethods
	def cm; $log << 'M1 cm'; super rescue nil; end
    end
    include_class_methods
end

module M2
    extended_include M1;
    module MyClassMethods
	def cm; $log << 'M2 MCM cm'; super rescue nil; end
    end
    include_class_methods(MyClassMethods) do
	def cm; $log << 'M2 anon cm'; super rescue nil; end
    end
end

module M3; extended_include M2; end

class TestExtInc_00 < MiniTest::Unit::TestCase

    def test1
	$log = []
	M3.cm
	assert_equal [ 'M2 anon cm', 'M2 MCM cm', 'M1 cm' ], $log
    end

end

# END
