//
//  TimeLineCell.m
//  TwitterClient01
//
//  Created by g-2016 on 2015/01/18.
//  Copyright (c) 2015年 aki120121. All rights reserved.
//

#import "TimeLineCell.h"

@implementation TimeLineCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _tweetTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tweetTextLabel.font = [UIFont systemFontOfSize:14];
        _tweetTextLabel.textColor = [UIColor blackColor];
        _tweetTextLabel.numberOfLines = 0;
        [self.contentView addSubview:_tweetTextLabel];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _nameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_nameLabel];
        
        _profileImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_profileImageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.profileImageView.frame = CGRectMake(5,5,48,48);
    self.tweetTextLabel.frame = CGRectMake(58, 5, 256, self.tweetTextLabelHeight);
    self.nameLabel.frame = CGRectMake(58, self.tweetTextLabelHeight + 15, 257, 15);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
