#import "BookItem.h"

@implementation BookItem

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSString *identifier = dict[@"id"] ?: dict[@"identifier"];
        if (![identifier isKindOfClass:[NSString class]]) identifier = @"";
        _identifier = [identifier copy];

        NSString *title = dict[@"title"] ?: @"";
        if (![title isKindOfClass:[NSString class]]) title = @"";
        _title = [title copy];

        NSArray *authors = dict[@"authors"];
        if (![authors isKindOfClass:[NSArray class]]) {
            _authors = @[];
        } else {
            NSMutableArray *validAuthors = [NSMutableArray array];
            for (id a in authors) {
                if ([a isKindOfClass:[NSString class]]) [validAuthors addObject:a];
            }
            _authors = [validAuthors copy];
        }

        NSString *publishedDate = dict[@"publishedDate"];
        if (![publishedDate isKindOfClass:[NSString class]]) publishedDate = @"";
        _publishedDate = [publishedDate copy];

        NSString *infoLink = dict[@"infoLink"];
        if (![infoLink isKindOfClass:[NSString class]]) infoLink = @"";
        _infoLink = [infoLink copy];

        NSString *thumbnailStr = nil;
        NSDictionary *imageLinks = dict[@"imageLinks"];
        if ([imageLinks isKindOfClass:[NSDictionary class]]) {
            thumbnailStr = imageLinks[@"thumbnail"] ?: imageLinks[@"smallThumbnail"];
        }
        if (thumbnailStr && [thumbnailStr isKindOfClass:[NSString class]]) {
            _thumbnailURL = [NSURL URLWithString:thumbnailStr];
        } else {
            _thumbnailURL = nil;
        }
    }
    return self;
}

@end
