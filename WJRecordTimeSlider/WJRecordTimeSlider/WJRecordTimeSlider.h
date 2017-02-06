//
//  WJTimer.h
//  WJTimerTest
//
//  Created by Wynton on 2016/12/21.
//  Copyright © 2016年 juanvision. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WJRecordTimeSliderGesutreSupport) {
    WJRecordTimeSliderGesutreSupportPan = 1 << 1,
    WJRecordTimeSliderGesutreSupportPinch = 1 << 2,
};

@class WJRecordTimeSlider,WJRecordParagraph;
@protocol WJRecordTimeSliderDelegate <NSObject>


/**
 手势触发回调

 @param recordTimeSlider self
 @param gestureType 手势类型
 @param gesture 手势对象
 */
- (void)WJRecordTimeSlider:(WJRecordTimeSlider *)recordTimeSlider ActionWithGestureType:(WJRecordTimeSliderGesutreSupport)gestureType Gesture:(UIGestureRecognizer *)gesture;

@end

@interface WJRecordTimeSlider : UIView

//最左边(self.frame.origin.x)的时间
@property (nonatomic, assign, readonly) NSTimeInterval leftTime;

//最左边(self.frame.origin.x+self.frame.size.width)的时间
@property (nonatomic, assign, readonly) NSTimeInterval rightTime;

//是否正在拖动
@property (nonatomic, assign, readonly) BOOL isPaning;

//是否正在缩放
@property (nonatomic, assign, readonly) BOOL isScaling;

//一倍缩放下一小时刻度宽: 默认self.bounds.size.width/4
@property (nonatomic, assign, readonly) CGFloat hourWidth;

@property (nonatomic,assign) id <WJRecordTimeSliderDelegate> delegate;

//支持的手势, 默认都支持
@property (nonatomic, assign) WJRecordTimeSliderGesutreSupport gestureSuport;

//当前时间
@property (nonatomic, assign) NSTimeInterval currentTime;

//当前缩放值: 默认1
@property (nonatomic, assign) CGFloat currentScale;

//缩放最大值: 默认4
@property (nonatomic, assign) CGFloat maxScale;

//缩放最小值: 默认:1
@property (nonatomic, assign) CGFloat minScale;

//当前时间位置: 默认self.center.x
@property (nonatomic, assign) CGFloat currentTimeLineX;

//刻度线颜色: 默认whiteColor
@property (nonatomic, strong) UIColor *lineColor;

//存在录像部分区域颜色: 默认orangeColor
@property (nonatomic, strong) UIColor *existRecordPathColor;

//存在录像(或已缓冲)区域, 多段录像时, 务必使用升序
@property (nonatomic, strong) NSArray<WJRecordParagraph *> *existRecordTimeParagrapArr;

/**
 重置刻度线宽度, 缩放大小会重置为1

 @param hourWidth 一小时刻度宽
 */
- (void)resetScaleWithHourWidth:(CGFloat)hourWidth;


@end


//
//录像段模型
//
@interface WJRecordParagraph : NSObject

@property (nonatomic, assign) int startTime;
@property (nonatomic, assign) int endTime;

+ (instancetype)paragraphWithStartTime:(int)startTime EndTime:(int)endTime;

@end
