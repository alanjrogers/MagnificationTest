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
	CGSize _imageSize;
	CALayer *_containerLayer;
	__weak NSScrollView *_observingScrollView;
}

static void _CommonInit(AJRImageView *self) {
	NSURL *imageURL = [[NSBundle mainBundle] URLForResource:@"screen" withExtension:@"png"];
	NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];

	CGRect frame = [self frame];
	self->_imageSize = [image size];
	frame.size = [image size];
	[self setFrame:frame];

	[self setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawNever];
	CALayer *backingLayer = [CALayer layer];
	[backingLayer setAnchorPoint:CGPointMake(0., 0.)];
	[backingLayer setFrame:[self bounds]];
	[backingLayer setBackgroundColor:[NSColor redColor].CGColor];
	
	[backingLayer setActions:@{kCATransition: [NSNull null], @"sublayers": [NSNull null]}];
	[self setLayer:backingLayer];
	[self setWantsLayer:YES];

	self->_containerLayer = [CALayer layer];
	[self->_containerLayer setAnchorPoint:CGPointZero];
	[self->_containerLayer setFrame:CGRectMake(0., 0., [image size].width, [image size].height)];
	[self->_containerLayer setContents:image];
	[self->_containerLayer setActions:@{kCATransition: [NSNull null], @"sublayers": [NSNull null], @"transform" : [NSNull null]}];

	[[self layer] addSublayer:self->_containerLayer];

	CALayer *sublayer = [CALayer layer];
	[sublayer setAnchorPoint:CGPointMake(0,0)];

	[sublayer setBackgroundColor:CGColorGetConstantColor(kCGColorWhite)];
	[sublayer setFrame:CGRectMake(100., 100., 100., 100.)];
	[sublayer setActions:@{kCATransition: [NSNull null], @"sublayers": [NSNull null], @"bounds" : [NSNull null], @"position": [NSNull null]}];

	[self->_containerLayer addSublayer:sublayer];
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
	// If _observingScrollView is nil, then we don't need to stop observing it, and this is ok to silently fail
	[_observingScrollView removeObserver:self forKeyPath:_AJRImageViewScrollViewMagnificationKey context:(void*)&_AJRImageViewMagnificationContext];

}

- (void)viewDidMoveToWindow {
	if ([self enclosingScrollView] != nil) {
		_observingScrollView = [self enclosingScrollView];
		[[self enclosingScrollView] addObserver:self forKeyPath:_AJRImageViewScrollViewMagnificationKey options:NSKeyValueObservingOptionNew context:(void*)&_AJRImageViewMagnificationContext];

		CGFloat magnification = 1.;
		if (_imageSize.width > _imageSize.height) {
			magnification = [[self enclosingScrollView] frame].size.width/_imageSize.width;
		}
		else {
			magnification = [[self enclosingScrollView] frame].size.height/_imageSize.height;
		}

		[_observingScrollView setMinMagnification:magnification];
		[_observingScrollView setMagnification:magnification];
	}
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

@end
