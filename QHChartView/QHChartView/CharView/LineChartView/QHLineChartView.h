//
//  CyclePieView.h
//  yimashuo
//
//  Created by imqiuhang on 15/8/18.
//  Copyright (c) 2015年 imqiuhang. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "QHCircleDotView.h"
#import "QHLineView.h"
#import "CyclePieIntroductionView.h"

@protocol QHLineChartViewDelegate <NSObject>

@optional

- (void)didTouchAreaWithIndex:(int)index;

- (void)didReleaseAreaWithIndex:(int)index;


@end

@interface QHLineChartView : UIView
{
    @protected
    UIView *touchFlowLineView,*panGestureRecognizerView;
    QHCircleDotView *touchedDot;
    int curChoosedTag;
    UILabel *touchNumLable;
    
}

@property (nonatomic,weak)id <QHLineChartViewDelegate> delegate;

@property (strong, nonatomic) UIColor *underLineSpaceColor;
@property (strong, nonatomic) UIColor *topLineSpaceColor;

@property (nonatomic)BOOL shouldAnimationWhenReload;
//set
@property (nonatomic,strong)NSArray *chartInfos;

- (void)reloadView;

@end
