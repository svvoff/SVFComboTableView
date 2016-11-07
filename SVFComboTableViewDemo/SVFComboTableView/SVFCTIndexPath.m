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
    SVFCTIndexPath * returningIP = [[SVFCTIndexPath alloc] init];
    returningIP -> _section = section;
    returningIP -> _row = row;
    returningIP -> _column = column;
    return returningIP;
    
}

@end
