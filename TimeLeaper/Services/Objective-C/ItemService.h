//
//  ItemService.h
//  TimeLeaper
//
//  Created by 上條蓮太朗 on 2025/12/27.
//

#import <Foundation/Foundation.h>
#import "BookItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ItemServiceCompletion)(NSArray<BookItem *> * _Nullable items, NSError * _Nullable error);

@interface ItemService : NSObject

+ (instancetype)sharedService;

- (void)searchBooksForQuery:(NSString *)query
                  maxResults:(NSInteger)maxResults
                  completion:(ItemServiceCompletion)completion;

@end

NS_ASSUME_NONNULL_END
