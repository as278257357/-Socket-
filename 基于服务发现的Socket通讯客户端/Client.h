//
//  Client.h
//  基于服务发现的Socket通讯客户端
//
//  Created by EaseMob on 16/5/7.
//  Copyright © 2016年 EaseMob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Client : NSObject<NSNetServiceDelegate>
{
    int port;
}
@property (nonatomic, strong)NSMutableArray *services;
@property (nonatomic, strong)NSNetService *service;



@end
