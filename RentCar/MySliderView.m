//
//  MySliderView.m
//  RentCar
//
//  Created by ffm on 16/11/10.
//  Copyright © 2016年 ITPanda. All rights reserved.
//

#import "MySliderView.h"



@interface MySliderView ()

@property (weak, nonatomic) IBOutlet UIView *sliderWrapperView;
@property (nonatomic, strong)  NSMutableArray *dotsMurArr;
@property (nonatomic, strong) UIButton *carBtn;


@end
@implementation MySliderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/




- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initializeView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initializeView];
    }
    return self;
}

- (void)initializeView
{
    UIView *childView = [[[NSBundle mainBundle] loadNibNamed:@"MySliderView" owner:self options:nil] firstObject];
    childView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);

    if (childView)
    {
        [self addSubview:childView];
    }
}

//加载子控件的时候会调用
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutIfNeeded];
    
    UIView *sliderBar = [[UIView alloc] initWithFrame:CGRectMake(0, (self.sliderWrapperView.bounds.size.height - 4)/2, self.sliderWrapperView.frame.size.width, 4)];
    sliderBar.layer.cornerRadius = 2;
    sliderBar.backgroundColor = [UIColor grayColor];
//    sliderBar.center = self.sliderWrapperView.center;
    [self.sliderWrapperView addSubview:sliderBar];
    
    
    CGFloat dotY = self.sliderWrapperView.frame.size.height / 2 - 4;
    for (int i = 0; i < 4; i++)
    {
        CGFloat dotX = i * (self.sliderWrapperView.frame.size.width / 3) -4;
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(dotX, dotY, 8, 8)];
        dotView.layer.cornerRadius = 4;
        dotView.backgroundColor = [UIColor darkGrayColor];
        [self.sliderWrapperView addSubview:dotView];
        [self.dotsMurArr addObject:dotView];
    }
    [self.sliderWrapperView bringSubviewToFront:self.carBtn];
//    [self carBtn];
}

#pragma mark clickMethods

//这里这个方法边界判断还是有点bug呀擦擦擦擦
- (void)carBtn:(UIButton *)sender draggedWithEvent:(UIEvent *)event
{
    [self limitationJudge:sender];
    NSArray *touchesArray = [[event touchesForView:sender] allObjects];
    UITouch *touchPoint = [touchesArray firstObject];
    if (touchPoint)
    {
        CGFloat offset = [touchPoint locationInView:sender].x - [touchPoint previousLocationInView:sender].x;
        
        CGRect offsetRect = CGRectMake(sender.frame.origin.x + offset, sender.frame.origin.y, sender.frame.size.width, sender.frame.size.height);
        sender.frame = offsetRect;
    }

}

- (void)carBtn:(UIButton *)sender touchesUpWithEvent:(UIEvent *)event
{
    [self limitationJudge:sender];
    [self carBtnMoveToNearestPosititon:[self findCarBtnNearestPosition]];
    [self.delegate sliderControl:self moveToPosition:[self findCarBtnNearestPosition]];
}

//判断carBtn是否超出了轨道，如果是的话，则返回边界处
- (void)limitationJudge:(UIButton *)sender
{
    if (sender.center.x < 0)
    {
        UIView *firstDotView = [self.dotsMurArr firstObject];
        sender.center = firstDotView.center;
        
    } else if (sender.center.x > self.sliderWrapperView.frame.size.width)
    {
        UIView *firstDotView = [self.dotsMurArr lastObject];
        sender.center = firstDotView.center;
    }

}

- (int)findCarBtnNearestPosition
{
    int position = (int)round(self.carBtn.center.x/(self.sliderWrapperView.bounds.size.width/3));
    if (position < 0)
    {
        position = 0;
    } else if (position > 3)
    {
        position = (int)self.dotsMurArr.count -1;
    }
    return position;
}

- (void)carBtnMoveToNearestPosititon:(int )position
{
    UIView *dotView = self.dotsMurArr[position];
    self.carBtn.center = dotView.center;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UIView *currentDotView;
    for (int i = 0; i < self.dotsMurArr.count; i++)
    {
        currentDotView = self.dotsMurArr[i];
        if ([touches anyObject].view == currentDotView)
        {
            self.carBtn.center = currentDotView.center;
            [self.delegate sliderControl:self moveToPosition:i];
            break;
        }
    }
}


#pragma mark 懒加载
- (NSMutableArray *)dotsMurArr
{
    if (!_dotsMurArr)
    {
        _dotsMurArr = [NSMutableArray array];
    }
    return _dotsMurArr;
}

- (UIButton *)carBtn
{
    if (!_carBtn)
    {
        //创建button
        _carBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_carBtn setImage:[UIImage imageNamed:@"car_button"] forState:UIControlStateNormal];
        UIView *currentDot = [self.dotsMurArr firstObject];
        _carBtn.center = currentDot.center;
        [self.sliderWrapperView addSubview:_carBtn];
        [_carBtn addTarget:self action:@selector(carBtn:draggedWithEvent:) forControlEvents:UIControlEventTouchDragInside];
        [_carBtn addTarget:self action:@selector(carBtn:touchesUpWithEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _carBtn;
}

@end
