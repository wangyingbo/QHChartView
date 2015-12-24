//
//  CyclePieView.m
//  yimashuo
//
//  Created by imqiuhang on 15/8/18.
//  Copyright (c) 2015年 imqiuhang. All rights reserved.
//

#import "CyclePieView.h"
#import "QHCycleRotationGestureRecognizer.h"
#import "CyclePieIntroductionView.h"
#import "POP.h"

#define piePointerBackgroundImgViewSizeProportion 0.5f
#define piePointerBackgroundImgViewTriangleHeight 21.f/2.f

@implementation CyclePieView
{
    float angle;
    QHCycleRotationGestureRecognizer *cycleRotationGestureRecognizer;
    
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        angle = 0.f;
        [self initView];
    }
    return self;
}

- (void)initView {
    

    
    pieColorBackgroundImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MIN(self.width, self.height), MIN(self.width, self.height))];
    pieColorBackgroundImgView.centerX = self.width/2.f;
    pieColorBackgroundImgView.centerY = self.height/2.f;
    pieColorBackgroundImgView.image = [UIImage imageNamed:@"pieColorfulBg"];
        pieColorBackgroundImgView.userInteractionEnabled = YES;
    [self addSubview:pieColorBackgroundImgView];
    
    UIImageView *pieRoundLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pie_roundLine"]];
    pieRoundLine.width = pieColorBackgroundImgView.width+15;
    pieRoundLine.height =pieColorBackgroundImgView.height+15;
    pieRoundLine.centerX = self.width/2.f;
    pieRoundLine.centerY = self.height/2.f;
    [self insertSubview:pieRoundLine belowSubview:pieColorBackgroundImgView];
    
    piePointerBackgroundImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, pieColorBackgroundImgView.width*piePointerBackgroundImgViewSizeProportion, 0)];
    CGSize  imageRealSize = [UIImage imageNamed:@"piePointerBg"].size;
    piePointerBackgroundImgView.height = piePointerBackgroundImgView.width*(imageRealSize.height/imageRealSize.width);
    piePointerBackgroundImgView.image = [UIImage imageNamed:@"piePointerBg"];
    
    float scale = piePointerBackgroundImgView.height/ imageRealSize.height;
    float moveTopHeight = scale*piePointerBackgroundImgViewTriangleHeight/2.f;
    
    piePointerBackgroundImgView.centerX = self.width/2.f;
    piePointerBackgroundImgView.centerY = self.height/2.f -moveTopHeight;
    [self addSubview:piePointerBackgroundImgView];
    
    cycleRotationGestureRecognizer = [[QHCycleRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotating:)];
    
    [pieColorBackgroundImgView addGestureRecognizer:cycleRotationGestureRecognizer];
    
    cycleDrawLineView = [[CycleDrawLineView alloc] initWithFrame:pieColorBackgroundImgView.bounds];
    cycleDrawLineView.backgroundColor = [UIColor clearColor];
    [pieColorBackgroundImgView addSubview:cycleDrawLineView];

}

- (void)setCyclePieInfos:(NSArray *)cyclePieInfos {
    _cyclePieInfos = cyclePieInfos;
    
    cycleDrawLineView.cyclePieInfos = cyclePieInfos;
    if (!cyclePieIntroductionView) {
        cyclePieIntroductionView =[[CyclePieIntroductionView alloc] init];
        cyclePieIntroductionView.centerX  =self.width/2.f;
        cyclePieIntroductionView.centerY = self.height/2.f;
        [self addSubview:cyclePieIntroductionView];
    }
    
    cyclePieIntroductionView.cyclePieInfos = cycleDrawLineView.cyclePieInfos;
    cyclePieIntroductionView.precents = cycleDrawLineView.allPrecents;
    
    
    
    float angel1 = [[[cycleDrawLineView allPrecents] firstObject] floatValue]*2*M_PI;
    float middleNeedAngle = M_PI/2-angel1/2;
    [self rotationWithRotation:middleNeedAngle];
}


- (void)rotationWithRotation:(float)rotation {
    [pieColorBackgroundImgView setTransform:CGAffineTransformRotate(pieColorBackgroundImgView.transform,rotation)];
    angle-=rotation;
    int index = [cycleDrawLineView getIndexWithAngele:angle];
    cyclePieIntroductionView.index = index;
}

- (void)rotating:(QHCycleRotationGestureRecognizer *)recognizer {
    [self rotationWithRotation:recognizer.rotation];
}


- (void)animation {
    [pieColorBackgroundImgView.layer pop_removeAllAnimations];
    [pieColorBackgroundImgView setTransform:CGAffineTransformRotate(pieColorBackgroundImgView.transform, -M_PI/9)];
    [pieColorBackgroundImgView removeAllGestureRecognizers];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
        anim.springBounciness    = 8;
        anim.springSpeed         = 2;
        anim.toValue             = [NSNumber numberWithFloat:  atan2f(pieColorBackgroundImgView.transform.b, pieColorBackgroundImgView.transform.a)+M_PI/9 ];
        [pieColorBackgroundImgView.layer pop_addAnimation:anim forKey:@"pieColorBackgroundImgViewAni"];
        [anim setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
            [pieColorBackgroundImgView addGestureRecognizer:cycleRotationGestureRecognizer];
        }];
    });

}

@end
