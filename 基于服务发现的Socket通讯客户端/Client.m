//
//  Client.m
//  基于服务发现的Socket通讯客户端
//
//  Created by EaseMob on 16/5/7.
//  Copyright © 2016年 EaseMob. All rights reserved.
//

#import "Client.h"

@implementation Client

- (id)init {
    _service = [[NSNetService alloc]initWithDomain:@"local." type:@"_tonyipp._tcp." name:@"tony"];
    [_service setDelegate:self];
    //设置解析地址超时时间
    [_service resolveWithTimeout:1];
    _services = [[NSMutableArray alloc]init];
    return self;
}

#pragma mark - NSNetServiceDelegate Methods
- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"netServiceDidResolveAddress");
    [_services addObject:sender];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    NSLog(@"didNotResolve%@",errorDict);
}



@end
