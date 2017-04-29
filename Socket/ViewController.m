//
//  ViewController.m
//  Socket
//
//  Created by ZXJ on 2017/4/29.
//  Copyright © 2017年 maodenden. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

#define SW UIScreen.mainScreen.bounds.size.width

#define HOST @"127.0.0.1"
#define PORT 9090

@interface ViewController ()<NSStreamDelegate, GCDAsyncSocketDelegate>
@property (nonatomic, strong) UITextField *messageTextField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UILabel *otherMessageLabel;

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupUI];
    
//    [self createSocket];
    [self createGCDAsyncSocket];
}

- (IBAction)sendMessage:(id)sender {
    NSData *data = [self.messageTextField.text dataUsingEncoding:NSUTF8StringEncoding];
//    [self.outputStream write:data.bytes maxLength:data.length];
    
    [self.asyncSocket writeData:data withTimeout:-1 tag:100];
}

- (void)readData {
//    uint8_t buffer[1024];
//    NSInteger length = [self.inputStream read:buffer maxLength:sizeof(buffer)];
//    
//    self.otherMessageLabel.text = [[NSString alloc] initWithBytes:buffer length:length encoding:NSUTF8StringEncoding];

}

#pragma mark - 初始化Socket客户端
- (void)createSocket {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)HOST, PORT, &readStream, &writeStream);
    
    self.outputStream = (__bridge NSOutputStream *)(writeStream);
    self.inputStream = (__bridge NSInputStream *)(readStream);
    
    // 监听数据代理
    self.outputStream.delegate = self;
    self.inputStream.delegate = self;
    
    [self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.outputStream open];
    [self.inputStream open];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    NSLog(@"Tread--------%@", [NSThread currentThread]);
    
    switch (eventCode) {
        case NSStreamEventNone:
        {
            
        }
            break;
            
        case NSStreamEventOpenCompleted:
        {
            NSLog(@"StreamEventOpenCompleted");
        }
            break;
            
        case NSStreamEventHasBytesAvailable:
        {
            NSLog(@"StreamEventHasBytesAvailable");
        }
            break;
            
        case NSStreamEventHasSpaceAvailable:
        {
            NSLog(@"StreamEventHasSpaceAvailable");
        }
            break;
            
        case NSStreamEventErrorOccurred:
        {
            NSLog(@"StreamEventErrorOccurred");
        }
            break;
            
        case NSStreamEventEndEncountered:
        {
            NSLog(@"StreamEventEndEncountered");
            [self.outputStream close];
            [self.inputStream close];
            
            [self.outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [self.inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 创建GCDAsyncSocket
- (void)createGCDAsyncSocket {
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    NSError *error;
    [self.asyncSocket connectToHost:HOST onPort:PORT error:&error];
    if (error) {
        NSLog(@"---------------connect fail");
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"---------------didConnect");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"---------------%@", sock);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"---------------%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [sock readDataWithTimeout:-1 tag:tag];
}

#pragma mark - 设置界面
- (void)setupUI {
    [self.view addSubview:self.messageTextField];
    [self.view addSubview:self.sendButton];
    [self.view addSubview:self.otherMessageLabel];
}

#pragma mark - 懒加载
- (UITextField *)messageTextField {
    if (!_messageTextField) {
        _messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 20, SW, 44)];
        _messageTextField.backgroundColor = [UIColor blueColor];
    }
    return _messageTextField;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 84, SW, 44)];
        [_sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
        _sendButton.backgroundColor = [UIColor redColor];
    }
    return _sendButton;
}

- (UILabel *)otherMessageLabel {
    if (_otherMessageLabel == nil) {
        _otherMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 148, SW, 44)];
        _otherMessageLabel.backgroundColor = [UIColor greenColor];
    }
    return _otherMessageLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
