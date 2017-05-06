#!/usr/bin/env ruby

require 'set'

def signature_declares_error(signature)
	signature =~ /throws|Error/
end


chain_function_signatures_text = %[
(B) -> C

(B) -> () -> C
(B) -> ((C) -> Void) -> Void
(B) -> ((Error?) -> Void) -> Void
(B) -> ((C?, Error?) -> Void) -> Void

(B, (C) -> Void) -> Void
(B, (Error?) -> Void) -> Void
(B, (C?, Error?) -> Void) -> Void

((C) -> Void) -> Void
((Error?) -> Void) -> Void
((C?, Error?) -> Void) -> Void

() -> C
]

@chain_function_signatures = chain_function_signatures_text.
							split("\n").
							delete_if { |n| n.size == 0 }.
							collect { |n| n.strip }
							

@chain_function_signatures = @chain_function_signatures.map { |signature|
	ret = signature
	if signature =~ /(\([^()]*\)\s*->\sVoid)/
		sub_func = $1
		unless signature.end_with?(sub_func) # if the capture isn't the whole signature
			ret = [signature.gsub(sub_func, "@escaping #{sub_func}")]
			ret << signature.gsub(sub_func, "(#{sub_func})?")
		end
	end
	ret
}.flatten

@chain_function_signatures = @chain_function_signatures.map { |signature|
	ret = signature
	unless signature_declares_error(signature)
		insertion_index = signature.rindex(" ->")
		ret = [signature,
					signature.dup.insert(insertion_index," throws")]
	end
	ret
}.flatten

@chain_function_signatures.sort! {|a,b| a.size <=> b.size}

def generate_chainable()
	generated_chain_declarations = []

	@chain_function_signatures.each {|function_signature|
		include_error_handler = signature_declares_error(function_signature)
		error_handler_string = include_error_handler ? ", _ errorHandler: @escaping (Error,B) -> Void" : ""
		transform_result_type = function_signature =~ /C/ ? "C" : "B"
		extra_generic_parameter = transform_result_type != "B" ? "<C>" : ""
		void_receiving = function_signature =~ /^\(\)/
		method_name = void_receiving ?  "splice" : "chain"
		documentation = transform_result_type != "B" ? 
			"///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink" :
			"///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink"
		
		generated_chain_declarations << documentation
		generated_chain_declarations << "@discardableResult func #{method_name}#{extra_generic_parameter}(_ function: @escaping #{function_signature}#{error_handler_string} ) -> ProcessLink<B,#{transform_result_type}>"
		generated_chain_declarations << ""
	}


	chainable_protocol_string = %[
/// Generated protocol declaring chain functions.
protocol Chainable {
	associatedtype B

#{generated_chain_declarations.join("\n")}
}
]
	output_to_file_if_different("Chainable.swift",chainable_protocol_string)
end

def generate_chain_operator() 
	generated_chain_declarations = []

	@chain_function_signatures.each {|function_signature|
		include_error_handler = signature_declares_error(function_signature)
		right_hand_side = include_error_handler ? "FunctionWithErrorHandler<#{function_signature},B>" : "@escaping #{function_signature}"
		transform_result_type = function_signature =~ /C/ ? "C" : "B"
		generic_parameters = transform_result_type != "B" ? "<A,B,C>" : "<A,B>"
		void_receiving = function_signature =~ /^\(\)/
		symbol_name = void_receiving ?  "^-" : "^^"
		method_name = void_receiving ?  "splice" : "chain"
		implementation = include_error_handler ? "return left.#{method_name}(right.function, right.errorHandler)" : "return left.#{method_name}(right)"
		
		generated_chain_declarations << "///operator syntax for ProcessLink.chain"
		generated_chain_declarations << "@discardableResult public func #{symbol_name}#{generic_parameters}(left: ProcessLink<A,B>, right: #{right_hand_side}) -> ProcessLink<B, #{transform_result_type}> {"
		generated_chain_declarations << "\t#{implementation}"
		generated_chain_declarations << "}"
		generated_chain_declarations << ""
	}
	
	chain_operator_string = %[
/// Generated chain operator functions.

public struct FunctionWithErrorHandler<Func,Cause> {
	let function: Func
	let errorHandler: (Error,Cause) -> Void
}

precedencegroup HoneyBeeErrorHandlingPrecedence {
	associativity: left
	higherThan: LogicalConjunctionPrecedence
}

infix operator ^! : HoneyBeeErrorHandlingPrecedence

public func ^!<F,Cause>(left: F, right: @escaping (Error,Cause) -> Void) -> FunctionWithErrorHandler<F,Cause> {
	return FunctionWithErrorHandler(function: left, errorHandler: right)
}

infix operator ^^ : LogicalConjunctionPrecedence

infix operator ^- : LogicalConjunctionPrecedence

#{generated_chain_declarations.join("\n")}
]

	output_to_file_if_different("ChainOperator.swift",chain_operator_string)
end

def output_to_file_if_different(filename, contnet)
	output_file = File.join(File.dirname(__FILE__),filename)

	existing_contents = File.exists?(output_file) ? File.readlines(output_file).join() : ""

	if (existing_contents != contnet)
		File.open(output_file,"w") {|f| f.print contnet }
	end
end


bind_patterns = %w[
	A
	AB
	AA
	ABC
	ABCD
]

@bind_instances = Set.new

bind_patterns.each {|pattern|
	pattern.split('').each {|variable|
		@bind_instances << [pattern,variable]
	}
}


def generate_bind()
	generated_bind_declarations = []
	
	generated_operator_declarations = []	
	
	@bind_instances.each {|arguments, consumed_arg|		
		generic_argument_declaration = arguments.split('').uniq.join(",")
		argument_declaration = arguments.split('').join(",")
		consumed_index = arguments.index(consumed_arg)
		consumed_arguments= arguments.dup
		consumed_arguments[consumed_index,1] = ''
		consumed_argument_declaration = consumed_arguments.split('').join(",")
		consumed_argument_params = consumed_arguments.split('').collect {|letter| "#{letter.downcase}: #{letter}"}.join(", ")
		replaced_arguments= arguments.dup
		replaced_arguments[consumed_index,1] = 'X'
		replaced_arguments = replaced_arguments.split('').collect {|letter| letter.downcase}.join(", ")
		replaced_arguments.gsub!("x","arg")
		
		generated_bind_declarations << "/// bind argument to function. Type: #{consumed_index + 1} onto #{arguments.length}"
		generated_bind_declarations << "public func bind<#{generic_argument_declaration},R>(_ function: @escaping (#{argument_declaration})->R, _ arg: #{consumed_arg}) -> (#{consumed_argument_declaration})-> R {"
		generated_bind_declarations << "	return { (#{consumed_argument_params}) in"
		generated_bind_declarations << "		return function(#{replaced_arguments})"
		generated_bind_declarations << "	}"
		generated_bind_declarations << "}"
		generated_bind_declarations << ""
		
		generated_operator_declarations << "/// bind argument to function. Type: #{consumed_index + 1} onto #{arguments.length}"
		generated_operator_declarations << "public func =<< <#{generic_argument_declaration},R>(_ function: @escaping (#{argument_declaration})->R, _ arg: #{consumed_arg}) -> (#{consumed_argument_declaration})-> R {"
		generated_operator_declarations << "	return bind(function,arg)"
		generated_operator_declarations << "}"
		generated_operator_declarations << ""
	}
	

	bind_string = %[
/// Generated bind (partial apply) functions.

#{generated_bind_declarations.join("\n")}
]
	output_to_file_if_different("Bind.swift",bind_string)
	
	
	bind_operator_string = %[
/// Generated bind (partial apply) operator functions.

precedencegroup HoneyBeeBindPrecedence {
	associativity: left
	higherThan: LogicalConjunctionPrecedence
}

infix operator =<< : HoneyBeeBindPrecedence

#{generated_operator_declarations.join("\n")}
]
	output_to_file_if_different("BindOperator.swift",bind_operator_string)
	
end

generate_chainable()
generate_chain_operator()
generate_bind()

