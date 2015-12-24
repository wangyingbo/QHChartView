//
//  CyclePieView.h
//  yimashuo
//
//  Created by imqiuhang on 15/8/18.
//  Copyright (c) 2015年 imqiuhang. All rights reserved.
//

#import "QHLineView.h"

@implementation QHLineView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

    CGContextRef currentContext = UIGraphicsGetCurrentContext();
 
    CGContextSetFillColorWithColor(currentContext, [self.topSpaceColor CGColor]);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, round(self.startPoint.x), self.startPoint.y);
    CGContextAddLineToPoint(currentContext, round(self.endPoint.x), self.endPoint.y);
    CGContextAddLineToPoint(currentContext, round(self.endPoint.x), self.frame.origin.y);
    CGContextAddLineToPoint(currentContext, round(self.startPoint.x), self.frame.origin.x);
    CGContextClosePath(currentContext);
    CGContextDrawPath(currentContext, kCGPathFill);
    
    
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    [path1 setLineWidth:self.lineWidth];
    [path1 moveToPoint:self.startPoint];
    CGPoint endPostion = self.isEndPosition?CGPointMake(self.endPoint.x-2, self.endPoint.y):self.endPoint;
    [path1 addLineToPoint:endPostion];
    path1.lineCapStyle = kCGLineCapRound;
    [self.lineColor set];
    [path1 strokeWithBlendMode:kCGBlendModeNormal alpha:1];
    
   
}




@end