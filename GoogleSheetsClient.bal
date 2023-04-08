import ballerina/regex;
import ballerina/log;
import ballerinax/googleapis.sheets as sheets;

public class GoogleSheetClient {
    sheets:Client spreadsheetClient;
    function init() returns error? {
        sheets:ConnectionConfig spreadsheetConfig = {
            auth: {
                clientId: credentials.clientId,
                clientSecret: credentials.clientSecret,
                refreshUrl: sheets:REFRESH_URL,
                refreshToken: credentials.refreshToken
            }
        };
        self.spreadsheetClient = check new (spreadsheetConfig);
    }
    function appendRowToSheet(AggregatedDay 'record) returns error? {
        string[] split = regex:split('record.day, "-");
        string sheetName = "records-" + split[0] + "-" + split[1];
        sheets:Spreadsheet|error spreadSheet = self.spreadsheetClient->openSpreadsheetByUrl(credentials.spreadSheetUrl);
        if spreadSheet is sheets:Spreadsheet {
            sheets:Sheet|error sheet = self.spreadsheetClient->getSheetByName(spreadSheet.spreadsheetId, sheetName);
            if sheet is error {
                _ = check self.spreadsheetClient->addSheet(spreadSheet.spreadsheetId, sheetName);
                _ = check self.spreadsheetClient->appendRowToSheet(spreadSheet.spreadsheetId, sheetName, ["Date", "Total0To9", "Total9To0", "GridTotal0to9", "GridTotal9To0","Total"], (), sheets:USER_ENTERED);
            }
            check self.spreadsheetClient->appendRowToSheet(spreadSheet.spreadsheetId, sheetName, ['record.day, 'record.total0to9Inv, 'record.total9to0Inv, 'record.total0to9Main, 'record.total9to0Main,'record.total0to9Main+'record.total9to0Main], "A:F", sheets:USER_ENTERED);
        } else {
            log:printError("Error while opening spreadsheet", spreadSheet);
        }
    }
}
