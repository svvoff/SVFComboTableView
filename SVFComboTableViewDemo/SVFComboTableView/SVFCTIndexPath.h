//
//  CTIndexPath.h
//  bachmann crm mobile app bps2
//
//  Created by Andrey on 03/07/15.
//  Copyright (c) 2015 Kirill Pyulzyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVFCTIndexPath : NSObject

+ (SVFCTIndexPath *) indexPathForRow:(NSInteger) row column:(NSInteger) column inSection:(NSInteger) section;

@property (nonatomic, readonly) NSInteger column;
@property (nonatomic, readonly) NSInteger row;
@property (nonatomic, readonly) NSInteger section;

@end
