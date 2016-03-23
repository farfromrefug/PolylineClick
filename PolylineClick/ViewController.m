#import "ViewController.h"

#define CENTER_POS CLLocationCoordinate2DMake(45.1841656,5.7155425)

@import GoogleMaps;
@import CoreLocation;

@interface ViewController () <GMSIndoorDisplayDelegate, GMSMapViewDelegate>

@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) GMSPolyline *currentPoly;
@property (nonatomic) NSInteger count;
-(void) updateMarkerDetails;

@end

@implementation ViewController

- (void)concatPolyline:(GMSMutablePath *)path fromString:(NSString *)encodedString {
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
    
    int i;
    for (i = 0; i < coordIdx; i++)
    {
        [path addCoordinate:coords[i]];
    }
    free(coords);

}


-(void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
//  CLLocationCoordinate2D location = CLLocationCoordinate2DMake(40.295210, -124.032841);
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:CENTER_POS zoom:8];
    self.mapView.delegate = self;
  [self.mapView animateToCameraPosition:camera];
  [self.mapView setMapType:kGMSTypeHybrid];
  [self createPolyline];
}

#pragma mark - ViewController class extension methods

-(void)createPolyline
{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@"https://maps.googleapis.com/maps/api/directions/json?units=metric&mode=bicycling&origin=45.17898607970475,5.706222653388977&destination=43.58489750612025,7.114509455859661&waypoints=&language=en&region=en"]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                NSObject* obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    GMSMutablePath *path = [[GMSMutablePath alloc] init];
                    NSDictionary* route = [[obj valueForKey:@"routes"] objectAtIndex:0];
                    [[route valueForKey:@"legs"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [[obj valueForKey:@"steps"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            [self concatPolyline:path fromString:[[obj valueForKey:@"polyline"] valueForKey:@"points"]];
                        }];
                    }];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
                        polyline.tappable = YES;
                        polyline.map = self.mapView;
                    });
                    
                }
                
            }] resume];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    NSLog(@"center.lon %f", position.target.longitude);
    NSLog(@"center.lat %f", position.target.latitude);
    NSLog(@"zoom %f", position.zoom);
}

- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay {
    if (self.currentPoly && overlay != self.currentPoly) {
        self.currentPoly.strokeWidth = 2;
    }
    self.currentPoly=  nil;
    if ([overlay isKindOfClass:[GMSPolyline class]]) {
        self.currentPoly=  overlay;
        self.currentPoly.strokeWidth = 6;
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self.currentPoly) {
        self.currentPoly.strokeWidth = 2;
    }
}
@end
