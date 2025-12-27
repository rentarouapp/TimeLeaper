//
//  BookItem.h
//  TimeLeaper
//
//  Created by 上條蓮太朗 on 2025/12/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BookItem : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSArray<NSString *> *authors;
@property (nonatomic, copy, readonly) NSString *publishedDate;
@property (nonatomic, strong, readonly, nullable) NSURL *thumbnailURL;
@property (nonatomic, copy, readonly) NSString *infoLink;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
