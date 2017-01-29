//
//  SVFComboTableViewCell.m
//  SVFComboTableViewDemo
//
//  Created by Andrey Sorokin on 29/01/2017.
//  Copyright © 2017 _SVF_. All rights reserved.
//

#import "SVFComboTableViewCell.h"
#import "SVFComboTableViewConstants.h"


@implementation SVFComboTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:SVFComboTableViewConstantsCollectionViewID];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
