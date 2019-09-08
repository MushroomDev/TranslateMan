//
//  NSView+Category..m
//  UEnAi
//
//  Created by swain on 15/3/20.
//  Copyright (c) 2015年 swain. All rights reserved.
//

#import "NSView+Category.h"


@implementation NSView (Category)

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.origin.x+self.size.width/2;
}

- (void)setCenterX:(CGFloat)centerX {
    CGRect oldframe = self.frame;
    self.frame = CGRectMake(centerX-oldframe.size.width/2, oldframe.origin.y, oldframe.size.width, oldframe.size.height);
}

- (CGFloat)centerY {
    return self.origin.y+self.size.height/2;
}

- (void)setCenterY:(CGFloat)centerY {
    CGRect oldframe = self.frame;
    self.frame = CGRectMake(oldframe.origin.x,centerY-oldframe.size.height/2, oldframe.size.width, oldframe.size.height);
}

- (void)setCenter:(CGPoint)point {
    CGRect oldframe = self.frame;
    self.frame = CGRectMake(point.x-oldframe.size.width/2,point.y-oldframe.size.height/2 , oldframe.size.width, oldframe.size.height);
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

-(void)setAnchorPoint:(CGPoint)anchorPoint{
    
    self.layer.anchorPoint = anchorPoint;
    
    CGRect frame = self.layer.frame;
    float xCoord = frame.origin.x + frame.size.width;
    float yCoord = frame.origin.y + frame.size.height;
    
    CGPoint point = CGPointMake(xCoord, yCoord);
    
    self.layer.position = point;
}

@end
