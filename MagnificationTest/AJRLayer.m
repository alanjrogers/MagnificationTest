//
//  AJRLayer.m
//  MagnificationTest
//
//  Created by Alan Rogers on 31/07/12.
//  Copyright (c) 2012 Alan Rogers. All rights reserved.
//

#import "AJRLayer.h"

@implementation AJRLayer

//- (void)setFrame:(CGRect)frame {
//	[super setFrame:CGRectMake(100., 100., 100., 100.)];
//}
//
//- (void)setTransform:(CATransform3D)transform {
//}
//
//- (void)setSublayerTransform:(CATransform3D)sublayerTransform {
//	
//}

- (void)layoutSublayers {
	CATransform3D superlayerTransform = [self.superlayer sublayerTransform];

	//CATransform3D inverseTransform = CATransform3DInvert(superlayerTransform);

	self.transform = superlayerTransform;

	[super layoutSublayers];
}

@end
