public type LoginResponseData record {
    string secret;
    int expire;
    string token;
    int role;
    string usr;
    int uid;
};

public type LoginResponse record {|
int err;
string desc?;
LoginResponseData dat?;
|};