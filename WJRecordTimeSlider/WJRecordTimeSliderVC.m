//
//  WJRecordTimeSliderVC.m
//  WJKit
//
//  Created by Wynton on 2016/12/23.
//  Copyright © 2016年 wynton. All rights reserved.
//

#import "WJRecordTimeSliderVC.h"
#import "WJRecordTimeSlider.h"

@interface WJRecordTimeSliderVC ()<WJRecordTimeSliderDelegate>
{
    
}
@property (nonatomic, strong) WJRecordTimeSlider *timeSlider;
@property (nonatomic, strong) UILabel *curTimeLabel;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UIView *currentTimeLine;
@end

@implementation WJRecordTimeSliderVC

- (IBAction)changeWidth:(id)sender {
//    self.timeSlider.hourWidth = self.view.bounds.size.width/3;
    [self.timeSlider setNeedsDisplay];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置当前时间
    NSDate *curDate = [NSDate dateWithTimeIntervalSince1970:1482537600];
    
    self.timeSlider = [[WJRecordTimeSlider alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height-80)/2, self.view.bounds.size.width, 80)];
    self.timeSlider.currentTime = [curDate timeIntervalSince1970];
    self.timeSlider.delegate = self;
    [self.view addSubview:self.timeSlider];
    
    [self _initDemoUI];
    
    //同步时间轴当前时间位置和刻度线位置
    self.timeSlider.currentTimeLineX = self.currentTimeLine.center.x;
    
    
    //设置存在录像(或已缓冲)区域
    NSMutableArray *records = [NSMutableArray array];
    int time = [curDate timeIntervalSince1970];
    for (int i = 0; i < 5; i++) {
        WJRecordParagraph *recordPara = [WJRecordParagraph paragraphWithStartTime:time EndTime:time+1800];
        [records addObject:recordPara];
        time += 3600;
    }
    
    self.timeSlider.existRecordTimeParagrapArr = [NSArray arrayWithArray:records];
    
    [self _resetTimeString];
}

- (void)_initDemoUI
{
    self.curTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.timeSlider.frame.origin.y-50, self.view.bounds.size.width, 20)];
    self.curTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.curTimeLabel];
    
    self.leftTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.timeSlider.frame.origin.y-20, self.view.bounds.size.width/2, 20)];
    self.leftTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.leftTimeLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:self.leftTimeLabel];
    
    self.rightTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2, self.timeSlider.frame.origin.y-20, self.view.bounds.size.width/2, 20)];
    self.rightTimeLabel.textAlignment = NSTextAlignmentRight;
    self.rightTimeLabel.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:self.rightTimeLabel];
    
    //当前时间刻度线
    self.currentTimeLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.timeSlider.frame.origin.y, 5, self.timeSlider.frame.size.height)];
    self.currentTimeLine.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    self.currentTimeLine.center = CGPointMake(self.view.bounds.size.width/2, self.currentTimeLine.center.y);
    [self.view addSubview:self.currentTimeLine];
    
    //刻度线拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panAction:)];
    [self.currentTimeLine addGestureRecognizer:pan];
}

- (void)_panAction:(UIPanGestureRecognizer *)sender
{
    static CGFloat tempX;
    CGPoint point = [sender translationInView:self.view];
    if (sender.state == UIGestureRecognizerStateBegan) {
        tempX = sender.view.frame.origin.x;
    }
    CGRect frame = sender.view.frame;
    frame.origin.x = tempX + point.x;
    sender.view.frame = frame;
    self.timeSlider.currentTimeLineX = sender.view.center.x;
    [self _resetTimeString];
}

- (void)WJRecordTimeSlider:(WJRecordTimeSlider *)recordTimeSlider ActionWithGestureType:(WJRecordTimeSliderGesutreSupport)gestureType Gesture:(UIGestureRecognizer *)gesture
{
    [self _resetTimeString];
}


- (void)_resetTimeString
{
    self.curTimeLabel.text = [[NSDate dateWithTimeIntervalSince1970:self.timeSlider.currentTime] description];
    self.leftTimeLabel.text = [[[NSDate dateWithTimeIntervalSince1970:self.timeSlider.leftTime] description] substringWithRange:NSMakeRange(11, 8)];
    self.rightTimeLabel.text = [[[NSDate dateWithTimeIntervalSince1970:self.timeSlider.rightTime] description]
                                substringWithRange:NSMakeRange(11, 8)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


