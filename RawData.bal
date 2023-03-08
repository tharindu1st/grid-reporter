# Description
#
# + time - Timestamp  
# + matchineType - MachType  
# + loadStatus - Load status and charge status  
# + batVolt - BatVolt(V)  
# + chargeCurrent - ChargeCurr(A)  
# + batSoc - BatSoc(%)  
# + batteryType - BatTypeSet  
# + busVolt - BusVolt(V)  
# + gridvoltage - GridCurr(V)  
# + gridcurrent - GridCurrent(A)  
# + gridfrequency - GridFreq(Hz)
# + maincurrent - Mains Current(A)  
# + pvInputvoltage - PvInputVolt(V)  
# + pvInputCurrent - PvInputCurr(A)  
# + pvChargingPower - PV charging power(W)  
# + pvCurrent - PvCurr(A)  
# + pvChargePower - ChargePower(W)  
# + outvoltage - OutVolt(V)  
# + inverterCurrent - InvCurr(A)  
# + outFrequencey - OutFreq(Hz)  
# + loadCurrent - Load current(A)  
# + loadactive - Load active(W)  
# + loadApperentPower - Load apparent power(VA)  
# + loadRate - Load rate(%)  
# + pvRadiatortemp - PV radiator temperature(�C)  
# + heatsinkbtemp - Heat sink B temperature(�C)  
# + inverterRadiatorTemp - Inverter radiator temperature(�C) 
# + batteryChargeOnsameDay - Battery charge on the same day(AH)  
# + batteryDischargeOnSameDay - Battery discharge on the same day(AH)  
# + pvPowerGenonDay - PV power generation on the day(kWh)  
# + loadPowerConcumptionOnday - Load power consumption on the day(kWh) 
# + powerConsumptionOnMain - Power consumption from the mains on the day of the load(kWh)  
# + accumilatedbatteryChargeHours - Accumulated battery charge hours(AH)  
# + accumilatedbatterydisChargeHours - Accumulated battery discharge time(AH)  
# + cumulativecharge - Cumulative charge(AH)  
# + cumulativePVPowerGen - PV cumulative power generation(kWh)  
# + loadCumulativePowerConsumption - Load cumulative power consumption(kWh)  
# + accumilatedLoadFromMainsConsumption - Accumulated load from mains consumption(kWh)  
# + voltageLevel - Voltage level
public type EnergyCSVRecord record {
    string time;
    string matchineType;
    string loadStatus;
    decimal batVolt;
    decimal chargeCurrent;
    decimal batSoc;
    string batteryType;
    decimal busVolt;
    decimal gridvoltage;
    decimal gridcurrent;
    decimal gridfrequency;
    decimal maincurrent;
    decimal pvInputvoltage;
    decimal pvInputCurrent;
    decimal pvChargingPower;
    decimal pvCurrent;
    decimal pvChargePower;
    decimal outvoltage;
    decimal inverterCurrent;
    decimal outFrequencey;
    decimal loadCurrent;
    decimal loadactive;
    decimal loadApperentPower;
    decimal loadRate;
    decimal pvRadiatortemp;
    decimal heatsinkbtemp;
    decimal inverterRadiatorTemp;
    decimal batteryChargeOnsameDay;
    decimal batteryDischargeOnSameDay;
    decimal pvPowerGenonDay;
    decimal loadPowerConcumptionOnday;
    decimal powerConsumptionOnMain;
    decimal accumilatedbatteryChargeHours;
    decimal accumilatedbatterydisChargeHours;
    decimal cumulativecharge;
    decimal cumulativePVPowerGen;
    decimal loadCumulativePowerConsumption;
    decimal accumilatedLoadFromMainsConsumption;
    string voltageLevel;
};

public type TitleRaw record {
    string title;
    string unit?;
};

public type RawData record {
    boolean realtime;
    string[] 'field;
};

public type DailyRawData record {
    int total;
    int page;
    int pagesize;
    TitleRaw[] title;
    RawData[] row;
};

public type DailyResponse record {|
    int err;
    string desc;
    DailyRawData dat?;

|};
public function convertFromRawtoEnergyRecord(RawData raw) returns EnergyCSVRecord|error{


    EnergyCSVRecord energyRecord = {
        time: raw.'field[1],
        matchineType: raw.'field[2],
        loadStatus: raw.'field[3],
        batVolt: check decimal:fromString(raw.'field[4]),
        chargeCurrent: check decimal:fromString(raw.'field[5]),
        batSoc: check decimal:fromString(raw.'field[6]),
        batteryType: raw.'field[7],
        busVolt: check decimal:fromString(raw.'field[8]),
        gridvoltage: check decimal:fromString(raw.'field[9]),
        gridcurrent: check decimal:fromString(raw.'field[10]),
        gridfrequency: check decimal:fromString(raw.'field[11]),
        maincurrent: check decimal:fromString(raw.'field[12]),
        pvInputvoltage: check decimal:fromString(raw.'field[13]),
        pvInputCurrent: check decimal:fromString(raw.'field[14]),
        pvChargingPower: check decimal:fromString(raw.'field[15]),
        pvCurrent: check decimal:fromString(raw.'field[16]),
        pvChargePower: check decimal:fromString(raw.'field[17]),
        outvoltage: check decimal:fromString(raw.'field[18]),
        inverterCurrent: check decimal:fromString(raw.'field[19]),
        outFrequencey: check decimal:fromString(raw.'field[20]),
        loadCurrent: check decimal:fromString(raw.'field[21]),
        loadactive: check decimal:fromString(raw.'field[22]),
        loadApperentPower: check decimal:fromString(raw.'field[23]),
        loadRate: check decimal:fromString(raw.'field[24]),
        pvRadiatortemp: check decimal:fromString(raw.'field[25]),
        heatsinkbtemp: check decimal:fromString(raw.'field[26]),
        inverterRadiatorTemp: check decimal:fromString(raw.'field[27]),
        batteryChargeOnsameDay: check decimal:fromString(raw.'field[28]),
        batteryDischargeOnSameDay: check decimal:fromString(raw.'field[29]),
        pvPowerGenonDay: check decimal:fromString(raw.'field[30]),
        loadPowerConcumptionOnday: check decimal:fromString(raw.'field[31]),
        powerConsumptionOnMain: check decimal:fromString(raw.'field[32]),
        accumilatedbatteryChargeHours: check decimal:fromString(raw.'field[33]),
        accumilatedbatterydisChargeHours: check decimal:fromString(raw.'field[34]),
        cumulativecharge: check decimal:fromString(raw.'field[35]),
        cumulativePVPowerGen: check decimal:fromString(raw.'field[36]),
        loadCumulativePowerConsumption: check decimal:fromString(raw.'field[37]),
        accumilatedLoadFromMainsConsumption: check decimal:fromString(raw.'field[38]),
        voltageLevel: raw.'field[39]
    };
    return energyRecord;
}