#import "APIClient.h"

@interface APIClient ()
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation APIClient

+ (instancetype)sharedClient {
    static APIClient *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] initPrivate];
    });
    return shared;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _baseURL = [NSURL URLWithString:@"https://www.googleapis.com/books/v1/"];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[APIClient sharedClient]" userInfo:nil];
    return nil;
}

- (void)getPath:(NSString *)path parameters:(NSDictionary<NSString*,NSString*> *)parameters completion:(APIClientCompletion)completion {
    // Build URL relative to baseURL
    NSURL *relative = [NSURL URLWithString:path relativeToURL:self.baseURL];
    NSURLComponents *components = [NSURLComponents componentsWithURL:relative resolvingAgainstBaseURL:YES];
    if (parameters.count > 0) {
        NSMutableArray<NSURLQueryItem *> *queryItems = [NSMutableArray array];
        [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:obj]];
        }];
        components.queryItems = queryItems;
    }
    NSURL *url = components.URL;
    if (!url) {
        if (completion) {
            NSError *err = [NSError errorWithDomain:@"APIClientErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid URL"}];
            dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, err); });
        }
        return;
    }

    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, error); });
            return;
        }
        if (!data) {
            if (completion) {
                NSError *err = [NSError errorWithDomain:@"APIClientErrorDomain" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"No data returned"}];
                dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, err); });
            }
            return;
        }
        NSError *jsonError;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, jsonError); });
            return;
        }
        if (![json isKindOfClass:[NSDictionary class]]) {
            if (completion) {
                NSError *err = [NSError errorWithDomain:@"APIClientErrorDomain" code:-3 userInfo:@{NSLocalizedDescriptionKey: @"Unexpected JSON format"}];
                dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, err); });
            }
            return;
        }
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion((NSDictionary *)json, nil); });
    }];
    [task resume];
}

@end
