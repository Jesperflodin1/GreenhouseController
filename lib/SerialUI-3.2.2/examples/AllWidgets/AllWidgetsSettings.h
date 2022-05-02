
#ifndef _AllWidgets_AllWidgetsSettings_h
#define _AllWidgets_AllWidgetsSettings_h


/*
 * AllWidgetsSettings.h -- part of the AllWidgets project.
 * Hard-coded system settings, configurable through #defines
 * Pat Deegan
 * Psychogenic.com 
 * 
 * Copyright (C) 2019 Pat Deegan
 * 
 * Generated by DruidBuilder [https://devicedruid.com/], 
 * as part of project "b4cf0e8f5cb24a839ec218119f68cfc0lEUPnNbYtz",
 * aka AllWidgets.
 * 
 * Druid4Arduino, Device Druid, Druid Builder, the builder 
 * code brewery and its wizards, SerialUI and supporting 
 * libraries, as well as the generated parts of this program 
 * are 
 *            Copyright (C) 2013-2019 Pat Deegan 
 * [https://psychogenic.com/ | https://inductive-kickback.com/]
 * and distributed under the terms of their respective licenses.
 * See https://devicedruid.com for details.
 * 
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE 
 * PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, 
 * YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
 * CORRECTION.
 * 
 * Keep in mind that there is no warranty and you are solely 
 * responsible for the use of all these cool tools.
 * 
 * Play safe, have fun.
 * 
 */



/* Defaults should be fine, but you may set each to 
 * something appropriate for your situation.
 *
 * Of special interest: serial_baud_rate -- this must match 
 * what you specify while using the Druid GUI
 *
 * generated for usbserial
 */

// serial_baud_rate -- connect to device at this baud rate, using druid
#define serial_baud_rate			57600


// have a "heartbeat" function to hook-up.  It will be called periodically while 
// someone is connected...  Set heartbeat_function_period_ms (millis) to specify
// how often it will be called
#define heartbeat_function_period_ms  2000UL


// serial_maxidle_ms -- how long before we consider the user
// gone, for lack of activity (milliseconds)
#define serial_maxidle_ms			30000

// serial_readtimeout_ms -- timeout when we're expecting input
// for a specific request/read (milliseconds)
#define serial_readtimeout_ms		20000

#define serial_ui_greeting_str	" AllWidgets "
// serial_input_terminator -- what we consider an <ENTER> (i.e. newline)
#define serial_input_terminator		'\n'

// if you included requests for "strings", 
// request_inputstring_maxlen will set the max length allowable
// (bigger need more RAM)
#define request_inputstring_maxlen	50



#endif
