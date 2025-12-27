#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^APIClientCompletion)(NSDictionary * _Nullable json, NSError * _Nullable error);

@interface APIClient : NSObject

+ (instancetype)sharedClient;

- (void)getPath:(NSString *)path
      parameters:(nullable NSDictionary<NSString*, NSString*> *)parameters
      completion:(APIClientCompletion)completion;

@end

NS_ASSUME_NONNULL_END
