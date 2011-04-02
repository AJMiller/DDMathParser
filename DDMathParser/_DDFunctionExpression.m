//
//  _DDFunctionExpression.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "_DDFunctionExpression.h"
#import "DDMathEvaluator.h"
#import "DDMathEvaluator+Private.h"
#import "_DDNumberExpression.h"
#import "_DDVariableExpression.h"
#import "DDMathParserMacros.h"

@implementation _DDFunctionExpression

- (id) initWithFunction:(NSString *)f arguments:(NSArray *)a error:(NSError **)error {
	self = [super init];
	if (self) {
		for (id arg in a) {
			if ([arg isKindOfClass:[DDExpression class]] == NO) {
				if (error != nil) {
					*error = ERR_EVAL(@"function arguments must be DDExpression objects");
					*error = nil;
				}
				[self release];
				return nil;
			}
		}
		
		function = [f copy];
		arguments = [a copy];
	}
	return self;
}
- (void) dealloc {
	[function release];
	[arguments release];
	[super dealloc];
}
- (DDExpressionType) expressionType { return DDExpressionTypeFunction; }

- (NSString *) function { return [function lowercaseString]; }
- (NSArray *) arguments { return arguments; }

- (DDExpression *) simplifiedExpressionWithEvaluator:(DDMathEvaluator *)evaluator error:(NSError **)error {
	BOOL canSimplify = YES;
	for (DDExpression * e in [self arguments]) {
		DDExpression * a = [e simplifiedExpressionWithEvaluator:evaluator error:error];
		if (error && *error) { return nil; }
		if ([a expressionType] != DDExpressionTypeNumber) {
			canSimplify = NO;
		}
	}
	
	if (canSimplify) {
		if (evaluator == nil) { evaluator = [DDMathEvaluator sharedMathEvaluator]; }
		
		DDMathFunction mathFunction = [evaluator functionWithName:[self function]];
		id result = mathFunction([self arguments], nil, evaluator, error);
		
		if ([result isKindOfClass:[_DDNumberExpression class]]) {
			return result;
		} else if ([result isKindOfClass:[NSNumber class]]) {
			return [DDExpression numberExpressionWithNumber:result];
		}		
	}
	
	return self;
}

- (NSNumber *) evaluateWithSubstitutions:(NSDictionary *)substitutions evaluator:(DDMathEvaluator *)evaluator error:(NSError **)error {
	if (evaluator == nil) { evaluator = [DDMathEvaluator sharedMathEvaluator]; }
	
	DDMathFunction mathFunction = [evaluator functionWithName:[self function]];
	
	if (mathFunction != nil) {
		
		id result = mathFunction([self arguments], substitutions, evaluator, error);
		if (error && *error) { return nil; }
		
		while ([result isKindOfClass:[_DDVariableExpression class]]) {
			result = [result evaluateWithSubstitutions:substitutions evaluator:evaluator error:error];
			if (error && *error) { return nil; }
		}
		
		NSNumber * numberValue = nil;
		if ([result isKindOfClass:[_DDNumberExpression class]]) {
			numberValue = [result number];
		} else if ([result isKindOfClass:[NSNumber class]]) {
			numberValue = result;
		} else {
			if (error != nil) {
				*error = ERR_BADARG(@"invalid return type from %@ function", [self function]);
			}
			return nil;
		}
		return numberValue;
	} else {
		[evaluator functionExpressionFailedToResolve:self error:error];
		return nil;
	}
	
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@(%@)", [self function], [[[self arguments] valueForKey:@"description"] componentsJoinedByString:@","]];
}

@end
