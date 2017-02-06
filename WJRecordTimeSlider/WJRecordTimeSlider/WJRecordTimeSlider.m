//
//  WJTimer.m
//  WJTimerTest
//
//  Created by Wynton on 2016/12/21.
//  Copyright © 2016年 juanvision. All rights reserved.
//

#import "WJRecordTimeSlider.h"

@interface WJRecordTimeSlider ()
{
    CGFloat _minuteWidth;
    CGFloat _secondWidth;
    CGFloat _aPxSeconds;
    NSUInteger _unitFlags;
    CGFloat _tempHourWidth;
}
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) NSCalendar *calendar;
@end

@implementation WJRecordTimeSlider

#pragma mark - --- Public ---

- (void)resetScaleWithHourWidth:(CGFloat)hourWidth
{
    [self setHourWidth:hourWidth];
}

#pragma mark -

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        _calendar = [NSCalendar currentCalendar];
        _calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        _unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        _currentScale = 1.0f;
        _maxScale = 4;
        _minScale = 1;
        
        [self setHourWidth:self.bounds.size.width/4];
        self.currentTimeLineX = self.bounds.size.width/2;
        
        _lineColor = [UIColor whiteColor];
        _existRecordPathColor = [UIColor orangeColor];
        
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panAction:)];
        [self addGestureRecognizer:_panGesture];
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(_pinchAction:)];
        [self addGestureRecognizer:_pinchGesture];
        
        _gestureSuport = WJRecordTimeSliderGesutreSupportPinch | WJRecordTimeSliderGesutreSupportPan;
        
    }
    return self;
}

#pragma mark - --- Gesture ---
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _panGesture) {
        return (_gestureSuport & WJRecordTimeSliderGesutreSupportPan);
    }else if (gestureRecognizer == _pinchGesture){
        return (_gestureSuport & WJRecordTimeSliderGesutreSupportPinch);
    }
    
    return YES;
}

- (void)_panAction:(UIPanGestureRecognizer *)sender
{
    static CGFloat tempTime;
    
    CGPoint point = [sender translationInView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateChanged)
    {
        _currentTime = tempTime - point.x * _aPxSeconds;
        [self _resetParam];
        [self setNeedsDisplay];
    }
    else if (sender.state == UIGestureRecognizerStateBegan)
    {
        tempTime = _currentTime;
        _isPaning = YES;
    }
    else
    {
        _isPaning = NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(WJRecordTimeSlider:ActionWithGestureType:Gesture:)]) {
        [self.delegate WJRecordTimeSlider:self ActionWithGestureType:WJRecordTimeSliderGesutreSupportPan Gesture:sender];
    }
    
}

- (void)_pinchAction:(UIPinchGestureRecognizer *)sender
{
    static CGFloat tempScale;
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = tempScale + sender.scale-1;
        if (scale > _maxScale) {
            scale = _maxScale;
        }
        if (scale < _minScale) {
            scale = _minScale;
        }

        self.currentScale = scale;
    }else if (sender.state == UIGestureRecognizerStateBegan) {
        tempScale = _currentScale;
        _isScaling = YES;
    }else{
        _isScaling = NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(WJRecordTimeSlider:ActionWithGestureType:Gesture:)]) {
        [self.delegate WJRecordTimeSlider:self ActionWithGestureType:WJRecordTimeSliderGesutreSupportPinch Gesture:sender];
    }
    
}

#pragma mark - --- Draw ---

- (void)drawRect:(CGRect)rect {
    
    //判断当前区域是否需要画录像
    if (!(self.existRecordTimeParagrapArr.firstObject.startTime > _rightTime || self.existRecordTimeParagrapArr.lastObject.endTime < _leftTime))
    {
        for (WJRecordParagraph *para in self.existRecordTimeParagrapArr) {
            
            CGFloat startX, endX;
            
            //该段开始时间超出时间轴右边时间, 则后面都不用画了
            if (para.startTime > _rightTime) {
                break;
            }
            
            //如果该段结束时间小于时间轴左边时间, 则该段不用画
            if (para.endTime < _leftTime) {
                continue;
            }
            
            startX = (para.startTime-_leftTime)*_secondWidth;
            endX = (para.endTime-_leftTime)*_secondWidth;
            
            [self drawExistRecordLineWithStartX:startX EndX:endX];
        }
    }
    
    NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:_currentTime];
    NSDateComponents *dateComponent = [_calendar components:_unitFlags fromDate:currentDate];
    dateComponent.hour++;
    dateComponent.minute = 0;
    dateComponent.second = 0;
    dateComponent.nanosecond = 0;
    NSDate *nextHourDate = [_calendar dateFromComponents:dateComponent];
    NSTimeInterval difTime = [nextHourDate timeIntervalSinceDate:currentDate];
    
    CGFloat perWidth = _hourWidth;
    CGFloat lineX = difTime*_secondWidth+_currentTimeLineX;
    
    NSInteger lineHour = dateComponent.hour;
    CGFloat tempLineX = lineX;
    
    
    
    //画当前时间线右边的刻度
    while (lineX < self.bounds.size.width)
    {
        NSString *time = [NSString stringWithFormat:@"%02ld:00",lineHour > 23 ? lineHour-24 : lineHour];
        
        //大刻度线(小时)
        [self drawLineWithStartPoint:CGPointMake(lineX, 10) Length:self.bounds.size.height-30 TimeString:time];
        
        //小刻度线(10分钟)
        for (int i = 1; i < 6; i++) {
            [self drawLineWithStartPoint:CGPointMake(perWidth/6*i+lineX, 20) Length:self.bounds.size.height-50 TimeString:nil];
        }
        
        lineX += perWidth;
        lineHour++;
    }
    
    
    lineHour = dateComponent.hour;
    //画当前时间线左边的刻度
    while (tempLineX > 0) {
        
        tempLineX -= perWidth;
        lineHour--;
        
        NSString *time = [NSString stringWithFormat:@"%02ld:00",lineHour < 0 ? lineHour+24 : lineHour];
        //大刻度线(小时)
        [self drawLineWithStartPoint:CGPointMake(tempLineX, 10) Length:self.bounds.size.height-30 TimeString:time];
        
        //小刻度线(10分钟)
        for (int i = 1; i < 6; i++) {
            [self drawLineWithStartPoint:CGPointMake(perWidth/6*i+tempLineX, 20) Length:self.bounds.size.height-50 TimeString:nil];
        }
    }
    
    //向左画多一个小时的刻度, 防止最左边空缺数个小刻度
    tempLineX -= perWidth;
    lineHour--;
    for (int i = 1; i < 6; i++) {
        [self drawLineWithStartPoint:CGPointMake(perWidth/6*i+tempLineX, 20) Length:self.bounds.size.height-50 TimeString:nil];
    }
    
}

- (void)drawLineWithStartPoint:(CGPoint)point Length:(CGFloat)length TimeString:(NSString *)timeString
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
    CGContextMoveToPoint(context, point.x-.5, point.y);
    CGContextAddLineToPoint(context, point.x-.5, point.y+length);
    CGContextStrokePath(context);
    if (timeString) {
        CGContextSetFillColorWithColor(context,_lineColor.CGColor);
        [timeString drawInRect:CGRectMake(point.x-13, point.y+length, 40, 10) withFont:[UIFont systemFontOfSize:10]];
    }
}

- (void)drawExistRecordLineWithStartX:(int)startX EndX:(int)endX
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, _existRecordPathColor.CGColor);//画笔颜色
    CGContextSetLineWidth(context, self.bounds.size.height);//笔宽
    CGContextMoveToPoint(context, startX, self.bounds.size.height/2);
    CGContextAddLineToPoint(context, endX, self.bounds.size.height/2);
    CGContextStrokePath(context);
    
}

#pragma mark - --- Property ---

- (void)setHourWidth:(CGFloat)hourWidth
{
    _tempHourWidth = hourWidth;
    _hourWidth = hourWidth;
    _minuteWidth = _hourWidth/60;
    _secondWidth = _minuteWidth/60;
    _aPxSeconds = 1.0/_secondWidth;
    _currentScale = 1;
    [self _resetParam];
    [self setNeedsDisplay];
}

- (void)setCurrentScale:(CGFloat)currentScale
{
    _currentScale = currentScale;
    
    _hourWidth = _tempHourWidth*_currentScale;
    _minuteWidth = _hourWidth/60;
    _secondWidth = _minuteWidth/60;
    _aPxSeconds = 1.0/_secondWidth;
    [self _resetParam];
    [self setNeedsDisplay];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    _currentTime = currentTime;
    [self _resetParam];
    [self setNeedsDisplay];
}

- (void)setCurrentTimeLineX:(CGFloat)currentTimeLineX
{
    _currentTimeLineX = currentTimeLineX;
    [self _resetParam];
    [self setNeedsDisplay];
}

- (void)setMaxScale:(CGFloat)maxScale
{
    _maxScale = maxScale;
    if (_currentScale > _maxScale) {
        self.currentScale = _maxScale;
    }
}

- (void)setMinScale:(CGFloat)minScale
{
    _minScale = minScale;
    if (_currentScale < _minScale) {
        self.currentScale = _minScale;
    }
}

#pragma mark - --- Private ---

- (void)_resetParam
{
    _leftTime =  _currentTime - _currentTimeLineX*_aPxSeconds;
    _rightTime = _currentTime + (self.bounds.size.width-_currentTimeLineX) * _aPxSeconds;
}

@end

@implementation WJRecordParagraph

+ (instancetype)paragraphWithStartTime:(int)startTime EndTime:(int)endTime
{
    return [[WJRecordParagraph alloc]initWithStartTime:startTime EndTime:endTime];
}

- (instancetype)initWithStartTime:(int)startTime EndTime:(int)endTime
{
    self = [super init];
    if (self) {
        _startTime = startTime;
        _endTime = endTime;
    }
    return self;
}

 -(NSString *)description
{
    return [NSString stringWithFormat:@"{startTime:%d,endTime:%d}",_startTime,_endTime];
}

@end
