/*
 Copyright 2014 OpenMarket Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MXRestClient.h"

#import <AFNetworking.h>

#define MX_PREFIX_PATH  @"/_matrix/client/api/v1"

@interface MXRestClient ()
{
    AFHTTPRequestOperationManager *httpManager;
    
    NSString *access_token;
}
@end

@implementation MXRestClient

-(id)initWithHomeServer:(NSString *)homeserver
{
    return [self initWithHomeServer:homeserver andAccessToken:nil];
}

-(id)initWithHomeServer:(NSString *)homeserver andAccessToken:(NSString *)accessToken
{
    self = [super init];
    if (self)
    {
        access_token = accessToken;
        
        httpManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", homeserver, MX_PREFIX_PATH]]];
    }
    return self;
}

- (id)requestWithMethod:(NSString *)httpMethod
                                         path:(NSString *)path
                                   parameters:(id)parameters
                                      success:(void (^)(NSDictionary *JSONResponse))success
                                      failure:(void (^)(NSError *error))failure
{
    if (access_token)
    {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@", access_token]];
    }
    
    NSString *URLString = [[NSURL URLWithString:path relativeToURL:httpManager.baseURL] absoluteString];

    NSMutableURLRequest *request = [httpManager.requestSerializer requestWithMethod:httpMethod URLString: URLString parameters:parameters error:nil];
    
    AFHTTPRequestOperation *operation = [httpManager HTTPRequestOperationWithRequest:request
        success:^(AFHTTPRequestOperation *operation, NSDictionary *JSONResponse) {
            success(JSONResponse);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    
    [httpManager.operationQueue addOperation:operation];
    
    return operation;
}

@end