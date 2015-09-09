//
//  ViewController.m
//  StillImageCapture
//
//  Created by Jayaprada Behera on 09/09/15.
//  Copyright (c) 2015 WebileApps. All rights reserved.
//

#import "ViewController.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageProperties.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()
{
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureVideoPreviewLayer *previewLayer;
    UIImage *profileImage;

}
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
- (IBAction)takePhotoBtnTapped:(id)sender;
@property (nonatomic, strong) AVCaptureSession * captureSession;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)captureImage{
    self.captureSession = [[AVCaptureSession alloc]init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    //Add device
    AVCaptureDevice *device =[self frontCamera];
    
    //Input
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    if (!input)
    {
        //NSLog(@"No Input");
    }
    
    [self.captureSession addInput:input];
    
    // Make a still image output
    stillImageOutput = [AVCaptureStillImageOutput new];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    if ([self.captureSession canAddOutput:stillImageOutput])
        [self.captureSession addOutput:stillImageOutput];
    
    //Preview Layer
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    previewLayer.frame = CGRectMake(0.0f, 60.0f, self.view.frame.size.width, 200.0f);
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:previewLayer];
    //Start capture session
    [self.captureSession startRunning];
    
    
    //Add take photo btn
    UIView * bgView= [[UIView alloc] initWithFrame:CGRectMake(0.0f, 250.0f, self.view.frame.size.width, 50.0f)];
    [bgView setBackgroundColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.5f]];
    [self.view addSubview:bgView];
    UIButton * takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePhotoButton setFrame:CGRectMake(20.0f, 250.0f, 120.0f, 50.0f)];
    [takePhotoButton setTitle:@"Take Photo" forState:UIControlStateNormal];
    [takePhotoButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [takePhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [takePhotoButton addTarget:self action:@selector(takePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takePhotoButton];
   
}

#pragma mark - image capture

- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}

-(void)takePhotoButtonAction:(UIButton *)sender{
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        { break;
        }
    }
    
    //NSLog(@"about to request a capture from: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments)
         {
             // Do something with the attachments.
             //NSLog(@"attachements: %@", exifAttachments);
         }
         else{
             //NSLog(@"no attachments");
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         profileImage = [[UIImage alloc] initWithData:imageData];
         self.profileImageView.image = profileImage;
         
     }];
    
}
-(void)dealloc{
    [self deallocSession];
}

-(void)deallocSession
{
    [previewLayer removeFromSuperlayer];
    for(AVCaptureInput *input in self.captureSession.inputs) {
        [self.captureSession removeInput:input];
    }
    
    for(AVCaptureOutput *output in self.captureSession.outputs) {
        [self.captureSession removeOutput:output];
    }
    [self.captureSession stopRunning];
    self.captureSession=nil;
    previewLayer=nil;
    stillImageOutput=nil;
    
}
- (IBAction)takePhotoBtnTapped:(id)sender {
    [self captureImage];
}
@end
