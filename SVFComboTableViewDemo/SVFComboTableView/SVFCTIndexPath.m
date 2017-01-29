//
//  SVFCTIndexPath.m
//  SVFComboTableViewDemo
//
//  Created by Andrei Sorokin on 03/07/15.
//  Copyright © 2016 _SVF_. All rights reserved.
//

#import "SVFCTIndexPath.h"

@implementation SVFCTIndexPath

+ (SVFCTIndexPath *) indexPathForRow:(NSInteger) row column:(NSInteger) column inSection:(NSInteger) section {
    return [[SVFCTIndexPath alloc] initWithRow:row column:column section:section];
}

- (instancetype) initWithRow:(NSInteger) row column:(NSInteger) column section:(NSInteger) section {
    self = [super init];
    if (self) {
        _row = row;
        _column = column;
        _section = section;
    }
    
    return self;
}

@end
