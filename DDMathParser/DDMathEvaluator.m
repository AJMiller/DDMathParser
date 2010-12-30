//
//  DDMathEvaluator.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/17/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathEvaluator.h"
#import "DDMathEvaluator+Private.h"
#import "DDParser.h"
#import "DDExpression.h"
#import "_DDFunctionUtilities.h"

@interface DDMathEvaluator ()

- (NSSet *) _standardFunctions;
- (NSDictionary *) _standardAliases;
- (void) _registerStandardFunctions;

@end


@implementation DDMathEvaluator

static DDMathEvaluator * _sharedEvaluator = nil;

+ (id) sharedMathEvaluator {
	if (_sharedEvaluator == nil) {
		_sharedEvaluator = [[DDMathEvaluator alloc] init];
	}
	return _sharedEvaluator;
}

- (id) init {
	self = [super init];
	if (self) {
		functions = [[NSMutableDictionary alloc] init];
		[self _registerStandardFunctions];
	}
	return self;
}

- (void) dealloc {
	if (self == _sharedEvaluator) {
		_sharedEvaluator = nil;
	}
	[functions release];
	[super dealloc];
}

- (BOOL) registerFunction:(DDMathFunction)function forName:(NSString *)functionName {
	if ([self functionWithName:functionName] != nil) { return NO; }
	if ([[self _standardFunctions] containsObject:[functionName lowercaseString]]) { return NO; }
	
	function = Block_copy(function);
	[functions setObject:function forKey:[functionName lowercaseString]];
	Block_release(function);
	
	return YES;
}

- (void) unregisterFunctionWithName:(NSString *)functionName {
	//can't unregister built-in functions
	if ([[self _standardFunctions] containsObject:[functionName lowercaseString]]) { return; }
	
	[functions removeObjectForKey:[functionName lowercaseString]];
}

- (DDMathFunction) functionWithName:(NSString *)functionName {
	return [functions objectForKey:[functionName lowercaseString]];
}

- (NSArray *) registeredFunctions {
	return [functions allKeys];
}

- (NSString *) nsexpressionFunctionWithName:(NSString *)functionName {
	return nil;
//	NSDictionary * map = [DDMathFunctionContainer nsexpressionFunctions];
//	NSString * function = [map objectForKey:[functionName lowercaseString]];
//	return function;
}

- (void) functionExpressionFailedToResolve:(_DDFunctionExpression *)functionExpression {
	[NSException raise:NSInvalidArgumentException format:@"unknown function: %@", [functionExpression function]];
}

- (BOOL) addAlias:(NSString *)alias forFunctionName:(NSString *)functionName {
	//we can't add an alias for a function that already exists
	DDMathFunction function = [self functionWithName:alias];
	if (function != nil) { return NO; }
	
	function = [self functionWithName:functionName];
	return [self registerFunction:function forName:alias];
}

- (void) removeAlias:(NSString *)alias {
	//you can't unregister a standard alias (like "avg")
	if ([[self _standardAliases] objectForKey:[alias lowercaseString]] != nil) { return; }
	[self unregisterFunctionWithName:alias];
}

#pragma mark Evaluation

- (NSNumber *) evaluateString:(NSString *)expressionString withSubstitutions:(NSDictionary *)variables {
	NSNumber * returnValue = nil;
	@try {
		DDParser * parser = [DDParser parserWithString:expressionString];
		DDExpression * parsedExpression = [parser parsedExpression];
		returnValue = [parsedExpression evaluateWithSubstitutions:variables evaluator:self];
	}
	@catch (NSException * e) {
		NSLog(@"caught exception: %@", e);
		returnValue = nil;
	}
	@finally {
		return returnValue;
	}
}

- (NSNumber *) evaluateFunction:(DDExpression *)expression withSubstitutions:(NSDictionary *)variables {
	DDMathFunction function = [self functionWithName:[expression function]];
	if (function == nil) {
		[NSException raise:NSInvalidArgumentException format:@"unrecognized function: %@", [expression function]];
		return nil;
	}
	
	DDExpression * evaluatedValue = function([expression arguments], variables, self);
	if (evaluatedValue != nil && [evaluatedValue expressionType] == DDExpressionTypeNumber) {
		return [evaluatedValue number];
	}
	
	[NSException raise:NSInvalidArgumentException format:@"invalid function response: %@", evaluatedValue];
	return nil;
}

- (id) performFunction:(NSArray *)parameters {
	NSMutableArray * mutableParameters = [parameters mutableCopy];
	NSString * functionName = [[mutableParameters objectAtIndex:0] constantValue];
	[mutableParameters removeObjectAtIndex:0];
	NSLog(@"stuff to %@: %@", functionName, mutableParameters);
	[mutableParameters release];
	return [NSNumber numberWithInt:0];
}

#pragma mark Built-In Functions

- (NSSet *) _standardFunctions {
	return [NSSet setWithObjects:
			//arithmetic functions (2 parameters)
			@"add",
			@"subtract",
			@"multiply",
			@"divide",
			@"mod",
			@"factorial",
			@"pow",
			
			//bitwise functions (2 parameters)
			@"and",
			@"or",
			@"xor",
			@"rshift",
			@"lshift",
			
			//functions that take > 0 parameters
			@"average",
			@"sum",
			@"count",
			@"min",
			@"max",
			@"median",
			@"stddev",
			
			//functions that take 1 parameter
			@"negate",
			@"not",
			@"sqrt",
			@"log",
			@"ln",
			@"exp",
			@"ceil",
			@"trunc",
			@"floor",
			@"abs",
			
			//trig functions
			@"sin",
			@"cos",
			@"tan",
			@"asin",
			@"acos",
			@"atan",
			@"dtor",
			@"rtod",
			@"sinh",
			@"cosh",
			@"tanh",
			@"asinh",
			@"acosh",
			@"atanh",
			
			//trig inverse functions
			@"csc",
			@"sec",
			@"cotan",
			@"acsc",
			@"asec",
			@"acotan",
			@"csch",
			@"sech",
			@"cotanh",
			@"acsch",
			@"asech",
			@"acotanh",
			
			//functions that take 0 parameters
			@"pi",
			@"pi_2",
			@"pi_4",
			@"sqrt2",
			@"e",
			@"log2e",
			@"log10e",
			@"ln2",
			@"ln10",
			nil];
	
}

- (NSDictionary *) _standardAliases {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			@"average", @"avg",
			@"average", @"mean",
			@"floor", @"trunc",
			nil];
}

- (void) _registerStandardFunctions {
	for (NSString * functionName in [self _standardFunctions]) {
		
		NSString * methodName = [NSString stringWithFormat:@"%@Function", [functionName lowercaseString]];
		SEL methodSelector = NSSelectorFromString(methodName);
		if ([_DDFunctionUtilities respondsToSelector:methodSelector]) {
			DDMathFunction function = [_DDFunctionUtilities performSelector:methodSelector];
			if (function != nil) {
				[functions setObject:function forKey:[functionName lowercaseString]];
			} else {
				NSLog(@"error registering function: %@", functionName);
			}
		}
	}
	
	NSDictionary * aliases = [self _standardAliases];
	for (NSString * alias in aliases) {
		NSString * function = [aliases objectForKey:alias];
		(void)[self addAlias:alias forFunctionName:function];
	}
}

@end
