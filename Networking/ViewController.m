//
//  ViewController.m
//  Networking
//
//  Created by Denis deniss.kaibagarovs@gmail.com  on 7/23/13.
//  Copyright (c) 2013 test. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField    *LVLField;
@property (weak, nonatomic) IBOutlet UILabel        *ResultFiled;
@property (weak, nonatomic) IBOutlet UIPickerView   *FromCurrency;
@property (weak, nonatomic) IBOutlet UIPickerView   *toCurrencyPicker;

@property (strong,nonatomic) NSMutableArray *currencyArray;
@property (strong,nonatomic) NSMutableArray *toCurrencyArray;
@property (strong,nonatomic) NSString       *fromCurren;
@property (strong,nonatomic) NSString       *toCurrency;
@property (strong,nonatomic) NSMutableData  *receivedData;


- (IBAction)randomButton:(UIButton *)sender;
- (IBAction)convertButton:(UIButton *)sender;

- (void)startRequest;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.LVLField.delegate = self;
    _currencyArray = [[NSMutableArray alloc]init];
    _toCurrencyArray = [[NSMutableArray alloc]init];
    _receivedData = [[NSMutableData alloc]init];
    
    
    [_currencyArray addObject:@"USD"];
    [_currencyArray addObject:@"LVL"];
    [_currencyArray addObject:@"EUR"];

    _toCurrencyArray = [_currencyArray copy];
    
    
    NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *urlPath = [documentFolderPath stringByAppendingPathComponent:@"MyArray.plist"];
    
    if([[NSFileManager defaultManager] isReadableFileAtPath:urlPath]) {
        _currencyArray = [NSMutableArray arrayWithContentsOfFile:urlPath];
        _toCurrencyArray = [_currencyArray copy]; }
    else
        [self startRequest];
        
    _toCurrency  = _currencyArray[0];
    _fromCurren = _toCurrencyArray[0];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)convertButton:(UIButton *)sender {
    [self.FromCurrency reloadAllComponents];
    
     NSString *amount = _LVLField.text;
    
    if(_fromCurren==_toCurrency) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"NO!"
                                                       message: @"Select different currency!"
                                                      delegate: self
                                             cancelButtonTitle:@"OKaaay"
                                             otherButtonTitles:nil];
        [alert show];
    }
    else  {
        amount = [NSString stringWithFormat:@"http://rate-exchange.appspot.com/currency?from=%@&to=%@&q=%@",_fromCurren,_toCurrency,amount];
    
        NSURL *url = [NSURL URLWithString:amount];
        NSData *tmpData = [NSData dataWithContentsOfURL:url];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Sorry :("
                                                       message: @"Can't finde currency rate!"
                                                      delegate: self
                                             cancelButtonTitle:@"OKaaay"
                                             otherButtonTitles:nil];
        if(!tmpData) {
            [alert show];
        }
            else {
                NSError *err;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:tmpData
                                                     options:NSJSONReadingAllowFragments error:&err];
                NSLog(@"JSON %@", json);
                NSNumber *num = [json objectForKey:@"v"];
                    if(!num)  [alert show];
                        self.ResultFiled.text = [NSString stringWithFormat:@"%f", [num floatValue]];
            }
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if(pickerView.tag == 0)
        return [_currencyArray count];
    else
        return [_toCurrencyArray count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if(pickerView.tag == 0)
        return [_currencyArray objectAtIndex:row];
    else
       return [_toCurrencyArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
  
    if(pickerView.tag == 0) 
        _fromCurren = [_currencyArray objectAtIndex:row];
    else
        _toCurrency = [_toCurrencyArray objectAtIndex:row];
}

- (IBAction)randomButton:(UIButton *)sender {
    
    int random = 0;
    
    random = arc4random_uniform(90);
    [self.FromCurrency selectRow:random inComponent:0 animated:YES];
        _fromCurren = _currencyArray[random];
    
    random = arc4random_uniform(90);
    [self.toCurrencyPicker selectRow:random inComponent:0 animated:YES];
        _toCurrency = _toCurrencyArray[random];
}


- (void)startRequest {
    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://spreadsheets.google.com/feeds/list/0Av%202v4lMxiJ1AdE9laEZJdzhmMzdmcW90VWNf%20UTYtM2c/2/public/basic?alt=json"]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        _receivedData = [NSMutableData data];
        NSLog(@"Data recived");
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Sorry :("
                                                       message: @"Can't finde a connection"
                                                      delegate: self
                                             cancelButtonTitle:@"OKaaay"
                                             otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [_receivedData appendData:data];
    //NSLog(@"reciveData");
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    
    _receivedData = nil;
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data", [_receivedData length]);
   
    NSError *err;
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:_receivedData
                                                         options:NSJSONReadingAllowFragments error:&err];
    int amount = [[[json objectForKey:@"feed" ]objectForKey:@"entry"] count];
    
    for(int i = 0; i<amount;i++){
        [_currencyArray addObject:[[[[[json objectForKey:@"feed"]objectForKey:@"entry"] objectAtIndex:i] objectForKey:@"title"] objectForKey:@"$t"]];
        
        _toCurrencyArray = [_currencyArray copy];
        }
    
    [self.FromCurrency reloadAllComponents];
    [self.toCurrencyPicker reloadAllComponents];
    
    NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *urlPath = [documentFolderPath stringByAppendingPathComponent:@"MyArray.plist"];
    
    //NSLog(@"%@",urlPath);
    
    [_currencyArray writeToFile:urlPath atomically:YES];
}


@end
