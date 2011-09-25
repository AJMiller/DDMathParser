//
//  _DDNumberExpression.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "_DDNumberExpression.h"


@implementation _DDNumberExpression

- (id) initWithNumber:(NSNumber *)n {
	self = [super init];
	if (self) {
		number = [n retain];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithNumber:[aDecoder decodeObjectForKey:@"number"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self number] forKey:@"number"];
}

- (void) dealloc {
	[number release];
	[super dealloc];
}

- (DDExpressionType) expressionType { return DDExpressionTypeNumber; }

- (DDExpression *)simplifiedExpressionWithEvaluator:(DDMathEvaluator *)evaluator error:(NSError **)error {
#pragma unused(evaluator, error)
	return self;
}

- (NSNumber *) evaluateWithSubstitutions:(NSDictionary *)substitutions evaluator:(DDMathEvaluator *)evaluator error:(NSError **)error {
#pragma unused(substitutions, evaluator, error)
	return [self number];
}

- (NSNumber *) number { return number; }

- (NSExpression *) expressionValueForEvaluator:(DDMathEvaluator *)evaluator {
#pragma unused(evaluator)
	return [NSExpression expressionForConstantValue:[self number]];
}

- (NSString *) description {
	return [[self number] description];
}

@end
