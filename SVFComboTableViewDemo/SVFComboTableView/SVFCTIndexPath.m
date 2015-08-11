//
//  CTIndexPath.m
//  bachmann crm mobile app bps2
//
//  Created by Andrey on 03/07/15.
//  Copyright (c) 2015 Kirill Pyulzyu. All rights reserved.
//

#import "SVFCTIndexPath.h"

@implementation SVFCTIndexPath

+ (SVFCTIndexPath *) indexPathForRow:(NSInteger) row column:(NSInteger) column inSection:(NSInteger) section {
    SVFCTIndexPath * returningIP = [[SVFCTIndexPath alloc] init];
    returningIP -> _section = section;
    returningIP -> _row = row;
    returningIP -> _column = column;
    return returningIP;
    
}

@end
