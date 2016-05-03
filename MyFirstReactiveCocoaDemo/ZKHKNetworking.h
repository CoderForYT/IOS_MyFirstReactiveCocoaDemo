//
//  ZKHKNetworking.h
//  ZKHKNetworking
//
//  Created by zkhk on 16/3/7.
//  Copyright © 2016年 zkhk. All rights reserved.
//  这是针对AFNworking 2.5的封装

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NSURLSessionTask ZKHKURLSessionTask;

// 服务器返回的类型
typedef NS_ENUM(NSUInteger, ZKHKResponseType) {
    kZKHKResponseTypeJSON = 1, // JSON ,默认
    kZKHKResponseTypeXML, //XML
    kZKHKResponseTypeData, // 特殊情况下，一转换服务器就无法识别的，默认会尝试转换成JSON，若失败则需要自己去转换
};

// 请求类型数据的类型
typedef NS_ENUM(NSUInteger, ZKHKRequestType) {
    kZKHKRequestTypeJSON = 1, // JSON ,默认
    kZKHKRequestTypePlainText = 2, //普通text/html
};


/**
 *  @author zkhk, 16-03-07 10:03:00
 *  进度
 *  @param bytesRead      已下载的文件大小
 *  @param totalBytesRead 文件总大小
 */
typedef void(^ZKHKProgress)(int16_t bytesRead, int64_t totalBytesRead);

typedef ZKHKProgress ZKHKGetProgress;
typedef ZKHKProgress ZKHKPostProgress;
typedef ZKHKProgress ZKHKDownloadProgress;
typedef ZKHKProgress ZKHKUploadProgress;


/**
 *  @author zkhk, 16-03-07 10:03:03
 *
 *  请求成功的回调
 *
 *  @param response 服务器返回的数据类型,通常是字典
 */
typedef void(^ZKHKResponseSuccess)(id response);
/**
 *  @author zkhk, 16-03-07 10:03:03
 *
 *  请求失败的回调
 *
 *  @param response 错误信息
 */
typedef void(^ZKHKResponseFail)(NSError *error);


@interface ZKHKNetworking : NSObject

/**
 *  @author zkhk, 16-03-07 10:03:14
 *
 *  用于指定和更新请求接口的Url
 *
 *  @param baseUrl 请求接口Url
 */
+ (void)updateBaseUrl:(NSString *)baseUrl;

/**
 *  @author zkhk, 16-03-07 10:03:06
 *
 *  用于获取当前所设置的接口基础url
 *
 *  @return 当前基础url
 */
+ (NSString *)baseUrl;

/*!
 *  @author zkhk, 16-03-07 10:03:06
 *
 *  配置返回格式，默认为JSON。若为XML或者PLIST请在全局修改一下
 *
 *  @param responseType 响应格式
 */
+ (void)configResponseType:(ZKHKResponseType)responseType;

/*!
 *  @author zkhk, 16-03-07 10:03:06
 *
 *  配置请求格式，默认为JSON。如果要求传XML或者PLIST，请在全局配置一下
 *
 *  @param requestType 请求格式
 */
+ (void)configRequestType:(ZKHKRequestType)requestType;


/*!
 *  @author zkhk, 16-03-07 10:03:06
 *
 *  开启或关闭是否自动将URL使用UTF8编码，用于处理链接中有中文时无法请求的问题
 *
 *  @param shouldAutoEncode YES or NO,默认为NO
 */
+ (void)shouldAutoEncodeUrl:(BOOL)shouldAutoEncode;

/**
 *  @author zkhk, 16-03-07 10:03:52
 *
 *  GET请求借口, 若不指定baseurl, 可传完整url
 *
 *  @param url     接口路径
 *  @param params  参数
 *  @param success 请求成功的回调
 *  @param fail    请求失败的回调
*  @param progress 进度
 *
 *  @return 返回一个Task
 */
+ (ZKHKURLSessionTask *)getWithUrl:(NSString *)url success:(ZKHKResponseSuccess)success fail:(ZKHKResponseFail)fail;

+ (ZKHKURLSessionTask *)getWithUrl:(NSString *)url params:(NSDictionary *)params success:(ZKHKResponseSuccess)success fail:(ZKHKResponseFail)fail;

+ (ZKHKURLSessionTask *)getWithUrl:(NSString *)url params:(NSDictionary *)params progress:(ZKHKGetProgress)progress success:(ZKHKResponseSuccess)success fail:(ZKHKResponseFail)fail;

/**
 *  @author zkhk, 16-03-07 10:03:52
 *
 *  POST请求借口, 若不指定baseurl, 可传完整url
 *
 *  @param url     接口路径
 *  @param params  参数
 *  @param success 请求成功的回调
 *  @param fail    请求失败的回调
 *
 *  @return 返回一个Task
 */
+ (ZKHKURLSessionTask *)postWithUrl:(NSString *)url params:(NSDictionary *)params success:(ZKHKResponseSuccess)success fail:(ZKHKResponseFail)fail;

+ (ZKHKURLSessionTask *)postWithUrl:(NSString *)url params:(NSDictionary *)params progress:(ZKHKPostProgress)progress success:(ZKHKResponseSuccess)success fail:(ZKHKResponseFail)fail;

/**
 *  @author zkhk, 16-03-07 10:03:44
 *
 *  上传图片的接口,若不指定baseurl, 可传完整url
 *
 *  @param image    图片对象
 *  @param url      接口路径
 *  @param name     与指定的图片相关联的名称，这是由后端写接口的人指定的
 *  @param filename 图片名字
 *  @param miniType 图片类型: 默认未image/jpeg
 *  @param params   参数
 *  @param progress 进度
 *  @param success  请求成功的回调
 *  @param fail     请求失败的回调
 *
 *  @return 返回一个Task
 */
+ (ZKHKURLSessionTask *)uploadWithImage:(UIImage *)image url:(NSString *)url name:(NSString *)name filename:(NSString *)filename mimeType:(NSString *)miniType parameters:(NSDictionary *)params progress:(ZKHKUploadProgress)progress success:(ZKHKResponseSuccess)success fail:(ZKHKResponseFail)fail;

/**
 *  @author zkhk, 16-03-07 10:03:41
 *
 *  上传文件接口
 *
 *  @param url           上传文件的接口, 若不指定baseurl, 可传完整url
 *  @param uploadingFile 等待上传的文件
 *  @param progress      上传的进度
 *  @param success       上传成功的回调
 *  @param fail          上传失败的回调
 *
 *  @return 上传任务的Task
 */
+ (ZKHKURLSessionTask *)uploadFileWithUrl:(NSString *)url uploadingFile:(NSString *)uploadingFile progress:(ZKHKUploadProgress)progress success:(ZKHKResponseSuccess)success fail:(ZKHKResponseFail)fail;

/*!
 *  @author zkhk, 16-03-07 10:03:41
 *
 *  下载文件
 *
 *  @param url           下载URL
 *  @param saveToPath    下载到哪个路径下
 *  @param progressBlock 下载进度
 *  @param success       下载成功后的回调
 *  @param failure       下载失败后的回调
 */
+ (ZKHKURLSessionTask *)downloadWithUrl:(NSString *)url saveToPath:(NSString *)saveToPath progress:(ZKHKUploadProgress)progressBlock success:(ZKHKResponseSuccess)success failure:(ZKHKResponseFail)failure;

@end
