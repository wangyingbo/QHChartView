//
//  CyclePieView.h
//  yimashuo
//
//  Created by imqiuhang on 15/8/18.
//  Copyright (c) 2015年 imqiuhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CycleDrawLineView.h"

#import "QHHead.h"

@interface CyclePieView : UIView
{
 @protected
    UIImageView *pieColorBackgroundImgView, *piePointerBackgroundImgView;
    CycleDrawLineView *cycleDrawLineView;
    CyclePieIntroductionView *cyclePieIntroductionView ;
}

- (void)animation;

@property (nonatomic,strong)NSArray *cyclePieInfos;;

@end
