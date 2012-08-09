//
//  AJRImageView.m
//  MagnificationTest
//
//  Created by Alan Rogers on 31/07/12.
//  Copyright (c) 2012 Alan Rogers. All rights reserved.
//

#import "AJRImageView.h"
#import "AJRLayer.h"

@implementation AJRImageView {
	//CALayer *_containerLayer;
	CGSize _imageSize;
}

static void _CommonInit(AJRImageView *self) {
	NSURL *imageURL = [[NSBundle mainBundle] URLForResource:@"yoda" withExtension:@"jpg"];
	NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];

	self->_imageSize = [image size];
	CGRect frame = [self frame];
	frame.size = [image size];
	[self setFrame:frame];

	[self setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawNever];
	CALayer *backingLayer = [CALayer layer];
	[backingLayer setAnchorPoint:CGPointMake(0., 0.)];
	[backingLayer setFrame:[self bounds]];
	[backingLayer setContents:image];
	[backingLayer setBackgroundColor:[NSColor greenColor].CGColor];
	
	[backingLayer setLayoutManager:self];
	[backingLayer setNeedsLayout];
	[backingLayer setActions:@{kCATransition: [NSNull null], @"sublayers": [NSNull null]}];
	[self setLayer:backingLayer];
	[self setWantsLayer:YES];
}

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self == nil) {
		return nil;
	}
	_CommonInit(self);

	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self == nil) {
		return nil;
	}

	_CommonInit(self);

	return self;
}

- (void)awakeFromNib {
	CALayer *sublayer = [CALayer layer];
	[sublayer setAnchorPoint:CGPointMake(0,0)];

	[sublayer setBackgroundColor:CGColorGetConstantColor(kCGColorWhite)];
	[sublayer setFrame:CGRectMake(100., 100., 100., 100.)];
	[sublayer setActions:@{kCATransition: [NSNull null], @"sublayers": [NSNull null], @"bounds" : [NSNull null], @"position": [NSNull null]}];

	[[self layer] addSublayer:sublayer];
}

- (BOOL)translatesAutoresizingMaskIntoConstraints {
	return YES;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
	[CATransaction disableActions];
	if (layer == [self layer]) {
		CGFloat w_scale = [self.layer bounds].size.width/_imageSize.width;
		CGFloat h_scale = [self.layer bounds].size.height/_imageSize.height;

		[[layer sublayers] enumerateObjectsUsingBlock:^(CALayer * obj, NSUInteger idx, BOOL *stop) {
			
			CGPoint constraintPoint = {.x = 100., .y = 100.};

			CGFloat width = 100.;
			CGFloat height = 100.;
		
			NSArray* constraints = @[
			[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMinX offset:constraintPoint.x*w_scale],
				[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY offset:constraintPoint.y*h_scale],
				[CAConstraint constraintWithAttribute:kCAConstraintWidth relativeTo:@"superlayer" attribute:kCAConstraintWidth scale:0. offset:w_scale*width],
				[CAConstraint constraintWithAttribute:kCAConstraintHeight relativeTo:@"superlayer" attribute:kCAConstraintHeight scale:0. offset:h_scale*height]];


			

			[obj setConstraints:constraints];
		}];
		[[CAConstraintLayoutManager layoutManager] layoutSublayersOfLayer:layer];
	}
	[CATransaction commit];
}

@end
