#import "ItemService.h"
#import "APIClient.h"

@implementation ItemService

+ (instancetype)sharedService {
    static ItemService *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)searchBooksForQuery:(NSString *)query maxResults:(NSInteger)maxResults completion:(ItemServiceCompletion)completion {
    if (query.length == 0) {
        if (completion) {
            NSError *err = [NSError errorWithDomain:@"ItemServiceErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Query must not be empty"}];
            dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, err); });
        }
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"q"] = query;
    if (maxResults > 0) params[@"maxResults"] = [NSString stringWithFormat:@"%ld", (long)maxResults];

    [[APIClient sharedClient] getPath:@"volumes" parameters:params completion:^(NSDictionary * _Nullable json, NSError * _Nullable error) {
        if (error) {
            if (completion) completion(nil, error);
            return;
        }
        NSArray *items = json[@"items"];
        if (![items isKindOfClass:[NSArray class]]) {
            if (completion) {
                NSError *err = [NSError errorWithDomain:@"ItemServiceErrorDomain" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"No items in response"}];
                completion(nil, err);
            }
            return;
        }
        NSMutableArray<BookItem *> *results = [NSMutableArray arrayWithCapacity:items.count];
        for (NSDictionary *item in items) {
            if (![item isKindOfClass:[NSDictionary class]]) continue;
            NSDictionary *volumeInfo = item[@"volumeInfo"];
            NSMutableDictionary *combined = [NSMutableDictionary dictionaryWithDictionary:volumeInfo ?: @{}];
            // include id at top level for BookItem
            if (item[@"id"]) combined[@"id"] = item[@"id"];
            BookItem *bi = [[BookItem alloc] initWithDictionary:combined];
            if (bi) [results addObject:bi];
        }
        if (completion) completion([results copy], nil);
    }];
}

@end
