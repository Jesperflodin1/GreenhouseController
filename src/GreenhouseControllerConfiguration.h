#ifndef _GreenhouseControllerConfiguration_h
#define _GreenhouseControllerConfiguration_h
#include <Arduino.h>

/* --- Default configuration --- */
#define CFG_EnableSensor1 1
#define CFG_Sensor1Limit 90
#define CFG_wateringTimeSens1 14
#define CFG_MaxTimeInterval1 48
#define CFG_MinTimeInterval1 8
#define CFG_EnableSensor2 0
#define CFG_Sensor2Limit 90
#define CFG_wateringTimeSens2 14
#define CFG_MaxTimeInterval2 48
#define CFG_MinTimeInterval2 8
#define CFG_EnableSensor3 0
#define CFG_Sensor3Limit 90
#define CFG_wateringTimeSens3 14
#define CFG_MaxTimeInterval3 48
#define CFG_MinTimeInterval3 8
#define CFG_Sensor1Dry 660
#define CFG_Sensor1Wet 85
#define CFG_Sensor2Dry 660
#define CFG_Sensor2Wet 85
#define CFG_Sensor3Dry 660
#define CFG_Sensor3Wet 85
#define CFG_HumidityInterval 1800 //sec

// 10 byte sensor configuration struct
typedef struct SensorConfiguration {
    bool enable;
    uint8_t humidityLimit;
    uint8_t pumpTime;                       // Seconds
    uint8_t maxPumpings;
    uint8_t pumpTimeout;                    // Hours
    uint8_t pumpDelay;                      // Hours
    uint16_t calibrationDry;
    uint16_t calibrationWet;
} SensorConfiguration;

// 10*NUM_SENSORS + 1 byte configuration struct (Default 10*3+1 = 31 byte)
typedef struct Configuration {
    uint8_t humidityCheckInterval;          // TODO: Change sec to minutes in rest of code
    SensorConfiguration Sensor[];
} Configuration;


/* --- SerialUI config --- */
// serial_baud_rate -- connect to device at this baud rate, using druid
#define serial_baud_rate			9600

// have a "heartbeat" function to hook-up.  It will be called periodically while 
// someone is connected...  Set heartbeat_function_period_ms (millis) to specify
// how often it will be called
#define heartbeat_function_period_ms  1000

// serial_maxidle_ms -- how long before we consider the user
// gone, for lack of activity (milliseconds)
#define serial_maxidle_ms			60000

// serial_readtimeout_ms -- timeout when we're expecting input
// for a specific request/read (milliseconds)
#define serial_readtimeout_ms		60000

#define serial_ui_greeting_str	" AutoWaterer \r\n"
// serial_input_terminator -- what we consider an <ENTER> (i.e. newline)
#define serial_input_terminator		'\n'

// if you included requests for "strings", 
// request_inputstring_maxlen will set the max length allowable
// (bigger need more RAM)
#define request_inputstring_maxlen	50


uint8_t SetupConfig(void);

void readCFG(void);
void updateCFG(void);
void resetCFG(void);
void printVersion(void);

#endif