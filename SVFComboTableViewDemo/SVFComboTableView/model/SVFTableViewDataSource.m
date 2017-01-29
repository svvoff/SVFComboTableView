//
//  TableViewDataSource.m
//  SVFComboTableViewDemo
//
//  Created by Andrey Sorokin on 29/01/2017.
//  Copyright © 2017 _SVF_. All rights reserved.
//

#import "SVFTableViewDataSource.h"
#import "SVFComboTableViewCell.h"
#import "SVFComboTableViewConstants.h"

@implementation SVFTableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfSectionsForComboTableView:self.cTableView];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource cTableView:self.cTableView numberOfRowsInSection:section];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SVFComboTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SVFComboTableViewConstantsTableViewID forIndexPath:indexPath];
    
//    if ([self.delegate respondsToSelector:@selector(cTableView:colorForTableViewCellForIndexPath:)]) {
//        SVFCTIndexPath * index = [SVFCTIndexPath indexPathForRow:indexPath.row column:0 inSection:indexPath.section];
//        UIColor * cellColor = [self.delegate cTableView:self colorForTableViewCellForIndexPath:index];
//        cell.backgroundColor = cellColor;
//    }
    
    [self configureCollectionView:cell.collectionView forTargetView:cell.contentView forSection:indexPath.section];
    NSLog(@"%@", cell.contentView.subviews);
    
    return cell;
}

- (void) configureCollectionView:(UICollectionView *) collectionView forTargetView:(UIView *) targetView forSection:(NSInteger) section {

    [self configureCollectionView:collectionView];
    
    NSMutableArray * cvSectionArray = nil;
    if (section < _sectionsCvArray.count) {
        cvSectionArray = [_sectionsCvArray[section] mutableCopy];
    } else {
        cvSectionArray = [NSMutableArray new];
    }
    
    
//    for (UIView * item in targetView.subviews) {
//        if ([item isKindOfClass:[UICollectionView class]]) {
//            [item removeFromSuperview];
//            if ([cvSectionArray containsObject:item]) {
//                [cvSectionArray removeObject:item];
//            }
//        }
//    }
    
    [cvSectionArray addObject:collectionView];
    if (_sectionsCvArray.count == section) {
        [_sectionsCvArray insertObject:cvSectionArray atIndex:section];
    } else {
        [_sectionsCvArray replaceObjectAtIndex:section withObject:cvSectionArray];
    }
}

- (void) configureCollectionView:(UICollectionView *) collectionView {
    
    collectionView.dataSource = self.cTableView;
    collectionView.delegate = self.cTableView;
    
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [collectionView setContentOffset:_contentOffsetPoint animated:YES];
}

@end
