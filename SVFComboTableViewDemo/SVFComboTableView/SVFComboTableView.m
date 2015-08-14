//
//  ComboTableView.m
//  bachmann crm mobile app bps2
//
//  Created by Andrey on 03/07/15.
//  Copyright (c) 2015 Kirill Pyulzyu. All rights reserved.
//

#import "SVFComboTableView.h"

@interface SVFComboTableView () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@end

static NSString * tableViewCellId = @"tableViewCellId";
static NSString * collectionViewCellId = @"collectionViewCellId";

@implementation SVFComboTableView {
    NSMutableArray * ___sectionsCvArray;
    UICollectionView * ____firstScrolled; // collection view witch reacting on touch
    CGPoint ___contentOffsetPoint;
    UITableView * ___tableView;
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self createTableViewWithFrame:frame];
    [self configureSourceData];
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self createTableViewWithFrame:self.frame];
    [self configureSourceData];
    return self;
}

- (void) createTableViewWithFrame:(CGRect) frame {
    ___tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    ___tableView.dataSource = self;
    ___tableView.delegate = self;
    ___tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:___tableView];
    [self configureTableView];
}

- (void) configureTableView {
    [___tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableViewCellId];
}

- (void) configureSourceData {
    ___sectionsCvArray = [NSMutableArray new];
    ___contentOffsetPoint = CGPointZero;
    self.comboTableViewSelectionType = SVFComboTableViewNonSelection;
}

#pragma mark - TableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.dataSource) {
        return [self.dataSource numberOfSectionsForComboTableView:self];
    } else {
        return 0;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource) {
        return [self.dataSource cTableView:self numberOfRowsInSection:section];
    } else {
        return 0;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellId forIndexPath:indexPath];
    
    [self configureCollectionViewForTargetView:cell forSection:indexPath.section];
    
    return cell;
}

#pragma mark - TableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat h = 44.f;
    if ([self.dataSource respondsToSelector:@selector(cTableView:heightForRow:inSection:)]) {
        
        h = [self.dataSource cTableView:self heightForRow:indexPath.row inSection:indexPath.section];
    }
    return h;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat h = 44.f;
    if ([self.delegate respondsToSelector:@selector(cTableView:heightForHeaderInSection:)]) {
        h = [self.delegate cTableView:self heightForHeaderInSection:section];
        return h;
    } else if (![self.delegate respondsToSelector:@selector(cTableView:viewForHeaderInSection:)]) {
        h = .01f;
        return h;
    }
    //UIView * headerView = [___tableView headerViewForSection:section];
    //[self configureCollectionViewForTargetView:headerView forSection:section];
    return h;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (![self.delegate respondsToSelector:@selector(cTableView:viewForHeaderInSection:)]) {
        return nil;
    } else {
        UIView * headerView = [self.delegate cTableView:self viewForHeaderInSection:section];
        [self configureCollectionViewForTargetView:headerView forSection:section];
        return headerView;
    }
}

#pragma mark - Configure

- (void) configureCollectionViewForTargetView:(UIView *) targetView forSection:(NSInteger) section {
    CGRect frameForCV = CGRectMake(0, 0, targetView.frame.size.width, targetView.frame.size.height);
    UICollectionView * cv = [self configureCollectionViewWithFrame:frameForCV];
    
    NSMutableArray * cvSectionArray = nil;
    if (section < ___sectionsCvArray.count) {
        cvSectionArray = [___sectionsCvArray[section] mutableCopy];
    } else {
        cvSectionArray = [NSMutableArray new];
    }
    
    
    for (UIView * item in targetView.subviews) {
        if ([item isKindOfClass:[UICollectionView class]]) {
            [item removeFromSuperview];
            if ([cvSectionArray containsObject:item]) {
                [cvSectionArray removeObject:item];
            }
        }
    }
    
    [cvSectionArray addObject:cv];
    if (___sectionsCvArray.count == section) {
        [___sectionsCvArray insertObject:cvSectionArray atIndex:section];
    } else {
        [___sectionsCvArray replaceObjectAtIndex:section withObject:cvSectionArray];
    }
    //
    [targetView addSubview:cv];
}

- (UICollectionView *) configureCollectionViewWithFrame:(CGRect) frame {
    UICollectionViewFlowLayout * layout = [self configureCollectionViewFlowLayoutWithFrame:frame];
    
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:collectionViewCellId];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [collectionView setContentOffset:___contentOffsetPoint animated:YES];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return collectionView;
}

- (UICollectionViewFlowLayout *) configureCollectionViewFlowLayoutWithFrame:(CGRect) frame {
    UICollectionViewFlowLayout * cvfl = [[UICollectionViewFlowLayout alloc] init];
    [cvfl setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [cvfl setItemSize:CGSizeMake(frame.size.width, frame.size.height)];
    cvfl.minimumInteritemSpacing = 0.f;
    cvfl.minimumLineSpacing = 0.f;
    return cvfl;
}

#pragma mark - ColletionViewDataSource

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource cTableView:self numberOfColumnsInSection:section];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellId forIndexPath:indexPath];
    
    /*if ([collectionView.superview isEqual:sectionHeaderView]) {
        [self clearSubviewsForView:cell forClass:[UIView class]];
        [self clearSubviewsForView:cell forClass:[UIImageView class]];
        NSString * title = dataDict[@"titles"][indexPath.row];
        NSString * alignStr = dataDict[@"aligns"][indexPath.row];
        NSTextAlignment align = NSTextAlignmentLeft;
        if (![alignStr isEqualToString:@"left"]) {
            align = NSTextAlignmentRight;
        }
        [self addLabelToView:cell withText:title isTitle:YES align:align];
    }*/
    
    UITableViewCell * tableCell = (UITableViewCell *) collectionView.superview;
    NSIndexPath * index = [self indexPathForTableViewCell:tableCell];
    CGRect cellFrame = cell.bounds;

    
    //UIView * header = [___tableView headerViewForSection:index.section];
    
    /*if (!index) {
        //NSLog(@"%@", tableCell.subviews);
        cell.backgroundColor = [UIColor redColor];
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = [UIColor blueColor];
        }
    }*/
    
    if (!index && [self.dataSource respondsToSelector:@selector(cTableView:viewForItemInHeaderViewForIndexPath:withCellFrame:)]) {
        NSInteger sectionNumber = [self sectionNumberForCollectionView:collectionView];
        SVFCTIndexPath * ctIndexPath = [SVFCTIndexPath indexPathForRow: - 1 column:indexPath.row inSection:sectionNumber];
        UIView * viewInCell = [self.dataSource cTableView:self viewForItemInHeaderViewForIndexPath:ctIndexPath withCellFrame:cellFrame];
        [self clearSubviewsForView:cell forClass:[viewInCell class]];
        if (viewInCell) {
            [cell addSubview:viewInCell];
        }
    }
    
    if ([collectionView.superview isKindOfClass:[UITableViewCell  class]]) {
        [self clearSubviewsForView:cell forClass:[UIView class]];
        
        if (index) {
            SVFCTIndexPath * ctIndexPath = [SVFCTIndexPath indexPathForRow:index.row column:indexPath.row inSection:index.section];
            UIView * viewInCell = [self.dataSource cTableView:self viewForItemAtIndexPath:ctIndexPath withCellFrame:cellFrame];
            //[self clearSubviewsForView:cell forClass:[viewInCell class]];
            if (viewInCell) {
                [cell addSubview:viewInCell];
            }
        }
    }    
    return cell;
}

- (NSIndexPath *) indexPathForCollectionView:(UICollectionView *) collectionView {
    UITableViewCell * tableCell = (UITableViewCell *) collectionView.superview;
    return [self indexPathForTableViewCell:tableCell];
}

- (NSIndexPath *) indexPathForTableViewCell:(UITableViewCell *) tableViewCell {
    if ([tableViewCell isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath * index = [___tableView indexPathForCell:tableViewCell];
        return index;
    } else {
        return nil;
    }
}

- (void) clearSubviewsForView:(UIView *) targetView forClass:(Class) class{
    for (UIView * item in targetView.subviews) {
        if ([item isKindOfClass:class]) {
            [item removeFromSuperview];
        }
    }
}

- (SVFCTIndexPath *) ctIndexPathForTableIndexPath:(NSIndexPath *) tableIP andCollectionIndexPath:(NSIndexPath *) collectionIP collectionView:(UICollectionView *) collectionView {
    if (tableIP && collectionIP) {
        SVFCTIndexPath * ctIndexPath = [SVFCTIndexPath indexPathForRow:tableIP.row column:collectionIP.row inSection:tableIP.section];
        return ctIndexPath;
    } else if (!tableIP && collectionIP) {
        NSInteger section = [self sectionNumberForCollectionView:collectionView];
        
        SVFCTIndexPath * ctIndexPath = [SVFCTIndexPath indexPathForRow:-1 column:collectionIP.row inSection:section];
        return ctIndexPath;
    } else {
        return nil;
    }
}

- (NSInteger) sectionNumberForCollectionView:(UICollectionView *) collectionView {
    NSInteger section = - 1;
    
    for (int i = 0; i < ___sectionsCvArray.count; ++i) {
        NSArray * sectionArray = ___sectionsCvArray[i];
        for (int j = 0; j < sectionArray.count; ++j) {
            UICollectionView * cv = sectionArray[j];
            if ([cv isEqual:collectionView]) {
                section = i;
                break;
            }
        }
        if (section != -1) {
            break;
        }
    }
    return section;
}

#pragma mark - CollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath * index = [self indexPathForCollectionView:collectionView];
    SVFCTIndexPath * ctIndexPath = [self ctIndexPathForTableIndexPath:index andCollectionIndexPath:indexPath collectionView:collectionView];
    switch (self.comboTableViewSelectionType) {
        case SVFComboTableViewNonSelection: {
            
        }
            break;
        case SVFComboTableViewItemSelection: {
            
        }
            break;
        case SVFComboTableViewRowSelection: {
            [___tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
            [___tableView deselectRowAtIndexPath:index animated:YES];
        }
            break;
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(cTableView:didSelectItemForIndexPath:)]) {
        [self.delegate cTableView:self didSelectItemForIndexPath:ctIndexPath];
    }
}

#pragma mark - CollectionViewDelegateFlowLayout

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat h = collectionView.frame.size.height;
    CGFloat w = 50.f;
    NSIndexPath * index = [self indexPathForCollectionView:collectionView];
    SVFCTIndexPath * ctIndexPath = [self ctIndexPathForTableIndexPath:index andCollectionIndexPath:indexPath collectionView:collectionView];
    if ([self.dataSource respondsToSelector:@selector(cTableView:widthForColumnAtIndexPath:)] && ctIndexPath) {
        w = [self.dataSource cTableView:self widthForColumnAtIndexPath:ctIndexPath];
    }
    
    return CGSizeMake(w, h);
}

#pragma mark - ScrollViewDelegate

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    ____firstScrolled = nil;
    //NSLog(@"scrollViewDidEndDecelerating");
    
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!____firstScrolled) {
        ____firstScrolled = (UICollectionView *) scrollView;
    }
    //NSLog(@"viewWillBeginDragging");
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    ____firstScrolled = nil;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        if (!____firstScrolled) {
            ____firstScrolled = (UICollectionView *) scrollView;
        }
        
        NSArray * selectedSection = [self getArrayForSelectedCollectionView:____firstScrolled];
        
        if ([scrollView isEqual:____firstScrolled]) {
            for (UICollectionView * item in selectedSection) {
                if (![item isEqual:____firstScrolled]) {
                    ___contentOffsetPoint = scrollView.contentOffset;
                    [item setContentOffset:___contentOffsetPoint animated:NO];
                }
            }
            ____firstScrolled = nil;
        }
    }
}

- (NSArray *) getArrayForSelectedCollectionView:(UICollectionView *) selectedCV {
    NSArray * selectedSection = nil;
    
    for (NSArray * section in ___sectionsCvArray) {
        for (UICollectionView * scrolledCV in section) {
            if ([scrolledCV isEqual:____firstScrolled]) {
                selectedSection = section;
                break;
            }
        }
        if (selectedSection) {
            break;
        }
    }
    
    return selectedSection;
}

- (void) setContentOffsetForScrollView:(UIScrollView *) scrollView {
    
    NSArray * arrayWithCV = [self getArrayForSelectedCollectionView:____firstScrolled];
    
    if ([scrollView isKindOfClass:[UICollectionView class]]) {
        
        for (UICollectionView * item in arrayWithCV) {
            if (![item isEqual:scrollView]) {
                [item setContentOffset:scrollView.contentOffset animated:NO];
                ___contentOffsetPoint = scrollView.contentOffset;
            }
        }
    }
}

#pragma mark - Properties

#pragma mark - Other

- (void) reloadData {
    [___tableView reloadData];
}

- (void) addSubview:(UIView *)view {
    if ([view isKindOfClass:[UIRefreshControl class]]) {
        [___tableView addSubview:view];
    } else {
        [super addSubview:view];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
