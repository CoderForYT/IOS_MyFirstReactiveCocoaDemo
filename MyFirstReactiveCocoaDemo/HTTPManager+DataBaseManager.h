//
//  HTTPManager.h
//  HuiKangEJia
//
//  Created by SghOmk on 16/1/27.
//  Copyright © 2016年 ZKHK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger ,HTTPManagerHTTPStatusCode) {
    HTTPStatusCodeSuccessed =0,//请求成功
    HTTPStatusCodeNoded =1,//没有数据
    HTTPStatusCodeInvalid =8,//用户被冻结
    HTTPStatusCodeSessionInvalid =9,//用户session失效
    HTTPStatusCodeError =-1//请求异常
};

typedef NS_ENUM(NSInteger ,HTTPManagerHTTPObtainStyle) {
    HTTPManagerHTTPObtainStyle_Bp =1,//获取血压
    HTTPManagerHTTPObtainStyle_Bs,//获取血糖
    HTTPManagerHTTPObtainStyle_3in1, //获取三合一
    HTTPManagerHTTPObtainStyle_Minihoter//获取迷你心电
};

typedef NS_ENUM(NSInteger ,HTTPManagerHTTPTimesStyle) {
    HTTPManagerHTTPTimesStyleDefault =0,//读取三十天内的数据
    HTTPManagerHTTPTimesStyleNear,//读取近期数据
    HTTPManagerHTTPTimesStyleWeekly, //近一周的数据
    HTTPManagerHTTPTimesStyleTen,//读取近十条的数据
    HTTPManagerHTTPTimesStyleFive//读取近5条的数据
};

@protocol HTTPManagerDelegate;

@interface HTTPManager : NSObject

@property (nonatomic,assign) id<HTTPManagerDelegate>delegate;

+(HTTPManager *)defaultManager;
/*
 获取数据都在此调用接口
 */
-(void)alternatelyWithServer:(NSString *)url ObtainStyle:(HTTPManagerHTTPObtainStyle)obtainStyle TimesStyle:(HTTPManagerHTTPTimesStyle)timesStyle SuccessedBlock:(void (^)(NSDictionary *obtainDictionary))sucBlock FailedBlock:(void (^)(HTTPManagerHTTPStatusCode code ,NSString *failMessage))failBlock ComplitionBlock:(void(^)(void))block;

-(void)alternatelyWithServer:(NSString *)url StartTime:(NSString *)startTime EndTime:(NSString *)endTime;
@end

@protocol HTTPManagerDelegate <NSObject>
/*
 这个代理传出的数据是需要写入数据库的
 */
@optional

-(void)activateRequestDataForDataBase:(NSMutableArray *)reqMutableArray;

@end

typedef  NS_ENUM(NSInteger, DataBaseSreachStyle){
    DataBaseSreachStyleDefault =0,//读取三十天内的数据
    DataBaseSreachStyleShort,//读取近期数据
    DataBaseSreachStyleWeek,//近一周的数据
    DataBaseSreachStyleTen,//读取近十条的数据
    DataBaseSreachStyleFive,//读取近5条的数据
};

typedef  NS_ENUM(int, DataBaseResultType){
    DataBaseResultTypeDefault =0,//全部,这种类型仅仅在读取数量的时候使用,现在暂时还没有使用到读取全部
    DataBaseResultTypeBP,//血压
    DataBaseResultTypeBS,//血糖
    DataBaseResultTypeTHREE,//三合一
    DataBaseResultTypeMINI,//迷你
};

@interface DataBaseManager : NSObject
/*单例控制数据库读取*/
+(DataBaseManager *)sharedManager;
/*创建数据表*/
-(void)createDBTable:(NSString *)aTableName;
/*删除数据表*/
-(void)clearDBTable:(NSString *)aTableName;
/*写入数据*/
-(int)writeDBTable:(NSString *)aTableName JSONStringArray:(NSMutableArray *)jsonStringArray;
/*读取数据内容,这里数组里面装的有可能是单种数据,也有可能是多种数据,根据不同的场合使用*/
-(NSMutableArray *)readDBTable:(NSString *)aTableName searchStyle:(DataBaseSreachStyle)style type:(DataBaseResultType)aType;
/*读取数据条数*/
-(int)countDBTable:(NSString *)aTableName type:(DataBaseResultType)aType isNormal:(BOOL)aIsNormal;
/*读取数据库中最大的时间*/
-(NSString *)maxTimeDBTable:(NSString *)aTableName;

@end

@interface DBObject : NSObject
/*用来初始化装在数据库里面的数据*/
@property (nonatomic,assign) DataBaseResultType type;//数据类型
@property (nonatomic,copy) id JSONString;//未解析的json数据
@property (nonatomic,copy) NSString *time;//测量时间
@property (nonatomic,assign) BOOL isNormal;//是否正常

+(DBObject *)object:(NSDictionary *)dic;
@end



