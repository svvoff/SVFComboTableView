//
//  SVFCTIndexPath.h
//  SVFComboTableViewDemo
//
//  Created by Andrei Sorokin on 03/07/15.
//  Copyright © 2016 _SVF_. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVFCTIndexPath : NSObject

+ (SVFCTIndexPath *) indexPathForRow:(NSInteger) row column:(NSInteger) column inSection:(NSInteger) section;

@property (nonatomic, readonly) NSInteger column;
@property (nonatomic, readonly) NSInteger row;
@property (nonatomic, readonly) NSInteger section;

@end
