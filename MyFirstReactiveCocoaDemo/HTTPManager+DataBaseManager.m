//
//  HTTPManager.m
//  HuiKangEJia
//
//  Created by SghOmk on 16/1/27.
//  Copyright © 2016年 ZKHK. All rights reserved.
//

#import "HTTPManager+DataBaseManager.h"
#import "ASIFormDataRequest.h"
#import "FMDB.h"
#import "JSON.h"

static HTTPManager * manager=nil;

@interface HTTPManager()<ASIHTTPRequestDelegate>

@property (nonatomic,retain) NSMutableArray *activeMutableArray;
@property (nonatomic,assign) NSInteger activeCounts;

@end


@implementation HTTPManager

+(HTTPManager *)defaultManager{
    if (nil ==manager) {
        manager =[[HTTPManager alloc] init];
    }
    return manager;
}

-(NSMutableArray *)activeMutableArray{
    if (nil ==_activeMutableArray) {
        _activeMutableArray =[[NSMutableArray alloc] init];
    }
    return _activeMutableArray;
}

-(void)alternatelyWithServer:(NSString *)url ObtainStyle:(HTTPManagerHTTPObtainStyle)obtainStyle TimesStyle:(HTTPManagerHTTPTimesStyle)timesStyle SuccessedBlock:(void (^)(NSDictionary *))sucBlock FailedBlock:(void (^)(HTTPManagerHTTPStatusCode, NSString *))failBlock ComplitionBlock:(void (^)(void))block{
    ASIFormDataRequest *request =[ASIFormDataRequest requestWithURL:[self postUrl:url]];
    [request setTimeOutSeconds:15.f];
    [request setPostValue:[self paramsStrObtainStyle:obtainStyle TimesStyle:timesStyle] forKey:@"params"];
    [request startAsynchronous];
    [request setCompletionBlock:^{
        NSDictionary *_dataDic =[self parserJSONString:request.responseString];
        switch ([[_dataDic objectForKey:@"state"] integerValue]) {
            case HTTPStatusCodeSuccessed:{
                sucBlock(_dataDic);
                block();
            }
                break;
            case HTTPStatusCodeNoded:{
                failBlock(HTTPStatusCodeNoded,@"没有数据");
                block();
            }
                break;
            case HTTPStatusCodeInvalid:{
                failBlock(HTTPStatusCodeInvalid,@"用户被冻结");
                block();
            }
                break;
            case HTTPStatusCodeSessionInvalid:{
                failBlock(HTTPStatusCodeSessionInvalid,@"session失效");
                block();
            }
                break;
            default:
                failBlock(HTTPStatusCodeError,[_dataDic objectForKey:@"message"]);
                block();
                break;
        }
    }];
    [request setFailedBlock:^{
        failBlock(HTTPStatusCodeError,@"检查网络连接");
        block();
    }];
}

-(NSURL *)postUrl:(NSString *)url{
//    NSString *urlStr =[NSString stringWithFormat:@"%@%@",HostName,url];
    NSString *urlStr =[NSString stringWithFormat:@"%@%@",@"http://192.168.10.69:8080/MiddleWare",url];
    return [NSURL URLWithString:urlStr];
}

-(NSString *)paramsStrObtainStyle:(HTTPManagerHTTPObtainStyle)obtainStyle TimesStyle:(HTTPManagerHTTPTimesStyle)timesStyle{
    NSDictionary *pramDic =[self pramDic:obtainStyle TimesStyle:timesStyle];
    NSDictionary *pramsDic =@{
                              @"memberId" :MEMBERID,/*这里需要会员Id*/
                              @"session" :SESSION,
                              @"param":pramDic,
                              @"version" :@"v1.0",
                              @"loginLog" :[self before:0]
                                                    };
    SBJsonWriter *dubWriter =[[SBJsonWriter alloc] init];
    NSString *paramsStr =[dubWriter stringWithObject:pramsDic];
    [dubWriter release];
    return paramsStr;
}

-(NSDictionary *)pramDic:(HTTPManagerHTTPObtainStyle)obtainStyle TimesStyle:(HTTPManagerHTTPTimesStyle)timesStyle{
    switch (timesStyle) {
        case HTTPManagerHTTPTimesStyleDefault:
            return @{
                     @"memberId":MEMBERID,/*这里需要会员Id*/
                     @"dataType":[NSString stringWithFormat:@"%ld",(long)obtainStyle],
                     @"timeStart":[self monthBefore],
                     @"timeEnd":[self before:0],
                     @"count":@100
                                    };
            break;
            
        case HTTPManagerHTTPTimesStyleNear:
            return @{
                     @"memberId":MEMBERID,/*这里需要会员Id*/
                     @"dataType":[NSString stringWithFormat:@"%ld",(long)obtainStyle],
                     @"timeStart":[self shortBefore],
                     @"timeEnd":[self before:0],
                     @"count":@100
                     };
            break;
            
        case HTTPManagerHTTPTimesStyleWeekly:
            return @{
                     @"memberId":MEMBERID,/*这里需要会员Id*/
                     @"dataType":[NSString stringWithFormat:@"%ld",(long)obtainStyle],
                     @"timeStart":[self weekBefore],
                     @"timeEnd":[self before:0],
                     @"count":@100
                     };
            break;
            
        case HTTPManagerHTTPTimesStyleTen:
            return @{
                     @"memberId":MEMBERID,/*这里需要会员Id*/
                     @"dataType":[NSString stringWithFormat:@"%ld",(long)obtainStyle],
                     @"timeStart":[self monthBefore],
                     @"timeEnd":[self before:0],
                     @"count":@100
                     };
            break;
            
        case HTTPManagerHTTPTimesStyleFive:
            return @{
                     @"memberId":MEMBERID,/*这里需要会员Id*/
                     @"dataType":[NSString stringWithFormat:@"%ld",(long)obtainStyle],
                     @"timeStart":[self monthBefore],
                     @"timeEnd":[self before:0],
                     @"count":@100
                     };
            break;
    }
}
#pragma mark- 这里的方法是是做数据同步的方法
-(void)alternatelyWithServer:(NSString *)url StartTime:(NSString *)startTime EndTime:(NSString *)endTime{
    [self obtainBloodPluse:startTime EndTime:endTime WithUrl:url];
    [self obtainBloodPluse:startTime EndTime:endTime WithUrl:url];
    [self obtainMini:startTime EndTime:endTime WithUrl:url];
    [self obtainThree:startTime EndTime:endTime WithUrl:url];
}
-(NSString *)paramString:(NSString *)startTime EndTime:(NSString *)endTime dataType:(NSString *)dataType{
    NSDictionary *params =@{@"memberId" :MEMBERID,/*这里需要会员Id*/
                            @"session" :SESSION,
                            @"param":@{@"memberId":MEMBERID,/*这里需要会员Id*/
                                       @"dataType":dataType,
                                       @"timeStart":startTime,
                                       @"timeEnd":endTime,
                                       @"count":@100},
                            @"version" :@"v1.0" ,
                            @"loginLog" :endTime};
    SBJsonWriter *dubWriter =[[SBJsonWriter alloc] init];
    NSString *paramsStr =[dubWriter stringWithObject:params];
    [dubWriter release];
    return paramsStr;
}
#pragma mark- 以下这四个方法是读取登录,程序拉起,以及有访问网络数据的时候调用的
-(void)obtainBloodPluse:(NSString *)startTime EndTime:(NSString *)endTime WithUrl:(NSString *)url{
    ASIFormDataRequest *requestBP =[ASIFormDataRequest requestWithURL:[self postUrl:url]];
    [requestBP setTimeOutSeconds:15.f];
    [requestBP setPostValue:[self paramString:startTime EndTime:endTime dataType:@"1"] forKey:@"params"];
    [requestBP setDelegate:self];
    [requestBP startAsynchronous];
}
-(void)obtainBloodSugar:(NSString *)startTime EndTime:(NSString *)endTime WithUrl:(NSString *)url{
    ASIFormDataRequest *requestBS =[ASIFormDataRequest requestWithURL:[self postUrl:url]];
    [requestBS setTimeOutSeconds:15.f];
    [requestBS setPostValue:[self paramString:startTime EndTime:endTime dataType:@"2"] forKey:@"params"];
    [requestBS setDelegate:self];
    [requestBS startAsynchronous];
}
-(void)obtainThree:(NSString *)startTime EndTime:(NSString *)endTime WithUrl:(NSString *)url{
    ASIFormDataRequest *requestThree =[ASIFormDataRequest requestWithURL:[self postUrl:url]];
    [requestThree setTimeOutSeconds:15.f];
    [requestThree setPostValue:[self paramString:startTime EndTime:endTime dataType:@"3"] forKey:@"params"];
    [requestThree setDelegate:self];
    [requestThree startAsynchronous];
}
-(void)obtainMini:(NSString *)startTime EndTime:(NSString *)endTime WithUrl:(NSString *)url{
    ASIFormDataRequest *requestMini =[ASIFormDataRequest requestWithURL:[self postUrl:url]];
    [requestMini setTimeOutSeconds:15.f];
    [requestMini setPostValue:[self paramString:startTime EndTime:endTime dataType:@"4"] forKey:@"params"];
    [requestMini setDelegate:self];
    [requestMini startAsynchronous];
}

-(void)requestFinished:(ASIHTTPRequest *)request{
    NSDictionary *_dataDic =[self parserJSONString:request.responseString];
    _activeCounts ++;
    if (HTTPStatusCodeSuccessed ==[[_dataDic objectForKey:@"state"] intValue]) {
        NSArray *contentArray =[_dataDic objectForKey:@"content"];
        for (NSDictionary *dic in contentArray) {
            [self.activeMutableArray addObject:[DBObject object:dic]];
        }
    }
    if (4 ==_activeCounts) {
        if (_delegate &&[_delegate respondsToSelector:@selector(activateRequestDataForDataBase:)]) {
            [_delegate activateRequestDataForDataBase:[NSMutableArray arrayWithArray:self.activeMutableArray]];
            [self.activeMutableArray removeAllObjects];
            _activeCounts =0;
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    _activeCounts ++;
    if (4 ==_activeCounts) {
        if (_delegate &&[_delegate respondsToSelector:@selector(activateRequestDataForDataBase:)]) {
            [_delegate activateRequestDataForDataBase:[NSMutableArray arrayWithArray:self.activeMutableArray]];
            [self.activeMutableArray removeAllObjects];
            _activeCounts =0;
        }
    }
}

#pragma mark- 这个函数是解析数据的方法
-(NSDictionary *)parserJSONString:(NSString *)responseString{
    SBJsonParser *json =[[SBJsonParser alloc] init];
    NSDictionary *_dataDic =[json objectWithString:responseString];
    [json release];
    return _dataDic;
}

#pragma mark- 这里是一些网络操作需要的时间函数
-(NSString *)monthBefore{
    return [self before:-30 *24 *60 *60];
}

-(NSString *)shortBefore{
    return [self before:-3 *24 *60 *60];
}

-(NSString *)weekBefore{
    return [self before:-7 *24 *60 *60];
}

-(NSString *)before:(NSTimeInterval)sec{
    NSDate *date =[NSDate dateWithTimeIntervalSinceNow:sec];
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];;
    NSString *dateString =[formatter stringFromDate:date];
    [formatter release];
    return dateString;
}

@end

static DataBaseManager *_manager =nil;

@interface DataBaseManager ()

@property (nonatomic,retain) FMDatabaseQueue *db_queue;

@end

@implementation DataBaseManager

-(void)dealloc{
    [_db_queue release];
    [super dealloc];
}

+(DataBaseManager *)sharedManager{
    if (!_manager) {
        _manager =[[DataBaseManager alloc] init];
    }
    return _manager;
}

-(id)init{
    self =[super init];
    if (self) {
        [self copyDBForPath];
        [self createDBQueue];
    }
    return self;
}

//判断是否已经将数据库拷贝到磁盘
-(void)copyDBForPath{
    //获取资源束中的文件
    NSString *sourcePath =[[NSBundle mainBundle] pathForResource:@"database" ofType:@"sqlite"];
    //获取document路径
    NSString *docPath =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    //拼接dbPath
    NSString *dbPath =[docPath stringByAppendingPathComponent:@"fileCache/dbCache"];
    //数据库最终的path
    NSString *path =[dbPath stringByAppendingPathComponent:@"newdatabase.sqlite"];
    //判断路径是否存在
    NSError *error =nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]){
        if ([[NSFileManager defaultManager] createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:&error]){
            [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:path error:&error];
        }
    }else{
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
            [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:path error:&error];
        }
    }
}

//创建数据库操作线程
-(void)createDBQueue{
    NSString *docPath =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    //拼接dbPath
    NSString *dbPath =[docPath stringByAppendingPathComponent:@"fileCache/dbCache"];
    //数据库最终的path
    NSString *path =[dbPath stringByAppendingPathComponent:@"newdatabase.sqlite"];
    self.db_queue =[FMDatabaseQueue databaseQueueWithPath:path];
}
#pragma mark- 创建数据表,里面存储的是Json数据,四种数据类型均存储在一张表里面,根据表里面的Type区分属于哪种数据 1:BS 2:BP 3:THREE 4:MINI
-(void)createDBTable:(NSString *)aTableName{
    [self createTable:aTableName];
}
-(void)createTable:(NSString *)tableName{
    [self.db_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@_JSONString' (id INTEGER primary key autoincrement, type INTEGER, JSONString VARCHAR(4096) UNIQUE, time DATE, isNormal INTEGER)",tableName]];
    }];
}
#pragma mark- 删除数据库里面的一个月之前的数据
-(void)clearDBTable:(NSString *)aTableName{
    [self clearTable:aTableName];
}

-(void)clearTable:(NSString *)aTableName{
    [self.db_queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM '%@_JSONString' WHERE time <%@",aTableName,[self monthBefore]]];
    }];
}
#pragma mark- 写入Json数据到数据表
-(int)writeDBTable:(NSString *)aTableName JSONStringArray:(NSMutableArray *)jsonStringArray{
    return [self writeTableName:aTableName JSONStringArray:jsonStringArray];
}

-(int)writeTableName:(NSString *)aName JSONStringArray:(NSMutableArray *)jsonStringArray{
    __block int changes =0;
    [self.db_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (int i =0; i <[jsonStringArray count]; i ++) {
            DBObject *obj =[jsonStringArray objectAtIndex:i];
            BOOL isSuccess =[db executeUpdate:[NSString stringWithFormat:@"INSERT OR IGNORE INTO '%@_JSONString' (type,JSONString,time,isNormal) VALUES(?,?,?,?)",aName],[NSNumber numberWithInt:obj.type],obj.JSONString,obj.time,[NSNumber numberWithBool:obj.isNormal]];
            changes +=isSuccess;
        }
    }];
    int _changes =changes;
    return _changes;
}
#pragma mark- 读取数据库中的数据
-(NSMutableArray *)readDBTable:(NSString *)aTableName searchStyle:(DataBaseSreachStyle)style type:(DataBaseResultType)aType{
    return [self readTableName:aTableName searchStyle:style type:aType];
}

-(NSMutableArray *)readTableName:(NSString *)aTableName searchStyle:(DataBaseSreachStyle)style type:(DataBaseResultType)aType{
    __block NSMutableArray *JSONStringArray =[[NSMutableArray alloc] init];
    [self.db_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *JSONResultSet =[db executeQuery:[self tableName:aTableName sql:style type:aType]];
        switch (style) {
            case DataBaseSreachStyleShort:{
                while ([JSONResultSet next]) {
                    DBObject *obj =[[DBObject alloc] init];
                    obj.type =[JSONResultSet intForColumn:@"type"];
                    obj.JSONString =[JSONResultSet stringForColumn:@"JSONString"];
                    obj.time =[JSONResultSet stringForColumn:@"time"];
                    obj.isNormal =[JSONResultSet intForColumn:@"isNormal"];
                    [JSONStringArray addObject:obj];
                    [obj release];
                }
            }
                break;
            default:
                while ([JSONResultSet next]) {
                    [JSONStringArray addObject:[JSONResultSet stringForColumn:@"JSONString"]];
                }
                break;
        }
        [JSONResultSet close];
    }];
    return [NSMutableArray arrayWithArray:[JSONStringArray autorelease]];
}

-(NSString *)tableName:(NSString *)aName sql:(DataBaseSreachStyle)style type:(DataBaseResultType)aType{
    switch (style) {
        case DataBaseSreachStyleDefault:
            return [NSString stringWithFormat:@"SELECT JSONString FROM '%@_JSONString' WHERE time >%@ AND type =%d",aName,[self monthBefore],aType];
            break;
        case DataBaseSreachStyleShort:
            return [NSString stringWithFormat:@"SELECT type,JSONString,isNormal,time FROM '%@_JSONString' WHERE time >%@",aName,[self shortBefore]];
            break;
        case DataBaseSreachStyleWeek:
            return [NSString stringWithFormat:@"SELECT JSONString FROM '%@_JSONString' WHERE time >%@ AND type =%d",aName,[self weekBefore],aType];
            break;
        case DataBaseSreachStyleTen:
            return [NSString stringWithFormat:@"SELECT JSONString FROM '%@_JSONString' WHERE type =%d ORDER BY time DESC LIMIT 0,10",aName,aType];
            break;
        case DataBaseSreachStyleFive:
            return [NSString stringWithFormat:@"SELECT JSONString FROM '%@_JSONString' WHERE type =%d ORDER BY time DESC LIMIT 0,5",aName,aType];
            break;
        default:
            return nil;
            break;
    }
}
#pragma mark- 读取数据库中的数据数量
-(int)countDBTable:(NSString *)aTableName type:(DataBaseResultType)aType isNormal:(BOOL)aIsNormal{
    return [self countTableName:aTableName type:aType isNormal:aIsNormal];
}

-(int)countTableName:(NSString *)aTableName type:(DataBaseResultType)aType isNormal:(BOOL)aIsNormal{
    __block int count =0;
    [self.db_queue inDatabase:^(FMDatabase *db) {
        count =[db intForQuery:[self tableName:aTableName sql:aType isNormal:aIsNormal]];
    }];
    int _count =count;
    return _count;
}

-(NSString *)tableName:(NSString *)aName sql:(DataBaseResultType)aType isNormal:(BOOL)aIsNormal{
    switch (aType) {
        case DataBaseResultTypeDefault:
            return [NSString stringWithFormat:@"SELECT COUNT(1) FROM '%@_JSONString' WHERE isNormal =%d AND time >%@",aName,aIsNormal,[self monthBefore]];
            break;
        default:
            return [NSString stringWithFormat:@"SELECT COUNT(1) FROM '%@_JSONString' WHERE isNormal =%d AND type =%d AND time >%@",aName,aIsNormal,aType,[self monthBefore]];
            break;
    }
}
#pragma mark- 这里获取这张表里面最大的时间
-(NSString *)maxTimeDBTable:(NSString *)aTableName{
    NSString *maxTime =[self maxTimeTable:aTableName];
    if (maxTime) {
        return maxTime;
    }else{
        return [self monthBefore];
    }
}

-(NSString *)maxTimeTable:(NSString *)aTableName{
    __block NSString *maxTime =nil;
    [self.db_queue inDatabase:^(FMDatabase *db) {
        FMResultSet *MaxTimeSet =[db executeQuery:[self tableName:aTableName]];
        while ([MaxTimeSet next]) {
            maxTime =[MaxTimeSet stringForColumn:@"max(time)"];
        }
        [MaxTimeSet close];
    }];
    NSString *_maxTime =maxTime;
    return _maxTime;
}

-(NSString *)tableName:(NSString *)aName{
    return [NSString stringWithFormat:@"SELECT MAX(time) FROM '%@_JSONString'",aName];
}
#pragma mark- 这里是一些数据库操作需要的时间函数
-(NSString *)monthBefore{
    return [self before:-30 *24 *60 *60];
}

-(NSString *)shortBefore{
    return [self before:-3 *24 *60 *60];
}

-(NSString *)weekBefore{
    return [self before:-7 *24 *60 *60];
}

-(NSString *)before:(NSTimeInterval)sec{
    NSDate *date =[NSDate dateWithTimeIntervalSinceNow:sec];
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];;
    NSString *dateString =[formatter stringFromDate:date];
    [formatter release];
    return dateString;
}
@end

@implementation DBObject

-(void)dealloc{
    [_JSONString release];
    [_time release];
    
    [super dealloc];
}

-(void)setJSONString:(id)JSONString{
    /*在这里将Json转换成可以存到数据库的String,或者是讲string转换成可以解析的json*/
    if (JSONString) {
        if ([JSONString isKindOfClass:[NSDictionary class]]) {
            SBJsonWriter *jsonWriter =[[SBJsonWriter alloc] init];
            _JSONString =[[jsonWriter stringWithObject:JSONString] copy];
            [jsonWriter release];
        }else if ([JSONString isKindOfClass:[NSString class]]){
            SBJsonParser *jsonParser =[[SBJsonParser alloc] init];
            _JSONString =[[jsonParser objectWithString:JSONString] retain];
            [jsonParser release];
        }
    }
}
/*在这里初始化网络测量数据*/
+(DBObject *)object:(NSDictionary *)dic{
    DBObject *obj =[[DBObject alloc] init];
    obj.type =[[dic objectForKey:@"dataType"] intValue];
    obj.JSONString =[dic objectForKey:@"data"];
    obj.isNormal =[[dic objectForKey:@"isAbnormal"] boolValue];
    obj.time =[dic objectForKey:@"measureTime"];
    return [obj autorelease];
}

@end
