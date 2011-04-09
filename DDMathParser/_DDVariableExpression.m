//
//  _DDVariableExpression.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "_DDVariableExpression.h"
#import "DDMathEvaluator.h"
#import "DDMathEvaluator+Private.h"
#import "DDMathParserMacros.h"

@implementation _DDVariableExpression

- (id) initWithVariable:(NSString *)v {
	self = [super init];
	if (self) {
		variable = [v copy];
	}
	return self;
}

- (void) dealloc {
	[variable release];
	[super dealloc];
}

- (DDExpressionType) expressionType { return DDExpressionTypeVariable; }

- (NSString *) variable { return variable; }

- (DDExpression *) simplifiedExpressionWithEvaluator:(DDMathEvaluator *)evaluator {
	return self;
}

- (NSNumber *) evaluateWithSubstitutions:(NSDictionary *)substitutions evaluator:(DDMathEvaluator *)evaluator error:(NSError **)error {
	if (evaluator == nil) { evaluator = [DDMathEvaluator sharedMathEvaluator]; }
	
	id variableValue = [substitutions objectForKey:[self variable]];
	if ([variableValue isKindOfClass:[DDExpression class]]) {
		return [variableValue evaluateWithSubstitutions:substitutions evaluator:evaluator error:error];
	}
	if ([variableValue isKindOfClass:[NSNumber class]]) {
		return variableValue;
	}
	if (error != nil) {
		*error = ERR_GENERIC(@"unable to evaluate expression: %@", self);
	}
	return nil;
}

- (NSExpression *) expressionValueForEvaluator:(DDMathEvaluator *)evaluator {
	return [NSExpression expressionForVariable:[self variable]];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"$%@", [self variable]];
}

@end
