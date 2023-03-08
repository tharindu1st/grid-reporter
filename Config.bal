configurable string devicePin = ?;
configurable string serialNo = ?;
configurable string username = ?;
configurable string password = ?;
configurable GoogleCredentials credentials = ?;

public type GoogleCredentials record {
    string clientId;
    string clientSecret;
    string refreshToken;
    string spreadSheetUrl;
};
