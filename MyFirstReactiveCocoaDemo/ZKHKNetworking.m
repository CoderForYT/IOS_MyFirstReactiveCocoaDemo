//
//  ZKHKNetworking.m
//  ZKHKNetworking
//
//  Created by zkhk on 16/3/7.
//  Copyright © 2016年 zkhk. All rights reserved.
//

#import "ZKHKNetworking.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

// 项目打包上线都不会打印日志，因此可放心。
#ifdef DEBUG
#define ZKHKNetworkLog(s, ... ) NSLog( @"[%@：in line: %d]-->%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define HYBAppLog(s, ... )
#endif

static NSString *sg_privateNetworkBaseUrl = nil;
static ZKHKResponseType sg_responseType = kZKHKResponseTypeJSON;
static ZKHKRequestType sg_requestType = kZKHKRequestTypeJSON;
static BOOL sg_shouldAutoEncode = NO;

@implementation ZKHKNetworking

#pragma mark - 参数设置

+ (void)updateBaseUrl:(NSString *)baseUrl {
    sg_privateNetworkBaseUrl = baseUrl;
}

+ (NSString *)baseUrl {
    return sg_privateNetworkBaseUrl;
}

+ (void)configRequestType:(ZKHKRequestType)requestType {
    sg_requestType = requestType;
}

+ (void)configResponseType:(ZKHKResponseType)responseType {
    sg_responseType = responseType;
}

+ (void)shouldAutoEncodeUrl:(BOOL)shouldAutoEncode {
    sg_shouldAutoEncode = shouldAutoEncode;
}

+ (BOOL)shouldEncodeUrl {
    return sg_shouldAutoEncode;
}

// 返回一个设置好的manager
+ (AFHTTPSessionManager *)manager {
    
    // 开启转圈圈
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPSessionManager *manager = nil;
    if ([self baseUrl] != nil) {
        manager = [[AFHTTPSessionManager manager] initWithBaseURL:[NSURL URLWithString:[self baseUrl]]];
    } else {
        manager = [AFHTTPSessionManager manager];
    }
    
    // 设置请求序列器
    switch (sg_requestType) {
        case kZKHKRequestTypeJSON: {
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"accept"];
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
        }
        case kZKHKRequestTypePlainText: {
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        }
            
        default:
            break;
    }
    // 设置响应序列器
    switch (sg_responseType) {
        case kZKHKResponseTypeJSON: {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
        case kZKHKResponseTypeXML: {
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        }
        case kZKHKResponseTypeData: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        default:
            break;
    }
    // 设置请求编码格式
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    // 设置响应格式
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",@"text/html",@"text/json",@"text/plain",@"text/javascript",@"text/xml",@"image/*"]];
    // 设置请求最大并发数
    manager.operationQueue.maxConcurrentOperationCount = 3;
    return manager;
}


#pragma mark - Get发送请求

+ (ZKHKURLSessionTask *)getWithUrl:(NSString *)url success:(ZKHKResponseSuccess)success fail:(ZKHKResponseFail)fail {
    return [self getWithUrl:url params:nil progress:nil success:success fail:fail];
}

+ (ZKHKURLSessionTask *)getWithUrl:(NSString *)url params:(NSDictionary *)params success:(ZKHKResponseSuccess)success fail:(ZKHKResponseFail)fail
{
    return [self getWithUrl:url params:params progress:nil success:success fail:fail];
}

+ (ZKHKURLSessionTask *)getWithUrl:(NSString *)url params:(NSDictionary *)params progress:(ZKHKGetProgress)progress success:(ZKHKResponseSuccess)success fail:(ZKHKResponseFail)fail
{
    url = [self handleUrl:url];
    
    NSURLSessionTask *task = [[self manager] GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
    return task;
}

#pragma mark - Post发送请求
+ (ZKHKURLSessionTask *)postWithUrl:(NSString *)url params:(NSDictionary *)params success:(ZKHKResponseSuccess)success fail:(ZKHKResponseFail)fail {
   return [self postWithUrl:url params:params progress:nil success:success fail:fail];
}

+ (ZKHKURLSessionTask *)postWithUrl:(NSString *)url params:(NSDictionary *)params progress:(ZKHKPostProgress)progress success:(ZKHKResponseSuccess)success fail:(ZKHKResponseFail)fail {
    
     url = [self handleUrl:url];
    if (url == nil) {
        return nil;
    }
    
    NSURLSessionTask *task = [[self manager] POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
    
    return task;
}

#pragma mark - download 

+ (ZKHKURLSessionTask *)downloadWithUrl:(NSString *)url saveToPath:(NSString *)saveToPath progress:(ZKHKUploadProgress)progressBlock success:(ZKHKResponseSuccess)success failure:(ZKHKResponseFail)failure {
    
    url = [self handleUrl:url];
    if (url == nil) {
        return nil;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    ZKHKURLSessionTask *task = [[self manager] downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        // 返回保存的目标路径
        return [NSURL URLWithString:saveToPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        success(response);
    }];
    return task;
}

#pragma mark - upload

+ (ZKHKURLSessionTask *)uploadWithImage:(UIImage *)image url:(NSString *)url name:(NSString *)name filename:(NSString *)filename mimeType:(NSString *)miniType parameters:(NSDictionary *)params progress:(ZKHKUploadProgress)progress success:(ZKHKResponseSuccess)success fail:(ZKHKResponseFail)fail {
    
    url = [self handleUrl:url];
    if (url == nil) {
        return nil;
    }
    
    ZKHKURLSessionTask *task = [[self manager]POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        
        NSString *imageFileName = filename;
        if (filename == nil || ![filename isKindOfClass:[NSString class]] || filename.length == 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            imageFileName = [NSString stringWithFormat:@"%@.jpg", str];
        }
        [formData appendPartWithFileData:imageData name:name fileName:filename mimeType:miniType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
    return task;
}

+ (ZKHKURLSessionTask *)uploadFileWithUrl:(NSString *)url uploadingFile:(NSString *)uploadingFile progress:(ZKHKUploadProgress)progress success:(ZKHKResponseSuccess)success fail:(ZKHKResponseFail)fail {
    
    
    
    NSURL *uploadingFileurl = [NSURL URLWithString:uploadingFile];
    
    if (uploadingFileurl == nil) {
        ZKHKNetworkLog(@"uploadingFile无效，无法生成URL。请检查待上传文件是否存在");
        return nil;
    }
    url = [self handleUrl:url];
    if (url == nil) {
        return nil;
    }
    
    NSURL *uploadUrl = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:uploadUrl];
    ZKHKURLSessionTask *task = [[self manager] uploadTaskWithRequest:request fromFile:uploadingFileurl progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress) {
            if (progress) {
                progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
            }
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            fail(error);
        } else {
            success(responseObject);
        }
    }];
    return task;
}

#pragma mark - 其他

+ (NSString *)handleUrl:(NSString *)url {
    
    NSString *finalUrl = url;
    if (![self checkUrl:url]) {
        return nil;
    }
    if ([self baseUrl]) {
        finalUrl = [NSString stringWithFormat:@"%@%@", [self baseUrl], url];
    }
    if ([self shouldEncodeUrl]) {
        finalUrl = [self encodeUrl:url];
    }
    return finalUrl;
}

+ (BOOL)checkUrl:(NSString *)url {
    
    if ([self baseUrl] == nil) {
        if ([NSURL URLWithString:url] == nil) {
            ZKHKNetworkLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return NO;
        }
    } else {
        if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self baseUrl], url]] == nil) {
            ZKHKNetworkLog(@"URLString无效，无法生成URL。可能是URL中有中文，请尝试Encode URL");
            return NO;
        }
    }
    return YES;
}

// 对字符串进行编码
+ (NSString *)encodeUrl:(NSString *)url {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"];
    return [url stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
}

@end
