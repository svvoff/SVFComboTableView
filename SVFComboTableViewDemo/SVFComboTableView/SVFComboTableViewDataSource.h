//
//  SVFComboTableViewDataSource.h
//  SVFComboTableViewDemo
//
//  Created by Andrey Sorokin on 29/01/2017.
//  Copyright © 2017 _SVF_. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SVFCTIndexPath, SVFComboTableView;

@protocol SVFComboTableViewDataSource <NSObject>

@required
- (NSInteger) numberOfSectionsForComboTableView:(SVFComboTableView *) cTableView;
- (NSInteger) cTableView:(SVFComboTableView *) cTableView numberOfRowsInSection:(NSInteger) section;
- (NSInteger) cTableView:(SVFComboTableView *) cTableView numberOfColumnsInSection:(NSInteger) section;
- (UIView *) cTableView:(SVFComboTableView *) cTableView viewForItemAtIndexPath:(SVFCTIndexPath *) indexPath withCellFrame:(CGRect) cellFrame;
- (UIView *) cTableView:(SVFComboTableView *) cTabelView viewForItemInHeaderViewForIndexPath:(SVFCTIndexPath *) indexPath withCellFrame:(CGRect) cellFrame;

@optional
- (CGFloat) cTableView:(SVFComboTableView *) cTableView heightForRow:(NSInteger) row inSection:(NSInteger) section;
- (CGFloat) cTableView:(SVFComboTableView *) cTableView widthForColumnAtIndexPath:(SVFCTIndexPath *) indexPath;

@end
