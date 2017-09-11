//
//  ViewController.m
//  Economic Village
//
//  Created by Ali Mirzamani on 2/8/17.
//  Copyright © 2017 Ali Mirzamani. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) IBOutlet UILabel *insert;
@property (nonatomic, strong) IBOutlet UILabel *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self check];
    
}
-(void)check {
    _session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.frame = CGRectMake(0,0,320,480);
    
    _insert.text = @"کارت خود را وارد کنید";
    _insert.font = [UIFont fontWithName:@"g aseman" size:100];
    _insert.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_insert];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (input) {
        [_session addInput:input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:output];
    
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code]];
    
    [_session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    NSString *QRCode = nil;
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            QRCode = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            break;
        }
    }
    [_session stopRunning];
    
    NSString *path = @"https://mirzamani.ir/ecvillage/json.php";
    NSURL *url = [NSURL URLWithString:path];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (data) {
        self.array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    } else {
        self.array = [NSArray array];
    }
    
    NSArray *gid = [self.array valueForKey:@"groupid"];
    NSArray *gmoney = [self.array valueForKey:@"groupmoney"];
    
    NSDictionary *group = [NSDictionary dictionaryWithObjects:gmoney forKeys:gid];
    
    NSLog(@"QR Codes: %@", QRCode);
    NSLog(@"QR Code: %@",group[QRCode]);
    
    if (group[QRCode]) {
        _insert.text = @" موجودی :";
        _insert.text = [_insert.text stringByAppendingString:group[QRCode]];
        _insert.text = [_insert.text stringByAppendingString:@" پشیز"];
    }
    
    _timer.hidden = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        _timer.hidden = YES;
        [self check];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
