#!/usr/bin/env ruby

require 'set'

def signature_declares_error(signature)
	signature =~ /throws|Error/
end


chain_function_signatures_text = %[
(B) -> C
(B) -> Void

(B) -> () -> C
(B) -> () -> Void
(B) -> (() -> Void) -> Void
(B) -> ((C) -> Void) -> Void
(B) -> ((Error?) -> Void) -> Void
(B) -> ((C?, Error?) -> Void) -> Void

(B, () -> Void) -> Void
(B, (C) -> Void) -> Void
(B, (Error?) -> Void) -> Void
(B, (C?, Error?) -> Void) -> Void

(() -> Void) -> Void
((C) -> Void) -> Void
((Error?) -> Void) -> Void
((C?, Error?) -> Void) -> Void

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
		ret = [signature.dup.insert(insertion_index," throws"), signature]
	end
	ret
}.flatten

@chain_function_signatures.sort! {|a,b| a.size <=> b.size}

def generate_chainable()
	safe_chain_declarations = []
	erroring_chain_declarations = []
	

	@chain_function_signatures.each {|function_signature|
		include_error_handler = signature_declares_error(function_signature)
		transform_result_type = function_signature =~ /C/ ? "C" : "B"
		extra_generic_parameter = transform_result_type != "B" ? "<C>" : ""
		documentation = transform_result_type != "B" ? 
			"///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link" :
			"///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link"
		
		declarations = include_error_handler ? erroring_chain_declarations : safe_chain_declarations
		declarations << documentation
		declarations << "@discardableResult\nfunc chain#{extra_generic_parameter}(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping #{function_signature} ) -> #{include_error_handler ? "":"Safe"}Link<#{transform_result_type}, P>"
		declarations << ""
	}


	chainable_protocol_string = %[
/// Generated protocol declaring safe chain functions.
protocol SafeChainable {
	associatedtype B
	associatedtype P: AsyncBlockPerformer

#{safe_chain_declarations.join("\n")}
}

/// Generated protocol declaring erroring chain functions.
protocol ErroringChainable  {
	associatedtype B
	associatedtype P: AsyncBlockPerformer

#{erroring_chain_declarations.join("\n")}
}

]
	output_to_file_if_different("Chainable.swift",chainable_protocol_string)
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
	AAC
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
		separated_arguments = arguments.split('')
		generic_argument_declaration = separated_arguments.uniq.join(",")
		argument_declaration = separated_arguments.join(",")
		consumed_index = arguments.index(consumed_arg)
		consumed_arguments= arguments.dup
		consumed_arguments[consumed_index,1] = ''
		consumed_argument_declaration = consumed_arguments.split('').join(",")
		argCounter = {}
		consumed_argument_params = consumed_arguments.split('').collect {|letter|
			argCounter[letter] ||= 0
			count = argCounter[letter] += 1
			if count == 1
				"#{letter.downcase}: #{letter}"
			else
				"#{letter.downcase}#{count}: #{letter}"
			end
		}.join(", ")
		replaced_arguments= arguments.dup
		replaced_arguments[consumed_index,1] = 'X'
		argCounter = {}
		replaced_arguments = replaced_arguments.split('').collect {|letter|
			argCounter[letter] ||= 0
			count = argCounter[letter] += 1
			if count == 1
				"#{letter.downcase}"
				else
				"#{letter.downcase}#{count}"
			end
		}.join(", ")
		replaced_arguments.gsub!("x","arg")
		
		["throws ", ""].each {|throw_or_no|		
			generated_bind_declarations << "/// bind argument to function. Type: #{consumed_index + 1} onto #{arguments.length}"
			generated_bind_declarations << "public func bind<#{generic_argument_declaration},R>(_ function: @escaping (#{argument_declaration}) #{throw_or_no}-> R, _ arg: #{consumed_arg}) -> (#{consumed_argument_declaration}) #{throw_or_no}-> R {"
			generated_bind_declarations << "	return { (#{consumed_argument_params}) in"
			generated_bind_declarations << "		return #{throw_or_no.size > 0 ? "try" : ""} function(#{replaced_arguments})"
			generated_bind_declarations << "	}"
			generated_bind_declarations << "}"
			generated_bind_declarations << ""
		
		
			generated_operator_declarations << "/// bind argument to function. Type: #{consumed_index + 1} onto #{arguments.length}"
			generated_operator_declarations << "public func =<< <#{generic_argument_declaration},R>(_ function: @escaping (#{argument_declaration}) #{throw_or_no}-> R, _ arg: #{consumed_arg}) -> (#{consumed_argument_declaration}) #{throw_or_no}-> R {"
			generated_operator_declarations << "	return bind(function,arg)"
			generated_operator_declarations << "}"
			generated_operator_declarations << ""
		}
		
		# now the instance curry forms
		
		first_argument = arguments[0]
		if first_argument != consumed_arg
			after_first_arguments = arguments[1,separated_arguments.count]
			consumed_after_first_arguments = after_first_arguments.dup
			if consumed_index = after_first_arguments.index(consumed_arg) 
				consumed_after_first_arguments[consumed_index,1] = ''
			end
			instance_signature = "(#{separated_arguments.first})->(#{after_first_arguments.split('').join(",")})"
			consumed_after_first_argument_declaration = "(#{([first_argument]+consumed_after_first_arguments.split('')).join(",")})"
			replaced_arguments_after_first= after_first_arguments.dup
			replaced_arguments_after_first[consumed_index,1] = 'X'
			replaced_arguments_after_first = replaced_arguments_after_first.split('').collect {|letter| letter.downcase}.join(", ")
			replaced_arguments_after_first.gsub!("x","arg")
		
			["throws ", ""].each {|throw_or_no|
				generated_bind_declarations << "/// bind argument to function. Type: instance curried #{consumed_index + 1} onto #{arguments.length}"
				generated_bind_declarations << "public func bind<#{generic_argument_declaration},R>(_ function: @escaping #{instance_signature} #{throw_or_no}-> R, _ arg: #{consumed_arg}) -> #{consumed_after_first_argument_declaration} #{throw_or_no}-> R {"
				generated_bind_declarations << "	return { (#{consumed_argument_params}) in"
				generated_bind_declarations << "		return #{throw_or_no.size > 0 ? "try" : ""} function(#{first_argument.downcase})(#{replaced_arguments_after_first})"
				generated_bind_declarations << "	}"
				generated_bind_declarations << "}"
				generated_bind_declarations << ""
		
		
				generated_operator_declarations << "/// bind argument to function. Type: instance curried #{consumed_index + 1} onto #{arguments.length}"
				generated_operator_declarations << "public func =<< <#{generic_argument_declaration},R>(_ function: @escaping #{instance_signature} #{throw_or_no}-> R, _ arg: #{consumed_arg}) -> #{consumed_after_first_argument_declaration} #{throw_or_no}-> R {"
				generated_operator_declarations << "	return bind(function,arg)"
				generated_operator_declarations << "}"
				generated_operator_declarations << ""
			}
		end
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


await_function_signatures_text = %[
() -> Void
(A) -> Void
(A, B) -> Void
(A, B, C) -> Void

() -> R
(A) -> R
(A, B) -> R
(A, B, C) -> R

(A) -> () -> Void
(A) -> (B) -> Void
(A) -> (B,C) -> Void

(A) -> () -> R
(A) -> (B) -> R
(A) -> (B, C) -> R

(A) -> (() -> Void) -> Void
(A) -> (B, () -> Void) -> Void
(A) -> (B, C, () -> Void) -> Void

(A) -> ((R) -> Void) -> Void
(A) -> (B, (R) -> Void) -> Void
(A) -> (B, C, (R) -> Void) -> Void

(A) -> ((Error?) -> Void) -> Void
(A) -> (B, (Error?) -> Void) -> Void
(A) -> (B, C, (Error?) -> Void) -> Void

(A) -> ((R?, Error?) -> Void) -> Void
(A) -> (B, (R?, Error?) -> Void) -> Void
(A) -> (B, C, (R?, Error?) -> Void) -> Void

(() -> Void) -> Void
(A, () -> Void) -> Void
(A, B, () -> Void) -> Void
(A, B, C, () -> Void) -> Void

((R) -> Void) -> Void
(A, (R) -> Void) -> Void
(A, B, (R) -> Void) -> Void
(A, B, C, (R) -> Void) -> Void

((Error?) -> Void) -> Void
(A, (Error?) -> Void) -> Void
(A, B, (Error?) -> Void) -> Void
(A, B, C, (Error?) -> Void) -> Void

((R?, Error?) -> Void) -> Void
(A, (R?, Error?) -> Void) -> Void
(A, B, (R?, Error?) -> Void) -> Void
(A, B, C, (R?, Error?) -> Void) -> Void

]

@await_function_signatures = await_function_signatures_text.
split("\n").
delete_if { |n| n.size == 0 }.
collect { |n| n.strip }


@await_function_signatures = @await_function_signatures.map { |signature|
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

@await_function_signatures = @await_function_signatures.map { |signature|
	ret = signature
	unless signature_declares_error(signature)
		insertion_index = signature.rindex(" ->")
		ret = [signature.dup.insert(insertion_index," throws"), signature]
	end
	ret
}.flatten

require 'pp'
pp @await_function_signatures

def generate_await()
	safe_await_declarations = []
	erroring_await_declarations = []
	
	@await_function_signatures.each {|function_signature|
		include_error_handler = signature_declares_error(function_signature)
		transform_result_type = function_signature =~ /R/ ? "R" : "Void"
		generic_parameters = []
		%w(A B C R).each { |genricType|
			generic_parameters << genricType if function_signature =~/#{genricType}/
		}
		extra_generic_parameter = generic_parameters.empty? ? "" : "<#{generic_parameters.join(", ")}>"
		documentation = transform_result_type != "B" ?
		"///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link" :
		"///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link"
		discardableOrNot = transform_result_type == "R" ? "" : "@discardableResult\n"
		
		returnType = "ReplaceMe"
		returnTypeParameters = generic_parameters
		returnTypeParameters << "Void" if transform_result_type == "Void"
		returnTypeParameterization = "<#{returnTypeParameters.join(", ")}, P>"
		case returnTypeParameters.count
		when 1
			returnType = "#{include_error_handler ? "":"Safe"}Link#{returnTypeParameterization}"
		when 2
			returnType = "AsyncSingleArgFunction#{returnTypeParameterization}"
		when 3
			returnType = "AsyncDoubleArgFunction#{returnTypeParameterization}"
		when 4
			returnType = "AsyncTripleArgFunction#{returnTypeParameterization}"
		end
		
		declarations = include_error_handler ? erroring_await_declarations : safe_await_declarations
		declarations << documentation
		declarations << "#{discardableOrNot}func await#{extra_generic_parameter}(_ function: @escaping #{function_signature}, file: StaticString, line: UInt) -> #{returnType}"
		declarations << ""
	}
	
	
	chainable_protocol_string = %[
/// Generated protocol declaring safe chain functions.
protocol SafeAwaitable {
	associatedtype P: AsyncBlockPerformer

	#{safe_await_declarations.join("\n")}
}
	
/// Generated protocol declaring erroring chain functions.
protocol ErroringAwaitable  {
	associatedtype P: AsyncBlockPerformer

	#{erroring_await_declarations.join("\n")}
}
]
	output_to_file_if_different("Awaitable.swift",chainable_protocol_string)
end

generate_chainable()
generate_bind()
generate_await()

