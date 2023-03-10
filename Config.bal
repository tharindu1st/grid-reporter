configurable string devicePin = ?;
configurable string serialNo = ?;
configurable string username = ?;
configurable string password = ?;
configurable GoogleCredentials credentials = ?;
configurable boolean month = false;
public type GoogleCredentials record {
    string clientId;
    string clientSecret;
    string refreshToken;
    string spreadSheetUrl;
};
