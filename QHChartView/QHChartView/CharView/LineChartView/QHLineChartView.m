//
//  CyclePieView.h
//  yimashuo
//
//  Created by imqiuhang on 15/8/18.
//  Copyright (c) 2015年 imqiuhang. All rights reserved.
//

#define animationLineSpeed 10.f

#define minIntroductionLablesTag 789098

#define bottomHeight 80

#define lineTopGap 80.f

#define ruleXGap 10.f

#import "QHLineChartView.h"

@implementation QHLineChartView
{
    UIView *lineContenView;
    UIImageView *bottonRuleImageView;
    
    NSMutableArray *dotPositions;
    
    NSMutableArray *dotViews;
}

- (void)setChartInfos:(NSArray *)chartInfos {
    _chartInfos = chartInfos;
    for(CyclePieInfo *info in _chartInfos) {
        info.number = info.number>=1?info.number:1;
    }
    [self reloadView];
}

- (void)initBaseData {
    self.shouldAnimationWhenReload = YES;
    self.underLineSpaceColor = [UIColor blackColor];
    self.topLineSpaceColor = [UIColor blackColor];
    curChoosedTag = -1;
    
    lineContenView = [[UIView alloc] initWithFrame:self.bounds];
    lineContenView.height = self.height - bottomHeight;
    lineContenView.width = self.width  - 80;
    lineContenView.centerX = self.width/2.f;
    [self addSubview:lineContenView];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        [self initBaseData];
    }
    return self;
}

- (void)reloadView {
    if (!self.chartInfos||self.chartInfos.count<=0) {
        return;
    }
    
    
    
    [self reloadLinesAndDots];
    [self reloadIntroductionLables];
    
    if (!panGestureRecognizerView) {
        panGestureRecognizerView = [[UIView alloc] initWithFrame:self.bounds];
        panGestureRecognizerView.bottom = self.height - bottomHeight +25;
        panGestureRecognizerView.backgroundColor = [UIColor clearColor];
        [self addSubview:panGestureRecognizerView];
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [panGestureRecognizerView addGestureRecognizer:panGestureRecognizer];
        
        UILongPressGestureRecognizer *longG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        longG.minimumPressDuration = 0.f;
        [panGestureRecognizerView addGestureRecognizer:longG];
    }

  
}

- (void)handlePan:(UIGestureRecognizer *)recognizer {
    if (!touchFlowLineView) {
        touchFlowLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, lineContenView.height)];
        touchFlowLineView.backgroundColor = [UIColor whiteColor];
        touchFlowLineView.alpha = 0;
        [lineContenView addSubview:touchFlowLineView];
    }
    
    if (!touchNumLable) {
        touchNumLable = [[UILabel alloc] init];
        [touchNumLable setText:nil andFont:defaultFont(24) andTextColor:[UIColor whiteColor]];
        touchNumLable.textAlignment  =NSTextAlignmentCenter;
        
        [lineContenView addSubview:touchNumLable];
    }
    touchNumLable.alpha  = 1.f;
    
    CGPoint translation = [recognizer locationInView:lineContenView];
    
    touchFlowLineView.left = translation.x;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        touchFlowLineView.alpha = 0.6;
    } completion:nil];
    
    int touchDotIndex = [self closestDotFromVerticalLine:touchFlowLineView];
    touchedDot = dotViews[touchDotIndex];
    [lineContenView bringSubviewToFront:touchedDot];
    
    float touchedVy = [self getDotYWithVLinePositionX:touchFlowLineView.left];
    
    touchFlowLineView.top = touchedVy;
    touchFlowLineView.height = lineContenView.height - touchedVy;
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        touchNumLable.centerX = touchedDot.left - 50;
        touchNumLable.bottom = touchedDot.top +50;
    }
    
    CyclePieInfo *info = self.chartInfos [touchedDot.tag];
    touchNumLable.text = [NSString stringWithFormat:@"%i人",info.number];
    [touchNumLable sizeToFit];
    if ((int)touchedDot.tag!=curChoosedTag) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            touchNumLable.top = touchedDot.top -30;
            if (touchedDot.tag==0) {
                touchNumLable.left =touchedDot.left+10;
            }else if (touchedDot.tag==self.chartInfos.count-1) {
                touchNumLable.right =touchedDot.left-10;
            }else {
                touchNumLable.centerX =touchedDot.centerX;
            }
        } completion:nil];
    }
    
    touchedDot.alpha = 1.f;
    if ((int)touchedDot.tag!=curChoosedTag) {
        if ([self.delegate respondsToSelector:@selector(didTouchAreaWithIndex:)]) {
            [self.delegate didTouchAreaWithIndex:((int)touchedDot.tag)];
        }
        curChoosedTag = (int)touchedDot.tag;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(didReleaseAreaWithIndex:)]) [self.delegate didReleaseAreaWithIndex:(int)(touchedDot.tag )];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            touchedDot.alpha = 0;
            touchFlowLineView.alpha = 0;
            touchNumLable.alpha = 0;
        } completion:nil];
    }
}


- (void)reloadLinesAndDots {
    
    for (UIView *subview in [lineContenView subviews]) {
        if ([subview isKindOfClass:[QHCircleDotView class]]||[subview isKindOfClass:[QHLineView class]])
            [subview removeFromSuperview];
    }
    
    dotPositions = [[NSMutableArray alloc] initWithCapacity:self.chartInfos.count];
    dotViews = [[NSMutableArray alloc] initWithCapacity:self.chartInfos.count];
    
    float max = [self getMaxNumber];
    
    for (int i = 0; i < self.chartInfos.count; i++) {
        
        CyclePieInfo *info = self.chartInfos[i];

        
        
        float positionX = (lineContenView.width/(self.chartInfos.count - 1))*i;
        
        float maxHeight = lineContenView.height- lineTopGap;
       
        float positionY = lineContenView.height-(maxHeight/max*info.number);
       
        
        [dotPositions addObject:[NSValue valueWithCGPoint:CGPointMake(positionX, positionY)]];
        
        QHCircleDotView *circleDot = [[QHCircleDotView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        circleDot.center = CGPointMake(positionX, positionY);
        circleDot.tag = i;
        circleDot.alpha = 0;
        [lineContenView addSubview:circleDot];
        [dotViews addObject:circleDot];
        [UIView animateWithDuration:0.5 delay:i/(animationLineSpeed) options:UIViewAnimationOptionCurveEaseOut animations:^{
            circleDot.alpha = 1.f;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                circleDot.alpha = 0;
            } completion:nil];
        }];
        
        
    }
    
    for (int i = 0; i < dotPositions.count-1; i++) {
        CGPoint positionLeft = [dotPositions[i] CGPointValue];
        CGPoint positionRight = [dotPositions[i+1] CGPointValue];
        QHLineView *lineView = [[QHLineView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        lineView.isEndPosition = i==dotPositions.count-2;
        lineView.startPoint = CGPointMake(positionLeft.x, positionLeft.y);
        lineView.endPoint = CGPointMake(positionRight.x, positionRight.y);
        lineView.topSpaceColor = self.topLineSpaceColor;
        lineView.bottomSpaceColor = self.underLineSpaceColor;
        lineView.lineColor = [UIColor whiteColor];
        lineView.lineWidth = 3.0;
        [lineContenView addSubview:lineView];
        [lineContenView sendSubviewToBack:lineView];
        if (self.shouldAnimationWhenReload) {
            lineView.alpha = 0;
            [UIView animateWithDuration:1.0 delay:i/(animationLineSpeed) options:UIViewAnimationOptionCurveEaseOut animations:^{
                lineView.alpha = 1.0;
            } completion:nil];
        }else {
            lineView.alpha = 1.f;
        }


    }
}


- (float)getMaxNumber {
    float curNum;
    float maxNum = 0;
    
    for (int i = 0; i < self.chartInfos.count; i++) {
        CyclePieInfo *info =self.chartInfos[i];
        curNum  = info.number;
        
        if (curNum > maxNum) {
            maxNum = curNum;
        }
    }
    
    return maxNum;
}

- (float)getMinNumber {
    
    float curNum;
    float minNum = INT_MAX;
    
    for (int i = 0; i < self.chartInfos.count; i++) {
        CyclePieInfo *info =self.chartInfos[i];
        curNum = info.number;
        
        if (curNum < minNum) {
            minNum = curNum;
        }
    }
    
    return minNum;
}


- (int)closestDotFromVerticalLine:(UIView *)aVerticalLine {
    
    int currentTouchTag  = INT_MAX;
    int dotIndex = 0;
    for (int i=0;i<dotViews.count;i++) {
        QHCircleDotView *curDotView = dotViews[i];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            curDotView.alpha = 0;
        } completion:nil];
        
        if (pow(((curDotView.center.x) - aVerticalLine.left), 2) < currentTouchTag) {
            currentTouchTag = pow(((curDotView.center.x) - aVerticalLine.left), 2);
            dotIndex = i;
        }
        
    }
    
    return dotIndex;
}

- (float)getDotYWithVLinePositionX:(float)vx {
    if (vx<=[[dotPositions firstObject] CGPointValue].x||vx>=[[dotPositions lastObject] CGPointValue].x) {
        return lineContenView.height;
    }
    
    int leftIndex = -1;
    
    for(int i=0;i<dotPositions.count-1;i++) {
        if (vx>[dotPositions [i] CGPointValue].x&&vx<=[dotPositions [i+1] CGPointValue].x) {
            leftIndex = i;
            break;
        }
    }
    
    if (leftIndex<0) {
        return lineContenView.height;
    }
    
    CGPoint left = [dotPositions[leftIndex] CGPointValue];
    CGPoint right = [dotPositions[leftIndex+1] CGPointValue];
    
    if (left.y>=right.y) {
        float height = fabs((vx - left.x)/(right.x-left.x)*(right.y-left.y));
        return MAX(left.y, right.y)-height;
    }else {
        float height = fabs((right.x - vx)/(right.x-left.x)*(right.y-left.y));
        return MAX(left.y, right.y)-height;
    }

}

- (void)reloadIntroductionLables {
    
    for (UIView *subview in [self subviews]) {
        if (([subview isKindOfClass:[UILabel class]]&&subview.tag>=minIntroductionLablesTag)||subview.tag<0)
            [subview removeFromSuperview];
    }
    
    NSMutableArray *lableCenterPositions = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (int i = 0; i < self.chartInfos.count; i++) {
        UILabel *introductionLable = [[UILabel alloc] init];
        CyclePieInfo *info =self.chartInfos[i];
        [introductionLable setText:info.introduction andFont:defaultFont(12) andTextColor:[UIColor whiteColor]];
        introductionLable.width = self.width/self.chartInfos.count;
        introductionLable.height = 30.f;
        introductionLable.left = i*self.width/(self.chartInfos.count);
        introductionLable.textAlignment = NSTextAlignmentCenter;
        introductionLable.centerY = self.height - bottomHeight/2.f;
        introductionLable.textAlignment = 1;
        introductionLable.tag = i+minIntroductionLablesTag;
        [self addSubview:introductionLable];
        [lableCenterPositions addObject:[NSValue valueWithCGPoint:introductionLable.center]];
    }
    
    for (int px = ruleXGap; px<self.width; px+=ruleXGap) {
        UIView *ruleLine = [[UIView alloc] initWithFrame:CGRectMake(px, self.height - bottomHeight+10, 1.5, 0)];
        ruleLine.height = [self isNearLableCenter:[dotPositions copy] positionX:ruleLine.right gap:ruleXGap]?9:5;
        ruleLine.tag = -1;
        ruleLine.layer.cornerRadius = 1;
        ruleLine.backgroundColor = [UIColor whiteColor];
        [self addSubview:ruleLine];
    }
    
    NSMutableArray *ruleLines = [[NSMutableArray alloc] init];
    
    for (int py = lineContenView.bottom; py>=lineContenView.top+lineTopGap; py-=ruleXGap) {
        UIView *ruleLine = [[UIView alloc] initWithFrame:CGRectMake(10, py, 0, 1.5)];
        ruleLine.width = 5;
        ruleLine.tag = -1;
        ruleLine.layer.cornerRadius = 1;
        ruleLine.backgroundColor = [UIColor whiteColor];
        [ruleLines addObject:ruleLine];
        [self addSubview:ruleLine];
        
    }

    for(int i=0;i<ruleLines.count;i+=ruleLines.count/5) {
        UIView *lineView = ruleLines[i];
        lineView.width = 9;
    }
    
    NSArray *middles = @[@(0),@(8),@(ruleLines.count-1)];
    for (int i=0; i<middles.count; i++) {
        UIView *lineView = ruleLines[ [middles[i] intValue]];
        UILabel *numLable = [[UILabel alloc] init];
        int count = i==0?0:i==1?([self getMaxNumber]/2.f):[self getMaxNumber];
        NSString * numTex = [NSString stringWithFormat:@"%i",count];
        if (i==1) {
            if (count==0||count==[self getMaxNumber]) {
                numTex = @"";
            }
        }
        [numLable setText:numTex andFont:defaultFont(12) andTextColor:[UIColor whiteColor]];
        [numLable sizeToFit];
        numLable.left =lineView.right+5;
        numLable.centerY = lineView.centerY;
        [self addSubview:numLable];
    }
    
    
}

- (BOOL)isNearLableCenter:(NSArray *)lablePositions positionX:(float)x gap:(int)gap {
    for(NSValue * centerV in lablePositions) {
        CGPoint center = [centerV CGPointValue];
        float cx = [self convertPoint:CGPointMake(x, 0) toView:lineContenView].x;
        if (cx-gap<center.x&&cx>=center.x) {
            return YES;
        }
    }
    
    return NO;
}

- (void)drawRect:(CGRect)rect {
    
    [self drawGradientColor:UIGraphicsGetCurrentContext() rect:lineContenView.frame options:kCGGradientDrawsBeforeStartLocation colors:@[[QHUtil colorWithHexString:@"#FF2E64"],[QHUtil colorWithHexString:@"#FF5145"]]];
}


- (void)drawGradientColor:(CGContextRef)p_context
                     rect:(CGRect)p_clipRect
                  options:(CGGradientDrawingOptions)p_options
                   colors:(NSArray *)p_colors {
    
    CGContextSaveGState(p_context);// 保持住现在的context
    CGContextClipToRect(p_context, p_clipRect);// 截取对应的context
    int colorCount = (int)p_colors.count;
    int numOfComponents = 4;
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat colorComponents[colorCount * numOfComponents];
    for (int i = 0; i < colorCount; i++) {
        UIColor *color = p_colors[i];
        CGColorRef temcolorRef = color.CGColor;
        const CGFloat *components = CGColorGetComponents(temcolorRef);
        for (int j = 0; j < numOfComponents; ++j) {
            colorComponents[i * numOfComponents + j] = components[j];
        }
    }
    CGGradientRef gradient =  CGGradientCreateWithColorComponents(rgb, colorComponents, NULL, colorCount);
    CGColorSpaceRelease(rgb);
    CGPoint startPoint = p_clipRect.origin;
    CGPoint endPoint = CGPointMake(CGRectGetMinX(p_clipRect), CGRectGetMaxY(p_clipRect));
    CGContextDrawLinearGradient(p_context, gradient, startPoint, endPoint, p_options);
    CGGradientRelease(gradient);
    CGContextRestoreGState(p_context);// 恢复到之前的context
}


@end