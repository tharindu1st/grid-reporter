import ballerina/time;
import ballerina/crypto;
import ballerina/http;
import ballerina/log;

public class DessClient {

    http:Client clientEndpoint;
    LoginResponse loginResponse = {err: 8};
    function init() returns error? {
        self.clientEndpoint = check new ("https://web.shinemonitor.com");
    }
    function login(string username, string password) returns error? {
        int salt = time:utcNow(3)[0];
        string pwdSha1 = crypto:hashSha1(password.toBytes()).toBase16().toString();
        string action = "authSource";
        string 'companyKey = "bnrl_frRFjEz8Mkn";
        string uriString = "action=" + action + "&usr=" + username + "&source=1&company-key=" + 'companyKey;
        string sign = crypto:hashSha1(string:concat(salt.toString(), pwdSha1, "&", uriString).toBytes()).toBase16().toString();
        string url = "/public/?sign=" + sign + "&salt=" + salt.toString() + "&" + uriString;
        LoginResponse response = check self.clientEndpoint->get(url, targetType = LoginResponse);
        if response.err == 0 {
            self.loginResponse = response;
        } else {
            log:printError("Login failed", response = response.toJsonString());
            return error("Login failed");
        }
    }
    public function retrieveDailyRecords(string date, int pageNumber, int pagesize) returns DailyResponse|error {
        int salt = time:utcNow(3)[0];
        LoginResponseData? dat = self.loginResponse.dat;
        if self.loginResponse.err == 0 {
            if dat is LoginResponseData {
                string secret = dat.secret;
                string token = dat.token;
                string uriString = "action=queryDeviceDataOneDayPaging&source=1&page=" + pageNumber.toString() + "&pagesize=" + pagesize.toString() + "&i18n=en_US&pn=" + devicePin + "&devcode=2361&devaddr=255&sn=" + serialNo + "&date=" + date;
                string sign = crypto:hashSha1(string:concat(salt.toString(), secret, token, "&", uriString).toBytes()).toBase16().toString();
                string url = "/public/?sign=" + sign + "&salt=" + salt.toString() + "&token=" + token + "&" + uriString;
                DailyResponse|error response = self.clientEndpoint->get(url, targetType = DailyResponse);
                return response;
            }
        }
        return error("Login failure");

    }
    public function retrieveAllDailyRecoreds(string date) returns RawData[]|error {
        RawData[] rawData = [];
        DailyResponse retrieveDailyRecordsResult = check self.retrieveDailyRecords(date, 0, 50);
        int count = 0;
        int retrievedCount = 0;
        int pageNumber = 0;
        DailyRawData? data = retrieveDailyRecordsResult.dat;
        if data is DailyRawData {
            if data.total > 0 {
                count = data.total;
                retrievedCount = data.row.length();
                rawData.push(...data.row);
                pageNumber += 1;
                while retrievedCount <= count {
                    retrieveDailyRecordsResult = check self.retrieveDailyRecords(date, pageNumber, 50);
                    DailyRawData? tempData = retrieveDailyRecordsResult.dat;
                    if tempData is DailyRawData {
                        retrievedCount += tempData.row.length();
                        pageNumber += 1;
                        rawData.push(...tempData.row);
                    } else {
                        break;
                    }
                }
            }
        }
        return rawData;
    }
}
