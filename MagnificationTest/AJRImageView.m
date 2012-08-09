//
//  AJRImageView.m
//  MagnificationTest
//
//  Created by Alan Rogers on 31/07/12.
//  Copyright (c) 2012 Alan Rogers. All rights reserved.
//

#import "AJRImageView.h"
#import "AJRLayer.h"

static NSString * const _AJRImageViewMagnificationContext = @"_AJRImageViewMagnificationContext";
static NSString * const _AJRImageViewScrollViewMagnificationKey = @"magnification";

@implementation AJRImageView {
	CALayer *_containerLayer;
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
	[backingLayer setBackgroundColor:[NSColor greenColor].CGColor];
	
	[backingLayer setActions:@{kCATransition: [NSNull null], @"sublayers": [NSNull null]}];
	[self setLayer:backingLayer];
	[self setWantsLayer:YES];

	self->_containerLayer = [CALayer layer];
	[self->_containerLayer setAnchorPoint:CGPointZero];
	[self->_containerLayer setFrame:CGRectMake(0., 0., self->_imageSize.width, self->_imageSize.height)];
	[self->_containerLayer setContents:image];
	[self->_containerLayer setActions:@{kCATransition: [NSNull null], @"sublayers": [NSNull null], @"transform" : [NSNull null]}];


	[[self layer] addSublayer:self->_containerLayer];
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

- (void)dealloc {
	[self removeObserver:self forKeyPath:_AJRImageViewScrollViewMagnificationKey context:(void*)&_AJRImageViewMagnificationContext];
}

- (void)awakeFromNib {
	CALayer *sublayer = [CALayer layer];
	[sublayer setAnchorPoint:CGPointMake(0,0)];

	[sublayer setBackgroundColor:CGColorGetConstantColor(kCGColorWhite)];
	[sublayer setFrame:CGRectMake(100., 100., 100., 100.)];
	[sublayer setActions:@{kCATransition: [NSNull null], @"sublayers": [NSNull null], @"bounds" : [NSNull null], @"position": [NSNull null]}];

	[_containerLayer addSublayer:sublayer];
	[[self enclosingScrollView] addObserver:self forKeyPath:_AJRImageViewScrollViewMagnificationKey options:NSKeyValueObservingOptionNew context:(void*)&_AJRImageViewMagnificationContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == &_AJRImageViewMagnificationContext) {
		CGFloat magnification = [change[NSKeyValueChangeNewKey] floatValue];

		CATransform3D transform = CATransform3DMakeScale(magnification, magnification, 1.);
		[_containerLayer setTransform:transform];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (BOOL)translatesAutoresizingMaskIntoConstraints {
	return YES;
}

@end
