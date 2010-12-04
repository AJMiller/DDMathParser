//
//  DDExpression.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/16/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDExpression.h"
#import "DDMathEvaluator.h"
#import "DDMathEvaluator+Private.h"
#import "DDParser.h"
#import "DDParser.h"

#import "_DDNumberExpression.h"
#import "_DDFunctionExpression.h"
#import "_DDVariableExpression.h"


@implementation DDExpression

+ (id) expressionFromString:(NSString *)expressionString {
	return [[DDParser parserWithString:expressionString] parsedExpression];
}

+ (id) numberExpressionWithNumber:(NSNumber *)number {
	return [[[_DDNumberExpression alloc] initWithNumber:number] autorelease];
}

+ (id) functionExpressionWithFunction:(NSString *)function arguments:(NSArray *)arguments {
	return [[[_DDFunctionExpression alloc] initWithFunction:function arguments:arguments] autorelease];
}

+ (id) variableExpressionWithVariable:(NSString *)variable {
	return [[[_DDVariableExpression alloc] initWithVariable:variable] autorelease];
}

#pragma mark -
#pragma mark Abstract method implementations

- (DDExpressionType) expressionType {
	[NSException raise:NSInvalidArgumentException format:@"this method should be overridden: %@", NSStringFromSelector(_cmd)];
	return 0;
}
- (NSNumber *) evaluateWithSubstitutions:(NSDictionary *)substitutions evaluator:(DDMathEvaluator *)evaluator { 
	[NSException raise:NSInvalidArgumentException format:@"this method should be overridden: %@", NSStringFromSelector(_cmd)]; 
	return nil; 
}
- (DDExpression *) simplifiedExpression {
	return [self simplifiedExpressionWithEvaluator:[DDMathEvaluator sharedMathEvaluator]];
}
- (DDExpression *) simplifiedExpressionWithEvaluator:(DDMathEvaluator *)evaluator {
	[NSException raise:NSInvalidArgumentException format:@"this method should be overridden: %@", NSStringFromSelector(_cmd)]; 
	return nil; 
}
- (NSExpression *) expressionValue { 
	return [self expressionValueForEvaluator:[DDMathEvaluator sharedMathEvaluator]];
}
- (NSExpression *) expressionValueForEvaluator:(DDMathEvaluator *)evaluator {
	[NSException raise:NSInvalidArgumentException format:@"this method should be overridden: %@", NSStringFromSelector(_cmd)]; 
	return nil; 
}
- (NSNumber *) number { 
	[NSException raise:NSInvalidArgumentException format:@"This is not a numeric expression"]; 
	return nil; 
}
- (NSString *) function { 
	[NSException raise:NSInvalidArgumentException format:@"This is not a function expression"]; 
	return nil; 
}
- (NSArray *) arguments { 
	[NSException raise:NSInvalidArgumentException format:@"This is not a function expression"]; 
	return nil; 
}
- (NSString *) variable { 
	[NSException raise:NSInvalidArgumentException format:@"This is not a variable expression"]; 
	return nil; 
}
- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[DDExpression class]] == NO) { return NO; }
	DDExpression * expression = (DDExpression *)object;
	if ([expression expressionType] != [self expressionType]) { return NO; }
	if ([self expressionType] == DDExpressionTypeNumber) {
		return [[self number] isEqualToNumber:[expression number]];
	}
	if ([self expressionType] == DDExpressionTypeVariable) {
		return [[self variable] isEqual:[expression variable]];
	}
	if ([self expressionType] == DDExpressionTypeFunction) {
		return ([[self function] isEqual:[expression function]] &&
				[[self arguments] isEqual:[expression arguments]]);
	}
	return NO;
}

@end
