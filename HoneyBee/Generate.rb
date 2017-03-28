#!/usr/bin/env ruby

chain_function_signatures_text = %[
() -> Void
(@escaping (Error?) -> Void) -> Void

(((C) -> Void)?) -> Void

(B) -> (C)
(B) throws -> (C)
(B) -> (() -> C)
(B, ((C) -> Void)?) -> Void
(B) -> (((C) -> Void)?) -> Void
(B, ((C) -> Void)?) throws -> Void
(B, @escaping (C) -> Void) -> Void
(B, ((C?, Error?) -> Void)?) -> Void
(B) -> (@escaping (C) -> Void) -> Void
(B, @escaping (C) -> Void) throws -> Void
(B, @escaping (C?, Error?) -> Void) -> Void

(B) -> (() -> Void)
(B, ((Error?) -> Void)?) -> Void
(B) -> (((Error?) -> Void)?) -> Void
(B, @escaping (Error?) -> Void) -> Void
(B) -> (@escaping (Error?) -> Void) -> Void

]

@chain_function_signatures = chain_function_signatures_text.
							split("\n").
							delete_if { |n| n.size == 0 }.
							collect { |n| n.strip }

def signature_declares_error(signature)
	signature =~ /throws|Error/
end

def generate_chainable()
	generated_chain_declarations = []

	@chain_function_signatures.each {|function_signature|
		include_error_handler = signature_declares_error(function_signature)
		error_handler_string = include_error_handler ? ", _ errorHandler: @escaping (Error) -> Void" : ""
		transform_result_type = function_signature =~ /C/ ? "C" : "B"
		extra_generic_parameter = transform_result_type != "B" ? "<C>" : ""
		documentation = transform_result_type != "B" ? 
			"///Creates a new ProcessLink which transforms argument of type B to type C and appends the link to the execution list of this ProcessLink" :
			"///Creates a new ProcessLink which passes through argument of type B and appends the link to the execution list of this ProcessLink"
		
		generated_chain_declarations << documentation
		generated_chain_declarations << "@discardableResult func chain#{extra_generic_parameter}(_ function:  @escaping #{function_signature}#{error_handler_string} ) -> ProcessLink<B,#{transform_result_type}>"
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
		right_hand_side = include_error_handler ? "FunctionWithErrorHandler<#{function_signature}>" : "@escaping #{function_signature}"
		implementation = include_error_handler ? "return left.chain(right.function, right.errorHandler)" : "return left.chain(right)"
		transform_result_type = function_signature =~ /C/ ? "C" : "B"
		generic_parameters = transform_result_type != "B" ? "<A,B,C>" : "<A,B>"
		
		
		generated_chain_declarations << "///operator syntax for ProcessLink.chain"
		generated_chain_declarations << "@discardableResult public func ^^#{generic_parameters}(left: ProcessLink<A,B>, right: #{right_hand_side}) -> ProcessLink<B, #{transform_result_type}> {"
		generated_chain_declarations << "\t#{implementation}"
		generated_chain_declarations << "}"
		generated_chain_declarations << ""
	}
	
	chain_operator_string = %[
/// Generated chain operator functions.

precedencegroup HoneyBeeErrorHandlingPrecedence {
	associativity: left
	higherThan: LogicalConjunctionPrecedence
}

infix operator ^! : HoneyBeeErrorHandlingPrecedence

public func ^!<F>(left: F, right: @escaping (Error) -> Void) -> FunctionWithErrorHandler<F> {
	return FunctionWithErrorHandler(function: left, errorHandler: right)
}


infix operator ^^ : LogicalConjunctionPrecedence

public struct FunctionWithErrorHandler<F> {
	let function: F
	let errorHandler: (Error) -> Void
}

#{generated_chain_declarations.join("\n")}
]

puts chain_operator_string

output_to_file_if_different("ChainOperator.swift",chain_operator_string)
end

def output_to_file_if_different(filename, contnet)
	output_file = File.join(File.dirname(__FILE__),filename)

	existing_contents = File.exists?(output_file) ? File.readlines(output_file).join() : ""

	if (existing_contents != contnet)
		File.open(output_file,"w") {|f| f.print contnet }
	end
end


generate_chainable()
generate_chain_operator()

