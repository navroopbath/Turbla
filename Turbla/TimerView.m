//
//  TimerView.m
//  Turbla
//
//  Created by Patricia S Demorest on 11/15/15.
//  Copyright © 2015 Turbla. All rights reserved.
//

#import "TimerView.h"

@interface TimerView ()

@property (nonatomic) IBOutlet UILabel *timeLeftLabel;

@end

@implementation TimerView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.percent = 1.0f;
    
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    CGFloat startAngle = 3 * M_PI / 2;
    CGFloat endAngle = 7 * M_PI / 2;
    
    // Create our arc, with the correct angles
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:rect.size.width / 4
                      startAngle:startAngle
                        endAngle:self.percent * (endAngle - startAngle) + startAngle
                       clockwise:YES];
    
    // Set the display for the path, and stroke it
    bezierPath.lineWidth = 7.0f;
    [[UIColor redColor] setStroke];
    [bezierPath stroke];
    
    self.timeLeftLabel.text = [NSString stringWithFormat:@"%.f", self.percent * 20];
    
}

@end
