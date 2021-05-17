//
//  DataLogger.m
//  CoreMotionLogger
//
//  Created by Patrick O'Keefe on 10/27/11.
//  Copyright (c) 2011 Patrick O'Keefe.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this
//  software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify,
//  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies
//  or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
//  THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "DataLogger.h"

@interface DataLogger (hidden)
/**
 * processMotion:withError:
 *
 * Appends the new motion data to the appropriate instance variable strings.
 */
- (void) processMotion:(CMDeviceMotion*)motion withError:(NSError*)error;

/**
 * processAccel:withError:
 *
 * Appends the new raw accleration data to the appropriate instance variable string.
 */
- (void) processAccel:(CMAccelerometerData*)accelData withError:(NSError*)error;

/**
 * processGyro:withError:
 *
 * Appends the new raw gyro data to the appropriate instance variable string.
 */
- (void) processGyro:(CMGyroData*)gyroData withError:(NSError*)error;

/**
 * writeDataToDisk
 *
 * Using the boolean instance variables to know which strings to write, this method saves
 * the data strings to the app's documents directory. The filename of each string contains
 * a date and time string so that a user can save multiple log runs. The time format needs
 * to be long so that a user can log two different runs that start in the same minute.
 */
- (void) writeDataToDisk;
@end
@implementation DataLogger

- (id)init {

    self = [super init];
    if (self) {

        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 0.01; //100 Hz
        _motionManager.accelerometerUpdateInterval = 0.01;
        _motionManager.gyroUpdateInterval = 0.01;

        // Limiting the concurrent ops to 1 is a cheap way to avoid two handlers editing the same
        // string at the same time.
        _deviceMotionQueue = [[NSOperationQueue alloc] init];
        [_deviceMotionQueue setMaxConcurrentOperationCount:1];

        _accelQueue = [[NSOperationQueue alloc] init];
        [_accelQueue setMaxConcurrentOperationCount:1];

        _gyroQueue = [[NSOperationQueue alloc] init];
        [_gyroQueue setMaxConcurrentOperationCount:1];

        _logAttitudeData = false;
        _logGravityData = false;
        _logMagneticFieldData = false;
        _logRotationRateData = false;
        _logUserAccelerationData = false;
        _logRawGyroscopeData = false;
        _logRawAccelerometerData = false;

        _attitudeString = [[NSString alloc] init];
        _gravityString = [[NSString alloc] init];
        _magneticFieldString = [[NSString alloc] init];
        _rotationRateString = [[NSString alloc] init];
        _userAccelerationString = [[NSString alloc] init];
        _rawGyroscopeString = [[NSString alloc] init];
        _rawAccelerometerString = [[NSString alloc] init];

    }

    return self;
}

- (void) startLoggingMotionData {

    NSLog(@"Starting to log motion data.");

    CMDeviceMotionHandler motionHandler = ^(CMDeviceMotion *motion, NSError *error) {
        [self processMotion:motion withError:error];
    };

    CMGyroHandler gyroHandler = ^(CMGyroData *gyroData, NSError *error) {
        [self processGyro:gyroData withError:error];
    };

    CMAccelerometerHandler accelHandler = ^(CMAccelerometerData *accelerometerData, NSError *error) {
        [self processAccel:accelerometerData withError:error];
    };


    if (_logAttitudeData || _logGravityData || _logMagneticFieldData || _logRotationRateData || _logUserAccelerationData ) {
        [_motionManager startDeviceMotionUpdatesToQueue:_deviceMotionQueue withHandler:motionHandler];
    }

    if (_logRawGyroscopeData) {
        [_motionManager startGyroUpdatesToQueue:_gyroQueue withHandler:gyroHandler];
    }

    if (_logRawAccelerometerData) {
        [_motionManager startAccelerometerUpdatesToQueue:_accelQueue withHandler:accelHandler];
    }

}

- (void) stopLoggingMotionDataAndSave {

    NSLog(@"Stopping data logging.");

    [_motionManager stopDeviceMotionUpdates];
    [_deviceMotionQueue waitUntilAllOperationsAreFinished];

    [_motionManager stopAccelerometerUpdates];
    [_accelQueue waitUntilAllOperationsAreFinished];

    [_motionManager stopGyroUpdates];
    [_gyroQueue waitUntilAllOperationsAreFinished];

    // Save all of the data!
    [self writeDataToDisk];

}

- (void) processAccel:(CMAccelerometerData*)accelData withError:(NSError*)error {

    if (_logRawAccelerometerData) {
        _rawAccelerometerString = [_rawAccelerometerString stringByAppendingFormat:@"%f,%f,%f,%f\n", accelData.timestamp,
                                                           accelData.acceleration.x,
                                                           accelData.acceleration.y,
                                                           accelData.acceleration.z,
                                                           nil];
    }
}

- (void) processGyro:(CMGyroData*)gyroData withError:(NSError*)error {
    NSLog(@"processGyro");

    if (_logRawGyroscopeData) {
        _rawGyroscopeString = [_rawGyroscopeString stringByAppendingFormat:@"%f,%f,%f,%f\n", gyroData.timestamp,
                                                   gyroData.rotationRate.x,
                                                   gyroData.rotationRate.y,
                                                   gyroData.rotationRate.z,
                                                   nil];
    }
}

- (void) processMotion:(CMDeviceMotion*)motion withError:(NSError*)error {
    
        NSLog(@"Processing motion with motion pointer %p",motion);
        NSLog(@"Curr _magneticFieldString %@",_magneticFieldString);

    if (_logAttitudeData) {
        _attitudeString = [_attitudeString stringByAppendingFormat:@"%f,%f,%f,%f\n", motion.timestamp,
                                           motion.attitude.roll,
                                           motion.attitude.pitch,
                                           motion.attitude.yaw,
                                           nil];
    }

    if (_logGravityData) {
        _gravityString = [NSString stringWithFormat:@"%f,%f,%f\n",
                          motion.gravity.x,
                          motion.gravity.y,
                          motion.gravity.z,
                          nil];
//        _gravityString = [_gravityString stringByAppendingFormat:@"%f,%f,%f,%f\n", motion.timestamp,
//                                         motion.gravity.x,
//                                         motion.gravity.y,
//                                         motion.gravity.z,
//                                         nil];
    }

    if (_logMagneticFieldData) {
        _magneticFieldString = [NSString stringWithFormat:@"%f,%f,%f",
                                motion.magneticField.field.x,
                                motion.magneticField.field.y,
                                motion.magneticField.field.z,
                                
                                
                                nil];
//        _magneticFieldString = [_magneticFieldString stringByAppendingFormat:@"%f,%f,%f,%f,%d\n", motion.timestamp,
//                                                     motion.magneticField.field.x,
//                                                     motion.magneticField.field.y,
//                                                     motion.magneticField.field.z,
//                                                     (int)motion.magneticField.accuracy,
//                                                     nil];
    }

    if (_logRotationRateData) {
        _rotationRateString = [NSString stringWithFormat:@"%f,%f,%f",
                               motion.rotationRate.x,
                               motion.rotationRate.y,
                               motion.rotationRate.z,nil];
//        _rotationRateString = [_rotationRateString stringByAppendingFormat:@"%f,%f,%f,%f\n", motion.timestamp,
//                                                   motion.rotationRate.x,
//                                                   motion.rotationRate.y,
//                                                   motion.rotationRate.z,
//                                                   nil];
    }

    if (_logUserAccelerationData) {
        _userAccelerationString =
        [NSString stringWithFormat:@"%f,%f,%f,%f", motion.timestamp,motion.userAcceleration.x,motion.userAcceleration.y,motion.userAcceleration.z,nil];
//        _userAccelerationString = [_userAccelerationString stringByAppendingFormat:@"%f,%f,%f,%f\n", motion.timestamp,
//                                                           motion.userAcceleration.x,
//                                                           motion.userAcceleration.y,
//                                                           motion.userAcceleration.z,
//                                                           nil];
    }

}



- (void) setLogAttitudeData:(BOOL)newValue {
    _logAttitudeData = newValue;
}

- (void) setLogGravityData:(BOOL)newValue {
    _logGravityData = newValue;
}

- (void) setLogMagneticFieldData:(BOOL)newValue {
    _logMagneticFieldData = newValue;
}

- (void) setLogRotationRateData:(BOOL)newValue {
    _logRotationRateData = newValue;
}

- (void) setLogUserAccelerationData:(BOOL)newValue {
    _logUserAccelerationData = newValue;
}

- (void) setLogRawGyroscopeData:(BOOL)newValue {
    _logRawGyroscopeData = newValue;
}

- (void) setLogRawAccelerometerData:(BOOL)newValue {
    _logRawAccelerometerData = newValue;
}


- (void) writeDataToDisk {
    NSLog(@"Saving everything to disk!");

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];

    // Some filesystems hate colons
    NSString *dateString = [[dateFormatter stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    // I hate spaces
    dateString = [dateString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    // Nobody can stand forward slashes
    dateString = [dateString stringByReplacingOccurrencesOfString:@"/" withString:@"_"];


    if (_logAttitudeData) {
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"attitude_%@.txt", dateString, nil]];

        [_attitudeString writeToFile:fullPath
                          atomically:NO
                            encoding:NSStringEncodingConversionAllowLossy
                               error:nil];
        _attitudeString = @"";
    }

    if (_logGravityData) {
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"gravity_%@.txt", dateString, nil]];

        [_gravityString writeToFile:fullPath
                         atomically:NO
                           encoding:NSStringEncodingConversionAllowLossy
                              error:nil];
        _gravityString = @"";
    }

    if (_logMagneticFieldData) {
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"magneticField_%@.txt", dateString, nil]];

        [_magneticFieldString writeToFile:fullPath
                               atomically:NO
                                 encoding:NSStringEncodingConversionAllowLossy
                                    error:nil];

    }

    if (_logRotationRateData) {
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"rotationRate_%@.txt", dateString, nil]];

        [_rotationRateString writeToFile:fullPath
                              atomically:NO
                                encoding:NSStringEncodingConversionAllowLossy
                                   error:nil];

    }

    if (_logUserAccelerationData) {
        NSLog(@"DataLogger : %@",_userAccelerationString);
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"userAcceleration_%@.txt", dateString, nil]];

        [_userAccelerationString writeToFile:fullPath
                                  atomically:NO
                                    encoding:NSStringEncodingConversionAllowLossy
                                       error:nil];
        
    }

    if (_logRawGyroscopeData) {
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"rawGyroscope_%@.txt", dateString, nil]];

        [_rawGyroscopeString writeToFile:fullPath
                              atomically:NO
                                encoding:NSStringEncodingConversionAllowLossy
                                   error:nil];
        _rawGyroscopeString = @"";
    }

    if (_logRawAccelerometerData) {
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"rawAccelerometer_%@.txt", dateString, nil]];

        [_rawAccelerometerString writeToFile:fullPath
                                  atomically:NO
                                    encoding:NSStringEncodingConversionAllowLossy
                                       error:nil];
        _rawAccelerometerString = @"";
    }


}



@end
