//
//  ViewController.m
//  基于服务发现的Socket通讯客户端
//
//  Created by EaseMob on 16/5/7.
//  Copyright © 2016年 EaseMob. All rights reserved.
//

#import "ViewController.h"
#import "Client.h"

@interface ViewController ()<NSStreamDelegate>
{
    int flag; // 操作标志 0 发送 1为接收
}
@property (nonatomic, retain)NSInputStream *inputStream;
@property (nonatomic, retain)NSOutputStream *outputStream;

@property (nonatomic, retain)Client *myClient;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton addTarget:self action:@selector(sendData:) forControlEvents:UIControlEventTouchUpInside];
    sendButton.backgroundColor = [UIColor redColor];
    sendButton.frame = CGRectMake(100, 100, 250, 50);
    [self.view addSubview:sendButton];
    
    UIButton *receiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    receiveButton.frame = CGRectMake(100, 300, 250, 50);
    receiveButton.backgroundColor = [UIColor blueColor];
    [receiveButton addTarget:self action:@selector(receiveData:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:receiveButton];
    // Do any additional setup after loading the view, typically from a nib.
}

//基于服务实现的客户端发送消息
- (void)sendData:(id)sender {
    flag = 0;
    [self openStream];
}

//基于服务器实现的客户端接收消息

- (void)receiveData:(id)sender {
    flag = 1;
    [self openStream];
}

- (void)closeStream {
    [_outputStream close];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream setDelegate:nil];
    [_inputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream setDelegate:nil];
}

- (void)openStream {
    for (NSNetService *service in _myClient.services) {
        if ([@"tony" isEqualToString:service.name]) {
            if (![service getInputStream:&_inputStream outputStream:&_outputStream]) {
                NSLog(@"连接服务器失败");
                return;
            }
            break;
        }
    }
    _outputStream.delegate = self;
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream open];
    _inputStream.delegate = self;
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
}

#pragma NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    NSString *event;
    switch (eventCode) {
        case NSStreamEventNone:
            event = @"NSStreamEventNone";
            break;
        case NSStreamEventOpenCompleted:
            event = @"NSStreamEventOpenCompleted";
            break;
        case NSStreamEventHasBytesAvailable:
            event = @"NSStreamEventHasBytesAvailable";
            if (flag == 1 && aStream == _inputStream) {
                NSMutableData *input = [[NSMutableData alloc]init];
                uint8_t buffer[1024];
                int len;
                while ([_inputStream hasBytesAvailable]) {
                    len = [_inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        [input appendBytes:buffer length:len];
                    }
                }
                NSString *resultstring = [[NSString alloc]initWithData:input encoding:NSUTF8StringEncoding];
                NSLog(@"接收: %@",resultstring);
                
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            event = @"NSStreamEventHasSpaceAvailable";
            if (flag == 0 && aStream == _outputStream) {
                //输出
                UInt8 buff[] = "Hello Server";
                [_outputStream write:buff maxLength:strlen((const char *)buff +1)];
                [_outputStream close];
            }
            break;
        case NSStreamEventErrorOccurred:
            event = @"NSStreamEventErrorOccurred";
            [self closeStream];
            break;
        case NSStreamEventEndEncountered:
            event = @"NSStreamEventEndEncountered";
            NSLog(@"Error %ld: %@",[[aStream streamError]code],[[aStream streamError]localizedDescription]);
            break;
            
        default:
            [self closeStream];
            event = @"Unkown";
            break;
    }
    NSLog(@"event ------ %@",event);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
