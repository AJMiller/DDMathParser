//
//  _DDFunctionExpression.m
//  DDMathParser
//
//  Created by Dave DeLong on 11/18/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DDMathParser.h"
#import "_DDFunctionExpression.h"
#import "DDMathEvaluator.h"
#import "DDMathEvaluator+Private.h"
#import "_DDNumberExpression.h"
#import "_DDVariableExpression.h"
#import "DDMathParserMacros.h"

@interface DDExpression ()

- (void)_setParentExpression:(DDExpression *)parent;

@end

@implementation _DDFunctionExpression

- (id)initWithFunction:(NSString *)f arguments:(NSArray *)a error:(NSError **)error {
	self = [super init];
	if (self) {
		for (id arg in a) {
			if ([arg isKindOfClass:[DDExpression class]] == NO) {
				if (error != nil) {
                    *error = ERR(DDErrorCodeInvalidArgument, @"function arguments must be DDExpression objects");
				}
                DD_RELEASE(self);
				return nil;
			}
		}
		
		function = [f copy];
		arguments = [a copy];
        for (DDExpression *argument in arguments) {
            [argument _setParentExpression:self];
        }
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSString *f = [aDecoder decodeObjectForKey:@"function"];
    NSArray *a = [aDecoder decodeObjectForKey:@"arguments"];
    return [self initWithFunction:f arguments:a error:NULL];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[self function] forKey:@"function"];
    [aCoder encodeObject:[self arguments] forKey:@"arguments"];
}

#if !DD_HAS_ARC
- (void)dealloc {
	[function release];
	[arguments release];
	[super dealloc];
}
#endif

- (DDExpressionType)expressionType { return DDExpressionTypeFunction; }

- (NSString *)function { return [function lowercaseString]; }
- (NSArray *)arguments { return arguments; }

- (DDExpression *)simplifiedExpressionWithEvaluator:(DDMathEvaluator *)evaluator error:(NSError **)error {
	BOOL canSimplify = YES;
    
    NSMutableArray *newSubexpressions = [NSMutableArray array];
	for (DDExpression * e in [self arguments]) {
		DDExpression * a = [e simplifiedExpressionWithEvaluator:evaluator error:error];
		if (!a) { return nil; }
        canSimplify &= [a expressionType] == DDExpressionTypeNumber;
        [newSubexpressions addObject:a];
	}
	
	if (canSimplify) {
		if (evaluator == nil) { evaluator = [DDMathEvaluator sharedMathEvaluator]; }
		
        id result = [evaluator evaluateExpression:self withSubstitutions:nil error:error];
		
		if ([result isKindOfClass:[_DDNumberExpression class]]) {
			return result;
		} else if ([result isKindOfClass:[NSNumber class]]) {
			return [DDExpression numberExpressionWithNumber:result];
		}		
	}
	
	return [_DDFunctionExpression functionExpressionWithFunction:[self function] arguments:newSubexpressions error:error];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@(%@)", [self function], [[[self arguments] valueForKey:@"description"] componentsJoinedByString:@","]];
}

@end
