//
//  APIClient.h
//  TimeLeaper
//
//  Created by 上條蓮太朗 on 2025/12/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const APIClientErrorDomain;

typedef NS_ENUM(NSInteger, APIClientErrorCode) {
    APIClientErrorCodeInvalidURL = -1,
    APIClientErrorCodeNoData = -2,
    APIClientErrorCodeUnexpectedFormat = -3,
    // HTTPステータスコードは直接使用（200-599）
};

typedef void (^APIClientCompletion)(NSDictionary * _Nullable json, NSError * _Nullable error);

@interface APIClient : NSObject

+ (instancetype)sharedClient;

- (void)getPath:(NSString *)path
      parameters:(nullable NSDictionary<NSString*, NSString*> *)parameters
      completion:(APIClientCompletion)completion;

@end

NS_ASSUME_NONNULL_END
