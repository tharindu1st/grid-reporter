import ballerina/io;
import ballerina/regex;
import ballerina/lang.array;
// import ballerina/file;
import ballerina/log;
import ballerina/time;

// import ballerina/file;

type EnergyRecord record {
    *EnergyCSVRecord;
    string date;
    int hour;
    int mins;
    decimal seconds;
    int timestamp;
};

public function main() returns error? {
    DessClient dessClient = check new;
    _ = check dessClient.login(username, password);
    GoogleSheetClient googleSheetClient = check new;
    time:Utc utcNow = time:utcNow();
    time:Civil civilTime = getPreviosDay(time:utcToCivil(utcNow));
    if month {
        int daysOfMonth = getDaysOfMonth(civilTime.year, civilTime.month);
        foreach int day in 1 ... daysOfMonth {
            string formattedDate = civilTime.year.toString() + "-" + civilTime.month.toString() + "-" + day.toString();
            log:printInfo("Retrieving data for " + formattedDate);
            AggregatedDay aggregatedRecord = check retrieveAggregatedDayResponse(dessClient, formattedDate);
            log:printInfo("Publishing data for " + civilTime.year.toString() + "-" + civilTime.month.toString() + "-" + day.toString());
            _ = check googleSheetClient.appendRowToSheet(aggregatedRecord);
            log:printInfo("Publishing End for " + civilTime.year.toString() + "-" + civilTime.month.toString() + "-" + day.toString());
        }
    } else {
        string formattedDate = civilTime.year.toString() + "-" + civilTime.month.toString() + "-" + civilTime.day.toString();
        log:printInfo("Retrieving data for " + formattedDate);
        AggregatedDay aggregatedRecord = check retrieveAggregatedDayResponse(dessClient, formattedDate);
        log:printInfo("Publishing data for " + civilTime.year.toString() + "-" + civilTime.month.toString() + "-" + civilTime.day.toString());
        _ = check googleSheetClient.appendRowToSheet(aggregatedRecord);
        log:printInfo("Publishing End for " + civilTime.year.toString() + "-" + civilTime.month.toString() + "-" + civilTime.day.toString());
    }
}

function getDaysOfMonth(int year, int month) returns int {
    if month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12 {
        return 31;
    } else if month == 4 || month == 6 || month == 9 || month == 11 {
        return 30;
    } else if month == 2 {
        if year % 4 == 0 {
            return 29;
        } else {
            return 28;
        }
    }
    return -1;
}

function retrieveAggregatedDayResponse(DessClient dessClient, string formattedDate) returns AggregatedDay|error {
    decimal startingWattage0To9Main = 0;
    decimal startingWattage9To0Main = 0;
    decimal total0to9Main = 0;
    decimal total9to0Main = 0;
    decimal endingWattage0To9Main = 0;
    decimal endingWattage9TO0Main = 0;
    decimal startingWattage0To9Inv = 0;
    decimal startingWattage9To0Inv = 0;
    decimal total0to9Inv = 0;
    decimal total9to0Inv = 0;
    decimal endingWattage0To9Inv = 0;
    decimal endingWattage9TO0Inv = 0;

    RawData[] rawData = check dessClient.retrieveAllDailyRecoreds(formattedDate);
    EnergyCSVRecord[] energyRecords = [];
    foreach RawData item in rawData {
        EnergyCSVRecord energeyRecord = check convertFromRawtoEnergyRecord(item);
        energyRecords.push(energeyRecord);
    }
    EnergyRecord[] formatedRecords = [];
    foreach EnergyCSVRecord energyRecord in energyRecords {
        string time = energyRecord.time;
        time:Civil date = check convertTimeStampStringTodecimal(time);
        time:Utc utcValue = check time:utcFromCivil(date);
        formatedRecords.push({
            time: energyRecord.time,
            matchineType: energyRecord.matchineType,
            loadStatus: energyRecord.loadStatus,
            batVolt: energyRecord.batVolt,
            chargeCurrent: energyRecord.chargeCurrent,
            batSoc: energyRecord.batSoc,
            batteryType: energyRecord.batteryType,
            busVolt: energyRecord.busVolt,
            gridvoltage: energyRecord.gridvoltage,
            gridcurrent: energyRecord.gridcurrent,
            gridfrequency: energyRecord.gridfrequency,
            maincurrent: energyRecord.maincurrent,
            pvInputvoltage: energyRecord.pvInputvoltage,
            pvInputCurrent: energyRecord.pvInputCurrent,
            pvChargingPower: energyRecord.pvChargingPower,
            pvCurrent: energyRecord.pvCurrent,
            pvChargePower: energyRecord.pvChargePower,
            outvoltage: energyRecord.outvoltage,
            inverterCurrent: energyRecord.inverterCurrent,
            outFrequencey: energyRecord.outFrequencey,
            loadCurrent: energyRecord.loadCurrent,
            loadactive: energyRecord.loadactive,
            loadApperentPower: energyRecord.loadApperentPower,
            loadRate: energyRecord.loadRate,
            pvRadiatortemp: energyRecord.pvRadiatortemp,
            heatsinkbtemp: energyRecord.heatsinkbtemp,
            inverterRadiatorTemp: energyRecord.inverterRadiatorTemp,
            batteryChargeOnsameDay: energyRecord.batteryChargeOnsameDay,
            batteryDischargeOnSameDay: energyRecord.batteryDischargeOnSameDay,
            pvPowerGenonDay: energyRecord.pvPowerGenonDay,
            loadPowerConcumptionOnday: energyRecord.loadPowerConcumptionOnday,
            powerConsumptionOnMain: energyRecord.powerConsumptionOnMain,
            accumilatedbatteryChargeHours: energyRecord.accumilatedbatteryChargeHours,
            accumilatedbatterydisChargeHours: energyRecord.accumilatedbatterydisChargeHours,
            cumulativecharge: energyRecord.cumulativecharge,
            cumulativePVPowerGen: energyRecord.cumulativePVPowerGen,
            loadCumulativePowerConsumption: energyRecord.loadCumulativePowerConsumption,
            accumilatedLoadFromMainsConsumption: energyRecord.accumilatedLoadFromMainsConsumption,
            voltageLevel: energyRecord.voltageLevel,
            date: string:concat(date.year.toString(), "-", date.month.toString(), "-", date.day.toString()),
            hour: date.hour,
            mins: date.minute,
            seconds: <decimal>date.second,
            timestamp: utcValue[0]
        });
    }
    EnergyRecord[] sortedRecords = formatedRecords.sort(array:ASCENDING, isolated function(EnergyRecord entry) returns int {
        return entry.timestamp;
    });
    int index0to9 = 0;
    int index9to0 = 0;

    foreach EnergyRecord sortedRecord in sortedRecords {
        if sortedRecord.hour <= 9 {
            if index0to9 == 0 {
                startingWattage0To9Main = sortedRecord.powerConsumptionOnMain;
                startingWattage0To9Inv = sortedRecord.loadPowerConcumptionOnday;
            } else {
                if startingWattage0To9Main <= sortedRecord.powerConsumptionOnMain {
                    endingWattage0To9Main = sortedRecord.powerConsumptionOnMain;
                    total0to9Main += endingWattage0To9Main - startingWattage0To9Main;
                    startingWattage0To9Main = endingWattage0To9Main;
                } else {
                    total0to9Main += endingWattage0To9Main - startingWattage0To9Main;
                    endingWattage0To9Main = sortedRecord.powerConsumptionOnMain;
                    startingWattage0To9Main = sortedRecord.powerConsumptionOnMain;
                    io:println("dropped1===" + sortedRecord.powerConsumptionOnMain.toString());
                }
                if startingWattage0To9Inv <= sortedRecord.loadPowerConcumptionOnday {
                    endingWattage0To9Inv = sortedRecord.loadPowerConcumptionOnday;
                    total0to9Inv += endingWattage0To9Inv - startingWattage0To9Inv;
                    startingWattage0To9Inv = endingWattage0To9Inv;
                } else {
                    total0to9Inv += endingWattage0To9Inv - startingWattage0To9Inv;
                    endingWattage0To9Inv = sortedRecord.loadPowerConcumptionOnday;
                    startingWattage0To9Inv = sortedRecord.loadPowerConcumptionOnday;
                    io:println("dropped1===" + sortedRecord.loadPowerConcumptionOnday.toString());
                }
            }
            index0to9 += 1;
        } else {
            if index9to0 == 0 {
                startingWattage9To0Main = sortedRecord.powerConsumptionOnMain;
                startingWattage9To0Inv = sortedRecord.loadPowerConcumptionOnday;
            } else {
                if startingWattage9To0Main <= sortedRecord.powerConsumptionOnMain {
                    endingWattage9TO0Main = sortedRecord.powerConsumptionOnMain;
                    total9to0Main += endingWattage9TO0Main - startingWattage9To0Main;
                    startingWattage9To0Main = sortedRecord.powerConsumptionOnMain;
                } else {
                    total9to0Main += endingWattage9TO0Main - startingWattage9To0Main;
                    endingWattage9TO0Main = sortedRecord.powerConsumptionOnMain;
                    startingWattage9To0Main = sortedRecord.powerConsumptionOnMain;
                    io:println("dropped3===" + sortedRecord.powerConsumptionOnMain.toString());
                }
                if startingWattage9To0Inv <= sortedRecord.loadPowerConcumptionOnday {
                    endingWattage9TO0Inv = sortedRecord.loadPowerConcumptionOnday;
                    total9to0Inv += endingWattage9TO0Inv - startingWattage9To0Inv;
                    startingWattage9To0Inv = sortedRecord.loadPowerConcumptionOnday;
                } else {
                    total9to0Inv += endingWattage9TO0Inv - startingWattage9To0Inv;
                    endingWattage9TO0Inv = sortedRecord.loadPowerConcumptionOnday;
                    startingWattage9To0Inv = sortedRecord.loadPowerConcumptionOnday;
                    io:println("dropped3===" + sortedRecord.loadPowerConcumptionOnday.toString());
                }
            }
            index9to0 += 1;
        }
    }
    AggregatedDay aggregatedRecord = {day: formattedDate, total0to9Inv: total0to9Inv, total0to9Main: total0to9Main, total9to0Inv: total9to0Inv, total9to0Main: total9to0Main};
    return aggregatedRecord;
}

public type AggregatedDay record {|
    string day;
    decimal total0to9Main;
    decimal total9to0Main;
    decimal total0to9Inv;
    decimal total9to0Inv;
|};

public function convertTimeStampStringTodecimal(string timestamp) returns time:Civil|error {
    string time = timestamp.substring(10, timestamp.length()).trim();
    string date = timestamp.substring(0, 10).trim();
    string[] ymd = regex:split(date, "-");
    string[] hms = regex:split(time, "\\:");
    time:Civil utcValue = {
        month: check int:fromString(ymd[1]),
        hour: check int:fromString(hms[0]),
        year: check int:fromString(ymd[0]),
        day: check int:fromString(ymd[2]),
        minute: check int:fromString(hms[1]),
        second: check decimal:fromString(hms[2])
    };
    utcValue.utcOffset = {
        hours: 5,
        minutes: 30
    };
    return utcValue;
}

public function getPreviosDay(time:Civil day) returns time:Civil {

    if day.day == 1 {
        if day.month == 1 {
            day.year = day.year - 1;
            day.month = 12;
            day.day = 31;
        } else {
            day.month = day.month - 1;
            if day.month == 1 || day.month == 3 || day.month == 5 || day.month == 7 || day.month == 8 || day.month == 10 || day.month == 12 {
                day.day = 31;
            } else if day.month == 4 || day.month == 6 || day.month == 9 || day.month == 11 {
                day.day = 30;
            } else {
                if day.year % 4 == 0 {
                    day.day = 29;
                } else {
                    day.day = 28;
                }
            }
        }
    } else {
        day.day = day.day - 1;
    }
    return day;
}
